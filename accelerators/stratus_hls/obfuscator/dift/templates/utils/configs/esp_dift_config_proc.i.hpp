/* Copyright 2018 Columbia University, SLD Group */

// -- Processes

inline void esp_dift_config_proc::config_wrapper()
{
    conf_info_t conf;

    HLS_DEFINE_PROTOCOL("config");

    // -- Begin the configuration

    conf_valid.write(true);
    done.write(false);
    wait();

    // -- Wait for the configuration

    bool end = false;

    do
    {
        HLS_UNROLL_LOOP(OFF);
        end = conf_done.read();
        wait();

    } while (!end);

    // -- The configuration is here

    this->done.write(true);

    conf = conf_info.read();

    // -- Verify the configuration

    acc_conf_info.write(conf);
    this->src_tag.write(0);
    this->dst_tag.write(0);
    this->tag_off.write(0);
    acc_conf_done.write(true);
    conf_valid.write(true);

    // -- The configuration is done

    while (true)
    {
        HLS_UNROLL_LOOP(OFF);

        wait();
    }
}

// -- Functions

inline void esp_dift_config_proc::wait_for_config()
{
    // NOTE: supposed to be called from a protocol region

    while (!done.read())
    {
        HLS_UNROLL_LOOP(OFF);

        wait();
    }
}
