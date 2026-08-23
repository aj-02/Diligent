#!/usr/bin/env python3
"""abap-audit.py — check ABAP sources against the standing rules in CLAUDE.md.

    ./scripts/abap-audit.py ovl/atc/corrections            audit a folder
    ./scripts/abap-audit.py kpmg/zmb5b/src --md report.md  write a markdown report

Statement-aware, not line-aware: ABAP statements are joined to their closing period
and string literals are respected, so a SELECT spread over nine lines is judged as one
statement and a `"` inside '...' is not mistaken for a comment.

Every finding names the rule from CLAUDE.md it breaks. Findings are candidates for
review, not automatic edits — see NOTES in the report for the known blind spots.
"""
import re, sys, os, io, hashlib

MAX_JOIN = 120     # lines joined into one statement before resyncing
MAX_STMT = 20000   # characters of a single statement actually analysed

# ---------------------------------------------------------------- lexing

SE80_NUM  = re.compile(r"^\s*\d+\s{2,}")
SE80_LINE = re.compile(r"^\s*\d+(?:\s(.*))?$")

def unwrap_se80_listing(text):
    """SE80 / ZR_PROG_DOWNLOAD listings carry a banner and a line-number prefix
    on every line ("368      LOOP AT header."). Strip both so the parser sees
    real ABAP; leave a plain source file untouched."""
    lines = text.splitlines()
    sample = [l for l in lines if l.strip()][:400]
    if not sample:
        return text, False
    numbered = sum(1 for l in sample if SE80_NUM.match(l))
    if numbered < len(sample) * 0.6:
        return text, False
    # A listing repeats its banner at every page break, and renders an empty
    # source line as a bare number. Keep numbered lines only — everything else
    # is pagination furniture, and an unstripped banner would otherwise be
    # joined into the following statement and hide it from every check.
    out = []
    for l in lines:
        m = SE80_LINE.match(l)
        if m:
            out.append(m.group(1) or "")
    return "\n".join(out), True


def strip_and_join(text):
    """Yield (line_no, statement_text) with comments removed and lines joined
    until the statement-ending period. Preserves string literals."""
    stmts, buf, start = [], [], None
    for n, raw in enumerate(text.splitlines(), 1):
        line = raw.rstrip("\n\r")
        if line.lstrip().startswith("*") or line.startswith("*"):
            continue                                   # full-line comment
        # strip trailing " comment, honouring '...' literals
        out, in_lit, i = [], False, 0
        while i < len(line):
            ch = line[i]
            if ch == "'":
                # '' inside a literal is an escaped quote
                if in_lit and i + 1 < len(line) and line[i + 1] == "'":
                    out.append("''"); i += 2; continue
                in_lit = not in_lit
            elif ch == '"' and not in_lit:
                break
            out.append(ch); i += 1
        code = "".join(out).strip()
        if not code:
            continue
        if start is None:
            start = n
        buf.append(code)
        # Statement ends at a period that is not inside a literal. An unbalanced
        # quote would otherwise swallow the rest of the file into one statement
        # and make the regexes below quadratic, so cap the join and resync.
        if len(buf) > MAX_JOIN:
            stmts.append((start, " ".join(buf)[:MAX_STMT]))
            buf, start = [], None
            continue
        joined = " ".join(buf)
        if _ends_statement(joined):
            stmts.append((start, joined[:MAX_STMT]))
            buf, start = [], None
    if buf:
        stmts.append((start, " ".join(buf)))
    return stmts


def _ends_statement(s):
    in_lit = False
    i = 0
    while i < len(s):
        c = s[i]
        if c == "'":
            if in_lit and i + 1 < len(s) and s[i + 1] == "'":
                i += 2; continue
            in_lit = not in_lit
        i += 1
    return (not in_lit) and s.rstrip().endswith(".")


def is_strict(stmt):
    """Strict Open SQL: comma-separated field list, or any @-escaped host variable."""
    if "@" in stmt:
        return True
    m = re.search(r"\bSELECT\b(.*?)\bFROM\b", stmt, re.I | re.S)
    return bool(m and "," in m.group(1))

# ---------------------------------------------------------------- checks

