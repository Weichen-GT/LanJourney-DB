"""
Generate reset.sql from schema.sql, so the two can never drift apart.

    python tools/build_reset.py

reset.sql = "drop every table and function that schema.sql creates" + the whole of schema.sql.
Run it after any change to schema.sql, and commit both files.
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
schema = open(os.path.join(ROOT, "schema.sql"), encoding="utf-8").read()

tables = re.findall(r"CREATE TABLE\s+IF NOT EXISTS\s+(\w+)", schema)
functions = re.findall(r"CREATE OR REPLACE FUNCTION\s+(\w+)\s*\(", schema)
assert tables, "no tables found in schema.sql"

drops = "\n".join(f"DROP TABLE IF EXISTS {t} CASCADE;" for t in reversed(tables))
drops += "\n" + "\n".join(f"DROP FUNCTION IF EXISTS {f}() CASCADE;" for f in functions)

header = f"""-- =============================================================
-- RESET: DELETES EVERYTHING, then rebuilds the empty schema.
-- GENERATED from schema.sql by tools/build_reset.py -- do not edit by hand.
--
-- !! This drops all {len(tables)} tables with all their data (users, articles, progress, vocabulary).
-- !! Only run it on a database you are happy to wipe (local dev, or an empty/staging project).
--
-- After it, load the vocabulary (see README.md > "Rebuild a database"):
--   seed/01_vocabulary_original.sql, seed/02_vocabulary_wordnet.sql, seed/03_frequency_rank.sql
-- Runs as one script in the Supabase SQL editor or psql (no BEGIN/COMMIT: the editor runs statements separately).
-- =============================================================

{drops}

-- =============================================================
-- schema.sql (verbatim)
-- =============================================================

"""
open(os.path.join(ROOT, "reset.sql"), "w", encoding="utf-8", newline="\n").write(
    header + schema.rstrip("\n") + "\n\nCOMMIT;\n")
print(f"reset.sql written: {len(tables)} tables, {len(functions)} function(s)")
