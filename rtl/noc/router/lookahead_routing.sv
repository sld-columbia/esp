// Compute next YX positional routing for a 2D mesh NoC
//
// This module determines the next routing direction (lookahead) for the current flit.
// First the coordinates of the next hop are determined based on the routing direction
// encoded in the header flit. Next, the routing direction is updated based on the
// coordinates of the destination router.
// Packets are routed first west or east (X axis), then north or south (Y axis).
// The YX positional routing is proven to be deadlock free.
//
// There is no delay from inputs destination and current_routing to output next_routing.
// Conversely, to improve timing, the local position input is sampled, thus there is a one-cycle
// delay from input position to output next_routing. Note, however, that position is supposed to be
// a static input after initialization, because it encodes the position of the router on the mesh.
//
// Interface
//
// * Inputs
// - clk: clock.
// - position: static input that encodes the x,y coordinates of the router on the mesh.
// - destination: x,y coordinates of the destination router.
// - current_routing: one-hot encoded routing direction for the current hop.
//
// * Outputs
// - next_routing: one-hot encoded routing direction for the next hop.
//

module lookahead_routing
  (
   input logic clk,
   input noc::xy_t position,
   input noc::xy_t destination,
   input noc::direction_t current_routing,
   output noc::direction_t next_routing
   );

  function automatic noc::direction_t routing(
    input noc::xy_t next_position,
    input noc::xy_t destination);
    // Compute next routing: go East/West first, then North/South
    noc::direction_t west, east, north, south;
    west = next_position.x > destination.x ?
           // 00100 : 11011
           noc::goWest : ~noc::goWest;
    east = next_position.x < destination.x ?
           // 01000 : 10111
           noc::goEast : ~noc::goEast;
    north = next_position.y > destination.y ?
            // 01101 : 11110
            noc::goNorth | noc::goWest | noc::goEast : ~noc::goNorth;
    south = next_position.y < destination.y ?
            // 01110 : 11101
            noc::goSouth | noc::goWest | noc::goEast : ~noc::goSouth;
    // Result is go_local when none of the above is true
    routing = west & east & north & south;
  endfunction

  // Compute next position for every possible routing except local port
  noc::xy_t [3:0] next_position_d, next_position_q;
  // North
  assign next_position_d[noc::kNorthPort].x = position.x;
  assign next_position_d[noc::kNorthPort].y = position.y - 1'b1;
  // South
  assign next_position_d[noc::kSouthPort].x = position.x;
  assign next_position_d[noc::kSouthPort].y = position.y + 1'b1;
  // West
  assign next_position_d[noc::kWestPort].x = position.x - 1'b1;
  assign next_position_d[noc::kWestPort].y = position.y;
  // East
  assign next_position_d[noc::kEastPort].x = position.x + 1'b1;
  assign next_position_d[noc::kEastPort].y = position.y;

  always_ff @(posedge clk) begin
    next_position_q <= next_position_d;
  end

  always_comb begin
    // We don't need to consider the case in which current_routing is goLocal
    unique case (current_routing)
      noc::goNorth : next_routing = routing(next_position_q[noc::kNorthPort], destination);
      noc::goSouth : next_routing = routing(next_position_q[noc::kSouthPort], destination);
      noc::goWest  : next_routing = routing(next_position_q[noc::kWestPort], destination);
      noc::goEast  : next_routing = routing(next_position_q[noc::kEastPort], destination);
      // When current_routing is goLocal, we don't care about next_routing assignment
      default : next_routing = current_routing;
    endcase
  end

endmodule
