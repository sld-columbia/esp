/*****************************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_apis.sv
 *
 * Date : 2015-16
 *
 * Description : Set of Zynq MPSoC BFM APIs that are used for writing tests.
 *                
 *****************************************************************************/

  /* API for setting the STOP_ON_ERROR*/  
  task automatic set_stop_on_error;
    input LEVEL;
    begin
      $display("[%0d] : %0s : Setting Stop On Error as %0b",$time, DISP_INFO, LEVEL);
      STOP_ON_ERROR = LEVEL;
     //  M_AXI_HPM0_FPD.master.set_stop_on_error(LEVEL);
     //  M_AXI_HPM1_FPD.master.set_stop_on_error(LEVEL);
     //  M_AXI_HPM0_LPD.master.set_stop_on_error(LEVEL);
     //  S_AXI_HPC0_FPD.slave.set_stop_on_error(LEVEL);
     //  S_AXI_HPC1_FPD.slave.set_stop_on_error(LEVEL);
     //  S_AXI_HP0_FPD.slave.set_stop_on_error(LEVEL);
     //  S_AXI_HP1_FPD.slave.set_stop_on_error(LEVEL);
     //  S_AXI_HP2_FPD.slave.set_stop_on_error(LEVEL);
     //  S_AXI_HP3_FPD.slave.set_stop_on_error(LEVEL);
     //  S_AXI_HPM0_LPD.slave.set_stop_on_error(LEVEL);
     //  S_AXI_ACP.slave.set_stop_on_error(LEVEL);
     //  S_AXI_ACE.slave.set_stop_on_error(LEVEL);
      M_AXI_HPM0_FPD.STOP_ON_ERROR = LEVEL;
      M_AXI_HPM1_FPD.STOP_ON_ERROR = LEVEL;
      M_AXI_HPM0_LPD.STOP_ON_ERROR = LEVEL;
      S_AXI_HPC0_FPD.STOP_ON_ERROR = LEVEL;
      S_AXI_HPC1_FPD.STOP_ON_ERROR = LEVEL;
      S_AXI_HP0_FPD.STOP_ON_ERROR = LEVEL;
      S_AXI_HP1_FPD.STOP_ON_ERROR = LEVEL;
      S_AXI_HP2_FPD.STOP_ON_ERROR = LEVEL;
      S_AXI_HP3_FPD.STOP_ON_ERROR = LEVEL;
      S_AXI_HPM0_LPD.STOP_ON_ERROR = LEVEL;
      S_AXI_ACP.STOP_ON_ERROR = LEVEL;
      S_AXI_ACE.STOP_ON_ERROR = LEVEL;

    end
  endtask 

  /* API for setting the verbosity for channel level info*/  
  task automatic set_channel_level_info;
    input [1023:0] name;
    input LEVEL;
    begin
     $display("[%0d] : [%0s] : %0s Port/s : Setting Channel Level Info as %0b",$time, DISP_INFO,  name , LEVEL);
     case(name)
     //  "M_AXI_HPM0_FPD" : M_AXI_GP0.master.set_channel_level_info(LEVEL);
     //  "M_AXI_HPM1_FPD" : M_AXI_GP1.master.set_channel_level_info(LEVEL);
     //  "M_AXI_HPM0_LPD" : M_AXI_GP2.master.set_channel_level_info(LEVEL);
     //  "S_AXI_HPC0_FPD" : S_AXI_GP0.slave.set_channel_level_info(LEVEL);
     //  "S_AXI_HPC1_FPD" : S_AXI_GP1.slave.set_channel_level_info(LEVEL);
     //  "S_AXI_HP0_FPD" : S_AXI_HP0_FPD.slave.set_channel_level_info(LEVEL);
     //  "S_AXI_HP1_FPD" : S_AXI_GP3.slave.set_channel_level_info(LEVEL);
     //  "S_AXI_HP2_FPD" : S_AXI_GP4.slave.set_channel_level_info(LEVEL);
     //  "S_AXI_HP3_FPD" : S_AXI_GP5.slave.set_channel_level_info(LEVEL);
     //  "S_AXI_HPM0_LPD" : S_AXI_GP6.slave.set_channel_level_info(LEVEL);
     //  "S_AXI_ACP" : S_AXI_ACP.slave.set_channel_level_info(LEVEL);
     //  "S_AXI_ACE" : S_AXI_ACE.slave.set_channel_level_info(LEVEL);
      "ALL"       : begin
     //                  M_AXI_HPM0_FPD.master.set_channel_level_info(LEVEL);
     //                  M_AXI_HPM1_FPD.master.set_channel_level_info(LEVEL);
     //                  M_AXI_HPM0_LPD.master.set_channel_level_info(LEVEL);
     //                  S_AXI_HPC0_FPD.slave.set_channel_level_info(LEVEL);
     //                  S_AXI_HPC1_FPD.slave.set_channel_level_info(LEVEL);
     //                  S_AXI_HP0_FPD.slave.set_channel_level_info(LEVEL);
     //                  S_AXI_HP1_FPD.slave.set_channel_level_info(LEVEL);
     //                  S_AXI_HP2_FPD.slave.set_channel_level_info(LEVEL);
     //                  S_AXI_HP3_FPD.slave.set_channel_level_info(LEVEL);
     //                  S_AXI_HPM0_LPD.slave.set_channel_level_info(LEVEL);
     //                  S_AXI_ACP.slave.set_channel_level_info(LEVEL);
     //                  S_AXI_ACE.slave.set_channel_level_info(LEVEL);
                    end
      default     : $display("[%0d] : %0s : Invalid Port name (%0s)",$time, DISP_ERR, name);
     endcase
    end
  endtask

  /* API for setting the verbosity for function level info*/  
  task automatic set_function_level_info;
    input [1023:0] name;
    input LEVEL;
    begin
     $display("[%0d] : [%0s] : %0s Port/s : Setting Function Level Info as %0b",$time, DISP_INFO,  name , LEVEL);
     case(name)
     //  "M_AXI_HPM0_FPD" : M_AXI_GP0.master.set_function_level_info(LEVEL);
     //  "M_AXI_HPM1_FPD" : M_AXI_GP1.master.set_function_level_info(LEVEL);
     //  "M_AXI_HPM0_LPD" : M_AXI_GP2.master.set_function_level_info(LEVEL);
     //  "S_AXI_HPC0_FPD" : S_AXI_GP0.slave.set_function_level_info(LEVEL);
     //  "S_AXI_HPC1_FPD" : S_AXI_GP1.slave.set_function_level_info(LEVEL);
     //  "S_AXI_HP0_FPD" : S_AXI_HP0_FPD.slave.set_function_level_info(LEVEL);
     //  "S_AXI_HP1_FPD" : S_AXI_GP3.slave.set_function_level_info(LEVEL);
     //  "S_AXI_HP2_FPD" : S_AXI_GP4.slave.set_function_level_info(LEVEL);
     //  "S_AXI_HP3_FPD" : S_AXI_GP5.slave.set_function_level_info(LEVEL);
     //  "S_AXI_HPM0_LPD" : S_AXI_GP6.slave.set_function_level_info(LEVEL);
     //  "S_AXI_ACP" : S_AXI_ACP.slave.set_function_level_info(LEVEL);
     //  "S_AXI_ACE" : S_AXI_ACE.slave.set_function_level_info(LEVEL);
      "ALL"       : begin
     //                  M_AXI_HPM0_FPD.master.set_function_level_info(LEVEL);
     //                  M_AXI_HPM1_FPD.master.set_function_level_info(LEVEL);
     //                  M_AXI_HPM0_LPD.master.set_function_level_info(LEVEL);
     //                  S_AXI_HPC0_FPD.slave.set_function_level_info(LEVEL);
     //                  S_AXI_HPC1_FPD.slave.set_function_level_info(LEVEL);
     //                  S_AXI_HP0_FPD.slave.set_function_level_info(LEVEL);
     //                  S_AXI_HP1_FPD.slave.set_function_level_info(LEVEL);
     //                  S_AXI_HP2_FPD.slave.set_function_level_info(LEVEL);
     //                  S_AXI_HP3_FPD.slave.set_function_level_info(LEVEL);
     //                  S_AXI_HPM0_LPD.slave.set_function_level_info(LEVEL);
     //                  S_AXI_ACP.slave.set_function_level_info(LEVEL);
     //                  S_AXI_ACE.slave.set_function_level_info(LEVEL);
                    end
      default     : $display("[%0d] : %0s : Invalid Port name (%0s)",$time, DISP_ERR, name);
     endcase
    end
  endtask

  /* API for setting the Message verbosity */  
  task automatic set_debug_level_info;
    input LEVEL;
    begin
      $display("[%0d] : %0s : Setting Debug Level Info as %0b",$time, DISP_INFO,  LEVEL);
      DEBUG_INFO = LEVEL;
      M_AXI_HPM0_FPD.DEBUG_INFO = LEVEL;
      M_AXI_HPM1_FPD.DEBUG_INFO = LEVEL;
      M_AXI_HPM0_LPD.DEBUG_INFO = LEVEL;
      S_AXI_HPC0_FPD.DEBUG_INFO = LEVEL;
      S_AXI_HPC1_FPD.DEBUG_INFO = LEVEL;
      S_AXI_HP0_FPD.DEBUG_INFO = LEVEL;
      S_AXI_HP1_FPD.DEBUG_INFO = LEVEL;
      S_AXI_HP2_FPD.DEBUG_INFO = LEVEL;
      S_AXI_HP3_FPD.DEBUG_INFO = LEVEL;
      S_AXI_HPM0_LPD.DEBUG_INFO = LEVEL;
      S_AXI_ACP.DEBUG_INFO = LEVEL; 
      S_AXI_ACE.DEBUG_INFO = LEVEL; 
    end
  endtask

  /* API for setting ARQos Values */  
  task automatic set_arqos;
    input [1023:0] name;
    input [axi_qos_width-1:0] value;
    begin
     $display("[%0d] : [%0s] : %0s Port/s : Setting AWQOS as %0b",$time, DISP_INFO,  name , value);
     case(name)
      "S_AXI_HPC0_FPD" : S_AXI_HPC0_FPD.set_arqos(value);
      "S_AXI_HPC1_FPD" : S_AXI_HPC1_FPD.set_arqos(value);
      "S_AXI_HP0_FPD" : S_AXI_HP0_FPD.set_arqos(value);
      "S_AXI_HP1_FPD" : S_AXI_HP1_FPD.set_arqos(value);
      "S_AXI_HP2_FPD" : S_AXI_HP2_FPD.set_arqos(value);
      "S_AXI_HP3_FPD" : S_AXI_HP3_FPD.set_arqos(value);
      "S_AXI_HPM0_LPD" : S_AXI_HPM0_LPD.set_arqos(value);
      "S_AXI_ACP" : S_AXI_ACP.set_arqos(value);
      "S_AXI_ACE" : S_AXI_ACE.set_arqos(value);
      default     : $display("[%0d] : %0s : Invalid Slave Port name (%0s)",$time, DISP_ERR, name);
     endcase
    end
  endtask

  /* API for setting AWQos Values */  
  task automatic set_awqos;
    input [1023:0] name;
    input [axi_qos_width-1:0] value;
    begin
     $display("[%0d] : [%0s] : %0s Port/s : Setting ARQOS as %0b",$time, DISP_INFO,  name , value);
     case(name)
      "S_AXI_HPC0_FPD" : S_AXI_HPC0_FPD.set_awqos(value);
      "S_AXI_HPC1_FPD" : S_AXI_HPC1_FPD.set_awqos(value);
      "S_AXI_HP0_FPD" : S_AXI_HP0_FPD.set_awqos(value);
      "S_AXI_HP1_FPD" : S_AXI_HP1_FPD.set_awqos(value);
      "S_AXI_HP2_FPD" : S_AXI_HP2_FPD.set_awqos(value);
      "S_AXI_HP3_FPD" : S_AXI_HP3_FPD.set_awqos(value);
      "S_AXI_HPM0_LPD" : S_AXI_HPM0_LPD.set_awqos(value);
      "S_AXI_ACP" : S_AXI_ACP.set_awqos(value);
      "S_AXI_ACE" : S_AXI_ACE.set_awqos(value);
      default     : $display("[%0d] : %0s : Invalid Slave Port (%0s)",$time, DISP_ERR, name);
     endcase
    end
  endtask

  /* API for por and strb reset control */
   task automatic por_srstb_reset;
     input por_reset_ctrl;
     begin
       if(DEBUG_INFO) $display("[%0d] : %0s : POR and STRB Reset called for 0x%0h",$time, DISP_INFO,  por_reset_ctrl); 
 //      gen_rst.por_srstb_reset(por_reset_ctrl); 
       gen_rst.por_srstb_reset(por_reset_ctrl);  
 
     end
   endtask

   /* API for soft reset control */
   task automatic fpga_soft_reset;
     input[data_width-1:0] reset_ctrl;
     begin
       if(DEBUG_INFO) $display("[%0d] : %0s : FPGA Soft Reset called for 0x%0h",$time, DISP_INFO,  reset_ctrl); 
       gen_rst.fpga_soft_reset(reset_ctrl);  
     end
   endtask

