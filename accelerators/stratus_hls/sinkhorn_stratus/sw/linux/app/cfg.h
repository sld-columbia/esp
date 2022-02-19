#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "final.h"
#include "total.h"
#include "input.h"
#include "sinkhorn_stratus.h"
#include "svd_vivado.h"

typedef int32_t token_t;

/* <<--params-def-->> */
#define MAXITER 150
#define GAMMA 1.6
#define Q_COLS 177
#define M_ROWS 3
#define P_ROWS 229

/* <<--params-->> */
const int32_t maxiter = MAXITER;
const float gamma_float = GAMMA;
const int32_t q_cols = Q_COLS;
const int32_t m_rows = M_ROWS;
const int32_t p_rows = P_ROWS;

#define NACC 2

struct svd_access svd_cfg_000[] = {
	{
		.q = Q_COLS,
		.p = P_ROWS,
		.m = M_ROWS,
		.p2p_out = 0,
		.p2p_in = 0,
		.p2p_iter = 1,
		.load_state = 0,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"", "", "", ""},
	}
};

struct sinkhorn_access sinkhorn_cfg_000[] = {
	{
		.maxiter = MAXITER,
		.gamma = GAMMA,
		.q_cols = Q_COLS,
		.m_rows = M_ROWS,
		.p_rows = P_ROWS,
		.src_offset = 0,
		.dst_offset = 0,
		.p2p_out = 0,
		.p2p_in = 0,
		.p2p_iter = 1,
		.store_state = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"svd.0", "", "", ""},
	},
	{
		.maxiter = MAXITER,
		.gamma = GAMMA,
		.q_cols = Q_COLS,
		.m_rows = M_ROWS,
		.p_rows = P_ROWS,
		.src_offset = 0,
		.dst_offset = 0,
		.p2p_out = 0,
		.p2p_in = 0,
		.p2p_iter = 1,
		.store_state = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"svd.0", "", "", ""},
	},
	{
		.maxiter = MAXITER,
		.gamma = GAMMA,
		.q_cols = Q_COLS,
		.m_rows = M_ROWS,
		.p_rows = P_ROWS,
		.src_offset = 0,
		.dst_offset = 0,
		.p2p_out = 0,
		.p2p_in = 0,
		.p2p_iter = 1,
		.store_state = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"svd.0", "", "", ""},
	},
	{
		.maxiter = MAXITER,
		.gamma = GAMMA,
		.q_cols = Q_COLS,
		.m_rows = M_ROWS,
		.p_rows = P_ROWS,
		.src_offset = 0,
		.dst_offset = 0,
		.p2p_out = 0,
		.p2p_in = 0,
		.p2p_iter = 1,
		.store_state = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"svd.0", "", "", ""},
	}
};

esp_thread_info_t cfg_000[] = {
	{
		.run = true,
		.devname = "svd.0",
		.ioctl_req = SVD_IOC_ACCESS,
		.esp_desc = &(svd_cfg_000[0].esp),
	},
	{
		.run = true,
		.devname = "sinkhorn.0",
		.ioctl_req = SINKHORN_IOC_ACCESS,
		.esp_desc = &(sinkhorn_cfg_000[0].esp),
	},
	{
		.run = true,
		.devname = "sinkhorn.1",
		.ioctl_req = SINKHORN_IOC_ACCESS,
		.esp_desc = &(sinkhorn_cfg_000[1].esp),
	},
	{
		.run = true,
		.devname = "sinkhorn.2",
		.ioctl_req = SINKHORN_IOC_ACCESS,
		.esp_desc = &(sinkhorn_cfg_000[2].esp),
	},
	{
		.run = true,
		.devname = "sinkhorn.3",
		.ioctl_req = SINKHORN_IOC_ACCESS,
		.esp_desc = &(sinkhorn_cfg_000[3].esp),
	}
};

struct svd_access svd_cfg_p2p[] = {
	{
		.q = Q_COLS,
		.p = P_ROWS,
		.m = M_ROWS,
		.p2p_out = 1,
		.p2p_in = 0,
		.p2p_iter = 1,
		.load_state = 0,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 1,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"sinkhorn.0", "", "", ""},
	}
};

