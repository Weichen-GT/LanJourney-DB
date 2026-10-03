"""
Generate SCHEMA.md (a readable reference for every table) from schema.sql.

    python tools/gen_schema_doc.py [--pg-bin "C:/Program Files/PostgreSQL/18/bin"]

It starts a throwaway local Postgres (needs the PostgreSQL binaries: initdb, pg_ctl, psql), loads
schema.sql into it, reads the real structure from the catalog, adds the descriptions and column notes
written as comments in schema.sql, and writes SCHEMA.md. The temporary server is removed afterwards.
Run it after any change to schema.sql, and commit SCHEMA.md.
"""
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PORT = "55439"
EXE = ".exe" if os.name == "nt" else ""


def find_bin(arg):
    cands = [arg, os.environ.get("PG_BIN")]
    found = shutil.which("initdb")
    if found:
        cands.append(os.path.dirname(found))
    for v in range(20, 12, -1):
        cands.append(f"C:/Program Files/PostgreSQL/{v}/bin")
    for c in cands:
        if c and os.path.isfile(os.path.join(c, "initdb" + EXE)):
            return c
    sys.exit("PostgreSQL binaries not found; pass --pg-bin <dir containing initdb>")


def sql_comments(schema):
    """table -> description (comment block above CREATE TABLE); (table, column) -> inline comment."""
    desc, col_notes = {}, {}
    lines = schema.split("\n")
    for i, line in enumerate(lines):
        if not line.startswith("CREATE TABLE"):
            continue
        j = i
        m = re.search(r"IF NOT EXISTS\s+(\w+)", line)
        if not m:  # name is on the next line: "  IF NOT EXISTS x ("
            j = i + 1
            m = re.search(r"IF NOT EXISTS\s+(\w+)", lines[j])
        name = m.group(1)
        block, k = [], i - 1
        while k >= 0 and lines[k].startswith("--"):
            t = lines[k][2:].strip()
            if t and not set(t) <= {"="}:
                block.insert(0, t)
            k -= 1
        text = re.sub(r"^\d+[a-z]?\)\s*", "", " ".join(block))
        desc[name] = re.sub(r"^" + name + r":\s*", "", text)
        depth = 0
        for body in lines[j:]:
            code = body.split("--")[0]
            depth += code.count("(") - code.count(")")
            cm = re.match(r"\s+(\w+)\s+[A-Za-z].*?--\s*(.+)$", body)
            if cm and cm.group(1).upper() not in ("CONSTRAINT", "PRIMARY", "UNIQUE", "CHECK", "FOREIGN", "IF"):
                col_notes[(name, cm.group(1))] = cm.group(2).strip()
            if depth <= 0 and ";" in code:
                break
    return desc, col_notes


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pg-bin")
    b = find_bin(ap.parse_args().pg_bin)
    schema_path = os.path.join(ROOT, "schema.sql")
    schema = open(schema_path, encoding="utf-8").read()
    tmp = tempfile.mkdtemp(prefix="ljdoc_")
    data = os.path.join(tmp, "data")

    def run(*a):
        return subprocess.run(a, check=True, capture_output=True, text=True)

    def psql(*a):
        return run(os.path.join(b, "psql" + EXE), "-h", "localhost", "-p", PORT, "-U", "postgres",
                   "-X", "-q", "-At", "-v", "ON_ERROR_STOP=1", *a).stdout

    def q(sql):
        return json.loads(psql("-d", "doc", "-c", f"select coalesce(json_agg(t),'[]') from ({sql}) t"))

    try:
        run(os.path.join(b, "initdb" + EXE), "-D", data, "-U", "postgres", "--auth=trust", "-E", "UTF8")
        # DEVNULL, not pipes: the server inherits the pipes and would keep this call waiting forever.
        subprocess.run([os.path.join(b, "pg_ctl" + EXE), "-D", data, "-o", f"-p {PORT}", "-l", os.path.join(tmp, "log"),
                        "-w", "start"], check=True, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        psql("-c", "create database doc")
        psql("-d", "doc", "-f", schema_path)
        pub = "join pg_namespace s on s.oid=c.relnamespace and s.nspname='public'"
        cols = q(f"""select c.relname tbl, a.attname col, format_type(a.atttypid,a.atttypmod) typ,
                    a.attnotnull nn, pg_get_expr(d.adbin,d.adrelid) def
                    from pg_attribute a join pg_class c on c.oid=a.attrelid {pub}
                    left join pg_attrdef d on d.adrelid=a.attrelid and d.adnum=a.attnum
                    where c.relkind='r' and a.attnum>0 and not a.attisdropped order by c.relname, a.attnum""")
        cons = q(f"""select c.relname tbl, k.conname name, k.contype typ, pg_get_constraintdef(k.oid) def,
                    (select json_agg(a.attname) from unnest(k.conkey) u(x)
                       join pg_attribute a on a.attrelid=k.conrelid and a.attnum=u.x) cols,
                    r.relname ref
                    from pg_constraint k join pg_class c on c.oid=k.conrelid {pub}
                    left join pg_class r on r.oid=k.confrelid order by c.relname, k.contype, k.conname""")
        idx = q("""select tablename tbl, indexname name, indexdef def from pg_indexes
                   where schemaname='public' and indexname not in (select conname from pg_constraint)
                   order by 1,2""")
        trg = q(f"""select c.relname tbl, t.tgname name, pg_get_triggerdef(t.oid) def from pg_trigger t
                   join pg_class c on c.oid=t.tgrelid {pub} where not t.tgisinternal order by 1,2""")
        rls_off = [r["tbl"] for r in q(f"select c.relname tbl from pg_class c {pub} where c.relkind='r' and not c.relrowsecurity")]
    finally:
        subprocess.run([os.path.join(b, "pg_ctl" + EXE), "-D", data, "-m", "fast", "stop"], capture_output=True)
        shutil.rmtree(tmp, ignore_errors=True)

    desc, notes = sql_comments(schema)
    order = re.findall(r"CREATE TABLE\s+IF NOT EXISTS\s+(\w+)", schema)

    def esc(s):
        return str(s).replace("|", "\\|").replace("\n", " ")

    rls_line = ("Every table has Row Level Security enabled (the backend connects as `postgres`, which bypasses it)."
                if not rls_off else f"WARNING: RLS is off for: {', '.join(rls_off)}.")
    out = ["# Database schema", "",
           "> Generated by `tools/gen_schema_doc.py` from `schema.sql` -- do not edit by hand.",
           "> `schema.sql` is the single source of truth; `reset.sql` is generated from it too.", "",
           f"{len(order)} tables, PostgreSQL. {rls_line}", "",
           "## Tables", "", "| Table | What it holds |", "|---|---|"]
    for t in order:
        out.append(f"| [`{t}`](#{t}) | {esc(desc.get(t, ''))} |")
    out += ["", "## Relationships", "", "```mermaid", "erDiagram"]
    for c in cons:
        if c["typ"] == "f":
            out.append(f'    {c["ref"]} ||--o{{ {c["tbl"]} : "{", ".join(c["cols"])}"')
    out += ["```", ""]
    for t in order:
        out += [f"## {t}", ""]
        if desc.get(t):
            out += [esc(desc[t]), ""]
        tc = [c for c in cons if c["tbl"] == t]
        pk = {x for c in tc if c["typ"] == "p" for x in c["cols"]}
        fk = {x: c for c in tc if c["typ"] == "f" for x in c["cols"]}
        uq = {x for c in tc if c["typ"] == "u" and len(c["cols"]) == 1 for x in c["cols"]}
        out += ["| Column | Type | Null | Default | Notes |", "|---|---|---|---|---|"]
        for c in [c for c in cols if c["tbl"] == t]:
            n = []
            if c["col"] in pk:
                n.append("PK")
            if c["col"] in fk:
                f = fk[c["col"]]
                od = re.search(r"ON DELETE (\w+(?: \w+)?)", f["def"])
                n.append(f"FK -> `{f['ref']}`" + (f" (on delete {od.group(1).lower()})" if od else ""))
            if c["col"] in uq:
                n.append("unique")
            if notes.get((t, c["col"])):
                n.append(notes[(t, c["col"])])
            out.append(f"| `{c['col']}` | {esc(c['typ'])} | {'no' if c['nn'] else 'yes'} | {esc(c['def'] or '')} | {esc('; '.join(n))} |")
        multi = [c for c in tc if c["typ"] in ("u", "c") or (c["typ"] == "p" and len(c["cols"]) > 1)]
        if multi:
            out += ["", "**Constraints**", ""]
            for c in multi:
                label = {"p": "primary key", "u": "unique", "c": "check"}[c["typ"]]
                out.append(f"- `{c['name']}` ({label}): `{esc(c['def'])}`")
        ti = [i for i in idx if i["tbl"] == t]
        if ti:
            out += ["", "**Indexes**", ""]
            for i in ti:
                d = re.sub(r"^CREATE (UNIQUE )?INDEX \S+ ON public\.", lambda m: (m.group(1) or "").lower() + "index on ", i["def"])
                out.append(f"- `{i['name']}`: `{esc(d)}`")
        tt = [x for x in trg if x["tbl"] == t]
        if tt:
            out += ["", "**Triggers**", ""]
            for x in tt:
                out.append(f"- `{x['name']}`: sets `updated_at` on every update" if "set_updated_at" in x["def"] else f"- `{x['name']}`")
        out.append("")
    open(os.path.join(ROOT, "SCHEMA.md"), "w", encoding="utf-8", newline="\n").write("\n".join(out))
    print(f"SCHEMA.md written: {len(order)} tables")


main()
