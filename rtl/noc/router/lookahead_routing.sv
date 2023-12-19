// Compute next YX positional routing for a 3D mesh NoC
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

module lookahead_routing #(
  parameter integer DEST_SIZE = 1)
  (
   input logic clk,
   input noc::xy_t position,
   input noc::xy_t [0:DEST_SIZE-1] destination,
   input logic [DEST_SIZE-1:0] val,
   input noc::direction_t current_routing,
   output noc::direction_t next_routing
   );
  
   logic [4:0] testing_local_west;
   logic [4:0] testing_local_east;
   logic [4:0] testing_local_north;
   logic [4:0] testing_local_south;
   logic [4:0] testing_local_local;

 
   noc::direction_t [DEST_SIZE-1:0] routing_paths;

  function automatic noc::direction_t routing(
    input noc::xy_t next_position,
    input noc::xy_t destination);
    // Compute next routing: go East/West first, then North/South
    noc::direction_t west, east, north, south, local1;

    west = next_position.x > destination.x ?
	  //  00100 : 11011;
	   noc::goWest : ~noc::goWest; 
    east = next_position.x < destination.x ?
            // 01000 : 10111;
           noc::goEast : ~noc::goEast;
    north = next_position.y > destination.y ?
            //  01101 : 11110;
            noc::goNorth | noc::goWest | noc::goEast : ~noc::goNorth;
    south = next_position.y < destination.y ?
            //  01110 : 11101;
            noc::goSouth | noc::goWest | noc::goEast : ~noc::goSouth;
    if (next_position.y == destination.y && next_position.x == destination.x)
	local1.go_local = 1;
 

    // Result is go_local when none of the above is true
    routing = west & east & north & south;

    //routing = local1;

    testing_local_west = west;
    testing_local_east =  east;
    testing_local_north = north;
    testing_local_south = south;
    testing_local_local = local1;


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
    // The function routing can be called for all destinations.
    // This can be done for all the destinations and then the final next_routing can be a OR of all the next_routing times.
    
    // When current_routing is goLocal, we don't care about next_routing assignment
    next_routing = 5'b0;
    for(int rout_num = 0; rout_num <DEST_SIZE; rout_num++) begin
        routing_paths[rout_num] =5'b00000; 
    end
    for(int dest_num = 0; dest_num < DEST_SIZE; dest_num++) begin
      if(val[dest_num])begin
        if((position.x == destination[dest_num].x && position.y == destination[dest_num].y)) begin
          routing_paths[dest_num].go_local = 0;
          routing_paths[dest_num].go_east = 0;
          routing_paths[dest_num].go_west = 0;
          routing_paths[dest_num].go_south = 0;
          routing_paths[dest_num].go_north = 0;
        end

        //if(current_routing == noc::goWest)    
        else if(current_routing.go_west)
        begin
          routing_paths[dest_num] = routing(next_position_q[noc::kWestPort], destination[dest_num]);
        end 

        //if(current_routing == noc::goEast)
        else if(current_routing.go_east)
        begin
          routing_paths[dest_num] = routing(next_position_q[noc::kEastPort], destination[dest_num]);
        end

        //if (current_routing == noc::goNorth) 
        else if (current_routing.go_north) 
        begin
          routing_paths[dest_num] = routing(next_position_q[noc::kNorthPort],destination[dest_num]);
        end
    
        //if(current_routing == noc::goSouth)
        else if(current_routing.go_south)
        begin
          routing_paths[dest_num] = routing(next_position_q[noc::kSouthPort], destination[dest_num]);
        end
        //
        //if(current_routing == noc::goLocal)
        
        else if(current_routing.go_local)
        begin
          routing_paths[dest_num] = routing(next_position_q[noc::kLocalPort], destination[dest_num]);
        end
      end
    end
    //next_routing = routing_paths[0] | routing_paths[1] | routing_paths[2];
       
    for(int rout_num = 0; rout_num <DEST_SIZE; rout_num++) begin
        next_routing = next_routing | routing_paths[rout_num];
    end
  end
endmodule
