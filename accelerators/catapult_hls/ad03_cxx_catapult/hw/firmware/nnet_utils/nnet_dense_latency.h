//
//    rfnoc-hls-neuralnet: Vivado HLS code for neural-net building blocks
//
//    Copyright (C) 2017 EJ Kreinar
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#ifndef NNET_DENSE_LATENCY_H_
#define NNET_DENSE_LATENCY_H_

#include "nnet_common.h"
#include "nnet_mult.h"
#include "nnet_helpers.h"
#include <ac_channel.h>
#include <ac_float.h>
#include <math.h>

namespace nnet {

template<class data_T, class res_T, typename CONFIG_T>
void dense_latency(
    data_T    data[CONFIG_T::n_in],
    res_T     res[CONFIG_T::n_out],
    typename CONFIG_T::weight_t  weights[CONFIG_T::n_in*CONFIG_T::n_out],
    typename CONFIG_T::bias_t    biases[CONFIG_T::n_out])
{
    data_T cache;
    typename CONFIG_T::accum_t mult[CONFIG_T::n_in*CONFIG_T::n_out];
    typename CONFIG_T::accum_t acc[CONFIG_T::n_out];

    // Use a function_instantiate in case it helps to explicitly optimize unchanging weights/biases

    if (CONFIG_T::io_type == io_parallel || CONFIG_T::io_type == io_stream){
        // For parallel inputs:
        //   - completely partition arrays -- target fabric
        //   - if we have an unroll factor, limit number of multipliers


        int multiplier_limit  = (int)DIV_ROUNDUP(float(CONFIG_T::n_in*CONFIG_T::n_out) , float(CONFIG_T::reuse_factor)) - (int)(float(CONFIG_T::n_zeros) / float(CONFIG_T::reuse_factor));
	CONFIG_T::template product<data_T, typename CONFIG_T::weight_t, typename CONFIG_T::accum_t>::limit(multiplier_limit);
    } else if (CONFIG_T::io_type == io_serial){
        // Only reduce cycle_factor if n_out is evenly divisible by reuse_factor
        // Otherwise, HLS wont be happy
        int cycle_factor = CONFIG_T::n_out / CONFIG_T::reuse_factor;
        int reused_cycle = DIV_ROUNDUP(CONFIG_T::n_out, CONFIG_T::reuse_factor);
        if (cycle_factor != reused_cycle) {
            cycle_factor = CONFIG_T::n_out;
        }
        /*int cycle_factor = CONFIG_T::n_out;
        float reused_cycle = CONFIG_T::n_out / CONFIG_T::reuse_factor;
        if (reused_cycle == ceil(reused_cycle)){
            // Dont use "ceil" here; as of 2018.2, HLS crashes mysteriously
            cycle_factor = cycle_factor / CONFIG_T::reuse_factor;
        }*/
        if (CONFIG_T::store_weights_in_bram){
        }
    }

    // Do the matrix-multiply
    Product1: for(unsigned ii = 0; ii < CONFIG_T::n_in; ii++) {
        if (CONFIG_T::io_type == io_serial){
        }
        cache = data[ii];
        Product2: for(unsigned jj = 0; jj < CONFIG_T::n_out; jj++) {
            if (CONFIG_T::io_type == io_serial) {
                int multiplier_limit  = DIV_ROUNDUP(float(CONFIG_T::n_out) , float(CONFIG_T::reuse_factor));
                CONFIG_T::template product<data_T, typename CONFIG_T::weight_t, typename CONFIG_T::accum_t>::limit(multiplier_limit);
            }
        int index = ii*CONFIG_T::n_out+jj;
        mult[index] = CONFIG_T::template product<data_T, typename CONFIG_T::weight_t, typename CONFIG_T::accum_t>::product(cache, weights[index]);
        }
    }

    // Initialize accumulator with input biases
    ResetAccum: for(unsigned iacc = 0; iacc < CONFIG_T::n_out; iacc++) {
        if (CONFIG_T::io_type == io_serial){
        }
        acc[iacc] = (typename CONFIG_T::accum_t) biases[iacc];
    }

    // Accumulate multiplication result
    Accum1: for(unsigned ii = 0; ii < CONFIG_T::n_in; ii++) {
        if (CONFIG_T::io_type == io_serial){
        }
        Accum2: for(unsigned jj = 0; jj < CONFIG_T::n_out; jj++) {
        int index = ii*CONFIG_T::n_out+jj;
        acc[jj] += mult[index];
        }
    }

    // Cast to "res_t" type
    Result: for(unsigned ires = 0; ires < CONFIG_T::n_out; ires++){
        if (CONFIG_T::io_type == io_serial){
        }
        //res[ires] = (res_T) (acc[ires]);
        res[ires] = cast<data_T, res_T, CONFIG_T>(acc[ires]);
    }
}

}

#endif
