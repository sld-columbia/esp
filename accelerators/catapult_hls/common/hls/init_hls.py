#!/usr/bin/env python3

# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

"""
init_hls.py — Create per-submodule HLS work folders for a given tech target.

Shared script in accelerators/catapult_hls/common/hls/.  Run it from anywhere
inside an accelerator tree (the accelerator root is the nearest parent
directory containing hw/src/), or pass --acc-dir explicitly:

  cd <acc_dir>
  python ../common/hls/init_hls.py -virtexup
  python ../common/hls/init_hls.py -virtex7 --acc-dir <acc_dir>

Creates hw/hls-work-<tech>/<stem>/ for each SC_MODULE sub-module found in
hw/src/ and hw/inc/ (the top-level module is auto-excluded).  Each subfolder gets:

  build_prj.tcl       — module-specific HLS script
  build_prj_top.tcl   — sources common.tcl then build_prj.tcl
  rtl_sim.tcl         — RTL co-simulation launcher
  Makefile            — standalone hls / clean targets

Options:
  --acc-dir  Accelerator root (default: auto-detected from cwd)
  --force    Overwrite files that already exist (default: skip)
  --dry-run  Print what would be created without touching disk

Then run design_plm.py to map selected PLM banks to URAM.
"""

import argparse
import re
import sys
from pathlib import Path

SPDX = (
    "#Copyright (c) 2011-2026 Columbia University, System Level Design Group\n"
    "#SPDX-License-Identifier: Apache-2.0\n"
)

SC_MODULE_RE = re.compile(r'\bSC_MODULE\s*\(\s*(\w+)\s*\)')


# ---------------------------------------------------------------------------
# Source-file scanner
# ---------------------------------------------------------------------------

def find_module(path: Path):
    try:
        text = path.read_text(errors='replace')
    except OSError:
        return None
    text = re.sub(r'/\*.*?\*/', ' ', text, flags=re.DOTALL)
    text = re.sub(r'//[^\n]*', ' ', text)
    m = SC_MODULE_RE.search(text)
    return m.group(1) if m else None


def scan_modules(scan_dirs: list) -> list:
    """Return [(path, module_name)] for every file that defines SC_MODULE."""
    exts = {'.hpp', '.h', '.cpp', '.cc'}
    found = []
    for d in scan_dirs:
        if not d.is_dir():
            continue
        for f in sorted(d.rglob('*')):
            if f.suffix not in exts:
                continue
            mod = find_module(f)
            if mod:
                found.append((f, mod))
    return found


# ---------------------------------------------------------------------------
# Shared-include detector
# ---------------------------------------------------------------------------

def find_shared_includes(inc_dir: Path, acc_prefix: str):
    """Return (data_types, conf_info, specs) Path objects — any may be None."""
    def _pick(stem):
        for ext in ('.hpp', '.h'):
            p = inc_dir / f'{stem}{ext}'
            if p.exists():
                return p
        return None

    return (
        _pick(f'{acc_prefix}_data_types'),
        _pick(f'{acc_prefix}_conf_info'),
        _pick(f'{acc_prefix}_specs'),
    )


# ---------------------------------------------------------------------------
# TCL / Makefile content generators
# ---------------------------------------------------------------------------

