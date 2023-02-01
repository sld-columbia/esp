// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "libesp.h"
#include "synth_stratus.h"
#include "string.h"

#define DEBUG 1
#define dprintf if(DEBUG) printf

#define NPHASES_MAX 100
#define NTHREADS_MAX 16
#define NDEV_MAX 16
#define IRREGULAR_SEED_MAX 2048

#define CFG 0
#define FIXED 1
#define AUTO 2

unsigned long long total_alloc = 0;

typedef struct accelerator_thread_info {
    int tid; 
    int ndev; 
    int chain[NDEV_MAX];
    int p2p;
    size_t memsz;
    enum contig_alloc_policy alloc_choice; 
    struct timespec th_start;
    struct timespec th_end; 
} accelerator_thread_info_t;

typedef struct soc_config {
    int rows; 
    int cols; 
    int nmem;
    int* mem_y;
    int* mem_x; 
    int nsynth; 
    int* synth_y;
    int* synth_x; 
    int* ddr_hops; 
} soc_config_t; 

size_t size_to_bytes (char* size){
    if (!strncmp(size, "M8", 2)){
        return 8388608;
    } else if (!strncmp(size, "M4", 2)){
        return 4194304;
    } else if (!strncmp(size, "M2", 2)){
        return 2097152;
    } else if (!strncmp(size, "M1", 2)){
        return 1048576;
    } else if (!strncmp(size, "K512", 4)){
        return 524288;
    } else if (!strncmp(size, "K256", 4)){
        return 262144;
    } else if (!strncmp(size, "K128", 4)){
        return 131072;
    } else if (!strncmp(size, "K64", 3)){
        return 65536;
    } else if (!strncmp(size, "K32", 3)){
        return 32768;
    } else if (!strncmp(size, "K16", 3)){
        return 16384;
    } else if (!strncmp(size, "K8", 2)){
        return 8192;
    } else if (!strncmp(size, "K4", 2)){
        return 4096;
    } else if (!strncmp(size, "K2", 2)){
        return 2048;
    } else if (!strncmp(size, "K1", 2)){
        return 1024;
    } else {
        return -1;
    }
}

char *devnames[] = {
"synth_stratus.0",
"synth_stratus.1",
"synth_stratus.2",
"synth_stratus.3",
"synth_stratus.4",
"synth_stratus.5",
"synth_stratus.6",
"synth_stratus.7",
"synth_stratus.8",
"synth_stratus.9",
"synth_stratus.10",
"synth_stratus.11",
"synth_stratus.12",
"synth_stratus.13",
"synth_stratus.14",
"synth_stratus.15",
};

static void read_soc_config(FILE* f, soc_config_t* soc_config){
    fscanf(f, "%d", &soc_config->rows); 
    fscanf(f, "%d", &soc_config->cols); 
    
    //get locations of memory controllers
    fscanf(f, "%d", &soc_config->nmem);
    
    int mem_loc;
    soc_config->mem_y = malloc(sizeof(int) * soc_config->nmem);
    soc_config->mem_x = malloc(sizeof(int) * soc_config->nmem);
    for (int i = 0; i < soc_config->nmem; i++){
        fscanf(f, "%d", &mem_loc); 
        soc_config->mem_y[i] = mem_loc / soc_config->cols; 
        soc_config->mem_x[i] = mem_loc % soc_config->cols; 
    }
    
    //get locations of synthetic accelerators
    fscanf(f, "%d", &soc_config->nsynth);
   
    int synth_loc;
    soc_config->synth_y = malloc(sizeof(int)*soc_config->nsynth);
    soc_config->synth_x = malloc(sizeof(int)*soc_config->nsynth);
    for (int i = 0; i < soc_config->nsynth; i++){
        fscanf(f, "%d", &synth_loc); 
        soc_config->synth_y[i] = synth_loc / soc_config->cols;  
        soc_config->synth_x[i] = synth_loc % soc_config->cols; 
    }

    //calculate hops to each ddr controller
    soc_config->ddr_hops = malloc(sizeof(int)*soc_config->nmem*soc_config->nsynth);
    for (int s = 0; s < soc_config->nsynth; s++){
        for (int m = 0; m < soc_config->nmem; m++){
            soc_config->ddr_hops[s*soc_config->nmem + m] = abs(soc_config->synth_y[s] - soc_config->mem_y[m]) + abs(soc_config->synth_x[s] - soc_config->mem_x[m]);
        }
    }  
}

