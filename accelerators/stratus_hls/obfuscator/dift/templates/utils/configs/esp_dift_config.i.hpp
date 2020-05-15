/* Copyright 2018 Columbia University, SLD Group */

// -- Functions

template < size_t _DMA_WIDTH_ >
inline void esp_dift_config::bind_with(esp_dift_wrapper<_DMA_WIDTH_> &wrap)
{
    this->clk(wrap.clk);
    this->rst(wrap.rst);
    this->conf_done(wrap.conf_done);
    this->conf_info(wrap.conf_info);
    this->acc_conf_done(sig_conf_done);
    this->acc_conf_info(sig_conf_info);
}

