// 4 inputs to 1 output router arbiter
//
// There is no delay from request to grant.
// The abriter assumes that the request remains stable while the entire
// packet is forwarded. Hence, priority is updated whenever a tail flit
// is forwarded. Grant is locked between a head flit and the corresponding
// tail flit.
//
// Interface
//
// * Inputs
// - clk: clock.
// - rst: active-high reset.
// - request: each bit should be set to 1 if there is a valid flit coming from the corresponding
//   input port that needs to be routed to the output port arbitrated by this module.
// - forwarding_head: set to 1 to indicate the head flit of a new packet is being routed this cycle.
//   The current grant gets locked until the tail flit is forwarded (wormhole routing)
// - forwarding_tail: set to 1 to indicate the tail flit of a packet is being routed this cycle.
//   Priority is updated and grant is unlocked.
//
// * Outputs
// - grant: one-hot or zero. When grant[i] is set, request[i] is granted and the packet from the
//   corresponding input port i can be routed.
//   and the packet from the input
// - grant_valid: this flag indicates whether the current grant output is valid. When at least one
//   request bit is set, the arbiter grants the next higher priority request with zero-cycles delay,
//   unless grant is locked.
//

module router_arbiter
  (
   input  logic clk,
   input  logic rst,
   input  logic [3:0] request,
   input  logic forwarding_head,
   input  logic forwarding_tail,
   output logic [3:0] grant,
   output logic grant_valid
   );

  logic grant_locked;

  // Lock current grant for flit between head and tail, tail included
  always_ff @(posedge clk) begin
    if (rst) begin
      grant_locked <= 1'b0;
    end else begin
      if (forwarding_tail) begin
        grant_locked <= 1'b0;
      end else if (forwarding_head) begin
        grant_locked <= 1'b1;
      end
    end
  end

  assign grant_valid = |request & ~grant_locked;

  // Update priority
  typedef logic [3:0][3:0] priority_t;
  priority_t priority_mask, priority_mask_next;
  priority_t grant_stage1;
  logic [3:0][1:0] grant_stage2;

  // Higher priority is given to request[0] at reset
  localparam priority_t InitialPriority = { 4'b0000,   // request[3]
                                            4'b1000,   // request[2]
                                            4'b1100,   // request[1]
					    4'b1110 }; // request[0]

  always_ff @(posedge clk) begin
    if (rst) begin
      priority_mask <= InitialPriority;
    end else if (forwarding_tail) begin
      priority_mask <= priority_mask_next;
    end
  end

  always_comb begin
    priority_mask_next = priority_mask;

    unique case (grant)
      4'b0001 : begin
        priority_mask_next[0] = '0;
        priority_mask_next[1][0] = 1'b1;
        priority_mask_next[2][0] = 1'b1;
        priority_mask_next[3][0] = 1'b1;
      end
      4'b0010 : begin
        priority_mask_next[1] = '0;
        priority_mask_next[0][1] = 1'b1;
        priority_mask_next[2][1] = 1'b1;
        priority_mask_next[3][1] = 1'b1;
      end
      4'b0100 : begin
        priority_mask_next[2] = '0;
        priority_mask_next[0][2] = 1'b1;
        priority_mask_next[1][2] = 1'b1;
        priority_mask_next[3][2] = 1'b1;
      end
      4'b1000 : begin
        priority_mask_next[3] = '0;
        priority_mask_next[0][3] = 1'b1;
        priority_mask_next[1][3] = 1'b1;
        priority_mask_next[2][3] = 1'b1;
      end
      default begin
      end
    endcase
  end

  genvar g_i, g_j;
  for (g_i = 0; g_i < 4; g_i++) begin : gen_grant

    for (g_j = 0; g_j < 4; g_j++) begin : gen_grant_stage1
      assign grant_stage1[g_i][g_j] = request[g_j] & priority_mask[g_j][g_i];
    end

    for (g_j = 0; g_j < 2; g_j++) begin : gen_grant_stage2
      assign grant_stage2[g_i][g_j] = ~(grant_stage1[g_i][2*g_j] | grant_stage1[g_i][2*g_j + 1]);
    end

    assign grant[g_i] = &grant_stage2[g_i] & request[g_i];

  end  // gen_grant

  //
  // Assertions
  //

`ifndef SYNTHESIS
// pragma coverage off
//VCS coverage off

  a_grant_onehot: assert property (@(posedge clk) disable iff(rst) $onehot0(grant))
    else $error("Fail: a_grant_onehot");

// pragma coverage on
//VCS coverage on
`endif // ~SYNTHESIS

endmodule

module router_fork_arbiter
  (
   input  logic clk,
   input  logic rst,
   input  logic [4:0] request,
   input  logic [4:0] forwarding_head,
   input  logic [4:0] forwarding_tail,
   output logic [4:0] grant,
   output logic grant_valid
   );

  logic grant_locked;
  logic forwarding_head_input, forwarding_tail_input;
  // Lock current grant for flit between head and tail, tail included
  always_ff @(posedge clk) begin
    if (rst) begin
      grant_locked <= 1'b0;
    end else begin
      if (forwarding_tail_input) begin
        grant_locked <= 1'b0;
      end else if (forwarding_head_input) begin
        grant_locked <= 1'b1;
      end
    end
  end

  assign forwarding_head_input = |(grant & forwarding_head);
  assign forwarding_tail_input = |(grant & forwarding_tail);

  assign grant_valid = |request & ~grant_locked;

  // Update priority
  typedef logic [4:0][4:0] priority_t;
  priority_t priority_mask, priority_mask_next;
  priority_t grant_stage1;
  logic [4:0][2:0] grant_stage2;

  // Higher priority is given to request[0] at reset
  localparam priority_t InitialPriority = { 5'b00000,   // request[4]
                                            5'b10000,   // request[3]
                                            5'b11000,   // request[2]
					    5'b11100,   // request[1]
					    5'b11110 }; // request[0]

  always_ff @(posedge clk) begin
    if (rst) begin
      priority_mask <= InitialPriority;
    end else if (forwarding_tail_input) begin
      priority_mask <= priority_mask_next;
    end
  end

  always_comb begin
    priority_mask_next = priority_mask;

    unique case (grant)
      5'b00001 : begin
        priority_mask_next[0] = '0;
        priority_mask_next[1][0] = 1'b1;
        priority_mask_next[2][0] = 1'b1;
        priority_mask_next[3][0] = 1'b1;
        priority_mask_next[4][0] = 1'b1;
      end
      5'b00010 : begin
        priority_mask_next[1] = '0;
        priority_mask_next[0][1] = 1'b1;
        priority_mask_next[2][1] = 1'b1;
        priority_mask_next[3][1] = 1'b1;
        priority_mask_next[4][1] = 1'b1;
      end
      5'b00100 : begin
        priority_mask_next[2] = '0;
        priority_mask_next[0][2] = 1'b1;
        priority_mask_next[1][2] = 1'b1;
        priority_mask_next[3][2] = 1'b1;
        priority_mask_next[4][2] = 1'b1;
      end
      5'b01000 : begin
        priority_mask_next[3] = '0;
        priority_mask_next[0][3] = 1'b1;
        priority_mask_next[1][3] = 1'b1;
        priority_mask_next[2][3] = 1'b1;
        priority_mask_next[4][3] = 1'b1;
      end
      5'b10000 : begin
        priority_mask_next[4] = '0;
        priority_mask_next[0][4] = 1'b1;
        priority_mask_next[1][4] = 1'b1;
        priority_mask_next[2][4] = 1'b1;
        priority_mask_next[3][4] = 1'b1;
      end
      default begin
      end
    endcase
  end

  genvar g_i, g_j;
  for (g_i = 0; g_i < 5; g_i++) begin : gen_grant

    for (g_j = 0; g_j < 5; g_j++) begin : gen_grant_stage1
      assign grant_stage1[g_i][g_j] = request[g_j] & priority_mask[g_j][g_i];
    end

    assign grant_stage2[g_i][0] = ~(grant_stage1[g_i][0] | grant_stage1[g_i][1]);
    assign grant_stage2[g_i][1] = ~(grant_stage1[g_i][2] | grant_stage1[g_i][3]);
    assign grant_stage2[g_i][2] = ~(grant_stage1[g_i][4]);    

    assign grant[g_i] = &grant_stage2[g_i] & request[g_i];

  end  // gen_grant

  //
  // Assertions
  //

`ifndef SYNTHESIS
// pragma coverage off
//VCS coverage off

  a_grant_onehot: assert property (@(posedge clk) disable iff(rst) $onehot0(grant))
    else $error("Fail: a_grant_onehot");

// pragma coverage on
//VCS coverage on
`endif // ~SYNTHESIS

endmodule