struct sinkhorn_access sinkhorn_cfg_p2p[] = {
	{
		.maxiter = MAXITER,
		.gamma = GAMMA,
		.q_cols = Q_COLS,
		.m_rows = M_ROWS,
		.p_rows = P_ROWS,
		.p2p_out = 0,
		.p2p_in = 1,
		.p2p_iter = 1,
		.store_state = 0,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 1,
		.esp.p2p_srcs = {"svd.0", "", "", ""},
	}
};

esp_thread_info_t cfg_p2p[] = {
	{
		.run = true,
		.devname = "svd.0",
		.ioctl_req = SVD_IOC_ACCESS,
 		.esp_desc = &(svd_cfg_p2p[0].esp),
	},
	{
		.run = true,
		.devname = "sinkhorn.0",
		.ioctl_req = SINKHORN_IOC_ACCESS,
		.esp_desc = &(sinkhorn_cfg_p2p[0].esp),
	}
};

struct svd_access svd_cfg_multi[] = {
	{
		.q = Q_COLS,
		.p = P_ROWS,
		.m = M_ROWS,
		.p2p_out = 1,
		.p2p_in = 0,
		.p2p_iter = 1,
		.load_state = 0,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 1,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"sinkhorn.0", "sinkhorn.1", "sinkhorn.2", "sinkhorn.3"},
	}
};

struct sinkhorn_access sinkhorn_cfg_multi[] = {
	{
		.maxiter = MAXITER,
		.gamma = GAMMA,
		.q_cols = Q_COLS,
		.m_rows = M_ROWS,
		.p_rows = P_ROWS,
		.p2p_out = 0,
		.p2p_in = 1,
		.p2p_iter = 1,
		.store_state = 0,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 1,
		.esp.p2p_srcs = {"svd.0", "", "", ""},
	},
	{
		.maxiter = MAXITER,
		.gamma = GAMMA,
		.q_cols = Q_COLS,
		.m_rows = M_ROWS,
		.p_rows = P_ROWS,
		.p2p_out = 0,
		.p2p_in = 1,
		.p2p_iter = 1,
		.store_state = 0,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 1,
		.esp.p2p_srcs = {"svd.0", "", "", ""},
	},
	{
		.maxiter = MAXITER,
		.gamma = GAMMA,
		.q_cols = Q_COLS,
		.m_rows = M_ROWS,
		.p_rows = P_ROWS,
		.p2p_out = 0,
		.p2p_in = 1,
		.p2p_iter = 1,
		.store_state = 0,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 1,
		.esp.p2p_srcs = {"svd.0", "", "", ""},
	},
	{
		.maxiter = MAXITER,
		.gamma = GAMMA,
		.q_cols = Q_COLS,
		.m_rows = M_ROWS,
		.p_rows = P_ROWS,
		.p2p_out = 0,
		.p2p_in = 1,
		.p2p_iter = 1,
		.store_state = 0,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 1,
		.esp.p2p_srcs = {"svd.0", "", "", ""},
	},
};

esp_thread_info_t cfg_multi[] = {
	{
		.run = true,
		.devname = "svd.0",
		.ioctl_req = SVD_IOC_ACCESS,
 		.esp_desc = &(svd_cfg_multi[0].esp),
	},
	{
		.run = true,
		.devname = "sinkhorn.0",
		.ioctl_req = SINKHORN_IOC_ACCESS,
 		.esp_desc = &(sinkhorn_cfg_multi[0].esp),
	},
	{
		.run = true,
		.devname = "sinkhorn.1",
		.ioctl_req = SINKHORN_IOC_ACCESS,
 		.esp_desc = &(sinkhorn_cfg_multi[1].esp),
	},
	{
		.run = true,
		.devname = "sinkhorn.2",
		.ioctl_req = SINKHORN_IOC_ACCESS,
 		.esp_desc = &(sinkhorn_cfg_multi[2].esp),
	},
	{
		.run = true,
		.devname = "sinkhorn.3",
		.ioctl_req = SINKHORN_IOC_ACCESS,
 		.esp_desc = &(sinkhorn_cfg_multi[3].esp),
	}
};