static void config_threads(FILE* f, accelerator_thread_info_t **thread_info, esp_thread_info_t ***cfg, struct synth_stratus_access ***synth_cfg, int phase, int* nthreads, int coherence_mode, enum accelerator_coherence coherence, unsigned **nacc){
    fscanf(f, "%d", nthreads); 
    dprintf("%d threads in phase %d\n", *nthreads, phase); 
    *cfg = malloc(sizeof(esp_thread_info_t*) * *nthreads);
    *nacc = malloc(sizeof(esp_thread_info_t*) * *nthreads);
    *synth_cfg = malloc(sizeof(struct synth_stratus_access*) * *nthreads);

    for (int t = 0; t < *nthreads; t++){
        thread_info[t] = malloc(sizeof(accelerator_thread_info_t));
        thread_info[t]->tid = t;
                
        //get number of devices and size
        fscanf(f, "%d\n", &(thread_info[t]->ndev));
        dprintf("%d devices in thread %d.%d\n", thread_info[t]->ndev, phase, t);
 
        (*cfg)[t] = malloc(sizeof(esp_thread_info_t) * thread_info[t]->ndev);
        (*synth_cfg)[t] = malloc(sizeof(struct synth_stratus_access) * thread_info[t]->ndev);
        (*nacc)[t] = thread_info[t]->ndev;

        char flow_choice[7];
        fscanf(f, "%s\n", flow_choice);

        if(!strcmp(flow_choice, "p2p")){
           thread_info[t]->p2p = 1;
        } else { 
           thread_info[t]->p2p = 0;
        }
        
        char size[5];
        fscanf(f, "%s\n", size); 
        
        char alloc_choice[13];
        fscanf(f, "%s\n", alloc_choice);

        if (!strcmp(alloc_choice, "preferred")){
            thread_info[t]->alloc_choice = CONTIG_ALLOC_PREFERRED;
        } else if (!strcmp(alloc_choice, "lloaded")){
            thread_info[t]->alloc_choice = CONTIG_ALLOC_LEAST_LOADED;
        } else if (!strcmp(alloc_choice, "balanced")){  
            thread_info[t]->alloc_choice = CONTIG_ALLOC_BALANCED;
        }

        size_t in_size;  
        in_size = size_to_bytes(size); 

        size_t memsz = in_size; 
        unsigned int offset = 0; 

        char pattern[10];
        char coh_choice[7];
        int prev_devid = 0;
        for (int d = 0; d < thread_info[t]->ndev; d++){
            fscanf(f, "%d", &(thread_info[t]->chain[d])); 
            
            //esp accelerator parameters
            int devid = thread_info[t]->chain[d];
            (*cfg)[t][d].run = true;
            (*cfg)[t][d].devname = devnames[devid];
            (*cfg)[t][d].ioctl_req = SYNTH_STRATUS_IOC_ACCESS;
            (*cfg)[t][d].esp_desc = &((*synth_cfg)[t][d].esp);
            
            (*synth_cfg)[t][d].src_offset = 0;
            (*synth_cfg)[t][d].dst_offset = 0;
            
            if (thread_info[t]->p2p && d != thread_info[t]->ndev - 1){
                (*synth_cfg)[t][d].esp.p2p_store = 1;
            } else {
                (*synth_cfg)[t][d].esp.p2p_store = 0;
            }

            if (thread_info[t]->p2p && d != 0){
                (*synth_cfg)[t][d].esp.p2p_nsrcs = 1;
                strcpy((*synth_cfg)[t][d].esp.p2p_srcs[0], devnames[prev_devid]);
            } else {
                (*synth_cfg)[t][d].esp.p2p_nsrcs = 0;
            }
            
            //read parameters into esp_thread_info_t     
            fscanf(f, "%s", pattern); 
            if (!strncmp(pattern, "STREAMING", 9)){
                (*synth_cfg)[t][d].pattern = PATTERN_STREAMING;
            } else if (!strncmp(pattern, "STRIDED", 7)){
                (*synth_cfg)[t][d].pattern = PATTERN_STRIDED;
            } else if (!strncmp(pattern, "IRREGULAR", 9)){
                (*synth_cfg)[t][d].pattern = PATTERN_IRREGULAR;
            }
            fscanf(f, "%d %d %d %d %d %d %d %d %d %s", 
                &(*synth_cfg)[t][d].access_factor,
                &(*synth_cfg)[t][d].burst_len,
                &(*synth_cfg)[t][d].compute_bound_factor,
                &(*synth_cfg)[t][d].reuse_factor,
                &(*synth_cfg)[t][d].ld_st_ratio,
                &(*synth_cfg)[t][d].stride_len,
                &(*synth_cfg)[t][d].in_place,
                &(*synth_cfg)[t][d].wr_data,
                &(*synth_cfg)[t][d].rd_data,
                coh_choice);
            
            if ((*synth_cfg)[t][d].pattern == PATTERN_IRREGULAR)
                (*synth_cfg)[t][d].irregular_seed = rand() % IRREGULAR_SEED_MAX;
        
            //calculate output size, offset, and memsize
            (*synth_cfg)[t][d].in_size = in_size;  
            unsigned int out_size = (in_size >> (*synth_cfg)[t][d].access_factor) 
                / (*synth_cfg)[t][d].ld_st_ratio;
            (*synth_cfg)[t][d].out_size = out_size;        
            (*synth_cfg)[t][d].offset = offset; 
           
            if((*synth_cfg)[t][d].in_place == 0 && !thread_info[t]->p2p){
                memsz += out_size;
                offset += in_size;
            }

            if (thread_info[t]->p2p && d == thread_info[t]->ndev - 1){
                memsz += out_size;
                (*synth_cfg)[t][d].offset = (*synth_cfg)[t][0].in_size - in_size;
            }
           
            unsigned int footprint = in_size >> (*synth_cfg)[t][d].access_factor;

            if (!(*synth_cfg)[t][d].in_place && (!thread_info[t]->p2p || d == thread_info[t]->ndev - 1))
                footprint += out_size;
                    
            if (thread_info[t]->p2p){
                (*synth_cfg)[t][d].esp.coherence = ACC_COH_NONE;
            } 
            else if (coherence_mode == FIXED){
                (*synth_cfg)[t][d].esp.coherence = coherence;
            }
            else if (!strcmp(coh_choice, "none")){
                (*synth_cfg)[t][d].esp.coherence = ACC_COH_NONE;
            }
            else if (!strcmp(coh_choice, "llc")){
                (*synth_cfg)[t][d].esp.coherence = ACC_COH_LLC;
            }
            else if (!strcmp(coh_choice, "recall")){
                (*synth_cfg)[t][d].esp.coherence = ACC_COH_RECALL;
            }
            else if (!strcmp(coh_choice, "full")){
                (*synth_cfg)[t][d].esp.coherence = ACC_COH_FULL;
            }

            (*synth_cfg)[t][d].esp.footprint = footprint * 4; 
            (*synth_cfg)[t][d].esp.in_place = (*synth_cfg)[t][d].in_place; 
            (*synth_cfg)[t][d].esp.reuse_factor = (*synth_cfg)[t][d].reuse_factor;

            in_size = out_size; 
            prev_devid = devid;
        }
        thread_info[t]->memsz = memsz * 4;
    }
}

