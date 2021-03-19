#include "gemm_pvt.hpp"
#include "conv_pvt.hpp"
#include "validate.hpp"

void run_pv(mojo::network* cnn,int prev_soft,int layer,float*in_hw,float*out,bool fully_connected)
{

	if (fully_connected==true)
	{
		gemm_pvt(layer,prev_soft,cnn->layer_sets[layer-1]->node.x,in_hw,out,
		 cnn->W[layer-1]->x,cnn->layer_sets[layer]->bias.x,cnn->layer_sets[layer]->relu,
		 cnn->W[layer-1]->rows, cnn->W[layer-1]->cols, cnn->W[layer-1]->get_size());
	        
		validate_gemm(layer,out,cnn->layer_sets[layer]->node.x,cnn->W[layer-1]->rows);
	} 
	

	else
	{
		conv_pvt(layer,prev_soft,cnn->layer_sets[layer-1]->node.x,in_hw,out,
			 cnn->W[layer-1]->x,cnn->layer_sets[layer]->bias.x,cnn->layer_sets[layer-1]->node.chans,
			 cnn->layer_sets[layer]->node.chans,cnn->layer_sets[layer-1]->node.cols,
			 cnn->layer_sets[layer-1]->node.rows,cnn->layer_sets[layer]->node.cols,
			 cnn->layer_sets[layer]->node.rows,1,1,cnn->layer_sets[layer]->do_pad,
			 cnn->layer_sets[layer]->do_pad,cnn->W[layer-1]->get_size(),
			 cnn->W[layer-1]->cols,cnn->W[layer-1]->rows,1,1,1,1,1,cnn->layer_sets[layer]->do_pool,
			 cnn->layer_sets[layer-1]->do_pool);

		validate_conv(layer,out,cnn->layer_sets[layer]->node.x,cnn->layer_sets[layer]->node.rows,
			      cnn->layer_sets[layer]->node.cols,cnn->layer_sets[layer]->do_pad,cnn->layer_sets[layer]->node.chans,
			      cnn->layer_sets[layer]->do_pool,cnn->layer_sets[layer]->node.get_size()); 
	}
}