RULES = {
    "FAE_NO_GUARD":  "IS NOT INITIAL guard before every FOR ALL ENTRIES",
    "FAE_NO_AT":     "FOR ALL ENTRIES IN @itab — the @ is mandatory",
    "INTO_NO_AT":    "INTO @lt_tab / INTO @DATA(ls) — the @ is mandatory in strict Open SQL",
    "WHERE_NO_AT":   "host variables in WHERE must be @-escaped in strict Open SQL",
    "SELECT_IN_LOOP":"no SELECT inside a LOOP where FOR ALL ENTRIES or a join would do",
    "CLAUSE_ORDER":  "UP TO n ROWS / OFFSET come after INTO; INTO comes after ORDER BY",
    "ORDER_PRIMARY": "ORDER BY PRIMARY KEY only on SELECT *",
    "CLIENT_MANDT":  "dropping CLIENT SPECIFIED means dropping mandt from the field list",
    "DAD_NO_SORT":   "DELETE ADJACENT DUPLICATES needs a matching SORT outside any loop",
    "SELECT_ENDSEL": "SELECT ... ENDSELECT — use an internal table",
    "EC_DOUBLE":     "one #EC per line; inside an existing \" comment, never a second \"",
    "HARDCODED":     "no hardcoded clients, dates or company codes unless the FS says so",
    "INTO_BEFORE_FROM": "strict Open SQL: INTO is the last clause, never before FROM/WHERE",
    "DUP_INLINE_DATA":  "the same @DATA(name) declared twice in one unit — will not activate",
}