static void alloc_phase(accelerator_thread_info_t **thread_info, esp_thread_info_t ***cfg, struct synth_stratus_access ***synth_cfg, int nthreads, soc_config_t soc_config, int alloc_mode, enum alloc_effort alloc, uint32_t **buffers, int phase){
    int largest_thread = 0;
    size_t largest_sz = 0;
    int* ddr_node_cost = malloc(sizeof(int)*soc_config.nmem);
    int preferred_node_cost;
    int preferred_node[NTHREADS_MAX];
    //determine preferred controller for each thread 
    for (int t = 0; t < nthreads; t++){
        if (thread_info[t]->memsz > largest_sz){
            largest_sz = thread_info[t]->memsz;
            largest_thread = t;
        }
    
        for (int m = 0; m < soc_config.nmem; m++){
            ddr_node_cost[m] = 0;
        }

        for (int d = 0; d < thread_info[t]->ndev; d++){
            for (int m = 0; m < soc_config.nmem; m++){
                ddr_node_cost[m] += soc_config.ddr_hops[thread_info[t]->chain[d]*soc_config.nmem + m];
            }
        }

        preferred_node_cost = ddr_node_cost[0];
        preferred_node[t] = 0;
        for (int m = 1; m < soc_config.nmem; m++){
            if (ddr_node_cost[m] < preferred_node_cost){
                preferred_node_cost = ddr_node_cost[m];
                preferred_node[t] = m;
            }
        }
    }
    
    //set policy
    for (int i = 0; i < nthreads; i++){
        struct contig_alloc_params params; 

        if (alloc_mode == CFG){
            params.policy = thread_info[i]->alloc_choice;
        } 
        else if (alloc_mode == FIXED){
            params.policy = alloc;
            thread_info[i]->alloc_choice = alloc;
        }
        // AUTO
        else if (nthreads < 3){
            params.policy = CONTIG_ALLOC_BALANCED;
            thread_info[i]->alloc_choice = CONTIG_ALLOC_BALANCED;
            params.pol.balanced.threshold = 4;
            params.pol.balanced.cluster_size = 1;
        } else if (i == largest_thread){
            thread_info[i]->alloc_choice = CONTIG_ALLOC_PREFERRED;
            params.policy = CONTIG_ALLOC_PREFERRED;
            params.pol.first.ddr_node = preferred_node[largest_thread];
        } else {
            thread_info[i]->alloc_choice = CONTIG_ALLOC_LEAST_LOADED;
            params.policy = CONTIG_ALLOC_LEAST_LOADED;
            params.pol.lloaded.threshold = 4;
        }

        if (alloc_mode == CFG || alloc_mode == FIXED){
            if (params.policy == CONTIG_ALLOC_PREFERRED){
                params.pol.first.ddr_node = preferred_node[i]; 
            } else if (params.policy == CONTIG_ALLOC_BALANCED){
                params.pol.balanced.threshold = 4;
                params.pol.balanced.cluster_size = 1;
            } else if (params.policy == CONTIG_ALLOC_LEAST_LOADED){
                params.pol.lloaded.threshold = 4; 
            }
        }

        total_alloc += thread_info[i]->memsz;
        buffers[i] = (uint32_t *) esp_alloc_policy(params, thread_info[i]->memsz);  
        if (buffers[i] == NULL){
            die_errno("error: cannot allocate %zu contig bytes", thread_info[i]->memsz);   
        }

        for (int j = 0; j < (*synth_cfg)[i][0].in_size; j++){
            buffers[i][j] = (*synth_cfg)[i][0].rd_data;
        }

        for (int acc = 0; acc < thread_info[i]->ndev; acc++){
            (*cfg)[i][acc].hw_buf = (void*) buffers[i];
        }
    }
    free(ddr_node_cost);
}

