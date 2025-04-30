
# Loop constraints
directive set /DataPath/compute/compute:rlp CSTEPS_FROM {{. == 1}}
directive set /DataPath/compute/compute:rlp/while CSTEPS_FROM {{. == 1} {.. == 1}}
directive set /DataPath/compute/compute:rlp/while/while:for CSTEPS_FROM {{. == 3} {.. == 1}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for CSTEPS_FROM {{. == 2} {.. == 2}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for CSTEPS_FROM {{. == 6} {.. == 1}}

# IO operation constraints

# Sync operation constraints

# Real operation constraints
directive set /DataPath/compute/compute:rlp/while/sync00.Pop() CSTEPS_FROM {{.. == 0}}
directive set /DataPath/compute/compute:rlp/while/conf_info_in.Pop() CSTEPS_FROM {{.. == 0}}
directive set /DataPath/compute/compute:rlp/while/while:for:acc#2 CSTEPS_FROM {{.. == 1}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:in_length:mul CSTEPS_FROM {{.. == 0}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for:acc#2 CSTEPS_FROM {{.. == 2}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:in_len:acc CSTEPS_FROM {{.. == 1}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:in_len:mux CSTEPS_FROM {{.. == 1}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:in_len:while:for:for:in_len:and CSTEPS_FROM {{.. == 1}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:acc#4 CSTEPS_FROM {{.. == 1}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/in_rd_rsp.Pop() CSTEPS_FROM {{.. == 1}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:while:for:for:for:mul CSTEPS_FROM {{.. == 2}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:acc#1 CSTEPS_FROM {{.. == 5}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:acc#2 CSTEPS_FROM {{.. == 1}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:if:unequal CSTEPS_FROM {{.. == 1}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/in_wr_req.Push() CSTEPS_FROM {{.. == 5}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:while:for:for:for:and CSTEPS_FROM {{.. == 6}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:while:for:for:for:and#1 CSTEPS_FROM {{.. == 2}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:acc#3 CSTEPS_FROM {{.. == 1}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:mux CSTEPS_FROM {{.. == 6}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:mux#3 CSTEPS_FROM {{.. == 2}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:mux#4 CSTEPS_FROM {{.. == 1}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:acc#1 CSTEPS_FROM {{.. == 2}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:for/while:for:for:acc CSTEPS_FROM {{.. == 2}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:acc#1 CSTEPS_FROM {{.. == 3}}
directive set /DataPath/compute/compute:rlp/while/while:for/while:for:acc#3 CSTEPS_FROM {{.. == 3}}

# Probe constraints
