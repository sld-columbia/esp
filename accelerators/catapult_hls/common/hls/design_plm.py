#!/usr/bin/env python3

# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

"""
design_plm.py — Discover PLMs, emit Catapult MAP_TO_MODULE directives,
                and patch load/store call sites in *_ctrl.hpp/.h.

Shared script in accelerators/catapult_hls/common/hls/.  Run it from anywhere
inside an accelerator tree (the accelerator root is the nearest parent
directory containing hw/src/), or pass --acc-dir explicitly.  Run
init_hls.py first so that hw/hls-work-<tech>/ exists.

Interactive mode (default — no flags):
  cd <acc_dir>
  python ../common/hls/design_plm.py

Non-interactive / scripting:
  python design_plm.py --acc-dir <acc_dir> --uram plmX
  python design_plm.py --list
  python design_plm.py --uram plmX[,plmY,...]
  python design_plm.py --uram plmX --show-tcl
  python design_plm.py --uram plmX --module AccController
  python design_plm.py --uram plmX --no-patch    (TCL only, skip C++ patching)

Interactive command syntax:
  map all [banks] of plmA to URAM
  map half [of] plmB to URAM
  map banks 0-3 of plmB to URAM
  map plmA to URAM, half of plmB to URAM      (comma-separated)
  map plmA to URAM while half of plmB to URAM (while / and / also accepted)
  show        — review current selection
  reset       — clear all selections
  done        — emit TCL directives, patch *_ctrl source, and exit
  quit        — exit without emitting
"""

import argparse
import re
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Bank-tree path generation
# ---------------------------------------------------------------------------

def _max_pow2_le(n: int) -> int:
    p = 1
    while p * 2 <= n:
        p *= 2
    return p


def bank_paths(n_banks: int) -> list:
    """Catapult instance path segment for every bank, left-to-right."""
    if n_banks == 1:
        return ["a"]
    w = _max_pow2_le(n_banks - 1)
    return (["a0." + p for p in bank_paths(w)] +
            ["a1." + p for p in bank_paths(n_banks - w)])


# ---------------------------------------------------------------------------
# Constant evaluator
# ---------------------------------------------------------------------------

_DEFINE_RE = re.compile(
    r'#\s*define\s+(\w+)\s+([\w\d\s\+\-\*\/\(\)]+?)(?:\s*//[^\n]*)?$',
    re.MULTILINE)
_CONST_RE = re.compile(
    r'\bconst\b[^;]*?\b(\w+)\s*=\s*([\w\d\s\+\-\*\/\(\)]+?)\s*;')


def _safe_eval(expr: str, syms: dict) -> int:
    for name in sorted(syms, key=len, reverse=True):
        expr = re.sub(r'\b' + re.escape(name) + r'\b', str(syms[name]), expr)
    if not re.fullmatch(r'[\d\s\+\-\*\/\(\)]+', expr):
        raise ValueError(f"unsafe: {expr!r}")
    return int(eval(expr))  # noqa: S307


def collect_symbols(files: list) -> dict:
    syms: dict = {}
    for f in files:
        try:
            text = f.read_text(errors='replace')
        except OSError:
            continue
        text = re.sub(r'/\*.*?\*/', ' ', text, flags=re.DOTALL)
        for m in _DEFINE_RE.finditer(text):
            try:
                syms[m.group(1)] = _safe_eval(m.group(2).strip(), syms)
            except Exception:
                pass
        for m in _CONST_RE.finditer(text):
            try:
                syms[m.group(1)] = _safe_eval(m.group(2).strip(), syms)
            except Exception:
                pass
    return syms


# ---------------------------------------------------------------------------
# Type bit-width resolver  (typedef → integer width)
# ---------------------------------------------------------------------------

# NVUINTW(expr) TypeName  or  ac_int<expr,...> TypeName
_NVUINT_RE  = re.compile(r'\btypedef\s+NVUINTW\s*\(\s*(.+?)\s*\)\s+(\w+)\s*;')
_ACTYPE_RE  = re.compile(
    r'\btypedef\s+ac_(?:int|uint|fixed)\s*<\s*([^,>]+)(?:[^>]*)?\s*>\s+(\w+)\s*;')