static int validate_buffer(accelerator_thread_info_t *thread_info, struct synth_stratus_access **synth_cfg, uint32_t *buf){
    int errors = 0; 
    for (int i = 0; i < thread_info->ndev; i++){
        if (thread_info->p2p && i != thread_info->ndev - 1)
            continue;

        int t = thread_info->tid;
        int offset = synth_cfg[t][i].offset;
        int in_size = synth_cfg[t][i].in_size;
        int out_size = synth_cfg[t][i].out_size;
        int in_place = synth_cfg[t][i].in_place;
        int wr_data = synth_cfg[t][i].wr_data;
        int next_in_place;
        
        if (i != thread_info->ndev - 1){
           next_in_place = synth_cfg[t][i+1].in_place;
           if (next_in_place)
               continue;
        }

        if (!in_place && !thread_info->p2p)
            offset += in_size; 
        else if (thread_info->p2p)
            offset = synth_cfg[t][0].in_size;

        for (int j = offset; j < offset + out_size; j++){
            if (j == offset + out_size - 1 && buf[j] != wr_data){
                errors += buf[j];
                printf("%u read errors in thread %d device %d\n", buf[j], t, i);
            }
            else if (j != offset + out_size - 1 && buf[j] != wr_data){
                errors++;
            }
        }
    }
    return errors;
}

static void free_phase(accelerator_thread_info_t **thread_info, esp_thread_info_t **cfg, struct synth_stratus_access **synth_cfg, int nthreads){
    for (int i = 0; i < nthreads; i++){
        esp_free(cfg[i]->hw_buf); 
        free(thread_info[i]);
        free(cfg[i]);
        free(synth_cfg[i]);
    }
    free(synth_cfg);
    free(cfg);
}

