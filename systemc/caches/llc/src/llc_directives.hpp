/* Copyright 2017 Columbia University, SLD Group */

#ifndef __LLC_DIRECTIVES_HPP__
#define __LLC_DIRECTIVES_HPP__


#define FLATTEN_REGS				\
    HLS_FLATTEN_ARRAY(tag_buf);			\
    HLS_FLATTEN_ARRAY(state_buf);		\
    HLS_FLATTEN_ARRAY(hprot_buf);		\
    HLS_FLATTEN_ARRAY(line_buf);		\
    HLS_FLATTEN_ARRAY(sharers_buf);		\
    HLS_FLATTEN_ARRAY(owner_buf)

// Reset functions
#define RESET_IO				\
    HLS_DEFINE_PROTOCOL("llc-reset-io-protocol")
#define RESET_STATES

#define RESET_STATES_LOOP				\
    HLS_DEFINE_PROTOCOL("llc-reset-states-protocol")

#endif /* __LLC_DIRECTIVES_HPP_ */
