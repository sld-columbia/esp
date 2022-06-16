// Copyright (c) 2011-2022 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "sm_sensor.hpp"

// Optional application-specific helper functions
inline void sm_sensor::compute_load_ready_handshake()
{
    {
        HLS_DEFINE_PROTOCOL("compute-load-ready-handshake");

        load_ready.req.req();
    }
}

inline void sm_sensor::load_compute_ready_handshake()
{
    {
        HLS_DEFINE_PROTOCOL("load-compute-ready-handshake");

        load_ready.ack.ack();
    }
}

inline void sm_sensor::compute_store_ready_handshake()
{
    {
        HLS_DEFINE_PROTOCOL("compute-store-ready-handshake");

        store_ready.req.req();
    }
}

inline void sm_sensor::store_compute_ready_handshake()
{
    {
        HLS_DEFINE_PROTOCOL("store-compute-ready-handshake");

        store_ready.ack.ack();
    }
}

inline void sm_sensor::compute_load_done_handshake()
{
    {
        HLS_DEFINE_PROTOCOL("compute-load-done-handshake");

        load_done.ack.ack();
    }
}

inline void sm_sensor::load_compute_done_handshake()
{
    {
        HLS_DEFINE_PROTOCOL("load-compute-done-handshake");

        load_done.req.req();
    }
}

inline void sm_sensor::compute_store_done_handshake()
{
    {
        HLS_DEFINE_PROTOCOL("compute-store-done-handshake");

        store_done.ack.ack();
    }
}

inline void sm_sensor::store_compute_done_handshake()
{
    {
        HLS_DEFINE_PROTOCOL("store-compute-done-handshake");

        store_done.req.req();
    }
}
