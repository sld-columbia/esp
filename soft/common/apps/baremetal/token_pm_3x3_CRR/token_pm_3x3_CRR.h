unsigned p_available;
const unsigned Pmax[N_ACC];
const unsigned Fmax[N_ACC];
const unsigned Fmin[N_ACC];
struct esp_device **dev_list = aligned_malloc(N_ACC*sizeof((struct *)esp_device));


void start_tile(struct esp_device espdevs[], unsigned i)
{
	if(Pmax[i]<p_available) {
		set_freq(&espdevs[i],Fmax[i]);
		p_available=p_available-Pmax[i];
	}
	else
	{
		set_freq(&espdevs[i],Fmin[i]);
	}
	write_config1(&espdevs[i],1,0,0,0);
	//Add to running list
}

void CRR_step_checkend(struct esp_device espdevs[], unsigned i)
{
	unsigned done_i=0;
	unsigned done_i_before=0;

 	for (i = 0; i < N_ACC; i++) {   
   			//if(i==1)

			//else if(i==2)
			
        	done_i = ioread32(i, STATUS_REG);
			done_i &= STATUS_MASK_DONE;
		
		if(done_i && !done_i_before) {
			write_config1(&espdevs[i], 0, 0, 0, 0);
			done_i_before=done_i;
			set_freq(&espdevs[i],Fmin[1]);
			p_available=p_available+Pmax[i];
    			#ifdef DEBUG
				printf("Finished F1\n");
    			#endif
		}
	}
}


