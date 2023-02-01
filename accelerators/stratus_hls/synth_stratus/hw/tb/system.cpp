// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <sstream>
#include "system.hpp"

#define NACC_RUN 2

#ifdef COLLECT_LATENCY
//
void system_t::report_latency()
{
    bool load_exec = false;
    bool compute_exec = false;
    bool store_exec = false;
    
    {
    load.reset();
    store.reset();
    compute.reset();
    wait();
    }
    
    while (!conf_done.read()) wait();    
    int acc_id = acc_num.read();

    std::stringstream fname;
    fname << "latency_BURSTLEN" << configs[acc_id].burst_len << "_CBFACTOR" << configs[acc_id].compute_bound_factor << ".dat";

    std::ofstream fout; 
    fout.open(fname.str().c_str());
    do {
        if (load.nb_can_get()){
            load.nb_get(load_exec);    
        }
        if (compute.nb_can_get()){
            compute.nb_get(compute_exec);    
        }
        if (store.nb_can_get()){
            store.nb_get(store_exec);    
        }
        fout << load_exec << ",";
        fout << compute_exec << ",";
        fout << store_exec << "\n";
        wait();
    } while(!acc_done.read());
    fout.close();

    while(true) wait();
}
#endif

// Process
void system_t::config_proc()
{

    // Reset
    {
	conf_done.write(false);
	conf_info.write(conf_info_t());
	wait();
    }

    ESP_REPORT_INFO("reset done");

    init_acc_params();

    for (int acc_id = 0; acc_id < NACC_RUN; acc_id++) {
    load_memory_acc_id(acc_id);
	send_config(acc_id);

        // Compute
	{
	    // Print information about begin time
	    sc_time begin_time = sc_time_stamp();
	    ESP_REPORT_TIME(begin_time, "BEGIN - synth");

	    // Wait the termination of the accelerator
	    do { wait(); } while (!acc_done.read());
	    debug_info_t debug_code = debug.read();
	    
        // Print information about end time
	    sc_time end_time = sc_time_stamp();
	    ESP_REPORT_TIME(end_time, "END - synth");

	    esc_log_latency(sc_object::basename(), clock_cycle(end_time - begin_time));
	    wait(); conf_done.write(false);
	}

	// Validate
	{
	    dump_memory_acc_id(acc_id); // store the output in more suitable data structure if needed
	    // check the results with the golden model
	    int errors = validate_acc_id(acc_id);
        if (errors)
	    {
		ESP_REPORT_ERROR("validation for acc_id %d failed with %d errors!", acc_id, errors);
	    } else
	    {
		ESP_REPORT_INFO("validation passed for acc_id %d!", acc_id);
	    }
	}
    }

    // Conclude
    {
	sc_stop();
    }
}

// Functions
void system_t::init_acc_params()
{
    //            in    out   af  bl cb rf ip  p  is lsr sl  o       wd          rd
conf_info_t conf0(2048, 1024, 0, 4, 1, 4, 0, 1, 0, 2, 32, 0, 0x01234567, 0x89abcdef);
configs[0] = conf0;
conf_info_t conf1(65536, 65536, 0, 4, 16, 4, 1, 1, 0, 1, 256, 0, 0x01234567, 0x89abcdef);
configs[1] = conf1;
conf_info_t conf2(4096, 1024, 0, 16, 2, 1, 1, 0, 0, 4, 32, 0, 0x01234567, 0x89abcdef);
configs[2] = conf2;
conf_info_t conf3(4096, 2048, 0, 4, 2, 1, 0, 2, 0, 2, 4, 0, 0x01234567, 0x89abcdef);
configs[3] = conf3;
conf_info_t conf4(4096, 1024, 0, 512, 1, 1, 0, 2, 0, 4, 32, 0, 0x01234567, 0x89abcdef);
configs[4] = conf4;
conf_info_t conf5(4096, 4096, 0, 256, 128, 4, 1, 0, 0, 1, 4, 0, 0x01234567, 0x89abcdef);
configs[5] = conf5;
conf_info_t conf6(4096, 1024, 0, 64, 8, 1, 0, 2, 0, 4, 512, 0, 0x01234567, 0x89abcdef);
configs[6] = conf6;
conf_info_t conf7(4096, 1024, 0, 256, 32, 1, 0, 2, 0, 4, 4, 0, 0x01234567, 0x89abcdef);
configs[7] = conf7;
conf_info_t conf8(4096, 2048, 0, 32, 64, 1, 0, 1, 0, 2, 4, 0, 0x01234567, 0x89abcdef);
configs[8] = conf8;
conf_info_t conf9(4096, 4096, 0, 4, 2, 1, 0, 0, 0, 1, 256, 0, 0x01234567, 0x89abcdef);
configs[9] = conf9;
conf_info_t conf10(4096, 2048, 0, 256, 32, 1, 0, 1, 0, 2, 32, 0, 0x01234567, 0x89abcdef);
configs[10] = conf10;
conf_info_t conf11(4096, 2048, 0, 4, 32, 1, 1, 1, 0, 2, 512, 0, 0x01234567, 0x89abcdef);
configs[11] = conf11;
conf_info_t conf12(4096, 1024, 0, 256, 2, 1, 1, 0, 0, 4, 4, 0, 0x01234567, 0x89abcdef);
configs[12] = conf12;
}

void system_t::load_memory(){

}

void system_t::load_memory_acc_id(int acc_id)
{
    for (int i = 0; i < configs[acc_id].in_size; i++)
    {
        mem[i] = configs[acc_id].rd_data;
    }
}


void system_t::send_config(int acc_id)
{
    conf_info_t config;
    // Custom configuration
    wait();
    conf_info.write(configs[acc_id]);
    acc_num.write(acc_id);
    conf_done.write(true);
    ESP_REPORT_INFO("config done");
}

void system_t::dump_memory_acc_id(int acc_id)
{
    // Get results from memory
    wait(configs[acc_id].in_size + configs[acc_id].out_size);
    ESP_REPORT_INFO("dump memory completed");
}

void system_t::dump_memory()
{
    // Get results from memory
    ESP_REPORT_INFO("dump memory completed");
}

int system_t::validate(){

}

int system_t::validate_acc_id(int acc_id)
{
    uint32_t errors = 0;
    uint32_t offset = 0;
    // Check for mismatches

    if (!configs[acc_id].in_place)
        offset = configs[acc_id].in_size;
  
    for (int j = 0; j < configs[acc_id].out_size; j++){
        int index = offset + j;
        if (j == configs[acc_id].out_size - 1 && mem[index] != configs[acc_id].wr_data){
            ESP_REPORT_INFO("Read errors on %x values\n", mem[index].to_uint());
            errors += mem[index].to_uint();
        }
        else if (j != configs[acc_id].out_size - 1 && mem[index] != configs[acc_id].wr_data){
            //ESP_REPORT_INFO("Write error at %d with value %d\n", index, mem[index].to_uint());
            errors += 1;
        }
    }

    return errors;
}
