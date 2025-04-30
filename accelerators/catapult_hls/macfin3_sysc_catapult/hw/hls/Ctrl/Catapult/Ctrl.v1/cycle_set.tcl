
# Loop constraints
directive set /Ctrl/Ctrl:config/config/config:rlp CSTEPS_FROM {{. == 1}}
directive set /Ctrl/Ctrl:config/config/config:rlp/while CSTEPS_FROM {{. == 2} {.. == 1}}

# IO operation constraints

# Sync operation constraints

# Real operation constraints
directive set /Ctrl/Ctrl:config/config/config:rlp/while/conf_info.Pop() CSTEPS_FROM {{.. == 0}}
directive set /Ctrl/Ctrl:config/config/config:rlp/while/conf_info_out.Push() CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:config/config/config:rlp/while/conf1.Push() CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:config/config/config:rlp/while/conf2.Push() CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:config/config/config:rlp/while/conf3.Push() CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:config/config/config:rlp/while/sync00.Push() CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:config/config/config:rlp/while/sync01.Push() CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:config/config/config:rlp/while/sync02.Push() CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:config/config/config:rlp/while/sync03.Push() CSTEPS_FROM {{.. == 1}}

# Probe constraints

# Loop constraints
directive set /Ctrl/Ctrl:load/load/load:rlp CSTEPS_FROM {{. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while CSTEPS_FROM {{. == 1} {.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for CSTEPS_FROM {{. == 4} {.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for CSTEPS_FROM {{. == 4} {.. == 3}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for CSTEPS_FROM {{. == 3} {.. == 2}}

# IO operation constraints

# Sync operation constraints

# Real operation constraints
directive set /Ctrl/Ctrl:load/load/load:rlp/while/sync01.Pop() CSTEPS_FROM {{.. == 0}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/conf1.Pop() CSTEPS_FROM {{.. == 0}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for:acc#2 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:len:mul CSTEPS_FROM {{.. == 0}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:len:acc#1 CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:len:acc CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for:acc#4 CSTEPS_FROM {{.. == 3}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:len1:acc CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:len1:mux CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:len1:while:for:for:len1:and CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/dma_read_ctrl.Push() CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:acc#2 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/dma_read_chnl.Pop() CSTEPS_FROM {{.. == 1}}
directive set {/Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for-1:ac_array_1D<FPDATA_WORD,320U>::operator[]:acc} CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for:if:write_mem(plm_in_ping.a0.a.d.data:rsc.@) CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for:if:write_mem(plm_in_ping.a1.a.d.data:rsc.@) CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for:else:write_mem(plm_in_pong.a0.a.d.data:rsc.@) CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for:else:write_mem(plm_in_pong.a1.a.d.data:rsc.@) CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:acc#1 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:mux#1 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/sync12.sync_out() CSTEPS_FROM {{.. == 3}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:acc#2 CSTEPS_FROM {{.. == 3}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:acc#3 CSTEPS_FROM {{.. == 3}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:acc CSTEPS_FROM {{.. == 3}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:acc#1 CSTEPS_FROM {{.. == 4}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:acc#3 CSTEPS_FROM {{.. == 4}}

# Probe constraints
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for-1:Ctrl:load:ac_shared_bank_array.h:ln85:assert:idx_lt_C#ctrl#prb#1 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for-1:Ctrl:load:ac_shared_bank_array.h:ln85:assert:idx_lt_C#2 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for-1:Ctrl:load:ac_array_1D.h:ln58:assert:idx_lt_D1#ctrl#prb#2 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for-1:Ctrl:load:ac_array_1D.h:ln58:assert:idx_lt_D1#4 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for-2:Ctrl:load:ac_shared_bank_array.h:ln85:assert:idx_lt_C#ctrl#prb#1 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for-2:Ctrl:load:ac_shared_bank_array.h:ln85:assert:idx_lt_C#2 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for-2:Ctrl:load:ac_array_1D.h:ln58:assert:idx_lt_D1#ctrl#prb#2 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for-2:Ctrl:load:ac_array_1D.h:ln58:assert:idx_lt_D1#4 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for-1:Ctrl:load:ac_shared_bank_array.h:ln85:assert:idx_lt_C#1#ctrl#prb#1 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for-1:Ctrl:load:ac_shared_bank_array.h:ln85:assert:idx_lt_C#3 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for-1:Ctrl:load:ac_array_1D.h:ln58:assert:idx_lt_D1#1#ctrl#prb#2 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for-1:Ctrl:load:ac_array_1D.h:ln58:assert:idx_lt_D1#5 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for-2:Ctrl:load:ac_shared_bank_array.h:ln85:assert:idx_lt_C#1#ctrl#prb#1 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for-2:Ctrl:load:ac_shared_bank_array.h:ln85:assert:idx_lt_C#3 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for-2:Ctrl:load:ac_array_1D.h:ln58:assert:idx_lt_D1#1#ctrl#prb#2 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:load/load/load:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for-2:Ctrl:load:ac_array_1D.h:ln58:assert:idx_lt_D1#5 CSTEPS_FROM {{.. == 1}}

# Loop constraints
directive set /Ctrl/Ctrl:compute/compute/compute:rlp CSTEPS_FROM {{. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while CSTEPS_FROM {{. == 1} {.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for CSTEPS_FROM {{. == 3} {.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for CSTEPS_FROM {{. == 4} {.. == 2}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for CSTEPS_FROM {{. == 4} {.. == 2}}

# IO operation constraints

# Sync operation constraints

# Real operation constraints
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/sync02.Pop() CSTEPS_FROM {{.. == 0}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/conf2.Pop() CSTEPS_FROM {{.. == 0}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for:acc#2 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:in_length:mul CSTEPS_FROM {{.. == 0}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for:acc#2 CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:in_len:acc CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:in_len:mux CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:in_len:while:for:for:in_len:and CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/sync12.sync_in() CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:acc#3 CSTEPS_FROM {{.. == 1}}
directive set {/Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/ac_array_1D<FPDATA_WORD,320U>::operator[]:acc} CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/plm_in_ping.a0.a.d.data:read_mem(plm_in_ping.a0.a.d.data:rsc.@) CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/plm_in_ping.a1.a.d.data:read_mem(plm_in_ping.a1.a.d.data:rsc.@) CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/plm_in_pong.a0.a.d.data:read_mem(plm_in_pong.a0.a.d.data:rsc.@) CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/plm_in_pong.a1.a.d.data:read_mem(plm_in_pong.a1.a.d.data:rsc.@) CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:mux#1 CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:mux#17 CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/in_rd_rsp.Push() CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:acc#1 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:if#1:unequal CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/in_wr_req.Pop() CSTEPS_FROM {{.. == 2}}
directive set {/Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/ac_array_1D<FPDATA_WORD,32U>::operator[]:acc} CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:if#1:if:write_mem(plm_out_ping.a0.a.d.data:rsc.@) CSTEPS_FROM {{.. == 3}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:if#1:if:write_mem(plm_out_ping.a1.a.d.data:rsc.@) CSTEPS_FROM {{.. == 3}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:if#1:else:write_mem(plm_out_pong.a0.a.d.data:rsc.@) CSTEPS_FROM {{.. == 3}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:if#1:else:write_mem(plm_out_pong.a1.a.d.data:rsc.@) CSTEPS_FROM {{.. == 3}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:if#1:qif:acc CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:acc#2 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:mux CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:while:for:for:for:and CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:mux#11 CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:mux#6 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:mux#13 CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:mux#14 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/sync23.sync_out() CSTEPS_FROM {{.. == 3}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:acc#1 CSTEPS_FROM {{.. == 3}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:acc CSTEPS_FROM {{.. == 3}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:acc#1 CSTEPS_FROM {{.. == 3}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:acc#3 CSTEPS_FROM {{.. == 3}}

# Probe constraints
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_shared_bank_array.h:ln85:assert:idx_lt_C CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_shared_bank_array.h:ln85:assert:idx_lt_C#ctrl#prb CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_array_1D.h:ln58:assert:idx_lt_D1#ctrl#prb#2 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_array_1D.h:ln58:assert:idx_lt_D1#14 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_shared_bank_array.h:ln85:assert:idx_lt_C#1 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_shared_bank_array.h:ln85:assert:idx_lt_C#1#ctrl#prb CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_array_1D.h:ln58:assert:idx_lt_D1#1#ctrl#prb#2 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_array_1D.h:ln58:assert:idx_lt_D1#12 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_shared_bank_array.h:ln85:assert:idx_lt_C#2 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_shared_bank_array.h:ln85:assert:idx_lt_C#2#ctrl#prb CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_array_1D.h:ln58:assert:idx_lt_D1#2#ctrl#prb#2 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_array_1D.h:ln58:assert:idx_lt_D1#15 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_shared_bank_array.h:ln85:assert:idx_lt_C#3 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_shared_bank_array.h:ln85:assert:idx_lt_C#3#ctrl#prb CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_array_1D.h:ln58:assert:idx_lt_D1#3#ctrl#prb#2 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_array_1D.h:ln58:assert:idx_lt_D1#13 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_shared_bank_array.h:ln85:assert:idx_lt_C#4 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_shared_bank_array.h:ln85:assert:idx_lt_C#4#ctrl#prb CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_array_1D.h:ln58:assert:idx_lt_D1#4#ctrl#prb#1 CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_array_1D.h:ln58:assert:idx_lt_D1#10 CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_shared_bank_array.h:ln85:assert:idx_lt_C#5 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_shared_bank_array.h:ln85:assert:idx_lt_C#5#ctrl#prb CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_array_1D.h:ln58:assert:idx_lt_D1#5#ctrl#prb#1 CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:compute/compute/compute:rlp/while/while:for/while:for:for/while:for:for:for/Ctrl:compute:ac_array_1D.h:ln58:assert:idx_lt_D1#11 CSTEPS_FROM {{.. == 2}}

# Loop constraints
directive set /Ctrl/Ctrl:store/store/store:rlp CSTEPS_FROM {{. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while CSTEPS_FROM {{. == 7} {.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for CSTEPS_FROM {{. == 2} {.. == 5}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for CSTEPS_FROM {{. == 4} {.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for CSTEPS_FROM {{. == 1} {.. == 3}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for CSTEPS_FROM {{. == 2} {.. == 0}}

# IO operation constraints
directive set /Ctrl/Ctrl:store/store/store:rlp/while/acc_done.write#1:asn(acc_done) CSTEPS_FROM {{.. == 6}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/acc_done.write#2:asn(acc_done) CSTEPS_FROM {{.. == 7}}

# Sync operation constraints

# Real operation constraints
directive set /Ctrl/Ctrl:store/store/store:rlp/while/sync03.Pop() CSTEPS_FROM {{.. == 0}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/conf3.Pop() CSTEPS_FROM {{.. == 0}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:length:acc CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:store_offset:mul#1 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:store_offset:acc#1 CSTEPS_FROM {{.. == 3}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:store_offset:acc CSTEPS_FROM {{.. == 3}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:store_offset:mul CSTEPS_FROM {{.. == 3}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for:acc#2 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for:acc#4 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/sync23.sync_in() CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:len:acc CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:len:mux CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:len:while:for:for:len:and CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/dma_write_ctrl.Push() CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for:acc#3 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for/plm_out_ping.a0.a.d.data:read_mem(plm_out_ping.a0.a.d.data:rsc.@) CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for/plm_out_ping.a1.a.d.data:read_mem(plm_out_ping.a1.a.d.data:rsc.@) CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for/plm_out_pong.a0.a.d.data:read_mem(plm_out_pong.a0.a.d.data:rsc.@) CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for/plm_out_pong.a1.a.d.data:read_mem(plm_out_pong.a1.a.d.data:rsc.@) CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for/while:for:for:for:for:while:for:for:for:for:mux1h CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for/while:for:for:for:for:mux CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for/while:for:for:for:for:mux#1 CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/dma_write_chnl.Push() CSTEPS_FROM {{.. == 0}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:acc#2 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:acc#1 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:acc#4 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:acc#2 CSTEPS_FROM {{.. == 4}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:acc#3 CSTEPS_FROM {{.. == 4}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:acc CSTEPS_FROM {{.. == 4}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:acc#1 CSTEPS_FROM {{.. == 2}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:acc#3 CSTEPS_FROM {{.. == 2}}

# Probe constraints
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for/Ctrl:store:ac_shared_bank_array.h:ln85:assert:idx_lt_C#ctrl#prb#1 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for/Ctrl:store:ac_shared_bank_array.h:ln85:assert:idx_lt_C#2 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for/Ctrl:store:ac_array_1D.h:ln58:assert:idx_lt_D1 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for/Ctrl:store:ac_array_1D.h:ln58:assert:idx_lt_D1#ctrl#prb CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for/Ctrl:store:ac_shared_bank_array.h:ln85:assert:idx_lt_C#1#ctrl#prb#1 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for/Ctrl:store:ac_shared_bank_array.h:ln85:assert:idx_lt_C#3 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for/Ctrl:store:ac_array_1D.h:ln58:assert:idx_lt_D1#1 CSTEPS_FROM {{.. == 1}}
directive set /Ctrl/Ctrl:store/store/store:rlp/while/while:for/while:for:for/while:for:for:for/while:for:for:for:for/Ctrl:store:ac_array_1D.h:ln58:assert:idx_lt_D1#1#ctrl#prb CSTEPS_FROM {{.. == 1}}