def audit_file(path):
    try:
        text = open(path, encoding="utf-8", errors="replace").read()
    except OSError as e:
        return [("READ_ERROR", 0, str(e))]

    text, _was_listing = unwrap_se80_listing(text)
    stmts = strip_and_join(text)
    findings, loop_depth, form = [], 0, None
    inline = {}                 # inline @DATA(name) -> line first declared
    native = False              # inside EXEC SQL ... ENDEXEC
    sorted_tabs, dad_seen = set(), []
    recent_guards = []          # (line, tabname) from IS NOT INITIAL checks

    for line_no, s in stmts:
        u = s.upper()

        # Native SQL (EXEC SQL ... ENDEXEC) is not Open SQL: it uses :host
        # variables and its own clause order. None of the rules below apply.
        # Native SQL has no ABAP periods, so the whole block (ENDEXEC included)
        # arrives as one joined statement — clear the flag on ENDEXEC anywhere
        # in the text, not just at its start, or every later statement is skipped.
        if native:
            if re.search(r"\bENDEXEC\b", u):
                native = False
            continue
        if re.search(r"\bEXEC\s+SQL\b", u):
            native = not re.search(r"\bENDEXEC\b", u)
            continue

        if re.match(r"\s*(FORM|METHOD|FUNCTION|MODULE)\s+(\S+)", u):
            form = re.match(r"\s*(?:FORM|METHOD|FUNCTION|MODULE)\s+(\S+)", s, re.I).group(1).rstrip(".")
            sorted_tabs, recent_guards, inline = set(), [], {}
        elif re.match(r"\s*(START-OF-SELECTION|END-OF-SELECTION|INITIALIZATION|"
                      r"TOP-OF-PAGE|AT\s+SELECTION-SCREEN|AT\s+LINE-SELECTION)\b", u):
            form = re.match(r"\s*(\S+)", s).group(1).rstrip(".")
            sorted_tabs, recent_guards, inline = set(), [], {}
        if re.match(r"\s*(LOOP\s+AT|DO\b|WHILE\b)", u):
            loop_depth += 1
        if re.match(r"\s*(ENDLOOP|ENDDO|ENDWHILE)\b", u):
            loop_depth = max(0, loop_depth - 1)

        # Guards come in three shapes, all of them common in this codebase:
        #   IF lt_tab IS NOT INITIAL.      IF lt_tab[] IS NOT INITIAL.
        #   IF NOT lt_tab IS INITIAL.      (legacy form)
        for t in re.findall(r"\b(\w+)\s*(?:\[\s*\])?\s+IS\s+NOT\s+INITIAL", u):
            recent_guards.append((line_no, t))
        for t in re.findall(r"\bNOT\s+(\w+)\s*(?:\[\s*\])?\s+IS\s+INITIAL", u):
            recent_guards.append((line_no, t))
        # LINES( tab ) > 0 / <> 0 is a guard too
        for t in re.findall(r"\bLINES\(\s*(\w+)", u):
            recent_guards.append((line_no, t))

        if re.match(r"\s*SORT\s+(\w+)", u):
            sorted_tabs.add(re.match(r"\s*SORT\s+(\w+)", s, re.I).group(1).upper())

        m = re.match(r"\s*DELETE\s+ADJACENT\s+DUPLICATES\s+FROM\s+(\w+)", s, re.I)
        if m:
            tab = m.group(1).upper()
            if tab not in sorted_tabs:
                findings.append(("DAD_NO_SORT", line_no,
                                 f"DELETE ADJACENT DUPLICATES FROM {tab} with no SORT {tab} seen "
                                 f"in {form or 'this unit'}"))
            if loop_depth > 0:
                findings.append(("DAD_NO_SORT", line_no,
                                 f"DELETE ADJACENT DUPLICATES FROM {tab} inside a loop"))

        if not re.search(r"\bSELECT\b", u):
            continue

        strict = is_strict(s)

        if loop_depth > 0 and re.match(r"\s*SELECT\b", u):
            findings.append(("SELECT_IN_LOOP", line_no,
                             f"SELECT inside a loop in {form or 'this unit'}: {squeeze(s)}"))

        if re.search(r"\bENDSELECT\b", u) or re.search(r"\bSELECT\b(?!.*\bINTO\b.*\bTABLE\b).*\.\s*$", u) and "ENDSELECT" in text.upper():
            pass  # ENDSELECT is checked separately below

        m = re.search(r"\bFOR\s+ALL\s+ENTRIES\s+IN\s+(@?)(\w+)", s, re.I)
        if m:
            at, tab = m.group(1), m.group(2).upper()
            if strict and not at:
                findings.append(("FAE_NO_AT", line_no,
                                 f"FOR ALL ENTRIES IN {tab} — missing @"))
            guarded = any(t.upper() == tab and abs(line_no - gl) <= 25 for gl, t in recent_guards)
            if not guarded:
                findings.append(("FAE_NO_GUARD", line_no,
                                 f"FOR ALL ENTRIES IN {tab} with no IS NOT INITIAL guard "
                                 f"within 25 statements"))

        if strict:
            m = re.search(r"\bINTO\s+(?:CORRESPONDING\s+FIELDS\s+OF\s+)?(?:TABLE\s+)?(@?)(\w+|DATA\()", s, re.I)
            if m and not m.group(1):
                findings.append(("INTO_NO_AT", line_no,
                                 f"INTO {m.group(2)} — missing @ in a strict Open SQL statement"))
            w = re.search(r"\bWHERE\b(.*?)(?:\bGROUP\s+BY\b|\bORDER\s+BY\b|\bINTO\b|$)", s, re.I | re.S)
            if w:
                for hv in re.findall(r"[=<>]\s*(?!@)([a-z_]\w*)", w.group(1), re.I):
                    if hv.upper() in ("ABAP_TRUE", "ABAP_FALSE", "SPACE", "SY", "AND", "OR", "NULL"):
                        continue
                    # tab~field is a column; tab-field is a host variable and needs @
                    if re.search(r"\b%s\s*~" % re.escape(hv), w.group(1)):
                        continue
                    findings.append(("WHERE_NO_AT", line_no,
                                     f"WHERE ... = {hv} — host variable not @-escaped"))
                    break

        # Clause order below is a STRICT Open SQL rule only. Classic syntax
        # (SELECT * INTO wa FROM t UP TO 1 ROWS WHERE ... ORDER BY ...) is valid
        # and must not be flagged.
        into_pos  = search_pos(u, r"\bINTO\b") if strict else None
        order_pos = search_pos(u, r"\bORDER\s+BY\b")
        upto_pos  = search_pos(u, r"\bUP\s+TO\b")
        offs_pos  = search_pos(u, r"\bOFFSET\b")
        if into_pos and order_pos and order_pos > into_pos:
            findings.append(("CLAUSE_ORDER", line_no,
                             "ORDER BY after INTO — INTO must follow ORDER BY"))
        for name, pos in (("UP TO n ROWS", upto_pos), ("OFFSET", offs_pos)):
            if into_pos and pos and pos < into_pos:
                findings.append(("CLAUSE_ORDER", line_no,
                                 f"{name} before INTO — it must come after INTO"))

        if strict:
            fpos = search_pos(u, r"\bFROM\b")
            ipos = search_pos(u, r"\bINTO\b")
            if fpos and ipos and ipos < fpos:
                findings.append(("INTO_BEFORE_FROM", line_no,
                                 "strict Open SQL with INTO ahead of FROM — INTO must be the "
                                 "last clause: " + squeeze(s, 70)))

        for nm in re.findall(r"@DATA\(\s*(\w+)\s*\)", s, re.I):
            key = nm.upper()
            if key in inline:
                findings.append(("DUP_INLINE_DATA", line_no,
                                 f"@DATA({nm}) already declared inline at line {inline[key]} "
                                 f"in {form or 'this unit'}"))
            else:
                inline[key] = line_no

        if re.search(r"\bORDER\s+BY\s+PRIMARY\s+KEY\b", u):
            fl = re.search(r"\bSELECT\b\s+(?:SINGLE\s+|DISTINCT\s+)?(.*?)\bFROM\b", s, re.I | re.S)
            # classic syntax puts INTO/APPENDING between the field list and FROM;
            # strip it so "SELECT * APPENDING TABLE it FROM t" is seen as "*"
            fields = re.sub(r"\b(INTO|APPENDING)\b.*$", "", fl.group(1),
                            flags=re.I | re.S).strip() if fl else ""
            if fl and fields != "*":
                findings.append(("ORDER_PRIMARY", line_no,
                                 "ORDER BY PRIMARY KEY on a field list — only valid on SELECT *"))

        if re.search(r"\bCLIENT\s+SPECIFIED\b", u) is None and re.search(r"\bMANDT\b", u):
            if re.search(r"\bSELECT\b.*\bMANDT\b.*\bFROM\b", u, re.S):
                findings.append(("CLIENT_MANDT", line_no,
                                 "mandt in the field list without CLIENT SPECIFIED"))

    up = text.upper()
    if "ENDSELECT" in up:
        for n, raw in enumerate(text.splitlines(), 1):
            if re.search(r"^\s*ENDSELECT\b", raw, re.I):
                findings.append(("SELECT_ENDSEL", n, "SELECT ... ENDSELECT loop"))

    for n, raw in enumerate(text.splitlines(), 1):
        if "#EC" in raw.upper():
            before = raw.upper().split("#EC")[0]
            if before.count('"') > 1:
                findings.append(("EC_DOUBLE", n,
                                 'second " added ahead of #EC — it belongs inside the existing comment'))
        m = re.search(r"\b(MANDT|BUKRS)\s*=\s*'(\d{3,4})'", raw, re.I)
        if m and not raw.lstrip().startswith("*"):
            findings.append(("HARDCODED", n, f"hardcoded {m.group(1).lower()} = '{m.group(2)}'"))

    return findings