def gen_build_prj(stem, module_name, mod_file, hw_dir,
                  data_types, conf_info, specs) -> str:
    # Path from hw/hls-work-<tech>/<stem>/ back to the module source file
    rel = mod_file.relative_to(hw_dir)          # e.g. src/xmem_ctrl.hpp
    src_rel = f'../../{rel.as_posix()}'

    file_lines = []
    if data_types:
        file_lines.append(f'solution file add "../../inc/{data_types.name}"')
    file_lines.append('solution file add "../../../../common/inc/esp_dma_info_sysc.hpp"')
    if conf_info:
        file_lines.append(f'solution file add "../../inc/{conf_info.name}"')
    file_lines.append(f'solution file add "{src_rel}"')
    if specs:
        file_lines.append(f'solution file add "../../inc/{specs.name}"')
        file_lines.append(
            f'solution file set ../../inc/{specs.name} -args -DDMA_WIDTH=$DMA_WIDTH')

    file_block = '\n'.join(file_lines)

    return f"""\
{SPDX}
set ccs_file "Catapult.ccs"

if {{[file exists $ccs_file]}} {{
    project load $ccs_file
}} else {{
    project new
}}

set sfd [file dir [info script]]

options set /Input/CppStandard c++11
options set /Input/CompilerFlags {{-DCONNECTIONS_ACCURATE_SIM -DCONNECTIONS_NAMING_ORIGINAL -DSEGMENT_BURST_SIZE=16 -DHLS_CATAPULT -DHLS_READY}}
options set /Input/SearchPath {{../../../../common/matchlib_toolkit/include}} -append
options set /Input/SearchPath {{../../../../common/matchlib_toolkit/examples/boost_home/}} -append
options set /Input/SearchPath {{../../../../common/matchlib_toolkit/examples/matchlib/cmod/include}} -append
options set Architectural DefaultLoopMerging false

flow package require /SCVerify

flow package require /QuestaSIM
flow package option set /QuestaSIM/ENABLE_CODE_COVERAGE true

#
# Input
#

solution options set /Input/SearchPath {{ \\
    ../../inc/ \\
    ../../src/ \\
    ../../tb/ \\
    ../../../../common/inc/ \\
    ../../../../common/inc/core/systems \\
    ../../inc/mem_bank }} -append

solution new -state new -solution solution.v1 {stem}

solution file add "../../tb/testbench.cpp" -exclude true
solution file add "../../tb/testbench.hpp" -exclude true
solution file add "../../tb/sc_main.cpp" -exclude true
solution file add "../../tb/system.hpp" -exclude true
{file_block}

#
# Output
#

# Verilog only
solution option set Output/OutputVHDL false
solution option set Output/OutputVerilog true

# Package output in Solution dir
solution option set Output/PackageOutput true
solution option set Output/PackageStaticFiles true

# Add Prefix to library and generated sub-blocks
solution option set Output/PrefixStaticFiles true
solution options set Output/SubBlockNamePrefix "esp_acc_${{ACCELERATOR}}_"

# Do not modify names
solution option set Output/DoNotModifyNames true

solution library \\
    add mgc_Xilinx-$FPGA_FAMILY$FPGA_SPEED_GRADE\\_beh -- \\
    -rtlsyntool Vivado \\
    -manufacturer Xilinx \\
    -family $FPGA_FAMILY \\
    -speed $FPGA_SPEED_GRADE \\
    -part $FPGA_PART_NUM

solution library add Xilinx_RAMS
directive set -CLOCKS {{clk {{-CLOCK_PERIOD 5.0}}}}

solution design set {module_name} -top
directive set REGISTER_THRESHOLD 34

go analyze
go compile
go libraries
go assembly

# URAM directives (UltraScale+ only): inserted here by design_plm.py
#   cd <acc_root> && python ../common/hls/design_plm.py --uram <plm,...>

go architect
go allocate
go extract

project save
"""


def gen_build_prj_top() -> str:
    return f"""\
{SPDX}
source ../../../../common/hls/common.tcl


# if {{$TECH eq "virtex7"}} {{
# source ../../inc/mem_bank/DUAL_PORT_RBW_VIRTEX7.tcl
# }} elseif {{$TECH eq "virtexu"}} {{
# source ../../inc/mem_bank/DUAL_PORT_RBW_VIRTEXU.tcl
# }} elseif {{$TECH eq "virtexup"}} {{
# source ../../inc/mem_bank/DUAL_PORT_RBW_VIRTEXUP.tcl}}

source ./build_prj.tcl
"""


def gen_rtl_sim(stem: str) -> str:
    return f"""\
{SPDX}
source ../../../../common/hls/common.tcl

project load Catapult.ccs

flow run /SCVerify/launch_make ./scverify/Verify_concat_sim_{stem}_v_msim.mk {{}} SIMTOOL=msim sim
"""


def gen_makefile(tech: str) -> str:
    return f"""\
{SPDX}
CATAPULT_PRODUCT = ultra
export DMA_WIDTH = 128
export ACCELERATOR = DUMMY
export TECH_PATH = DUMMY
export MEMTECH_PATH = DUMMY
export ESP_ROOT = ../../../../../../
export TECH = {tech}

all: hls
.PHONY: all

hls:
\tcatapult -product $(CATAPULT_PRODUCT) -shell -f ./build_prj_top.tcl
.PHONY: hls

clean:
\trm -rf Catapult*
\trm -rf catapult_cache*
\trm -f catapult.pinfo
\trm -f trace.vcd
\trm -f transcript
\trm -f catapult.log
\trm -f vsim_stacktrace.vstf
.PHONY: clean

distclean: clean
\t@rm -rf $(RTL_OUT)
.PHONY: distclean
"""


# ---------------------------------------------------------------------------
# Write helper
# ---------------------------------------------------------------------------

