
# Loop constraints
directive set /LeakyreluConfig/ConfigRead/ConfigRead:rlp CSTEPS_FROM {{. == 1}}
directive set /LeakyreluConfig/ConfigRead/ConfigRead:rlp/while CSTEPS_FROM {{. == 2} {.. == 1}}

# IO operation constraints

# Sync operation constraints

# Real operation constraints
directive set /LeakyreluConfig/ConfigRead/ConfigRead:rlp/while/conf_info.Pop() CSTEPS_FROM {{.. == 0}}
directive set /LeakyreluConfig/ConfigRead/ConfigRead:rlp/while/conf_info_ctrl_dma2acc.Push() CSTEPS_FROM {{.. == 1}}
directive set /LeakyreluConfig/ConfigRead/ConfigRead:rlp/while/conf_info_ctrl_plm2vec.Push() CSTEPS_FROM {{.. == 1}}
directive set /LeakyreluConfig/ConfigRead/ConfigRead:rlp/while/conf_info_ctrl_acc2dma.Push() CSTEPS_FROM {{.. == 1}}

# Probe constraints
