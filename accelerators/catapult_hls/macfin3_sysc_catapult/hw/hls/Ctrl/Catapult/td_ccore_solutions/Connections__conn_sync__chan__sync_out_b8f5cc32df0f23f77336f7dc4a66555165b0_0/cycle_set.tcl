
# Loop constraints
directive set /Connections::conn_sync::chan::sync_out/core/core:rlp CSTEPS_FROM {{. == 0}}
directive set /Connections::conn_sync::chan::sync_out/core/core:rlp/main CSTEPS_FROM {{. == 3} {.. == 0}}

# IO operation constraints
directive set /Connections::conn_sync::chan::sync_out/core/core:rlp/main/io_read(ccs_ccore_start:rsc.@) CSTEPS_FROM {{.. == 1}}
directive set /Connections::conn_sync::chan::sync_out/core/core:rlp/main/do:asn(this.vld) CSTEPS_FROM {{.. == 1}}
directive set /Connections::conn_sync::chan::sync_out/core/core:rlp/main/do:asn CSTEPS_FROM {{.. == 2}}
directive set /Connections::conn_sync::chan::sync_out/core/core:rlp/main/asn(this.vld) CSTEPS_FROM {{.. == 2}}

# Sync operation constraints

# Real operation constraints
directive set /Connections::conn_sync::chan::sync_out/core/core:rlp/main/do:mux#1 CSTEPS_FROM {{.. == 1}}

# Probe constraints