# ac_ieee_floatNN  or  ac_std_float<E,M>  — handled specially
_IEEEF_RE   = re.compile(r'\btypedef\s+ac_ieee_float(\d+)\s+(\w+)\s*;')
_STDF_RE    = re.compile(r'\btypedef\s+ac_std_float\s*<\s*(\d+)\s*,\s*\d+\s*>\s+(\w+)\s*;')


def collect_type_widths(files: list, syms: dict) -> dict:
    """Return {type_alias: bit_width} for integer/fixed-point typedefs."""
    widths: dict = {}

    def _res(expr):
        return _safe_eval(expr.strip(), {**syms, **widths})

    for f in files:
        try:
            text = f.read_text(errors='replace')
        except OSError:
            continue
        text = re.sub(r'/\*.*?\*/', ' ', text, flags=re.DOTALL)
        text = re.sub(r'//[^\n]*', ' ', text)

        for m in _NVUINT_RE.finditer(text):
            try:
                widths[m.group(2)] = _res(m.group(1))
            except Exception:
                pass
        for m in _ACTYPE_RE.finditer(text):
            try:
                widths[m.group(2)] = _res(m.group(1))
            except Exception:
                pass
        for m in _IEEEF_RE.finditer(text):
            widths[m.group(2)] = int(m.group(1))
        for m in _STDF_RE.finditer(text):
            widths[m.group(2)] = int(m.group(1))

    return widths


# ---------------------------------------------------------------------------
# Template argument helpers
# ---------------------------------------------------------------------------

def _split_template_args(body: str) -> list:
    args, depth, cur = [], 0, []
    for ch in body:
        if ch in '<(':   depth += 1; cur.append(ch)
        elif ch in '>)': depth -= 1; cur.append(ch)
        elif ch == ',' and depth == 0:
            args.append(''.join(cur).strip()); cur = []
        else:
            cur.append(ch)
    if cur:
        args.append(''.join(cur).strip())
    return args


def _find_template_hits(text: str, keyword: str) -> list:
    pattern = re.compile(r'\b' + re.escape(keyword) + r'\b\s*<')
    hits = []
    for m in pattern.finditer(text):
        start = m.end()
        depth, i = 1, start
        while i < len(text) and depth:
            if   text[i] == '<': depth += 1
            elif text[i] == '>': depth -= 1
            i += 1
        if depth == 0:
            hits.append((m.start(), text[start:i - 1], i))
    return hits


# ---------------------------------------------------------------------------
# SC_MODULE extractor
# ---------------------------------------------------------------------------

_SC_MODULE_RE = re.compile(r'\bSC_MODULE\s*\(\s*(\w+)\s*\)')


def find_module(text: str):
    m = _SC_MODULE_RE.search(text)
    return m.group(1) if m else None


# ---------------------------------------------------------------------------
# PLM declaration scanner
# ---------------------------------------------------------------------------

PLM_2R1W = 'ac_shared_bank_array_2D_2r1w'
PLM_1R1W = 'ac_shared_bank_array_2D'

RAM_TYPE = {
    '2r1w': 'URAM_2R1W_RBW',
    '1r1w': 'URAM_1R1W_RBW',
}