def search_pos(u, pat):
    m = re.search(pat, u)
    return m.start() if m else None


def squeeze(s, n=90):
    s = re.sub(r"\s+", " ", s).strip()
    return s if len(s) <= n else s[: n - 1] + "…"

# ---------------------------------------------------------------- driver

def main():
    args = [a for a in sys.argv[1:]]
    md = None
    no_dedupe = "--no-dedupe" in args
    if no_dedupe:
        args.remove("--no-dedupe")
    if "--md" in args:
        i = args.index("--md"); md = args[i + 1]; del args[i : i + 2]
    if not args:
        print(__doc__); sys.exit(2)

    files = []
    for target in args:
        if os.path.isdir(target):
            for root, _, names in os.walk(target):
                for nm in sorted(names):
                    if nm.lower().endswith((".abap", ".txt")):
                        files.append(os.path.join(root, nm))
        elif os.path.isfile(target):
            files.append(target)

    # The same object is often stored more than once (a loose .abap next to the
    # abapGit serialisation next to a by_package copy). Audit each distinct
    # content once, or every count is multiplied by however many copies exist.
    dupes = {}
    if not no_dedupe:
        seen, unique = {}, []
        for f in files:
            try:
                h = hashlib.md5(open(f, "rb").read()).hexdigest()
            except OSError:
                continue
            if h in seen:
                dupes.setdefault(seen[h], []).append(f)
            else:
                seen[h] = f
                unique.append(f)
        files = unique

    all_findings, per_rule = {}, {}
    for f in sorted(files):
        fs = audit_file(f)
        if fs:
            all_findings[f] = fs
            for code, _, _ in fs:
                per_rule[code] = per_rule.get(code, 0) + 1

    total = sum(len(v) for v in all_findings.values())
    ndup = sum(len(v) for v in dupes.values())
    print(f"scanned {len(files)} distinct object(s)"
          + (f" ({ndup} duplicate copies skipped)" if ndup else "")
          + f"; {total} finding(s) in {len(all_findings)} object(s)")
    for code, n in sorted(per_rule.items(), key=lambda x: -x[1]):
        print(f"  {n:5d}  {code:16s} {RULES.get(code, '')}")

    if md:
        with io.open(md, "w", encoding="utf-8") as fh:
            fh.write(render_md(files, all_findings, per_rule, total, dupes))
        print(f"\nreport written to {md}")


def render_md(files, all_findings, per_rule, total, dupes=None):
    out = ["# ABAP rule audit", ""]
    out.append(f"`scripts/abap-audit.py` over {len(files)} file(s): "
               f"**{total} finding(s)** in {len(all_findings)} file(s).")
    out.append("")
    out.append("| Count | Rule | From CLAUDE.md |")
    out.append("|---:|---|---|")
    for code, n in sorted(per_rule.items(), key=lambda x: -x[1]):
        out.append(f"| {n} | `{code}` | {RULES.get(code, '')} |")
    out.append("")
    for f in sorted(all_findings):
        out.append(f"## {f}")
        out.append("")
        out.append("| Line | Rule | Detail |")
        out.append("|---:|---|---|")
        for code, line, detail in sorted(all_findings[f], key=lambda x: x[1]):
            safe = detail.replace("|", "\\|")
            out.append(f"| {line} | `{code}` | {safe} |")
        out.append("")
    return "\n".join(out) + "\n"


if __name__ == "__main__":
    main()