//   /* API for por and strb reset control */
//   task automatic por_srstb_reset;
//     input por_reset_ctrl;
//     begin
//       if(DEBUG_INFO) $display("[%0d] : %0s : POR and STRB Reset called for 0x%0h",$time, DISP_INFO,  por_reset_ctrl); 
// //      gen_rst.por_srstb_reset(por_reset_ctrl); 
// //      gen_rst.por_srstb_reset(por_reset_ctrl);  
//       gen_rst.fpga_soft_reset(por_reset_ctrl);  
//     end
//   endtask



  /* API for pre-loading memories from (DDR/OCM model) */
  task automatic pre_load_mem_from_file;
    input [(max_chars*16)-1:0] file_name;
    input [addr_width-1:0] start_addr;
    input [int_width-1:0] no_of_bytes;
    reg [1:0] mem_type;
    integer succ;
    begin
      mem_type = decode_address(start_addr);
      succ = $fopen(file_name,"r");
      if(succ == 0) begin
        $display("[%0d] : %0s : '%0s' doesn't exist. 'pre_load_mem_from_file' call failed ...\n",$time, DISP_ERR, file_name); 
        if(STOP_ON_ERROR) $stop; 
      end   
      else if(check_addr_aligned(start_addr)) begin    
        case(mem_type)
        OCM_MEM : begin
                  ocmc.ocm.pre_load_mem_from_file(file_name,(start_addr-ocm_start_addr),no_of_bytes); 
                  if(DEBUG_INFO)
                    $display("[%0d] : %0s : Starting Address(0x%0h) -> OCM Memory is pre-loaded with %0d bytes of data from file %0s",$time, DISP_INFO,  start_addr, no_of_bytes, file_name); 
                  end 
        DDR_MEM : begin
                  ddrc.ddr.pre_load_mem_from_file(file_name,start_addr,no_of_bytes);
                  if(DEBUG_INFO)
                    $display("[%0d] : %0s : Starting Address(0x%0h) -> DDR Memory is pre-loaded with %0d bytes of data from file %0s",$time, DISP_INFO,  start_addr, no_of_bytes, file_name); 
                  end 
        default : begin
                  $display("[%0d] : %0s : Address(0x%0h) is out-of-range. 'pre_load_mem_from_file' call failed ...\n",$time, DISP_ERR,  start_addr); 
                  if(STOP_ON_ERROR) $stop; 
                  end 
        endcase
      end else begin 
        $display("[%0d] : %0s : Address(0x%0h) has to be 32-bit aligned. 'pre_load_mem_from_file' call failed ...",$time, DISP_ERR, start_addr);
        if(STOP_ON_ERROR)
          $stop; 
      end
    end
  endtask
 
  /* API for pre-loading memories (DDR/OCM) */
  task automatic pre_load_mem;
    input [1:0] data_type;
    input [addr_width-1:0] start_addr;
    input [int_width-1:0] no_of_bytes;
    reg [1:0] mem_type;
    begin
      mem_type = decode_address(start_addr);
      if(check_addr_aligned(start_addr)) begin    
        case(mem_type)
        OCM_MEM : begin
                  ocmc.ocm.pre_load_mem(data_type,(start_addr-ocm_start_addr),no_of_bytes); 
                  if(DEBUG_INFO)
                    $display("[%0d] : %0s : Starting Address(0x%0h) -> OCM Memory is pre-loaded with %0d bytes of data",$time, DISP_INFO,  start_addr, no_of_bytes); 
                  end
        DDR_MEM : begin
                  ddrc.ddr.pre_load_mem(data_type,start_addr,no_of_bytes); 
                  if(DEBUG_INFO)
                    $display("[%0d] : %0s : Starting Address(0x%0h) -> DDR Memory is pre-loaded with %0d bytes of data",$time, DISP_INFO,  start_addr, no_of_bytes); 
                  end
        default : begin
                  $display("[%0d] : %0s : Address(0x%0h) is out-of-range. 'pre_load_mem' call failed ...\n",$time, DISP_ERR,  start_addr); 
                  if(STOP_ON_ERROR) $stop; 
                  end
        endcase
      end else begin 
        $display("[%0d] : %0s : Address(0x%0h) has to be 32-bit aligned. 'pre_load_mem' call failed ...",$time, DISP_ERR, start_addr);
        if(STOP_ON_ERROR) $stop; 
      end
    end
  endtask

  /* API for backdoor write to memories (DDR/OCM) */
  task automatic write_mem;
    input [max_burst_bits-1 :0] data;
    input [addr_width-1:0] start_addr;
    input [max_burst_bytes_width:0] no_of_bytes;
    reg [1:0] mem_type;
    integer succ;
    begin
      mem_type = decode_address(start_addr);
      if(check_addr_aligned(start_addr)) begin    
        case(mem_type)
        OCM_MEM : begin
                  ocmc.ocm.write_mem(data,(start_addr-ocm_start_addr),no_of_bytes,all_strb_valid); 
                  if(DEBUG_INFO)
                    $display("[%0d] : %0s : Starting Address(0x%0h) -> Write %0d bytes of data to OCM Memory",$time, DISP_INFO,  start_addr, no_of_bytes); 
                  end 
        DDR_MEM : begin
                  ddrc.ddr.write_mem(data,start_addr,no_of_bytes,all_strb_valid);
                  if(DEBUG_INFO)
                    $display("[%0d] : %0s : Starting Address(0x%0h) -> Write %0d bytes of data to DDR Memory",$time, DISP_INFO,  start_addr, no_of_bytes); 
                  end 
        default : begin
                  $display("[%0d] : %0s : Address(0x%0h) is out-of-range. 'write_mem' call failed ...\n",$time, DISP_ERR,  start_addr); 
                  if(STOP_ON_ERROR) $stop; 
                  end 
        endcase
      end else begin 
        $display("[%0d] : %0s : Address(0x%0h) has to be 32-bit aligned. 'write_mem' call failed ...",$time, DISP_ERR, start_addr);
        if(STOP_ON_ERROR)
          $stop; 
      end
    end
  endtask

    /* read_memory */
    task automatic read_mem;
      input [addr_width-1:0] start_addr;
      input [max_burst_bytes_width :0] no_of_bytes;
      output[max_burst_bits-1 :0] data;
      reg [1:0] mem_type;
      integer succ;
      begin
        mem_type = decode_address(start_addr);
        if(check_addr_aligned(start_addr)) begin    
          case(mem_type)
          OCM_MEM : begin
                    ocmc.ocm.read_mem(data,(start_addr-ocm_start_addr),no_of_bytes); 
                    if(DEBUG_INFO)
                      $display("[%0d] : %0s : Starting Address(0x%0h) -> Read %0d bytes of data from OCM Memory ",$time, DISP_INFO,  start_addr, no_of_bytes); 
                    end 
          DDR_MEM : begin
                    ddrc.ddr.read_mem(data,start_addr,no_of_bytes);
                    if(DEBUG_INFO)
                      $display("[%0d] : %0s : Starting Address(0x%0h) -> Read %0d bytes of data from DDR Memory",$time, DISP_INFO,  start_addr, no_of_bytes); 
                    end 
          default : begin
                    $display("[%0d] : %0s : Address(0x%0h) is out-of-range. 'read_mem' call failed ...\n",$time, DISP_ERR,  start_addr); 
                    if(STOP_ON_ERROR) $stop; 
                    end 
          endcase
        end else begin 
          $display("[%0d] : %0s : Address(0x%0h) has to be 32-bit aligned. 'read_mem' call failed ...",$time, DISP_ERR, start_addr);
          if(STOP_ON_ERROR)
            $stop; 
        end
      end
  endtask

  /* API for backdoor read to memories (DDR/OCM) */
  task automatic peek_mem_to_file;
    input [(max_chars*8)-1:0] file_name;
    input [addr_width-1:0] start_addr;
    input [int_width-1:0] no_of_bytes;
    reg [1:0] mem_type;
    integer succ;
    begin
      mem_type = decode_address(start_addr);
      if(check_addr_aligned(start_addr)) begin    
        case(mem_type)
        OCM_MEM : begin
                  ocmc.ocm.peek_mem_to_file(file_name,(start_addr-ocm_start_addr),no_of_bytes); 
                  if(DEBUG_INFO)
                    $display("[%0d] : %0s : Starting Address(0x%0h) -> Peeked %0d bytes of data from OCM Memory to file %0s",$time, DISP_INFO,  start_addr, no_of_bytes, file_name); 
                  end 
        DDR_MEM : begin
                  ddrc.ddr.peek_mem_to_file(file_name,start_addr,no_of_bytes);
                  if(DEBUG_INFO)
                    $display("[%0d] : %0s : Starting Address(0x%0h) -> Peeked %0d bytes of data from DDR Memory to file %0s",$time, DISP_INFO,  start_addr, no_of_bytes, file_name); 
                  end 
        default : begin
                  $display("[%0d] : %0s : Address(0x%0h) is out-of-range. 'peek_mem_to_file' call failed ...\n",$time, DISP_ERR,  start_addr); 
                  if(STOP_ON_ERROR) $stop; 
                  end 
        endcase
      end else begin 
        $display("[%0d] : %0s : Address(0x%0h) has to be 32-bit aligned. 'peek_mem_to_file' call failed ...",$time, DISP_ERR, start_addr);
        if(STOP_ON_ERROR)
          $stop; 
      end
    end
  endtask

  /* API to read interrupt status */
  task automatic read_interrupt;
    output[irq_width-1:0] irq_status;
    begin
      irq_status = {PLPSIRQ1,PLPSIRQ0};
      if(DEBUG_INFO) $display("[%0d] : %0s : Reading Interrupt Status as 0x%0h",$time, DISP_INFO,  irq_status);
    end
  endtask

  /* API to wait on interrup */
  task automatic wait_interrupt;
    input [3:0] irq;
    output[irq_width-1:0] irq_status;
    begin
      if(DEBUG_INFO) $display("[%0d] : %0s : Waiting on Interrupt irq[%0d]",$time, DISP_INFO,  irq);

      case(irq) 
      0 :  wait(PLPSIRQ0[0] === 1'b1);
      1 :  wait(PLPSIRQ0[1] === 1'b1);
      2 :  wait(PLPSIRQ0[2] === 1'b1);
      3 :  wait(PLPSIRQ0[3] === 1'b1);
      4 :  wait(PLPSIRQ0[4] === 1'b1);
      5 :  wait(PLPSIRQ0[5] === 1'b1);
      6 :  wait(PLPSIRQ0[6] === 1'b1);
      7 :  wait(PLPSIRQ0[7] === 1'b1);
      8 :  wait(PLPSIRQ1[0] === 1'b1);
      9 :  wait(PLPSIRQ1[1] === 1'b1);
      10:  wait(PLPSIRQ1[2] === 1'b1);
      11:  wait(PLPSIRQ1[3] === 1'b1);
      12:  wait(PLPSIRQ1[4] === 1'b1);
      13:  wait(PLPSIRQ1[5] === 1'b1);
      14:  wait(PLPSIRQ1[6] === 1'b1);
      15:  wait(PLPSIRQ1[7] === 1'b1);
      default : $display("[%0d] : %0s : Only 16 Interrupt lines (irq_fp0:irq_fp15) are supported",$time, DISP_ERR);
      endcase
      if(DEBUG_INFO) $display("[%0d] : %0s : Received Interrupt irq[%0d]",$time, DISP_INFO,  irq);
      irq_status = {PLPSIRQ1,PLPSIRQ0};
    end
  endtask

  /* API to wait for a certain match pattern*/ 
  task automatic wait_mem_update;
    input[addr_width-1:0] address;
    input[data_width-1:0] data_in;
    output[data_width-1:0] data_out;
    reg[data_width-1:0] datao;
    begin
      if(mem_update_key) begin
        mem_update_key = 0;
        if(DEBUG_INFO) $display("[%0d] : %0s : 'wait_mem_update' called for Address(0x%0h) , Match Pattern(0x%0h) \n",$time, DISP_INFO, address, data_in); 
        if(check_addr_aligned(address)) begin
         ddrc.ddr.wait_mem_update(address, datao);
         if(datao != data_in)begin 
           $display("[%0d] : %0s : Address(0x%0h) -> DATA PATTERN MATCH FAILED, Expected data = 0x%0h, Received data = 0x%0h \n",$time, DISP_ERR, address, data_in,datao);
           $stop;
         end else
           $display("[%0d] : %0s : Address(0x%0h) -> DATA PATTERN(0x%0h) MATCHED \n",$time, DISP_INFO,  address, data_in);
         data_out = datao;
        end else begin
           $display("[%0d] : %0s : Address(0x%0h) has to be 32-bit aligned. 'wait_mem_update' call failed ...\n",$time, DISP_ERR,  address); 
           if(STOP_ON_ERROR) $stop;
        end
        mem_update_key = 1;
      end else 
        $display("[%0d] : %0s : One instance of 'wait_mem_update' thread is already running.Only one instance can be called at a time ...\n",$time, DISP_WARN); 
    end
  endtask


 /* API to initiate a WRITE transaction on one of the AXI-Master ports*/ 
 task automatic write_from_file;
   input [(max_chars*8)-1:0] file_name;
   input [addr_width-1:0] start_addr;
   input [int_width-1:0] wr_size;
   output [axi_rsp_width-1:0] response;
   integer succ;
   begin
      succ = $fopen(file_name,"r");
      if(succ == 0) begin
        $display("[%0d] : %0s : '%0s' doesn't exist. 'write_from_file' call failed ...\n",$time, DISP_ERR, file_name); 
        if(STOP_ON_ERROR) $stop; 
      end   
      else if(!check_master_address(start_addr)) begin
         $display("[%0d] : %0s : Master Address(0x%0h) is out of range\n",$time, DISP_ERR,  start_addr); 
         if(STOP_ON_ERROR) $stop;
      end else if(check_addr_aligned(start_addr)) begin
         $fclose(succ);
         if ((start_addr[31:28] === 4'b1010) || (start_addr[35:32] === 4'b0100) || (start_addr[39:36] === 4'b0001) || (start_addr[39:36] === 4'b0010) 
		     || (start_addr[39:36] === 4'b0011) || (start_addr[39:36] === 4'b0100) || (start_addr[39:32] === 8'b0100_0111) ) begin//G_MP0
            if(DEBUG_INFO)
              $display("[%0d] : M_AXI_HPM0_FPD : %0s : Starting Address(0x%0h) -> AXI Write -> %0d bytes from file %0s",$time, DISP_INFO,  start_addr, wr_size, file_name); 
            M_AXI_HPM0_FPD.write_from_file(file_name,start_addr,wr_size,response);
            if(DEBUG_INFO)
              $display("[%0d] : M_AXI_HPM0_FPD : %0s : Done AXI Write for Starting Address(0x%0h)",$time, DISP_INFO,  start_addr); 
            end else if ((start_addr[31:28] === 4'b1011) || (start_addr[35:32] === 4'b0101) || (start_addr[39:32] === 8'b0100_1000) || (start_addr[39:36] === 4'b0101) ||  
		                (start_addr[39:36] === 4'b0110) || (start_addr[39:36] === 4'b0111) || (start_addr[39:32] === 8'b0111_1111) ) begin//G_MP1
            if(DEBUG_INFO)
              $display("[%0d] : M_AXI_HPM1_FPD : %0s : Starting Address(0x%0h) -> AXI Write -> %0d bytes from file %0s",$time, DISP_INFO,  start_addr, wr_size, file_name); 
            M_AXI_HPM1_FPD.write_from_file(file_name,start_addr,wr_size,response);
            if(DEBUG_INFO)
              $display("[%0d] : M_AXI_HPM1_FPD : %0s : Done AXI Write for Starting Address(0x%0h)",$time, DISP_INFO,  start_addr); 
         end else if (start_addr[39:28] === 12'b0000_0000_1000) begin//G_MP2
            if(DEBUG_INFO)
              $display("[%0d] : M_AXI_HPM0_LPD : %0s : Starting Address(0x%0h) -> AXI Write -> %0d bytes from file %0s",$time, DISP_INFO,  start_addr, wr_size, file_name); 
            M_AXI_HPM0_LPD.write_from_file(file_name,start_addr,wr_size,response);
            if(DEBUG_INFO)
              $display("[%0d] : M_AXI_HPM0_LPD : %0s : Done AXI Write for Starting Address(0x%0h)",$time, DISP_INFO,  start_addr); 
         end 
      end else begin
          $display("[%0d] : %0s : Address(0x%0h) has to be 32-bit aligned. 'write_from_file' call failed ...\n",$time, DISP_ERR,  start_addr); 
          if(STOP_ON_ERROR) $stop;
      end
   end
 endtask

 /* API to initiate a READ transaction on one of the AXI-Master ports*/ 
 task automatic read_to_file;
   input [(max_chars*8)-1:0] file_name;
   input [addr_width-1:0] start_addr;
   input [int_width-1:0] rd_size;
   output [axi_rsp_width-1:0] response;
   begin
      if(!check_master_address(start_addr)) begin
         $display("[%0d] : %0s : Master Address(0x%0h) is out of range\n",$time, DISP_ERR ,  start_addr); 
         if(STOP_ON_ERROR) $stop;
      end else if(check_addr_aligned(start_addr)) begin
         if ((start_addr[31:28] === 4'b1010) || (start_addr[35:32] === 4'b0100) || (start_addr[39:36] === 4'b0001) || (start_addr[39:36] === 4'b0010) 
		     || (start_addr[39:36] === 4'b0011) || (start_addr[39:36] === 4'b0100) || (start_addr[39:32] === 8'b0100_0111) ) begin//G_MP0
            if(DEBUG_INFO)
               $display("[%0d] : M_AXI_HPM0_FPD : %0s : Starting Address(0x%0h) -> AXI Read -> %0d bytes to file %0s",$time, DISP_INFO,  start_addr, rd_size, file_name); 
            M_AXI_HPM0_FPD.read_to_file(file_name,start_addr,rd_size,response);
            if(DEBUG_INFO)
               $display("[%0d] : M_AXI_HPM0_FPD : %0s : Done AXI Read for Starting Address(0x%0h)",$time, DISP_INFO,  start_addr); 
         end else if ((start_addr[31:28] === 4'b1011) || (start_addr[35:32] === 4'b0101) || (start_addr[39:32] === 8'b0100_1000) || (start_addr[39:36] === 4'b0101) ||  
		                (start_addr[39:36] === 4'b0110) || (start_addr[39:36] === 4'b0111) || (start_addr[39:32] === 8'b0111_1111)) begin//G_MP1
            if(DEBUG_INFO)
               $display("[%0d] : M_AXI_HPM1_FPD : %0s : Starting Address(0x%0h) -> AXI Read -> %0d bytes to file %0s",$time, DISP_INFO,  start_addr, rd_size, file_name); 
            M_AXI_HPM1_FPD.read_to_file(file_name,start_addr,rd_size,response);
            if(DEBUG_INFO)
               $display("[%0d] : M_AXI_HPM1_FPD : %0s : Done AXI Read for Starting Address(0x%0h)",$time, DISP_INFO,  start_addr); 
         end else if (start_addr[39:28] === 12'b0000_0000_1000) begin//G_MP2
            if(DEBUG_INFO)
               $display("[%0d] : M_AXI_HPM0_LPD : %0s : Starting Address(0x%0h) -> AXI Read -> %0d bytes to file %0s",$time, DISP_INFO,  start_addr, rd_size, file_name); 
            M_AXI_HPM0_LPD.read_to_file(file_name,start_addr,rd_size,response);
            if(DEBUG_INFO)
               $display("[%0d] : M_AXI_HPM0_LPD : %0s : Done AXI Read for Starting Address(0x%0h)",$time, DISP_INFO,  start_addr); 
         end
      end else begin
          $display("[%0d] : %0s : Address(0x%0h) has to be 32-bit aligned. 'read_to_file' call failed ...\n",$time, DISP_ERR,  start_addr); 
          if(STOP_ON_ERROR) $stop;
      end
   end
 endtask

 /* API to initiate a WRITE transaction(<= 128 bytes) on one of the AXI-Master ports*/ 
 task automatic write_data;
   input [addr_width-1:0] start_addr;
   input [max_transfer_bytes_width:0] wr_size;
   input [(max_transfer_bytes*8)-1:0] w_data;
   output [axi_rsp_width-1:0] response;
   reg[511:0] rsp;
   begin
    if(!check_master_address(start_addr)) begin
         $display("[%0d] : %0s : Master Address(0x%0h) is out of range. 'write_data' call failed ...\n",$time, DISP_ERR,  start_addr); 
         if(STOP_ON_ERROR) $stop;
    end else if(wr_size > max_transfer_bytes) begin
         $display("[%0d] : %0s : Byte Size supported is 128 bytes only. 'write_data' call failed ...\n",$time, DISP_ERR,  start_addr); 
         if(STOP_ON_ERROR) $stop;
    end else if((start_addr[31:28] === 4'b1010) || (start_addr[35:32] === 4'b0100) || (start_addr[39:36] === 4'b0001) || (start_addr[39:36] === 4'b0010) 
		     || (start_addr[39:36] === 4'b0011) || (start_addr[39:36] === 4'b0100) || (start_addr[39:32] === 8'b0100_0111) ) begin//G_MP0
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_FPD : %0s : Starting Address(0x%0h) -> AXI Write -> %0d bytes",$time, DISP_INFO,  start_addr, wr_size); 
       M_AXI_HPM0_FPD.write_data(start_addr,wr_size,w_data,response);
       rsp = get_resp(response);
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_FPD : %0s : Done AXI Write for Starting Address(0x%0h) with Response '%0s'",$time, DISP_INFO,  start_addr, rsp); 
    end else if ((start_addr[31:28] === 4'b1011) || (start_addr[35:32] === 4'b0101) || (start_addr[39:32] === 8'b0100_1000) || (start_addr[39:36] === 4'b0101) ||  
		                (start_addr[39:36] === 4'b0110) || (start_addr[39:36] === 4'b0111) || (start_addr[39:32] === 8'b0111_1111) ) begin//G_MP1
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM1_FPD : %0s : Starting Address(0x%0h) -> AXI Write -> %0d bytes",$time, DISP_INFO,  start_addr, wr_size); 
       M_AXI_HPM1_FPD.write_data(start_addr,wr_size,w_data,response);
       rsp = get_resp(response);
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM1_FPD : %0s : Done AXI Write for Starting Address(0x%0h) with Response '%0s'",$time, DISP_INFO,  start_addr, rsp); 
    end else if(start_addr[39:28] === 12'b0000_0000_1000) begin//G_MP2
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_LPD : %0s : Starting Address(0x%0h) -> AXI Write -> %0d bytes",$time, DISP_INFO,  start_addr, wr_size); 
       M_AXI_HPM0_LPD.write_data(start_addr,wr_size,w_data,response);
       rsp = get_resp(response);
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_LPD : %0s : Done AXI Write for Starting Address(0x%0h) with Response '%0s'",$time, DISP_INFO,  start_addr, rsp); 
    end else
       $display("[%0d] : %0s : Invalid Address(0x%0h) 'write_data' call failed ...\n",$time, DISP_ERR, start_addr); 
   end
 endtask

 /* API to initiate a READ transaction(<= 128 bytes) on one of the AXI-Master ports*/ 
 task automatic read_data;
   input [addr_width-1:0] start_addr;
   input [max_transfer_bytes_width:0] rd_size;
   output[(max_transfer_bytes*8)-1:0] rd_data;
   output [axi_rsp_width-1:0] response;
   reg[511:0] rsp;
   begin
    if(!check_master_address(start_addr)) begin
       $display("[%0d] : %0s : Master Address(0x%0h) is out of range 'read_data' call failed ...\n",$time, DISP_ERR,  start_addr); 
       if(STOP_ON_ERROR) $stop;
    end else if(rd_size > max_transfer_bytes) begin
         $display("[%0d] : %0s : Byte Size supported is 128 bytes only.'read_data' call failed ... \n",$time, DISP_ERR,  start_addr); 
         if(STOP_ON_ERROR) $stop;
    end else if((start_addr[31:28] === 4'b1010) || (start_addr[35:32] === 4'b0100) || (start_addr[39:36] === 4'b0001) || (start_addr[39:36] === 4'b0010) 
		       || (start_addr[39:36] === 4'b0011) || (start_addr[39:36] === 4'b0100) || (start_addr[39:32] === 8'b0100_0111) ) begin//G_MP0
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_FPD : %0s : Starting Address(0x%0h) -> AXI Read -> %0d bytes",$time, DISP_INFO,  start_addr, rd_size); 
       M_AXI_HPM0_FPD.read_data(start_addr,rd_size,rd_data,response);
       rsp = get_resp(response);
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_FPD : %0s : Done AXI Read for Starting Address(0x%0h) with Response '%0s'",$time, DISP_INFO,  start_addr, rsp); 
    end else if((start_addr[31:28] === 4'b1011) || (start_addr[35:32] === 4'b0101) || (start_addr[39:32] === 8'b0100_1000) || (start_addr[39:36] === 4'b0101) ||  
		        (start_addr[39:36] === 4'b0110) || (start_addr[39:36] === 4'b0111) || (start_addr[39:32] === 8'b0111_1111)) begin//G_MP1
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM1_FPD : %0s : Starting Address(0x%0h) -> AXI Read -> %0d bytes",$time, DISP_INFO,  start_addr, rd_size); 
       M_AXI_HPM1_FPD.read_data(start_addr,rd_size,rd_data,response);
       rsp = get_resp(response);
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM1_FPD : %0s : Done AXI Read for Starting Address(0x%0h) with Response '%0s'",$time, DISP_INFO,  start_addr, rsp); 
    end else if(start_addr[39:28] === 12'b0000_0000_1000) begin//G_MP2
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_LPD : %0s : Starting Address(0x%0h) -> AXI Read -> %0d bytes",$time, DISP_INFO,  start_addr, rd_size); 
       M_AXI_HPM0_LPD.read_data(start_addr,rd_size,rd_data,response);
       rsp = get_resp(response);
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_LPD : %0s : Done AXI Read for Starting Address(0x%0h) with Response '%0s'",$time, DISP_INFO,  start_addr, rsp); 
    end else
       $display("[%0d] : %0s : Invalid Address(0x%0h) 'read_data' call failed ...\n",$time, DISP_ERR, start_addr); 
    end
 endtask

/* Hooks to call to BFM APIs */
 task automatic write_burst(input [addr_width-1:0] start_addr,input [axi_len_width-1:0] len,input [axi_size_width-1:0] siz,input [axi_brst_type_width-1:0] burst,input [axi_lock_width-1:0] lck,input [axi_cache_width-1:0] cache,input [axi_prot_width-1:0] prot,input [(axi_max_mdata_width*axi_burst_len)-1:0] data,input integer datasize, output [axi_rsp_width-1:0] response);
   reg[511:0] rsp;
   begin
    if(!check_master_address(start_addr)) begin
       $display("[%0d] : %0s : Master Address(0x%0h) is out of range. 'write_burst' call failed ...\n",$time, DISP_ERR,  start_addr); 
       if(STOP_ON_ERROR) $stop;
    end else if((start_addr[31:28] === 4'b1010) || (start_addr[35:32] === 4'b0100) || (start_addr[39:36] === 4'b0001) || (start_addr[39:36] === 4'b0010) 
		     || (start_addr[39:36] === 4'b0011) || (start_addr[39:36] === 4'b0100) || (start_addr[39:32] === 8'b0100_0111) ) begin//G_MP0
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_FPD : %0s : Starting Address(0x%0h) -> AXI Write -> %0d bytes",$time, DISP_INFO,  start_addr, datasize); 
       M_AXI_HPM0_FPD.write_burst(start_addr,len,siz,burst,lck,cache,prot,data,datasize,response);
       rsp = get_resp(response);
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_FPD : %0s : Done AXI Write for Starting Address(0x%0h) with Response '%0s'",$time, DISP_INFO,  start_addr, rsp); 
    end else if((start_addr[31:28] === 4'b1011) || (start_addr[35:32] === 4'b0101) || (start_addr[39:32] === 8'b0100_1000) || (start_addr[39:36] === 4'b0101) ||  
		        (start_addr[39:36] === 4'b0110) || (start_addr[39:36] === 4'b0111) || (start_addr[39:32] === 8'b0111_1111) ) begin//G_MP1
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM1_FPD : %0s : Starting Address(0x%0h) -> AXI Write -> %0d bytes",$time, DISP_INFO,  start_addr, datasize); 
       M_AXI_HPM1_FPD.write_burst(start_addr,len,siz,burst,lck,cache,prot,data,datasize,response);
       rsp = get_resp(response);
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM1_FPD : %0s : Done AXI Write for Starting Address(0x%0h) with Response '%0s'",$time, DISP_INFO,  start_addr, rsp); 
    end else if(start_addr[39:28] === 12'b0000_0000_1000) begin//G_MP2
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_LPD : %0s : Starting Address(0x%0h) -> AXI Write -> %0d bytes",$time, DISP_INFO,  start_addr, datasize); 
       M_AXI_HPM0_LPD.write_burst(start_addr,len,siz,burst,lck,cache,prot,data,datasize,response);
       rsp = get_resp(response);
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_LPD : %0s : Done AXI Write for Starting Address(0x%0h) with Response '%0s'",$time, DISP_INFO,  start_addr, rsp); 
    end else
       $display("[%0d] : %0s : Invalid Address(0x%0h) 'write_burst' call failed ... \n",$time, DISP_ERR, start_addr); 
   end
 endtask 

/* Hooks to call to BFM APIs */
 task automatic write_burst_strb(input [addr_width-1:0] start_addr,input [axi_len_width-1:0] len,input [axi_size_width-1:0] siz,input [axi_brst_type_width-1:0] burst,input [axi_lock_width-1:0] lck,input [axi_cache_width-1:0] cache,input [axi_prot_width-1:0] prot,input [(axi_max_mdata_width*axi_burst_len)-1:0] data,input strb_en,input [(axi_mgp_data_width*axi_burst_len)/8-1:0] strb,input integer datasize, output [axi_rsp_width-1:0] response);
   reg[511:0] rsp;
   begin
    if(!check_master_address(start_addr)) begin
       $display("[%0d] : %0s : Master Address(0x%0h) is out of range. 'write_burst_strb' call failed ...\n",$time, DISP_ERR,  start_addr); 
       if(STOP_ON_ERROR) $stop;
    end else if((start_addr[31:28] === 4'b1010) || (start_addr[35:32] === 4'b0100) || (start_addr[39:36] === 4'b0001) || (start_addr[39:36] === 4'b0010) 
		     || (start_addr[39:36] === 4'b0011) || (start_addr[39:36] === 4'b0100) || (start_addr[39:32] === 8'b0100_0111) ) begin//G_MP0
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_FPD : %0s : Starting Address(0x%0h) -> AXI Write -> %0d bytes",$time, DISP_INFO,  start_addr, datasize); 
       M_AXI_HPM0_FPD.write_burst_strb(start_addr,len,siz,burst,lck,cache,prot,data,strb_en,strb,datasize,response);
       rsp = get_resp(response);
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_FPD : %0s : Done AXI Write for Starting Address(0x%0h) with Response '%0s'",$time, DISP_INFO,  start_addr, rsp); 
    end else if((start_addr[31:28] === 4'b1011) || (start_addr[35:32] === 4'b0101) || (start_addr[39:32] === 8'b0100_1000) || (start_addr[39:36] === 4'b0101) ||  
		        (start_addr[39:36] === 4'b0110) || (start_addr[39:36] === 4'b0111) || (start_addr[39:32] === 8'b0111_1111) )  begin//G_MP1
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM1_FPD : %0s : Starting Address(0x%0h) -> AXI Write -> %0d bytes",$time, DISP_INFO,  start_addr, datasize); 
       M_AXI_HPM1_FPD.write_burst_strb(start_addr,len,siz,burst,lck,cache,prot,data,strb_en,strb,datasize,response);
       rsp = get_resp(response);
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM1_FPD : %0s : Done AXI Write for Starting Address(0x%0h) with Response '%0s'",$time, DISP_INFO,  start_addr, rsp); 
    end else if(start_addr[39:28] === 12'b0000_0000_1000) begin//G_MP2
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_LPD : %0s : Starting Address(0x%0h) -> AXI Write -> %0d bytes",$time, DISP_INFO,  start_addr, datasize); 
       M_AXI_HPM0_LPD.write_burst_strb(start_addr,len,siz,burst,lck,cache,prot,data,strb_en,strb,datasize,response);
       rsp = get_resp(response);
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_LPD : %0s : Done AXI Write for Starting Address(0x%0h) with Response '%0s'",$time, DISP_INFO,  start_addr, rsp); 
    end else
       $display("[%0d] : %0s : Invalid Address(0x%0h) 'write_burst_strb' call failed ... \n",$time, DISP_ERR, start_addr); 
   end
 endtask 

 task automatic write_burst_concurrent(input [addr_width-1:0] start_addr,input [axi_len_width-1:0] len,input [axi_size_width-1:0] siz,input [axi_brst_type_width-1:0] burst,input [axi_lock_width-1:0] lck,input [axi_cache_width-1:0] cache,input [axi_prot_width-1:0] prot,input [(axi_max_mdata_width*axi_burst_len)-1:0] data,input integer datasize, output [axi_rsp_width-1:0] response);
   reg[511:0] rsp; /// string for response
   begin
    if(!check_master_address(start_addr)) begin
       $display("[%0d] : %0s : Master Address(0x%0h) is out of range. 'write_burst_concurrent' call failed ...\n",$time, DISP_ERR,  start_addr); 
       if(STOP_ON_ERROR) $stop;
    end else if((start_addr[31:28] === 4'b1010) || (start_addr[35:32] === 4'b0100) || (start_addr[39:36] === 4'b0001) || (start_addr[39:36] === 4'b0010) 
		     || (start_addr[39:36] === 4'b0011) || (start_addr[39:36] === 4'b0100) || (start_addr[39:32] === 8'b0100_0111) ) begin//G_MP0
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_FPD : %0s : Starting Address(0x%0h) -> AXI Write -> %0d bytes",$time, DISP_INFO,  start_addr, datasize); 
       M_AXI_HPM0_FPD.write_burst_concurrent(start_addr,len,siz,burst,lck,cache,prot,data,datasize,response);
       rsp = get_resp(response);
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_FPD : %0s : Done AXI Write for Starting Address(0x%0h) with Response '%0s'",$time, DISP_INFO,  start_addr, rsp); 
    end else if((start_addr[31:28] === 4'b1011) || (start_addr[35:32] === 4'b0101) || (start_addr[39:32] === 8'b0100_1000) || (start_addr[39:36] === 4'b0101) ||  
		        (start_addr[39:36] === 4'b0110) || (start_addr[39:36] === 4'b0111) || (start_addr[39:32] === 8'b0111_1111) ) begin//G_MP1
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM1_FPD : %0s : Starting Address(0x%0h) -> AXI Write -> %0d bytes",$time, DISP_INFO,  start_addr, datasize); 
       M_AXI_HPM1_FPD.write_burst_concurrent(start_addr,len,siz,burst,lck,cache,prot,data,datasize,response);
       rsp = get_resp(response);
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM1_FPD : %0s : Done AXI Write for Starting Address(0x%0h) with Response '%0s'",$time, DISP_INFO,  start_addr, rsp); 
    end else if(start_addr[39:28] === 12'b0000_0000_1000) begin//G_MP2
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_LPD : %0s : Starting Address(0x%0h) -> AXI Write -> %0d bytes",$time, DISP_INFO,  start_addr, datasize); 
       M_AXI_HPM0_LPD.write_burst_concurrent(start_addr,len,siz,burst,lck,cache,prot,data,datasize,response);
       rsp = get_resp(response);
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_LPD : %0s : Done AXI Write for Starting Address(0x%0h) with Response '%0s'",$time, DISP_INFO,  start_addr, rsp); 
    end else
       $display("[%0d] : %0s : Invalid Address(0x%0h) 'write_burst_concurrent' call failed ... \n",$time, DISP_ERR, start_addr); 
   end
 endtask 

 task automatic read_burst;
   input [addr_width-1:0] start_addr;
   input [axi_len_width-1:0] len;
   input [axi_size_width-1:0] siz;
   input [axi_brst_type_width-1:0] burst;
   input [axi_lock_width-1:0] lck;
   input [axi_cache_width-1:0] cache;
   input [axi_prot_width-1:0] prot;
   output [(axi_max_mdata_width*axi_burst_len)-1:0] data;
   output [(axi_rsp_width*axi_burst_len)-1:0] response;
   reg[511:0] rsp;
   begin
    if(!check_master_address(start_addr)) begin
       $display("[%0d] : %0s : Master Address(0x%0h) is out of range. 'read_burst' call failed ...\n",$time, DISP_ERR,  start_addr); 
       if(STOP_ON_ERROR) $stop;
    end else if((start_addr[31:28] === 4'b1010) || (start_addr[35:32] === 4'b0100) || (start_addr[39:36] === 4'b0001) || (start_addr[39:36] === 4'b0010) 
		     || (start_addr[39:36] === 4'b0011) || (start_addr[39:36] === 4'b0100) || (start_addr[39:32] === 8'b0100_0111) ) begin//G_MP0
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_FPD : %0s : Starting Address(0x%0h) -> AXI Read",$time, DISP_INFO,  start_addr); 
       M_AXI_HPM0_FPD.read_burst(start_addr,len,siz,burst,lck,cache,prot,data,response);
       rsp = get_resp(response);
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_FPD : %0s : Done AXI Read for Starting Address(0x%0h) with Response '%0s'",$time, DISP_INFO,  start_addr, rsp); 
    end else if((start_addr[31:28] === 4'b1011) || (start_addr[35:32] === 4'b0101) || (start_addr[39:32] === 8'b0100_1000) || (start_addr[39:36] === 4'b0101) ||  
		        (start_addr[39:36] === 4'b0110) || (start_addr[39:36] === 4'b0111) || (start_addr[39:32] === 8'b0111_1111) ) begin//G_MP1
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM1_FPD : %0s : Starting Address(0x%0h) -> AXI Read",$time, DISP_INFO,  start_addr); 
       M_AXI_HPM1_FPD.read_burst(start_addr,len,siz,burst,lck,cache,prot,data,response);
       rsp = get_resp(response);
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM1_FPD : %0s : Done AXI Read for Starting Address(0x%0h) with Response '%0s'",$time, DISP_INFO,  start_addr, rsp); 
    end else if(start_addr[39:28] === 12'b0000_0000_1000) begin//G_MP2
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_LPD : %0s : Starting Address(0x%0h) -> AXI Read",$time, DISP_INFO,  start_addr); 
       M_AXI_HPM0_LPD.read_burst(start_addr,len,siz,burst,lck,cache,prot,data,response);
       rsp = get_resp(response);
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_LPD : %0s : Done AXI Read for Starting Address(0x%0h) with Response '%0s'",$time, DISP_INFO,  start_addr, rsp); 
    end else
       $display("[%0d] : %0s : Invalid Address(0x%0h) 'read_burst' call failed ... \n",$time, DISP_ERR, start_addr); 
    end
 endtask 

 task automatic wait_reg_update;
   input [addr_width-1:0] addr;
   input [data_width-1:0] data_i;
   input [data_width-1:0] mask_i;
   input [int_width-1:0] time_interval;
   input [int_width-1:0] time_out;
   output [data_width-1:0] data_o;

   reg upd_done0;
   reg upd_done1;
   reg upd_done2;
   begin
    if(!check_master_address(addr)) begin
       $display("[%0d] : %0s : Address(0x%0h) is out of range. 'wait_reg_update' call failed ...\n",$time, DISP_ERR,  addr); 
       if(STOP_ON_ERROR) $stop;
    end else if(addr[31:28] === 4'b1010) begin//G_MP0
     if(reg_update_key_0) begin
       reg_update_key_0 = 0;
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_FPD : %0s : 'wait_reg_update' called for Address(0x%0h), Mask(0x%0h), Match Pattern(0x%0h) \n ",$time, DISP_INFO, addr, mask_i, data_i); 
       M_AXI_HPM0_FPD.wait_reg_update(addr, data_i, mask_i, time_interval, time_out, data_o, upd_done0);
       if(DEBUG_INFO && upd_done0)
         $display("[%0d] : M_AXI_HPM0_FPD : %0s : Register mapped at Address(0x%0h) is updated ",$time, DISP_INFO, addr); 
       reg_update_key_0 = 1;
     end else
       $display("[%0d] : M_AXI_HPM0_FPD : One instance of 'wait_reg_update' thread is already running.Only one instance can be called at a time ...\n",$time, DISP_WARN); 
    end else if(addr[31:28] === 4'b1011) begin//G_MP1
     if(reg_update_key_1) begin
       reg_update_key_1 = 0;
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM1_FPD : %0s : 'wait_reg_update' called for Address(0x%0h), Mask(0x%0h), Match Pattern(0x%0h) \n ",$time, DISP_INFO, addr, mask_i, data_i); 
       M_AXI_HPM1_FPD.wait_reg_update(addr, data_i, mask_i, time_interval, time_out, data_o, upd_done1);
       if(DEBUG_INFO && upd_done1)
         $display("[%0d] : M_AXI_HPM1_FPD : %0s : Register mapped at Address(0x%0h) is updated ",$time, DISP_INFO,  addr); 
       reg_update_key_1 = 1;
     end else
       $display("[%0d] : M_AXI_HPM1_FPD : One instance of 'wait_reg_update' thread is already running.Only one instance can be called at a time ...\n",$time, DISP_WARN); 
    end else if(addr[31:29] === 3'b100) begin//G_MP2
     if(reg_update_key_2) begin
       reg_update_key_2 = 0;
       if(DEBUG_INFO)
         $display("[%0d] : M_AXI_HPM0_LPD : %0s : 'wait_reg_update' called for Address(0x%0h), Mask(0x%0h), Match Pattern(0x%0h) \n ",$time, DISP_INFO, addr, mask_i, data_i); 
       M_AXI_HPM0_LPD.wait_reg_update(addr, data_i, mask_i, time_interval, time_out, data_o, upd_done2);
       if(DEBUG_INFO && upd_done2)
         $display("[%0d] : M_AXI_HPM0_LPD : %0s : Register mapped at Address(0x%0h) is updated ",$time, DISP_INFO,  addr); 
       reg_update_key_2 = 1;
     end else
       $display("[%0d] : M_AXI_HPM0_LPD : One instance of 'wait_reg_update' thread is already running.Only one instance can be called at a time ...\n",$time, DISP_WARN); 
    end else
       $display("[%0d] : %0s : Invalid Address(0x%0h) 'wait_reg_update' call failed ... \n",$time, DISP_ERR, addr); 
   end
 endtask 

/* API to read register map */
 task read_register_map;
   input [addr_width-1:0] start_addr;
   input [max_regs_width:0] no_of_registers;
   output[max_burst_bits-1 :0] data;
   reg [max_regs_width:0] no_of_regs;
   begin
    no_of_regs = no_of_registers;
    if(no_of_registers > 32) begin
      $display("[%0d] : %0s : No_of_Registers(%0d) exceeds the supported number (32).\n Only 32 registers will be read.",$time, DISP_ERR, start_addr);
      no_of_regs = 32;
    end
    if(check_addr_aligned(start_addr)) begin
      if(decode_address(start_addr) == REG_MEM) begin
        if(DEBUG_INFO)  $display("[%0d] : %0s : Reading Registers starting address (0x%0h) -> %0d registers",$time, DISP_INFO,  start_addr,no_of_regs ); 
        regc.regm.read_reg_mem(data,start_addr,no_of_regs*4); /// as each register is of 4 bytes
        if(DEBUG_INFO)  $display("[%0d] : %0s : DONE -> Reading Registers starting address (0x%0h), Data returned(0x%0h)",$time, DISP_INFO,  start_addr, data ); 
      end else begin
       $display("[%0d] : %0s : Invalid Address(0x%0h) for Register Read. 'read_register_map' call failed ...",$time, DISP_ERR, start_addr);
      end
    end else begin
       data = 0;
       $display("[%0d] : %0s : Address(0x%0h) has to be 32-bit aligned. 'read_register_map' call failed ...",$time, DISP_ERR, start_addr);
    end
   end
 endtask

/* API to read single register */
 task read_register;
   input [addr_width-1:0] addr;
   output[data_width-1:0] data;
   begin
    if(check_addr_aligned(addr)) begin
       if(decode_address(addr) == REG_MEM) begin
         if(DEBUG_INFO)  $display("[%0d] : %0s : Reading Register (0x%0h) ",$time, DISP_INFO,  addr ); 
         regc.regm.get_data(addr >> 2, data);
         if(DEBUG_INFO)  $display("[%0d] : %0s : DONE -> Reading Register (0x%0h), Data returned(0x%0h)",$time, DISP_INFO,  addr, data ); 
       end else begin
         $display("[%0d] : %0s : Invalid Address(0x%0h) for Register Read. 'read_register' call failed ...",$time, DISP_ERR, addr);
       end
    end else begin
       data = 0;
       $display("[%0d] : %0s : Address(0x%0h) has to be 32-bit aligned. 'read_register' call failed ...",$time, DISP_ERR, addr);
    end

   end
 endtask

  /* API to set the AXI-Slave profile*/ 
 task automatic set_slave_profile;
    input[1023:0] name;
    input[1:0] latency ;
    begin 
     if(DEBUG_INFO) $display("[%0d] : %0s : %0s Port/s : Setting Slave profile",$time, DISP_INFO,  name);
     case(name)
      "S_AXI_HPC0_FPD" : S_AXI_HPC0_FPD.set_latency_type(latency);
      "S_AXI_HPC1_FPD" : S_AXI_HPC1_FPD.set_latency_type(latency);
      "S_AXI_HP0_FPD" : S_AXI_HP0_FPD.set_latency_type(latency);
      "S_AXI_HP1_FPD" : S_AXI_HP1_FPD.set_latency_type(latency);
      "S_AXI_HP2_FPD" : S_AXI_HP2_FPD.set_latency_type(latency);
      "S_AXI_HP3_FPD" : S_AXI_HP3_FPD.set_latency_type(latency);
      "S_AXI_HPM0_LPD" : S_AXI_HPM0_LPD.set_latency_type(latency);
      "S_AXI_ACP" : S_AXI_ACP.set_latency_type(latency);
      "S_AXI_ACE" : S_AXI_ACE.set_latency_type(latency);
      "ALL"       : begin
                     S_AXI_HPC0_FPD.set_latency_type(latency);
                     S_AXI_HPC1_FPD.set_latency_type(latency);
                     S_AXI_HP0_FPD.set_latency_type(latency);
                     S_AXI_HP1_FPD.set_latency_type(latency);
                     S_AXI_HP2_FPD.set_latency_type(latency);
                     S_AXI_HP3_FPD.set_latency_type(latency);
                     S_AXI_HPM0_LPD.set_latency_type(latency);
                     S_AXI_ACP.set_latency_type(latency);
                     S_AXI_ACE.set_latency_type(latency);
                    end  
     endcase
    end
 endtask


/*------------------------------ LOCAL APIs ------------------------------------------------ */

  /* local API for address decoding*/
  function automatic [1:0] decode_address;
    input [addr_width-1:0] address;
    begin
      if(address >= ocm_start_addr && address <= ocm_end_addr )
        decode_address = OCM_MEM; /// OCM 
      else if(address >= ddr_start_addr && address <= ddr_end_addr)
        decode_address = DDR_MEM; /// DDR 
      else if(C_HIGH_DDR_EN && address >= high_ddr_start_addr)
        decode_address = DDR_MEM; /// DDR
      else if(address >= reg_start_addr && address <= reg_end_addr)
        decode_address = REG_MEM; /// Register Map
      else
        decode_address = INVALID_MEM_TYPE; /// ERROR in Address 
    end
  endfunction 

  /* local API for checking address is 32-bit (4-byte) aligned */
  function automatic check_addr_aligned;
    input [addr_width-1:0] address;
    begin 
      if((address%4) !=0 ) begin // 
        check_addr_aligned = 0; ///not_aligned
      end else
        check_addr_aligned = 1;
    end
  endfunction

 /* local API to check address for GP Masters */
 function check_master_address; 
   input [addr_width-1:0] address;
   begin
     if((address >= m_axi_gp0_baseaddr && address <= m_axi_gp0_highaddr) || 
	    (address >= m_axi_gp0_mid_baseaddr && address <= m_axi_gp0_mid_highaddr) || 
		(address >= m_axi_gp0_high_baseaddr && address <= m_axi_gp0_high_highaddr)) 
       check_master_address = 1'b1; 
     else if(address >= m_axi_gp1_baseaddr && address <= m_axi_gp1_highaddr|| 
	        (address >= m_axi_gp1_mid_baseaddr && address <= m_axi_gp1_mid_highaddr) || 
		    (address >= m_axi_gp1_high_baseaddr && address <= m_axi_gp1_high_highaddr)) 
       check_master_address = 1'b1; 
     else if(address >= m_axi_gp2_baseaddr && address <= m_axi_gp2_highaddr) 
       check_master_address = 1'b1; 
     else
       check_master_address = 1'b0; /// ERROR in Address 
   end
 endfunction

 /* Response decode */
 function automatic [511:0] get_resp;
   input[axi_rsp_width-1:0] response;
   begin 
    case(response)
     2'b00 : get_resp = "OKAY";
     2'b01 : get_resp = "EXOKAY";
     2'b10 : get_resp = "SLVERR";
     2'b11 : get_resp = "DECERR";
    endcase
   end
 endfunction 