static void dump_results(FILE* out_file, accelerator_thread_info_t **thread_info, esp_thread_info_t **cfg, struct synth_stratus_access **synth_cfg, soc_config_t *soc_config, int phase, int nthreads, char** argv, int test_no){
    int t, d;
    unsigned long long thread_ns;
    unsigned long long phase_size = 0;
    unsigned long long phase_ns = 0;
    int phase_adj = test_no * 40 + phase;
    for (t = 0; t < nthreads; t++){
        thread_ns = 0;
        for (d = 0; d < thread_info[t]->ndev; d++){
            thread_ns += cfg[t][d].hw_ns;
            phase_ns += cfg[t][d].hw_ns;
            fprintf(out_file,"%d-%d-%d,", phase_adj, t, d);
            fprintf(out_file,"%d,", thread_info[t]->chain[d]);
            if (synth_cfg[t][d].esp.coherence == ACC_COH_FULL)
                fprintf(out_file,"full,");
            else if (synth_cfg[t][d].esp.coherence == ACC_COH_LLC)
                fprintf(out_file,"llc,");
            else if (synth_cfg[t][d].esp.coherence == ACC_COH_RECALL)
                fprintf(out_file,"recall,");
            else if (synth_cfg[t][d].esp.coherence == ACC_COH_NONE)
                fprintf(out_file,"none,");
            else if (synth_cfg[t][d].esp.coherence == ACC_COH_AUTO)
                fprintf(out_file,"auto,");

            if (thread_info[t]->alloc_choice == CONTIG_ALLOC_BALANCED)
                fprintf(out_file,"balanced,");
            else if (thread_info[t]->alloc_choice == CONTIG_ALLOC_PREFERRED)
                fprintf(out_file,"preferred,");
            else if (thread_info[t]->alloc_choice == CONTIG_ALLOC_LEAST_LOADED)
                fprintf(out_file,"lloaded,");

            fprintf(out_file, "%d,", synth_cfg[t][d].esp.footprint); 

            fprintf(out_file,"%d,", synth_cfg[t][d].esp.ddr_node);
            fprintf(out_file,"%llu\n", cfg[t][d].hw_ns);
        }
        fprintf(out_file, "%d-%d,", phase_adj, t);
        fprintf(out_file, "%d,", thread_info[t]->ndev);
        fprintf(out_file, "%s,", argv[2]);
        if (thread_info[t]->alloc_choice == CONTIG_ALLOC_BALANCED)
            fprintf(out_file,"balanced,");
        else if (thread_info[t]->alloc_choice == CONTIG_ALLOC_PREFERRED)
            fprintf(out_file,"preferred,");
        else if (thread_info[t]->alloc_choice == CONTIG_ALLOC_LEAST_LOADED)
            fprintf(out_file,"lloaded,");
        
        fprintf(out_file, "%zu,", thread_info[t]->memsz);
        phase_size += thread_info[t]->memsz; 
        
        fprintf(out_file,"%d,", synth_cfg[t][0].esp.ddr_node);
        fprintf(out_file, "%llu\n", thread_ns);
    }
    fprintf(out_file, "%d,", phase_adj);
    fprintf(out_file, "%d,", nthreads);
    fprintf(out_file, "%s,", argv[2]);
    fprintf(out_file, "%s,", argv[3]);
    fprintf(out_file, "%llu,", phase_size);
    fprintf(out_file, ",");
    fprintf(out_file, "%llu\n", phase_ns);
}

