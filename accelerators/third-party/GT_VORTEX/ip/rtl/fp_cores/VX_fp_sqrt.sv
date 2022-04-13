`include "VX_fpu_define.vh"

module VX_fp_sqrt #( 
    parameter TAGW = 1,
    parameter LANES = 1
) (
    input wire clk,
    input wire reset,   

    output wire ready_in,
    input wire  valid_in,

    input wire [TAGW-1:0] tag_in,
    
    input wire [`INST_FRM_BITS-1:0] frm,

    input wire [LANES-1:0][31:0]  dataa,
    output wire [LANES-1:0][31:0] result,  

    output wire has_fflags,
    output fflags_t [LANES-1:0] fflags,

    output wire [TAGW-1:0] tag_out,

    input wire  ready_out,
    output wire valid_out
);    
    wire stall = ~ready_out && valid_out;
    wire enable = ~stall;

    //xilinx fpu wires
    //reg a_tready_fpdiv;
    for (genvar i = 0; i < LANES; i++) begin
    `ifdef VERILATOR
        reg [31:0] r;
        fflags_t f;

        always @(*) begin        
            dpi_fsqrt (enable && valid_in, dataa[i], frm, r, f);
        end
        `UNUSED_VAR (f)

        VX_shift_register #(
            .DATAW  (32),
            .DEPTH  (`LATENCY_FSQRT),
            .RESETW (1)
        ) shift_req_dpi (
            .clk      (clk),
            .reset    (reset),
            .enable   (enable),
            .data_in  (r),
            .data_out (result[i])
        );
    `else
        `RESET_RELAY (fsqrt_reset);

        acl_fsqrt fsqrt (
            .aclk    (clk),
            .aresetn (fsqrt_reset),
            .aclken     (enable),
            .s_axis_a_tdata(dataa[i]),
            .m_axis_result_tdata(result[i]),
	    .s_axis_a_tvalid(valid_in)                       // input wire s_axis_c_tvalid
            //.s_axis_a_tready(a_tready_fpdiv),       // output wire s_axis_c_tready
            //.m_axis_result_tvalid(valid_out)  // output wire m_axis_result_tvalid
        );
    `endif
    end

    VX_shift_register #(
        .DATAW  (1 + TAGW),
        .DEPTH  (`LATENCY_FSQRT),
        .RESETW (1)
    ) shift_reg (
        .clk      (clk),
        .reset    (reset),
        .enable   (enable),
        .data_in  ({valid_in,  tag_in}),
        .data_out ({valid_out, tag_out})
    );

    assign ready_in = enable;
   // || a_tready_fpdiv;

    `UNUSED_VAR (frm)
    assign has_fflags = 0;
    assign fflags = 0;

endmodule