def scan_file(path: Path, syms: dict, type_widths: dict) -> list:
    """Return PLM descriptors found in *path*, in declaration order.

    Each descriptor has:
      name, module, n_banks, depth, bits, kind, src
    """
    try:
        raw = path.read_text(errors='replace')
    except OSError:
        return []

    text = re.sub(r'/\*.*?\*/', ' ', raw, flags=re.DOTALL)
    text = re.sub(r'//[^\n]*', ' ', text)

    module = find_module(text)

    hits = []
    for keyword, kind in [(PLM_2R1W, '2r1w'), (PLM_1R1W, '1r1w')]:
        for start, body, end in _find_template_hits(text, keyword):
            hits.append((start, body, end, kind))
    hits.sort(key=lambda x: x[0])

    results = []
    for start, body, end, kind in hits:
        vm = re.match(r'\s*(\w+)\s*;', text[end:])
        if not vm:
            continue
        varname = vm.group(1)

        args = _split_template_args(body)
        if len(args) < 2:
            continue

        try:
            n_banks = _safe_eval(args[1], syms)
        except Exception as e:
            print(f"[warn] {path.name}: bank count '{args[1]}': {e}",
                  file=sys.stderr)
            continue

        # Optional: depth (arg[2]) and bit-width (arg[0] via type_widths)
        depth = None
        if len(args) >= 3:
            try:
                depth = _safe_eval(args[2], syms)
            except Exception:
                pass

        bits = None
        type_name = args[0].strip()
        if type_name in type_widths:
            bits = type_widths[type_name]
        else:
            # Try to evaluate directly (e.g. ac_int<64, false> inlined)
            inner = re.match(r'ac_(?:int|uint|fixed)\s*<\s*([^,>]+)', type_name)
            if inner:
                try:
                    bits = _safe_eval(inner.group(1), syms)
                except Exception:
                    pass

        results.append({
            'name':    varname,
            'module':  module,
            'n_banks': n_banks,
            'depth':   depth,
            'bits':    bits,
            'kind':    kind,
            'src':     path,
        })
    return results


# ---------------------------------------------------------------------------
# TCL discovery helper
# ---------------------------------------------------------------------------

def find_tcl_for_src(src_file: Path, hls_work_dirs: list) -> list:
    basename = src_file.name
    matches = []
    for work_dir in hls_work_dirs:
        for tcl in sorted(work_dir.rglob('build_prj.tcl')):
            try:
                content = tcl.read_text(errors='replace')
            except OSError:
                continue
            for line in content.splitlines():
                if 'solution file add' in line and basename in line \
                        and '-exclude' not in line:
                    matches.append(tcl)
                    break
    return matches


# ---------------------------------------------------------------------------
# Directive emitter (supports partial bank selection)
# ---------------------------------------------------------------------------

def emit_directives_for_banks(plm: dict, ram_type: str,
                               bank_indices=None) -> list:
    """Return TCL directive lines for the specified bank indices (default: all)."""
    paths = bank_paths(plm['n_banks'])
    if bank_indices is None:
        bank_indices = range(len(paths))
    module = plm['module']
    name   = plm['name']
    return [
        f'directive set /{module}/{name}.{paths[i]}.d.data:rsc'
        f' -MAP_TO_MODULE {{Xilinx_RAMS.{ram_type}'
        f' suppress_sim_read_addr_range_errs=1}}'
        for i in sorted(bank_indices) if i < len(paths)
    ]


# ---------------------------------------------------------------------------
# Ctrl-file call-site patcher
# ---------------------------------------------------------------------------

# load/store: PLM is the LAST argument
# plm_rd/plm_wr: PLM is the FIRST argument inside the call
_B2U_MAP = {
    'load_b':        'load_u',
    'store_b':       'store_u',
    'plm_rd_b':      'plm_rd_u',
    'plm_wr_b':      'plm_wr_u',
    'plm_rd_b_pair': 'plm_rd_u_pair',
    'plm_wr_b_pair': 'plm_wr_u_pair',
    'plm_rd_b_quad': 'plm_rd_u_quad',
}
_U2B_MAP = {v: k for k, v in _B2U_MAP.items()}

_LOAD_STORE_FNS = frozenset(['load_b', 'load_u', 'store_b', 'store_u'])


def _patch_plm_calls(text: str, plm_name: str, to_uram: bool) -> str:
    """Idempotent: normalize call sites for plm_name to the target state.

    Always drives to BRAM first (_u→_b), then optionally lifts to URAM (_b→_u).
    This guarantees the correct result regardless of the file's current state.
    """
    def _apply(mapping, txt):
        for old, new in mapping.items():
            if old in _LOAD_STORE_FNS:
                # PLM is last arg: fn(..., plm_name)
                pattern = (r'\b' + re.escape(old) + r'\b'
                           r'(\([^;]*?\b' + re.escape(plm_name) + r'\s*\))')
            else:
                # PLM is first arg: fn(plm_name, ...)
                pattern = (r'\b' + re.escape(old) + r'\b'
                           r'(\s*\(\s*' + re.escape(plm_name) + r'\b)')
            txt = re.sub(pattern, new + r'\1', txt)
        return txt

    # Step 1: normalize to BRAM (_u → _b), regardless of starting state
    text = _apply(_U2B_MAP, text)
    # Step 2: if target is URAM, lift to URAM (_b → _u)
    if to_uram:
        text = _apply(_B2U_MAP, text)
    return text


