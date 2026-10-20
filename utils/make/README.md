# Vivado Optimization Controls

This directory contains the shared ESP makefile fragments. Vivado timing-closure
controls live in `vivado.mk` so they can be reused across FPGA boards instead of
being copied into board-local makefiles.

## Recommended profile

For Vivado 2023.2, enable the shared timing-closure profile with:

```bash
make vivado-syn VIVADO_ENABLE_ALL_OPTIMIZATIONS=1
```

This profile enables the following defaults unless you override an individual
variable on the same command line:

* `VIVADO_SYNTH_GLOBAL_RETIMING=true`
* `VIVADO_SYNTH_STRATEGY=Flow_PerfOptimized_high`
* `VIVADO_IMPL_STRATEGY=Performance_Explore`
* `VIVADO_OPT_DIRECTIVE=Explore`
* `VIVADO_PLACE_DIRECTIVE=ExtraNetDelay_high`
* `VIVADO_PHYS_OPT_DIRECTIVE=AggressiveExplore`
* `VIVADO_ROUTE_DIRECTIVE=AggressiveExplore`
* `VIVADO_POST_ROUTE_PHYS_OPT_ENABLE=true`
* `VIVADO_POST_ROUTE_PHYS_OPT_DIRECTIVE=AggressiveExplore`
* `VIVADO_ENABLE_EXTRA_TIMING_REPORTS=1`

Example with one override:

```bash
make vivado-syn \
  VIVADO_ENABLE_ALL_OPTIMIZATIONS=1 \
  VIVADO_ROUTE_DIRECTIVE=Explore
```

## Individual controls

You can also set individual controls directly without enabling the full profile:

* `VIVADO_SYNTH_GLOBAL_RETIMING`
* `VIVADO_SYNTH_STRATEGY`
* `VIVADO_IMPL_STRATEGY`
* `VIVADO_OPT_DIRECTIVE`
* `VIVADO_PLACE_DIRECTIVE`
* `VIVADO_PHYS_OPT_DIRECTIVE`
* `VIVADO_ROUTE_DIRECTIVE`
* `VIVADO_POST_ROUTE_PHYS_OPT_ENABLE`
* `VIVADO_POST_ROUTE_PHYS_OPT_DIRECTIVE`
* `VIVADO_ENABLE_EXTRA_TIMING_REPORTS`

For backward compatibility, `VIVADO_SYNTH_RETIMING=true` still maps to
`VIVADO_SYNTH_GLOBAL_RETIMING=true`.

In Vivado project mode, this enables the typed synthesis run property
`STEPS.SYNTH_DESIGN.ARGS.RETIMING=true`.

## Important behavior

These variables affect Vivado project setup in `setup.tcl`. If you change them,
use `make vivado-syn` and recreate the Vivado project when prompted, or clean
the Vivado project first.

`make vivado-update` reuses the existing Vivado project and does not reapply
setup-time changes.
