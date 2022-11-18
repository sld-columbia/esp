#include "token_pm_3x3_Ccommon.h"
#include "token_pm_3x3_SW_data.h"
#include "token_pm_nvdla.h"
//#define DEBUG
unsigned p_available = P_TOTAL;

const unsigned Pmax[N_ACC] = {max_power_NVDLA,max_power_FFT,max_power_VIT,max_power_FFT,max_power_VIT,max_power_FFT};
const unsigned Fmax[N_ACC]= {lut_data_const_NVDLA[max_tokens_NVDLA],lut_data_const_FFT[max_tokens_FFT],lut_data_const_VIT[max_tokens_VIT],lut_data_const_FFT[max_tokens_FFT],lut_data_const_VIT[max_tokens_VIT],lut_data_const_FFT[max_tokens_FFT]};
const unsigned Fmin[N_ACC] = {lut_data_const_NVDLA[8],lut_data_const_FFT[0],lut_data_const_VIT[0],lut_data_const_FFT[0],lut_data_const_VIT[0],lut_data_const_FFT[0]};
const unsigned Pmin[N_ACC] = {min_power_NVDLA,min_power_FFT,min_power_VIT,min_power_FFT,min_power_VIT,min_power_FFT};

struct esp_device espdevs[N_ACC];
struct esp_device *dev_list_acc[N_ACC]; 
unsigned done[N_ACC];
unsigned done_before[N_ACC];
	

struct node
{
  int data;
  struct node *next;
};

struct node *head_run;
struct node *head_idle;
struct node *head_wait;



nvdla_token_t *mem_n1;
nvdla_token_t *gold_nvdla;
   
   
void addLast(struct node **head, int val)
{
	//From https://www.log2base2.com/data-structures/linked-list/inserting-a-node-at-the-end-of-a-linked-list.html
    //create a new node
    struct node *newNode = aligned_malloc(sizeof(struct node));
    newNode->data = val;
    newNode->next = NULL;

    //if head is NULL, it is an empty list
    if(*head == NULL)
         *head = newNode;
    //Otherwise, find the last node and add the newNode
    else
    {
        struct node *lastNode = *head;
        //last node's next address will be NULL.
        while(lastNode->next != NULL)
        {
            lastNode = lastNode->next;
        }

        //add the newNode at the end of the linked list
        lastNode->next = newNode;   
    }
}

int popFirst(struct node **head)
{
 int result;
 struct node *headNode = *head;

 if(*head == NULL)
 	return -1;
 else
 	{
	result=(headNode->data);
    *head = (headNode->next);
 	return (result);
	}
}


int removeFromList(struct node **head,int index)
{
    struct node *current_node = *head;
   	if ( current_node != NULL) {
       	if((current_node->data)==index){
    		//printf("Found!!\n");
        	*head=(current_node->next);
			return 1;
		}
		else {
			return(removeFromList(&(current_node->next),index));
			}
    }
	else {return 0;}
}

void start_tile( unsigned i)
{
	if(Pmax[i]<=p_available) {
		set_freq(&espdevs[i],Fmax[i]);
		p_available=p_available-Pmax[i];
		#ifdef DEBUG
			printf("Starting tile %u at Pmax new Pav %u\n",i,p_available);
		#endif

		addLast(&head_run,i);
		if(i>0){
			iowrite32(dev_list_acc[i], CMD_REG, CMD_MASK_START);
			//write_config1(&espdevs[i],1,0,0,0);
		}
		else{
			write_config1(&espdevs[0], 1, 0, 0, 0);
			run_nvdla( &espdevs[0], dev_list_acc[0], gold_nvdla, mem_n1, 0);
			write_config1(&espdevs[0], 0, 0, 0, 0);
			//set_freq(&espdevs[0],Fmin[0]);
			p_available=p_available+Pmin[0];
			removeFromList(&head_run,0);
		}
	}
	else if(Pmin[i]<=p_available) {
		set_freq(&espdevs[i],Fmin[i]);
		p_available=p_available-Pmin[i];
		#ifdef DEBUG
			printf("Starting tile %u at Pmin new Pav %u\n",i,p_available);
		#endif
		
		addLast(&head_idle,i);
		if(i>0) {
			iowrite32(dev_list_acc[i], CMD_REG, CMD_MASK_START);
			//write_config1(&espdevs[i],1,0,0,0);
		}
		else {
			write_config1(&espdevs[0],1,0,0,0);
			run_nvdla( &espdevs[0], dev_list_acc[0], gold_nvdla, mem_n1, 0);
			write_config1(&espdevs[0], 0, 0, 0, 0);
			p_available=p_available+Pmin[0];
			removeFromList(&head_idle,0);
		}	
	}
	else {
		set_freq(&espdevs[i],Fmin[i]);
		#ifdef DEBUG
			printf("Waiting tile %u at new Pav %u\n",i,p_available);
		#endif

		//set_freq(&espdevs[i],Fmin[i]);
		addLast(&head_wait,i);
	}
	
}

