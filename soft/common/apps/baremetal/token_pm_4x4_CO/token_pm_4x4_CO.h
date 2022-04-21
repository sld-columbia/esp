#include "token_pm_4x4_SW_data.h"
#include "token_pm_gemm.h"
#include "token_pm_nv.h"
#include "token_pm_conv2d.h"


//struct esp_device **dev_list = aligned_malloc(N_ACC*sizeof((struct *)esp_device));
struct esp_device *dev_list_acc[N_ACC];
struct esp_device espdevs[N_ACC];
unsigned activity[N_ACC];
unsigned sum_max = 0;
unsigned done[N_ACC];
unsigned done_before[N_ACC];


float get_max_index(float array[], unsigned max_flag[])
{
	float mx = 0; 
	int mx_index=0;
	int i;
	for (i = 0; i < N_ACC; i++)
	{
		if (array[i]*max_flag[i]*1.0 >= mx)
		{
			mx = array[i]*max_flag[i];
			mx_index = i;
		}
	}
	return mx_index;
}

unsigned* set_tokens(unsigned sum_max, unsigned tile_id)
{
	int k,j;
	static unsigned freq[N_ACC];
	float token_has_float[N_ACC];
	float token_has_float_sorted[N_ACC];
	unsigned token_has_int[N_ACC];
	unsigned remaining_tokens = total_tokens;
	unsigned max_index;
	unsigned max_flag[N_ACC];	//Indicates which elements have been selected as max

	if (sum_max>0)
	{
		for (k=0; k<N_ACC; k++)
		{
			token_has_float[k] = (total_tokens * max_tokens[k] * activity[k]*1.0)/(1.0*sum_max); //Still need to think about rounding here...
			token_has_int[k] = (int)(token_has_float[k]);
			remaining_tokens -= token_has_int[k];

			//token_has_float_sorted=sort(index,((token_has_float)-floor(token_has_float)))
			token_has_float_sorted[k] = token_has_float[k]-token_has_int[k]; // Needs to be sorted
			max_flag[k] = 1;	//Initialize all acc flags to 1 
			//printf("Initial Index: %d, token: %f, diff: %f\n", k, token_has_float[k], token_has_float_sorted[k]);
			//printf("End Initial Index: %d, Rem tokens: %d, token: %f, diff: %f\n", k, remaining_tokens, token_has_float[k], token_has_float_sorted[k]);
		}
		//printf("Remaining tokens: %d\n", remaining_tokens);
		for (j=0; j<N_ACC; j++)
		{
			if(remaining_tokens > 0)
			{
				max_index = get_max_index(token_has_float_sorted, max_flag);
				if (activity[max_index])
				{
					token_has_int[max_index] += 1;
					remaining_tokens -= 1;
					max_flag[max_index] = 0;	//deselect acc with max index
				}
				else
				{
					//token_has_float_sorted[max_index] = 0;
					max_flag[max_index] = 0;	//deselect acc with max index when activity is 0
				}

				//printf("Pass2 Index: %d, token float: %f,  token: %d, Max flag: %d, activity: %d\n", max_index, token_has_float[max_index], token_has_int[max_index],max_flag[max_index],activity[max_index]);
			}
		}
		//printf("Remaining tokens: %d\n", remaining_tokens);
		for (j=0; j<N_ACC; j++)
		{
			freq[j] = LUT_DATA[j][token_has_int[j]];
			//printf("FINAL Index: %d TOKENS: %d, freq: 0x%x, active: %d\n", j, token_has_int[j], freq[j], activity[j]); 
		}
		//set_freq(&espdevs[tile_id],freq);
		//write_config1(&espdevs[i],1,0,0,0);
		//Add to running list
	}
	else
	{
		for (j=0;j<N_ACC;j++)	freq[j]=0xb;
	}
	return freq;
}

void init_params()
{
	int i;
	for (i=0;i<N_ACC;i++)
	{
		dev_list_acc[i]=aligned_malloc(sizeof(struct esp_device));
		activity[i] = 0;
		done[i]=0;
		done_before[i]=0;
	}
}


void start_tile(struct esp_device espdevs[], unsigned tile_id)
{
	int i;
	activity[tile_id] = 1;
	sum_max += max_tokens[tile_id];
	write_config1(&espdevs[tile_id],1,0,0,0);
	//freq = LUT_DATA[tile_id][token_has_int[tile_id]];
	unsigned *freq = set_tokens(sum_max, tile_id);
	for (i=0; i<N_ACC; i++)
		set_freq(&espdevs[i],freq[i]);
	//printf("Tile %d addr: 0x%x, frequency is 0x%x\n",tile_id, espdevs[tile_id].addr, freq[tile_id]);
	//Add to running list
	
}


unsigned CO_step_checkend(unsigned tile_id)
{
	done[tile_id] = ioread32(dev_list_acc[tile_id], STATUS_REG);
	done[tile_id] &= STATUS_MASK_DONE;
	
	if(done[tile_id] && !done_before[tile_id]) 
	{
		write_config1(&espdevs[tile_id],0,0,0,0);
		done_before[tile_id]=done[tile_id];
		//set_freq(&espdevs[i],Fmin[i]);
		//p_available=p_available+Pmax[i];
		return 1;
	}
	else
	{
		return 0;
	}
}



void end_tile(struct esp_device espdevs[], unsigned tile_id)
{
	int i;
	activity[tile_id] = 0;
	sum_max -= max_tokens[tile_id];
	unsigned *freq = set_tokens(sum_max, tile_id);
	for (i=0; i<N_ACC; i++)
		set_freq(&espdevs[i],freq[i]);
	//write_config1(&espdevs[i],1,0,0,0);
	//Add to running list
}