def patch_ctrl_files(src_files: list, selections: dict, no_patch: bool = False) -> int:
    """
    Patch load/store/plm_rd/plm_wr call sites in source files.

    selections: {plm_name: {'banks': [...], 'ram': str_or_None}}
      ram is None → explicit BRAM, 'URAM_...' string → URAM.

    Returns number of files modified.
    """
    if no_patch:
        print('# --no-patch: skipping C++ call-site patching.', file=sys.stderr)
        return 0

    # Print target state for each PLM so the user can verify intent
    print('# Patching call sites:', file=sys.stderr)
    for plm_name, sel in sorted(selections.items()):
        ram = sel['ram'] if isinstance(sel, dict) else sel
        target = 'URAM' if (ram is not None and 'URAM' in str(ram)) else 'BRAM'
        print(f'#   {plm_name} → {target}', file=sys.stderr)

    candidates = [f for f in src_files
                  if f.suffix in {'.hpp', '.h', '.cpp', '.cc'}]
    if not candidates:
        print('# WARNING: no .hpp/.h/.cpp/.cc source files found to patch!',
              file=sys.stderr)
        return 0

    n_patched = 0
    for f in candidates:
        try:
            original = f.read_text(errors='replace')
        except OSError as exc:
            print(f'# WARNING: cannot read {f}: {exc}', file=sys.stderr)
            continue

        text = original
        for plm_name, sel in selections.items():
            ram = sel['ram'] if isinstance(sel, dict) else sel
            is_uram = (ram is not None and 'URAM' in str(ram))
            text = _patch_plm_calls(text, plm_name, is_uram)

        if text != original:
            try:
                f.write_text(text)
            except OSError as exc:
                print(f'# ERROR: cannot write {f}: {exc}', file=sys.stderr)
                continue
            # Show each changed line
            orig_lines = original.splitlines()
            new_lines  = text.splitlines()
            print(f'# patched {f.name}:', file=sys.stderr)
            for i, (ol, nl) in enumerate(zip(orig_lines, new_lines), 1):
                if ol != nl:
                    print(f'#   line {i}  - {ol.strip()}', file=sys.stderr)
                    print(f'#   line {i}  + {nl.strip()}', file=sys.stderr)
            n_patched += 1
        else:
            print(f'# {f.name}: no changes needed (already in target state)',
                  file=sys.stderr)

    return n_patched


# ---------------------------------------------------------------------------
# Interactive mode — command parser
# ---------------------------------------------------------------------------

_CLAUSE_SPLIT = re.compile(
    r'\s*(?:,|;|\band\b|\bwhile\b|\balso\b)\s*', re.I)


