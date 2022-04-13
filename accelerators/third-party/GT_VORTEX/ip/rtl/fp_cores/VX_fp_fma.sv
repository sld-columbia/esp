`include "VX_fpu_define.vh"

module VX_fp_fma #( 
    parameter TAGW = 1,
    parameter LANES = 1
) (
    input wire clk,
    input wire reset,   

    output wire ready_in,
    input wire  valid_in,

    input wire [TAGW-1:0] tag_in,
    
    input wire [`INST_FRM_BITS-1:0] frm,

    input wire  do_madd,
    input wire  do_sub,
    input wire  do_neg,

    input wire [LANES-1:0][31:0]  dataa,
    input wire [LANES-1:0][31:0]  datab,
    input wire [LANES-1:0][31:0]  datac,
    output wire [LANES-1:0][31:0] result,  

    output wire has_fflags,
    output fflags_t [LANES-1:0] fflags,

    output wire [TAGW-1:0] tag_out,

    input wire  ready_out,
    output wire valid_out
);

    wire stall = ~ready_out && valid_out;
    wire enable = ~stall;
    //Xilinx FPU wires
    //assign valid_out = 
    //reg c_tready_fpdiv, b_tready_fpdiv, a_tready_fpdiv; 
    for (genvar i = 0; i < LANES; i++) begin       
        reg [31:0] a, b, c;

        always @(*) begin
            if (do_madd) begin
                // MADD/MSUB/NMADD/NMSUB
                a = do_neg ? {~dataa[i][31], dataa[i][30:0]} : dataa[i];                    
                b = datab[i];
                c = (do_neg ^ do_sub) ? {~datac[i][31], datac[i][30:0]} : datac[i];
            end else begin
                if (do_neg) begin
                    // MUL
                    a = dataa[i];
                    b = datab[i];
                    c = 0;
                end else begin
                    // ADD/SUB
                    a = 32'h3f800000; // 1.0f
                    b = dataa[i];
                    c = do_sub ? {~datab[i][31], datab[i][30:0]} : datab[i];
                end
            end    
        end

    `ifdef VERILATOR
        reg [31:0] r;
        fflags_t f;

        always @(*) begin        
            dpi_fmadd (enable && valid_in, a, b, c, frm, r, f);
        end
        `UNUSED_VAR (f)

        VX_shift_register #(
            .DATAW  (32),
            .DEPTH  (`LATENCY_FMA),
            .RESETW (1)
        ) shift_req_dpi (
            .clk      (clk),
            .reset    (reset),
            .enable   (enable),
            .data_in  (r),
            .data_out (result[i])
        );
    `else
        `RESET_RELAY (fma_reset);

        acl_fmadd fmadd (
            .aclk    (clk),
            .aresetn (fma_reset),
            .aclken     (enable),
            .s_axis_a_tdata      (a),
            .s_axis_b_tdata      (b),
            .s_axis_c_tdata      (c),
            .m_axis_result_tdata      (result[i]),
	    .s_axis_a_tvalid(valid_in),               // input wire s_axis_a_tvalid
            //.s_axis_a_tready(a_tready_fpdiv),       // output wire s_axis_a_tready
            .s_axis_b_tvalid(valid_in),                       // input wire s_axis_b_tvalid
            //.s_axis_b_tready(b_tready_fpdiv),       // output wire s_axis_b_tready
            .s_axis_c_tvalid(valid_in)                       // input wire s_axis_c_tvalid
            //.s_axis_c_tready(c_tready_fpdiv),       // output wire s_axis_c_tready
	    //.m_axis_result_tvalid()  // output wire m_axis_result_tvalid
        );
    `endif
    end
    
    VX_shift_register #(
        .DATAW  (1 + TAGW),
        .DEPTH  (`LATENCY_FMA),
        .RESETW (1)
    ) shift_reg (
        .clk(clk),
        .reset    (reset),
        .enable   (enable),
        .data_in  ({valid_in,  tag_in}),
        .data_out ({valid_out, tag_out})
    );

    assign ready_in = enable;
   // || (a_tready_fpdiv && b_tready_fpdiv && c_tready_fpdiv);

    `UNUSED_VAR (frm)
    assign has_fflags = 0;
    assign fflags = 0;

endmodule