void CRR_step_checkend()
{
	int i;
	int i_run;
	int i_idl;

 	for (i = 1; i < N_ACC; i++) {  //Starting at 1 because of NVDLA
        	done[i] = ioread32(dev_list_acc[i], STATUS_REG);
			done[i] &= STATUS_MASK_DONE;
		
		if(done[i] && !done_before[i]) {
			//write_config1(&espdevs[i], 0, 0, 0, 0);
			done_before[i]=done[i];
			set_freq(&espdevs[i],Fmin[i]);
			i_run=removeFromList(&head_run,i);
			i_idl=removeFromList(&head_idle,i);
			if(i_run) {
				p_available=p_available+Pmax[i];}
			else if(i_idl) {
				p_available=p_available+Pmin[i];}	
			#ifdef DEBUG
				printf("Finished tile %u was in %u%u new Pav %u\n",i,i_run,i_idl, p_available);
			#endif

		}
	}
}

void CRR_step_rotate()
{
	int index_stop;
	if(head_run != NULL && ((head_idle != NULL) || (head_wait != NULL)  )){
		index_stop=popFirst(&head_run);
		addLast(&head_idle,index_stop);
		set_freq(&espdevs[index_stop],Fmin[index_stop]);
		p_available=p_available+Pmax[index_stop]-Pmin[index_stop];
		#ifdef DEBUG
			printf("Idling tile %u new Pav %u\n",index_stop,p_available);
		#endif

	}
    struct node *idleNode = head_idle;
    struct node *waitNode = head_wait;		
           while(waitNode!= NULL)
	   {
		   if(Pmax[waitNode->data]<=p_available){
			   set_freq(&espdevs[waitNode->data],Fmax[waitNode->data]);
			   if((waitNode->data)>0){
				   iowrite32(dev_list_acc[waitNode->data], CMD_REG, CMD_MASK_START);
			   }
			   else{
				   write_config1(&espdevs[0],1,0,0,0);
				   run_nvdla( &espdevs[0], dev_list_acc[0], gold_nvdla, mem_n1, 0);
				   write_config1(&espdevs[0],0,0,0,0);
			   }
			   removeFromList(&head_wait,waitNode->data);
			   addLast(&head_run,waitNode->data);
			   p_available=p_available-Pmax[waitNode->data];
			   #ifdef DEBUG
			   	printf("wait->run tile %u new Pav %u\n",waitNode->data,p_available);
			   #endif

		   }
		   else if(Pmin[waitNode->data]<=p_available){
			   set_freq(&espdevs[waitNode->data],Fmin[waitNode->data]);
			   if(waitNode->data>0){
				   iowrite32(dev_list_acc[waitNode->data], CMD_REG, CMD_MASK_START);
			   }
			   else{
				   write_config1(&espdevs[0],1,0,0,0);
				   run_nvdla( &espdevs[0], dev_list_acc[0], gold_nvdla, mem_n1, 0);
				   write_config1(&espdevs[0],0,0,0,0);
			   }
			   removeFromList(&head_wait,waitNode->data);
			   addLast(&head_idle,waitNode->data);
			   p_available=p_available-Pmin[waitNode->data];
			   #ifdef DEBUG
			   	printf("wait->idle tile %u new Pav %u\n",waitNode->data,p_available);
			   #endif
		   }
		   waitNode = waitNode->next;
	   }
		
		while(idleNode!= NULL)
        {
            if((Pmax[idleNode->data]-Pmin[idleNode->data])<=p_available){
				//set_freq(dev_list_acc[idleNode->data],Fmax[idleNode->data]);
				set_freq(&espdevs[idleNode->data],Fmax[idleNode->data]);
				// Moving from Idle queue to Run queue
				addLast(&head_run,idleNode->data);
				removeFromList(&head_idle,idleNode->data);
				p_available=p_available-Pmax[idleNode->data] + Pmin[idleNode->data];
				#ifdef DEBUG
					printf("Idle->run tile %u new Pav %u\n",idleNode->data,p_available);
				#endif
			}
		idleNode = idleNode->next;
        }

}