struct svd_access svd_cfg_multi2[] = {
	{
		.q = Q_COLS,
		.p = P_ROWS,
		.m = M_ROWS,
		.p2p_out = 1,
		.p2p_in = 0,
		.p2p_iter = 1,
		.load_state = 0,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 1,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"sinkhorn.0", "", "", ""},
	},
	{
		.q = Q_COLS,
		.p = P_ROWS,
		.m = M_ROWS,
		.p2p_out = 1,
		.p2p_in = 0,
		.p2p_iter = 1,
		.load_state = 0,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 1,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"sinkhorn.1", "", "", ""},
	},
	{
		.q = Q_COLS,
		.p = P_ROWS,
		.m = M_ROWS,
		.p2p_out = 1,
		.p2p_in = 0,
		.p2p_iter = 1,
		.load_state = 0,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 1,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"sinkhorn.2", "", "", ""},
	},
	{
		.q = Q_COLS,
		.p = P_ROWS,
		.m = M_ROWS,
		.p2p_out = 1,
		.p2p_in = 0,
		.p2p_iter = 1,
		.load_state = 0,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 1,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"sinkhorn.3", "", "", ""},
	}
};

struct sinkhorn_access sinkhorn_cfg_multi2[] = {
	{
		.maxiter = MAXITER,
		.gamma = GAMMA,
		.q_cols = Q_COLS,
		.m_rows = M_ROWS,
		.p_rows = P_ROWS,
		.p2p_out = 0,
		.p2p_in = 1,
		.p2p_iter = 1,
		.store_state = 0,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 1,
		.esp.p2p_srcs = {"svd.0", "", "", ""},
	},
	{
		.maxiter = MAXITER,
		.gamma = GAMMA,
		.q_cols = Q_COLS,
		.m_rows = M_ROWS,
		.p_rows = P_ROWS,
		.p2p_out = 0,
		.p2p_in = 1,
		.p2p_iter = 1,
		.store_state = 0,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 1,
		.esp.p2p_srcs = {"svd.1", "", "", ""},
	},
	{
		.maxiter = MAXITER,
		.gamma = GAMMA,
		.q_cols = Q_COLS,
		.m_rows = M_ROWS,
		.p_rows = P_ROWS,
		.p2p_out = 0,
		.p2p_in = 1,
		.p2p_iter = 1,
		.store_state = 0,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 1,
		.esp.p2p_srcs = {"svd.2", "", "", ""},
	},
	{
		.maxiter = MAXITER,
		.gamma = GAMMA,
		.q_cols = Q_COLS,
		.m_rows = M_ROWS,
		.p_rows = P_ROWS,
		.p2p_out = 0,
		.p2p_in = 1,
		.p2p_iter = 1,
		.store_state = 0,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 1,
		.esp.p2p_srcs = {"svd.3", "", "", ""},
	},
};

esp_thread_info_t cfg_multi2[] = {
	{
		.run = true,
		.devname = "svd.0",
		.ioctl_req = SVD_IOC_ACCESS,
 		.esp_desc = &(svd_cfg_multi2[0].esp),
	},
	{
		.run = true,
		.devname = "svd.1",
		.ioctl_req = SVD_IOC_ACCESS,
 		.esp_desc = &(svd_cfg_multi2[1].esp),
	},
	{
		.run = true,
		.devname = "svd.2",
		.ioctl_req = SVD_IOC_ACCESS,
 		.esp_desc = &(svd_cfg_multi2[2].esp),
	},
	{
		.run = true,
		.devname = "svd.3",
		.ioctl_req = SVD_IOC_ACCESS,
 		.esp_desc = &(svd_cfg_multi2[3].esp),
	},
	{
		.run = true,
		.devname = "sinkhorn.0",
		.ioctl_req = SINKHORN_IOC_ACCESS,
 		.esp_desc = &(sinkhorn_cfg_multi2[0].esp),
	},
	{
		.run = true,
		.devname = "sinkhorn.1",
		.ioctl_req = SINKHORN_IOC_ACCESS,
 		.esp_desc = &(sinkhorn_cfg_multi2[1].esp),
	},
	{
		.run = true,
		.devname = "sinkhorn.2",
		.ioctl_req = SINKHORN_IOC_ACCESS,
 		.esp_desc = &(sinkhorn_cfg_multi2[2].esp),
	},
	{
		.run = true,
		.devname = "sinkhorn.3",
		.ioctl_req = SINKHORN_IOC_ACCESS,
 		.esp_desc = &(sinkhorn_cfg_multi2[3].esp),
	}
};

token_t prev_R[M_ROWS*M_ROWS];


#endif /* __ESP_CFG_000_H__ */
