#include "token_pm_4x4_Ccommon.h"
#include "token_pm_4x4_SW_data.h"

unsigned p_available = P_TOTAL;

const unsigned Pmax[N_ACC] = {max_power_GEMM,max_power_GEMM,max_power_GEMM,max_power_GEMM,max_power_NV,max_power_NV,max_power_NV,max_power_NV,max_power_CONV,max_power_CONV,max_power_CONV,max_power_NV,max_power_NV};
const unsigned Fmax[N_ACC]={lut_data_const_GEMM[max_tokens_GEMM],lut_data_const_GEMM[max_tokens_GEMM],lut_data_const_GEMM[max_tokens_GEMM],lut_data_const_GEMM[max_tokens_GEMM],lut_data_const_NV[max_tokens_NV],lut_data_const_NV[max_tokens_NV],lut_data_const_NV[max_tokens_NV],lut_data_const_NV[max_tokens_NV],lut_data_const_CONV[max_tokens_CONV],lut_data_const_CONV[max_tokens_CONV],lut_data_const_CONV[max_tokens_CONV],lut_data_const_NV[max_tokens_NV],lut_data_const_NV[max_tokens_NV]};
const unsigned Fmin[N_ACC] = {lut_data_const_GEMM[0],lut_data_const_GEMM[0],lut_data_const_GEMM[0],lut_data_const_GEMM[0],lut_data_const_NV[0],lut_data_const_NV[0],lut_data_const_NV[0],lut_data_const_NV[0],lut_data_const_CONV[0],lut_data_const_CONV[0],lut_data_const_CONV[0],lut_data_const_NV[0],lut_data_const_NV[0]};
const unsigned Pmin[N_ACC] = {min_power_GEMM,min_power_GEMM,min_power_GEMM,min_power_GEMM,min_power_NV,min_power_NV,min_power_NV,min_power_NV,min_power_CONV,min_power_CONV,min_power_CONV,min_power_NV,min_power_NV};

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
			removeFromList(&(current_node->next),index);
			}
    }
	else {return 0;}
}

void start_tile( unsigned i)
{
	if(Pmax[i]<=p_available) {
		set_freq(&espdevs[i],Fmax[i]);
		p_available=p_available-Pmax[i];
		printf("Starting tile %u at Pmax new Pav %u\n",i,p_available);
		addLast(&head_run,i);
		iowrite32(dev_list_acc[i], CMD_REG, CMD_MASK_START);
		write_config1(&espdevs[i],1,0,0,0);
	}
	else if(Pmin[i]<=p_available) {
		set_freq(&espdevs[i],Fmin[i]);
		p_available=p_available-Pmin[i];
		printf("Starting tile %u at Pmin new Pav %u\n",i,p_available);
		addLast(&head_idle,i);
		iowrite32(dev_list_acc[i], CMD_REG, CMD_MASK_START);
		write_config1(&espdevs[i],1,0,0,0);
		}
	else {
		set_freq(&espdevs[i],Fmin[i]);
		printf("Waiting tile %u at new Pav %u\n",i,p_available);
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
			write_config1(&espdevs[i], 0, 0, 0, 0);
			done_before[i]=done[i];
			set_freq(&espdevs[i],Fmin[i]);
			i_run=removeFromList(&head_run,i);
			i_idl=removeFromList(&head_idle,i);
			if(i_run) {
			p_available=p_available+Pmax[i];}
			else if(i_idl) {
			p_available=p_available+Pmin[i];}			
			printf("Finished tile %u was in %u%u new Pav %u\n",i,i_run,i_idl, p_available);
		}
	}
}

void CRR_step_rotate()
{
	int index_stop=popFirst(&head_run);
	addLast(&head_idle,index_stop);
	set_freq(&espdevs[index_stop],Fmin[index_stop]);
	p_available=p_available+Pmax[index_stop]-Pmin[index_stop];
	printf("Idling tile %u new Pav %u\n",index_stop,p_available);

    struct node *idleNode = head_idle;
    struct node *waitNode = head_wait;	
	
           while(waitNode->next != NULL)
        {
            if(Pmax[waitNode->data]<=p_available){
				set_freq(dev_list_acc[waitNode->data],Fmax[waitNode->data]);
				iowrite32(dev_list_acc[waitNode->data], CMD_REG, CMD_MASK_START);
				write_config1(&espdevs[waitNode->data],1,0,0,0);
				addLast(&head_run,waitNode->data);
				removeFromList(&head_wait,waitNode->data);
				p_available=p_available-Pmax[waitNode->data];
				printf("wait->run tile %u new Pav %u\n",waitNode->data,p_available);
			}
			else if(Pmin[waitNode->data]<=p_available){
				iowrite32(dev_list_acc[waitNode->data], CMD_REG, CMD_MASK_START);
				write_config1(&espdevs[waitNode->data],1,0,0,0);
				addLast(&head_idle,waitNode->data);
				removeFromList(&head_wait,waitNode->data);
				p_available=p_available-Pmin[waitNode->data];
				printf("wait->idle tile %u new Pav %u\n",waitNode->data,p_available);
			}
		waitNode = waitNode->next;
        }
		
		while(idleNode->next != NULL)
        {
            if(Pmax[idleNode->data]<=p_available){
				set_freq(dev_list_acc[idleNode->data],Fmax[idleNode->data]);
				addLast(&head_run,idleNode->data);
				removeFromList(&head_idle,idleNode->data);
				p_available=p_available-Pmax[idleNode->data];
				printf("Idle->run tile %u new Pav %u\n",idleNode->data,p_available);
			}
		idleNode = idleNode->next;
        }
}