def write_file(path: Path, content: str, force: bool, dry_run: bool) -> str:
    if path.exists() and not force:
        return 'skipped'
    tag = 'updated' if path.exists() else 'created'
    if not dry_run:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
    return tag


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
    # Accept -virtex7 / -virtexup / -virtexu  (single-dash word) as the tech
    # positional by stripping the dash before argparse sees it.
    argv = []
    raw_tech = None
    for a in sys.argv[1:]:
        if re.fullmatch(r'-[a-zA-Z]\w+', a):   # e.g. -virtex7  (not -h, --force)
            raw_tech = a.lstrip('-')
        else:
            argv.append(a)

    ap = argparse.ArgumentParser(
        description='Generate per-submodule HLS work folders for a tech target.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='Example:\n  python init_hls.py -virtexup\n'
               '  python init_hls.py -virtex7 --force')
    ap.add_argument('tech', nargs='?', default=raw_tech,
                    help='Target tech: virtex7 | virtexu | virtexup')
    ap.add_argument('--force',   action='store_true', help='Overwrite existing files')
    ap.add_argument('--dry-run', action='store_true', help='Preview without writing')
    ap.add_argument('--acc-dir', metavar='DIR',
                    help='Accelerator root (default: nearest parent of cwd '
                         'containing hw/src/)')
    args = ap.parse_args(argv)

    if not args.tech:
        ap.error('tech argument required (e.g. -virtexup or virtexup)')

    tech = args.tech.lstrip('-')    # normalise if user typed --virtexup

    acc_dir    = find_acc_dir(args.acc_dir)
    hw_dir     = acc_dir / 'hw'
    acc_name   = acc_dir.name
    acc_prefix = re.sub(r'_(?:sysc|cxx)_catapult$', '', acc_name)
    if acc_prefix == acc_name:           # no sysc/cxx infix (e.g. gemm_catapult)
        acc_prefix = re.sub(r'_catapult$', '', acc_name)
    work_dir   = hw_dir / f'hls-work-{tech}'

    # Scan hw/src/ and hw/inc/ for SC_MODULE files
    scan_dirs  = [hw_dir / 'src', hw_dir / 'inc']
    all_mods   = scan_modules(scan_dirs)

    if not all_mods:
        sys.exit(f'No SC_MODULE declarations found under {hw_dir}')

    # Top = module whose name matches the accelerator directory name
    sub_mods = [(p, m) for p, m in all_mods if m != acc_name]
    top_mods = [(p, m) for p, m in all_mods if m == acc_name]

    if not sub_mods:
        sys.exit('No sub-modules found (every SC_MODULE matched the top-level name).')

    # Shared includes: *_data_types, *_conf_info, *_specs in hw/inc/
    inc_dir = hw_dir / 'inc'
    data_types, conf_info, specs = find_shared_includes(inc_dir, acc_prefix)

    # Print summary
    top_str = ', '.join(m for _, m in top_mods) or '(none detected)'
    print(f'Accelerator : {acc_name}')
    print(f'Top module  : {top_str}')
    print(f'Sub-modules : {", ".join(m for _, m in sub_mods)}')
    print(f'Shared inc  : {", ".join(f.name for f in [data_types, conf_info, specs] if f)}')
    print(f'Output dir  : {work_dir.relative_to(acc_dir)}')
    print()

    totals = {'created': 0, 'updated': 0, 'skipped': 0}

    for mod_file, module_name in sub_mods:
        stem    = mod_file.stem                  # e.g. xmem_ctrl
        out_dir = work_dir / stem

        files = {
            'build_prj.tcl':     gen_build_prj(stem, module_name, mod_file, hw_dir,
                                               data_types, conf_info, specs),
            'build_prj_top.tcl': gen_build_prj_top(),
            'rtl_sim.tcl':       gen_rtl_sim(stem),
            'Makefile':          gen_makefile(tech),
        }

        for fname, content in files.items():
            dst = out_dir / fname
            tag = write_file(dst, content, args.force, args.dry_run)
            totals[tag] += 1
            marker = ' [DRY]' if args.dry_run else ''
            print(f'  {tag:8s}{marker}  {dst.relative_to(acc_dir)}')

    print()
    c, u, s = totals['created'], totals['updated'], totals['skipped']
    print(f'Done — created: {c}, updated: {u}, skipped: {s}')
    if s:
        print('       (use --force to overwrite skipped files)')
    if not args.dry_run and (c + u):
        print()
        print('To add URAM directives for UltraScale+ builds:')
        print(f'  cd {acc_dir}')
        print( '  python ../common/hls/design_plm.py --uram <plm,...> --show-tcl')


if __name__ == '__main__':
    main()
