#include "token_pm_3x3_SW_data.h"
//#define DEBUG
//struct esp_device **dev_list = aligned_malloc(N_ACC*sizeof((struct *)esp_device));
//struct esp_device *dev_list[N_ACC];
unsigned activity[N_ACC];
unsigned sum_max = 0;

struct node
{
  int data;
  struct node *next;
};

struct node *head_run;
struct node *head_idle;
struct node *head_wait;


int tile_complete[]={0,0,0,0,0,0};   
int acc_iter[]={0,0,0,0,0,0};   


void addLast(struct node **head, int val)
{
	//From https://www.log2base2.com/data-structures/linked-list/inserting-a-node-at-the-end-of-a-linked-list.html
    //create a new node
    struct node *newNode = malloc(sizeof(struct node));
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

int check_list(struct node **head,int index)
{
    struct node *current_node = *head;
    struct node *head_next;
   	if ( current_node != NULL) {
	       	if((current_node->data)==index){
			#ifdef DEBUG
				printf("Checking: Found Acc : %d!!\n", index);
			#endif
			//*head=(current_node->next);
			//free(current_node);
			return 1;
		}
		else {
			return check_list(&(current_node->next),index);
			//removeFromList(&(head_next),index);
			//return 0;
		}
    	}
	else {
		//printf("Head node is null\n");
		return 0;
	}
}

int removeFromList(struct node **head,int index)
{
    struct node *current_node = *head;
    struct node *head_next;
   	if ( current_node != NULL) {
	       	if((current_node->data)==index){
			#ifdef DEBUG
				printf("Found Acc : %d!!\n", index);
			#endif
			*head=(current_node->next);
			//free(current_node);
			return 1;
		}
		else {
			return removeFromList(&(current_node->next),index);
			//removeFromList(&(head_next),index);
			//return 0;
		}
    	}
	else {
		//printf("Head node is null\n");
		return 0;
	}
}

void start_tile( unsigned i)
{
	if(Pmax[i]<=p_available) {
		p_available=p_available-Pmax[i];
		#ifdef DEBUG
			printf("Starting tile %u at Pmax: %u... new Pav %u\n",i,Pmax[i],p_available);
		#endif

		addLast(&head_run,i);
		}
	else if(Pmin[i]<=p_available) {
		p_available=p_available-Pmin[i];
		#ifdef DEBUG
			printf("Starting tile %u at Pmin: %u... new Pav %u\n",i,Pmin[i],p_available);
		#endif
		
		addLast(&head_idle,i);
		}
	else {
		#ifdef DEBUG
			printf("Waiting tile %u at new Pav %u\n",i,p_available);
		#endif

		addLast(&head_wait,i);
	}
	
}

void CRR_step_checkend()
{
	int i,pret;
	int i_run=0;
	int i_idl=0;
	int state_run;
	int state_idle;
 	for (i = 0; i < N_ACC; i++) {  
		state_run = check_list(&head_run,i);
		state_idle = check_list(&head_idle,i);
		
		if (state_run == 1 ) 
		{
			acc_iter[i]+=2;
			#ifdef DEBUG
				printf("Accelerator %u found in run queue, runtime: %u\n",i, acc_iter[i]);
			#endif
		}
		else if (state_idle == 1  ) 
		{
			acc_iter[i]+=1;
			#ifdef DEBUG
				printf("Accelerator %u found in idle queue, runtime: %u\n",i, acc_iter[i]);
			#endif
		}
		else 
		{
			#ifdef DEBUG
				printf("Accelerator %u not found in run or idle queue\n",i);
			#endif
		}

		if (acc_iter[i] >= ACC_RUNTIME[i])	
		{
			tile_complete[i] = 1;
			#ifdef DEBUG
				printf("Accelerator %u runtime %u Complete!!!\n",i,acc_iter[i]);
			#endif
		}

		if (tile_complete[i]==1)
		{
			i_run=removeFromList(&head_run,i);
			//printf("Checking i_run: %d\n", i_run);
			i_idl=removeFromList(&head_idle,i);
			//printf("Checking i_idl: %d\n", i_idl);

			if(i_run) {
				p_available=p_available+Pmax[i];
				pret=Pmax[i];
				#ifdef DEBUG
					printf("Finished tile %u was in (%u,%u)... Returned %u, new Pav %u\n",i,i_run,i_idl, pret, p_available);
				#endif
			}
			else if(i_idl) {
				p_available=p_available+Pmin[i];
				pret=Pmin[i];
				#ifdef DEBUG
					printf("Finished tile %u was in (%u,%u)... Returned %u, new Pav %u\n",i,i_run,i_idl, pret, p_available);
				#endif
			}

		}
		//else
		//{
		//	#ifdef DEBUG
		//		printf("Tile %d is still running\n",i);
		//	#endif
		//}
	

	}
}

void CRR_step_rotate()
{
	int index_stop;
	if(head_run != NULL && ((head_idle != NULL) || (head_wait != NULL)  )){
		index_stop=popFirst(&head_run);
		addLast(&head_idle,index_stop);
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
				addLast(&head_run,waitNode->data);
				removeFromList(&head_wait,waitNode->data);
				p_available=p_available-Pmax[waitNode->data];
				#ifdef DEBUG
					printf("wait->run tile %u new Pav %u\n",waitNode->data,p_available);
				#endif

			}
			else if(Pmin[waitNode->data]<=p_available){
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
            if(Pmax[idleNode->data]<=p_available){
				addLast(&head_run,idleNode->data);
				removeFromList(&head_idle,idleNode->data);
				p_available=p_available-Pmax[idleNode->data];
				#ifdef DEBUG
					printf("Idle->run tile %u new Pav %u\n",idleNode->data,p_available);
				#endif
			}
		idleNode = idleNode->next;
        }
		
		


}


/*
void init_params()
{
	int i;
	for (i=0;i<N_ACC;i++)
		activity[i] = 0;
		//dev_list[i]=aligned_malloc(sizeof(struct esp_device));
}
*/


void check_tile(int step)
{
	//if((head_run != NULL) ||(head_idle != NULL) ||(head_wait != NULL) ) {
		CRR_step_checkend();
		CRR_step_rotate();
	
	//}
}