def _parse_quantity(clause: str, n_banks: int) -> list:
    """Extract bank indices from a clause string."""
    c = clause.lower()

    # "banks 2-5" or "banks 2 to 5"
    m = re.search(r'banks?\s+(\d+)\s*(?:-|to)\s*(\d+)', c)
    if m:
        a, b = int(m.group(1)), int(m.group(2))
        return list(range(max(0, a), min(b + 1, n_banks)))

    # "banks 0,1,2,3" or "banks 0 1 2"
    m = re.search(r'banks?\s+([\d ,]+)', c)
    if m:
        nums = [int(x) for x in re.findall(r'\d+', m.group(1))]
        return [b for b in nums if b < n_banks]

    # Fraction keywords
    fracs = [('half', 2), ('quarter', 4), ('third', 3)]
    for word, div in fracs:
        if re.search(rf'\b{word}\b', c):
            return list(range(n_banks // div))

    # First N banks: "4 banks", "first 4"
    m = re.search(r'\b(?:first\s+)?(\d+)\s+banks?\b', c)
    if m:
        return list(range(min(int(m.group(1)), n_banks)))

    return list(range(n_banks))   # default: all


def parse_command(text: str, plm_map: dict) -> list:
    """Parse a natural-language mapping command.

    Returns list of (plm_name, bank_indices, mem_type) where
    mem_type is 'URAM', 'BRAM', or None (ambiguous).
    """
    # Strip a leading "map" verb
    text = re.sub(r'^\s*map\s+', '', text, flags=re.I)

    clauses = _CLAUSE_SPLIT.split(text)
    results = []

    for clause in clauses:
        clause = clause.strip()
        if not clause:
            continue

        # Find PLM name (longest match wins to avoid partial overlaps)
        plm_name = None
        for name in sorted(plm_map, key=len, reverse=True):
            if re.search(r'\b' + re.escape(name) + r'\b', clause, re.I):
                plm_name = name
                break
        if plm_name is None:
            continue

        mem_type = None
        if re.search(r'\buram\b', clause, re.I):
            mem_type = 'URAM'
        elif re.search(r'\bbram\b', clause, re.I):
            mem_type = 'BRAM'

        banks = _parse_quantity(clause, plm_map[plm_name]['n_banks'])
        results.append((plm_name, banks, mem_type))

    return results


# ---------------------------------------------------------------------------
# Interactive display helpers
# ---------------------------------------------------------------------------

def _fmt_size(n_banks, depth, bits) -> str:
    if depth and bits:
        kb = depth * bits // 8 // 1024
        return f"{n_banks} banks × {depth} words × {bits}-bit  ({kb} KiB/bank)"
    if depth:
        return f"{n_banks} banks × {depth} words"
    return f"{n_banks} banks"


def _fmt_bank_range(indices: list, total: int) -> str:
    if not indices:
        return "(none)"
    if len(indices) == total:
        return f"all {total} banks"
    if indices == list(range(len(indices))):
        return f"banks 0–{indices[-1]}  ({len(indices)} of {total})"
    return f"banks [{', '.join(str(i) for i in indices)}]"


def _show_plm_table(plms: list):
    print()
    print(f"  {'PLM':<12} {'Kind':<6}  {'Layout':<44}  Notes")
    print("  " + "─" * 78)
    for p in plms:
        layout = _fmt_size(p['n_banks'], p['depth'], p['bits'])
        note = '← must use URAM_2R1W_RBW' if p['kind'] == '2r1w' else ''
        print(f"  {p['name']:<12} {p['kind'].upper():<6}  {layout:<44}  {note}")
    print()


def _show_selections(selections: dict, plm_map: dict):
    if not selections:
        print("  (no selections — all PLMs will use BRAM default)")
        return
    total_directives = 0
    for name, sel in selections.items():
        plm    = plm_map[name]
        n      = plm['n_banks']
        banks  = sorted(sel['banks'])
        ram    = sel['ram']
        brange = _fmt_bank_range(banks, n)
        rest   = n - len(banks)
        rest_s = f"  ({rest} bank(s) remain BRAM)" if 0 < rest < n else ""
        print(f"  {name}: {brange} → {ram}{rest_s}")
        total_directives += len(banks)
    print(f"  — {total_directives} directive(s) queued")


# ---------------------------------------------------------------------------
# Interactive mode entry point
# ---------------------------------------------------------------------------

def interactive_mode(plms: list, hls_work_dirs: list,
                     acc_dir: Path, src_files: list,
                     module_override=None, no_patch: bool = False):
    # Group PLMs by source file for display
    by_file: dict = {}
    for p in plms:
        by_file.setdefault(p['src'].name, []).append(p)

    for fname, fplms in by_file.items():
        mod = module_override or fplms[0]['module'] or '?'
        print(f"PLMs found in  {fname}  [module: {mod}]")
        _show_plm_table(fplms)

    plm_map = {p['name']: p for p in plms}
    if module_override:
        for p in plm_map.values():
            p['module'] = module_override

    print("  Default: all PLMs → BRAM (no directive).")
    print("  2R1W PLMs must use URAM_2R1W_RBW (BRAM has no true dual-read port).")
    print()
    print("  Commands:")
    print("    map all [banks] of <plm> to URAM|BRAM")
    print("    map half of <plm> to URAM")
    print("    map banks 0-3 of <plm> to URAM")
    print("    <plm> to URAM, half of <plm2> to URAM   (multi-PLM, comma/while/and)")
    print("    show | reset | done | quit")
    print()

    # selections: {plm_name: {banks: [indices], ram: str}}
    selections: dict = {}

    while True:
        try:
            line = input("plm> ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            break

        if not line:
            continue

        cmd_low = line.lower()

        if cmd_low in ('quit', 'q', 'exit'):
            print("Exiting — no directives emitted.")
            return

        if cmd_low in ('done', 'd', 'emit', 'go'):
            break

        if cmd_low in ('show', 's', 'status'):
            _show_selections(selections, plm_map)
            continue

        if cmd_low in ('reset', 'clear'):
            selections.clear()
            print("  All selections cleared.")
            continue

        parsed = parse_command(line, plm_map)
        if not parsed:
            print("  Could not find a PLM name in that command. Try: map all of plmA to URAM")
            continue

        applied = False
        for plm_name, banks, mem_type in parsed:
            plm = plm_map[plm_name]

            if mem_type is None:
                print(f"  [{plm_name}] Specify URAM or BRAM.")
                continue

            if mem_type == 'URAM':
                ram = RAM_TYPE[plm['kind']]
            else:
                ram = None  # BRAM — explicit; will be skipped at emit time

            selections[plm_name] = {'banks': banks, 'ram': ram}

            brange = _fmt_bank_range(banks, plm['n_banks'])
            ram_s  = ram if ram else 'BRAM (default — no directive)'
            ndirs  = len(banks) if ram else 0
            print(f"  {plm_name}: {brange} → {ram_s}"
                  + (f"  ({ndirs} directives)" if ram else ""))
            applied = True

        if not applied:
            print("  Nothing applied.")

    # ── Emit ────────────────────────────────────────────────────────────────
    print()

    # Show TCL file hints if work dirs exist
    emitted_src: set = set()
    total = 0

    for plm_name, sel in selections.items():
        plm  = plm_map[plm_name]
        ram  = sel['ram']
        if ram is None:
            continue  # explicit BRAM — no directive

        if hls_work_dirs and plm['src'] not in emitted_src:
            tcls = find_tcl_for_src(plm['src'], hls_work_dirs)
            for t in tcls:
                print(f'# → {t.relative_to(acc_dir)}')
            emitted_src.add(plm['src'])

        for line in emit_directives_for_banks(plm, ram, sel['banks']):
            print(line)
            total += 1

    if not selections:
        print("# No URAM mappings — all PLMs will be patched to BRAM defaults.")
    elif total:
        print(f"# {total} directive(s) emitted.", file=sys.stderr)

    # Build full selections: add BRAM default for every PLM not explicitly mapped
    full_selections = dict(selections)
    for plm_name, plm in plm_map.items():
        if plm_name not in full_selections:
            full_selections[plm_name] = {
                'banks': list(range(plm['n_banks'])),
                'ram': None,
            }

    patch_ctrl_files(src_files, full_selections, no_patch=no_patch)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def find_acc_dir(explicit=None) -> Path:
    """Accelerator root: --acc-dir, else nearest parent of cwd with hw/src/."""
    if explicit:
        acc_dir = Path(explicit).resolve()
        if not (acc_dir / 'hw' / 'src').is_dir():
            sys.exit(f'{acc_dir} is not an accelerator root (no hw/src/)')
        return acc_dir
    cwd = Path.cwd().resolve()
    for d in [cwd, *cwd.parents]:
        if (d / 'hw' / 'src').is_dir():
            return d
    sys.exit('Could not find accelerator root (a directory containing hw/src/); '
             'run from inside an accelerator tree or pass --acc-dir')


def main():
    ap = argparse.ArgumentParser(
        description='Discover PLMs and emit Catapult MAP_TO_MODULE directives.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__.split('Non-interactive')[1].strip())
    ap.add_argument('--uram', metavar='PLM[,PLM,...]', default='',
                    help='Non-interactive: 1R1W PLMs to map to URAM (comma-sep). '
                         '2R1W PLMs are always emitted.')
    ap.add_argument('--module', metavar='NAME',
                    help='Override SC_MODULE name in directive paths')
    ap.add_argument('--list', action='store_true',
                    help='List discovered PLMs and exit')
    ap.add_argument('--show-tcl', action='store_true',
                    help='Print target build_prj.tcl path before each PLM block')
    ap.add_argument('--no-patch', action='store_true',
                    help='Skip patching *_ctrl source files (TCL directives only)')
    ap.add_argument('--acc-dir', metavar='DIR',
                    help='Accelerator root (default: nearest parent of cwd '
                         'containing hw/src/)')
    args = ap.parse_args()

    acc_dir = find_acc_dir(args.acc_dir)
    hw_dir  = acc_dir / 'hw'

    scan_dirs = [hw_dir / 'src', hw_dir / 'inc']
    exts      = {'.hpp', '.h', '.cpp', '.cc'}
    src_files = [
        f for d in scan_dirs if d.is_dir()
        for f in sorted(d.rglob('*')) if f.suffix in exts
    ]

    if not src_files:
        sys.exit(f'No source files found under {hw_dir}')

    syms        = collect_symbols(src_files)
    type_widths = collect_type_widths(src_files, syms)
    hls_work_dirs = sorted(hw_dir.glob('hls-work-*'))

    # Scan for PLMs (deduplicated by module+name+banks+kind)
    seen: set  = set()
    plms: list = []
    for f in src_files:
        for plm in scan_file(f, syms, type_widths):
            key = (plm['module'], plm['name'], plm['n_banks'], plm['kind'])
            if key not in seen:
                seen.add(key)
                plms.append(plm)

    if not plms:
        sys.exit('No PLM declarations found.')

    mod_override = args.module

    # ── --list ──────────────────────────────────────────────────────────────
    if args.list:
        print(f"{'File':<30} {'Module':<20} {'PLM':<12} {'Kind':<6} "
              f"{'Banks':>6}  {'Depth':>6}  {'Bits':>5}")
        print('─' * 90)
        for p in plms:
            print(f"{p['src'].name:<30} {str(p['module']):<20} {p['name']:<12} "
                  f"{p['kind']:<6} {p['n_banks']:>6}  "
                  f"{str(p['depth'] or '?'):>6}  {str(p['bits'] or '?'):>5}")
        return

    # ── Non-interactive --uram ───────────────────────────────────────────────
    if args.uram:
        uram_set = {n.strip() for n in args.uram.split(',') if n.strip()}
        uram_selections: dict = {}
        for plm in plms:
            if mod_override:
                plm = {**plm, 'module': mod_override}
            if plm['module'] is None:
                print(f"[warn] {plm['name']}: no SC_MODULE, use --module",
                      file=sys.stderr)
                continue
            if plm['kind'] == '2r1w':
                ram = RAM_TYPE['2r1w']
            elif plm['name'] in uram_set:
                ram = RAM_TYPE['1r1w']
            else:
                ram = None  # BRAM — no directive, but include for patching

            if ram is not None:
                if args.show_tcl and hls_work_dirs:
                    for t in find_tcl_for_src(plm['src'], hls_work_dirs):
                        print(f'# → {t.relative_to(acc_dir)}')

                for line in emit_directives_for_banks(plm, ram):
                    print(line)

            uram_selections[plm['name']] = {
                'banks': list(range(plm['n_banks'])),
                'ram':   ram,
            }

        patch_ctrl_files(src_files, uram_selections, no_patch=args.no_patch)
        return

    # ── Interactive mode (default) ───────────────────────────────────────────
    interactive_mode(plms, hls_work_dirs, acc_dir, src_files, mod_override,
                     no_patch=args.no_patch)


if __name__ == '__main__':
    main()