int main (int argc, char** argv)
{
    srand(time(NULL));

    if (argc != 4){
        printf("Usage: ./synth.exe file coherence alloc\n");
    }
    //command line args
    FILE* f;
    f = fopen(argv[1], "r");

    int test_no = argv[1][9] - 48;

    char out_name[20];
    int len = strlen(strcpy(out_name, argv[1]));
    out_name[len-3] = 'c';
    out_name[len-2] = 's';
    out_name[len-1] = 'v';

    FILE* out_file;
    if (access(out_name, F_OK) != -1){
        out_file = fopen(out_name, "a");
    } else {
        out_file = fopen(out_name, "w");
        fprintf(out_file,  "Device/Thread/Phase name, devID/nacc/nthreads, coherence, allocation, footprint, DDR#, time\n");
    }
    
    enum accelerator_coherence coherence = ACC_COH_NONE; 
    enum alloc_effort alloc; 
    int coherence_mode, alloc_mode;
    
    if (!strcmp(argv[2], "none")){
        coherence_mode = FIXED;
        coherence = ACC_COH_NONE;
    }
    else if (!strcmp(argv[2], "llc")){
        coherence_mode = FIXED;
        coherence = ACC_COH_LLC;
    }
    else if (!strcmp(argv[2], "recall")){
        coherence_mode = FIXED;
        coherence = ACC_COH_RECALL;
    }
    else if (!strcmp(argv[2], "full")){
        coherence_mode = FIXED;
        coherence = ACC_COH_FULL;
    }
    else if (!strcmp(argv[2], "auto")){
        coherence_mode = FIXED;
        coherence = ACC_COH_AUTO;
    }
    else if (!strcmp(argv[2], "cfg")){
        coherence_mode = CFG;
    }
    else{
        printf("Valid coherence choices include none, llc, recall, full, auto, or cfg\n");
        return 1;
    }

    if (!strcmp(argv[3], "preferred")){
        alloc_mode = FIXED;
        alloc = CONTIG_ALLOC_PREFERRED;
    }
    else if (!strcmp(argv[3], "lloaded")){
        alloc_mode = FIXED;
        alloc = CONTIG_ALLOC_LEAST_LOADED;
    }
    else if (!strcmp(argv[3], "balanced")){
        alloc_mode = FIXED;
        alloc = CONTIG_ALLOC_BALANCED;
    }
    else if (!strcmp(argv[3], "auto")){
        alloc_mode = AUTO;
        alloc = ACC_COH_AUTO;
    }
    else if (!strcmp(argv[3], "cfg")){
        alloc_mode = CFG;
    }
    else{
        printf("Valid alloc choices include preferred, lloaded, balanced, auto, and cfg\n");
        return 1;
    }

    soc_config_t* soc_config = malloc(sizeof(soc_config_t)); 
    read_soc_config(f, soc_config);
    
    //get phases
    int nphases; 
    fscanf(f, "%d\n", &nphases); 
    dprintf("%d phases\n", nphases);
    
    struct timespec th_start;
    struct timespec th_end;
    unsigned long long hw_ns = 0, hw_ns_total = 0; 
    float hw_s = 0, hw_s_total = 0; 
    
    int nthreads;
    accelerator_thread_info_t *thread_info[NPHASES_MAX][NTHREADS_MAX];
    uint32_t *buffers[NTHREADS_MAX];
    esp_thread_info_t **cfg = NULL;
    struct synth_stratus_access **synth_cfg;
    unsigned *nacc = NULL;

    //loop over phases - config, alloc, spawn thread, validate, and free
    for (int p = 0; p < nphases; p++){
        config_threads(f, thread_info[p], &cfg, &synth_cfg, p, &nthreads, coherence_mode, coherence, &nacc); 
        alloc_phase(thread_info[p], &cfg, &synth_cfg, nthreads, *soc_config, alloc_mode, alloc, buffers, p); 
        
        gettime(&th_start);
        
        esp_run_parallel(cfg, nthreads, nacc);

        gettime(&th_end); 
        for (int t = 0; t < nthreads; t++){
            int errors = validate_buffer(thread_info[p][t], synth_cfg, buffers[t]);
            if (errors)
                printf("[FAIL] Thread %d.%d : %u errors\n", p, t, errors);
            else 
                printf("[PASS] Thread %d.%d\n", p, t);  
        }
        
        hw_ns = ts_subtract(&th_start, &th_end);
        hw_ns_total += hw_ns; 
        hw_s = (float) hw_ns / 1000000000;

        printf("PHASE.%d %.4f s\n", p, hw_s);
      
        dump_results(out_file, thread_info[p], cfg, synth_cfg, soc_config, p, nthreads, argv, test_no);

        free_phase(thread_info[p], cfg, synth_cfg, nthreads);
        free(nacc); 
    }
    hw_s_total = (float) hw_ns_total / 1000000000;
    printf("TOTAL %.4f s\n", hw_s_total); 
    
    free(soc_config->mem_y);
    free(soc_config->mem_x);
    free(soc_config->synth_y);
    free(soc_config->synth_x);
    free(soc_config->ddr_hops);
    free(soc_config);
    fclose(f);
    fclose(out_file); 
    return 0; 
}
