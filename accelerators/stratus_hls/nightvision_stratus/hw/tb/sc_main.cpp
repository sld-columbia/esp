// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "system.hpp"

#define RESET_PERIOD (30 * CLOCK_PERIOD)

system_t *testbench = NULL;

// Default settings if argv[] is not set

// std::string image_A_path    = "../../data/lena-18x28.txt";
// std::string image_out_path  = "../../data/out-18x28.txt";
// std::string image_gold_path = "../../data/gold-18x28.txt";
// uint32_t    n_Images        = 1;
// uint32_t    n_Rows          = 18;
// uint32_t    n_Cols          = 28;
// bool        do_validation   = true;
// bool        do_dwt          = true;

// std::string image_A_path    = "../../data/lena-30x40.txt";
// std::string image_out_path  = "../../data/out-30x40.txt";
// std::string image_gold_path = "../../data/gold-30x40.txt";
// uint32_t    n_Images        = 1;
// uint32_t    n_Rows          = 30;
// uint32_t    n_Cols          = 40;
// bool        do_validation   = true;
// bool        do_dwt          = true;

// std::string image_A_path    = "../../data/svhn_0_32x32.txt";
// std::string image_out_path  = "../../data/svhn_0_out_32x32.txt";
// std::string image_gold_path = "../../data/svhn_0_gold_32x32.txt";
// uint32_t    n_Images        = 1;
// uint32_t    n_Rows          = 32;
// uint32_t    n_Cols          = 32;
// bool        do_validation   = true;
// bool        do_dwt          = false;

// std::string image_A_path    = "../../data/lena-120x160.txt";
// std::string image_out_path  = "../../data/out-120x160.txt";
// std::string image_gold_path = "../../data/gold-120x160.txt";
// uint32_t    n_Images        = 1;
// uint32_t    n_Rows          = 120;
// uint32_t    n_Cols          = 160;
// bool        do_validation   = true;
// bool        do_dwt          = true;

std::string image_A_path    = "../../data/lena-480x640.txt";
std::string image_out_path  = "../../data/out-480x640.txt";
std::string image_gold_path = "../../data/gold-480x640.txt";
uint32_t    n_Images        = 1;
uint32_t    n_Rows          = 480;
uint32_t    n_Cols          = 640;
bool        do_validation   = true;
bool        do_dwt          = true;

extern void esc_elaborate()
{
    // Creating the whole system
    testbench = new system_t("testbench", image_A_path, image_out_path, n_Images, n_Rows, n_Cols, image_gold_path,
                             do_validation, do_dwt);
}

extern void esc_cleanup()
{
    // Deleting the system
    delete testbench;
}

int sc_main(int argc, char *argv[])
{
    // Kills a Warning when using SC_CTHREADS
    sc_report_handler::set_actions("/IEEE_Std_1666/deprecated", SC_DO_NOTHING);
    // Kills Warning from FlexChannels library: no unique name assignment
    sc_report_handler::set_actions(SC_WARNING, SC_DO_NOTHING);

    esc_initialize(argc, argv);

#ifndef CADENCE

    fprintf(stderr, "[INFO] argc: %d\n", argc);

    if (argc == 6 || argc == 7) {
        image_A_path   = argv[1];
        image_out_path = argv[2];
        n_Images       = std::atoi(argv[3]);
        n_Rows         = std::atoi(argv[4]);
        n_Cols         = std::atoi(argv[5]);

        if (argc == 7) {
            do_validation   = true;
            image_gold_path = argv[6];
        } else {
            do_validation = false;
        }

        do_dwt = false;

    } else {
        fprintf(stderr, "Wrong arguments.\n");
        fprintf(stderr, "Expected arguments: image_A_path (string), image_out_path (string),\n");
        fprintf(stderr, "n_Images, n_Rows, n_Cols, [optional: image_gold_path (string)].\n");
        fprintf(stderr, "EXECUTING THE DEFAULT!\n");
    }
#endif

    esc_elaborate();

    sc_clock        clk("clk", CLOCK_PERIOD, SC_PS);
    sc_signal<bool> rst("rst");

    testbench->clk(clk);
    testbench->rst(rst);

    rst.write(false);
    sc_start(RESET_PERIOD, SC_PS);
    rst.write(true);
    sc_start();

    esc_log_pass();
    esc_cleanup();

    return 0;
}
