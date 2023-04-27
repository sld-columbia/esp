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
   input noc::xy_t [1:0] destination,
   input logic [1:0] val,
   input noc::direction_t current_routing,
   output noc::direction_t next_routing
   );
  
   logic [4:0] testing_local_west;
   logic [4:0] testing_local_east;
   logic [4:0] testing_local_north;
   logic [4:0] testing_local_south;
   logic [4:0] testing_local_local;

 
   noc::direction_t [1:0] routing_paths;

  function automatic noc::direction_t routing(
    input noc::xy_t next_position,
    input noc::xy_t destination);
    // Compute next routing: go East/West first, then North/South
    noc::direction_t west, east, north, south, local1;

	west.go_local = 0;
	west.go_east = 0;
	west.go_west = 0;
	west.go_south = 0;
	west.go_north = 0;
	east.go_local = 0;
	east.go_east = 0;
	east.go_west = 0;
	east.go_south = 0;
	east.go_north = 0;
	north.go_local = 0;
	north.go_east = 0;
	north.go_west = 0;
	north.go_south = 0;
	north.go_north = 0;
	south.go_local = 0;
	south.go_east = 0;
	south.go_west = 0;
	south.go_south = 0;
	south.go_north = 0;
	local1.go_local = 0;
	local1.go_east = 0;
	local1.go_west = 0;
	local1.go_south = 0;
	local1.go_north = 0;



    if(next_position.x > destination.x) 
	begin
		west.go_west = 1;
		local1.go_west = 1;
	end
	else begin
		west.go_local = 1;
		west.go_east = 1;
		west.go_west = 0;
		west.go_south = 1;
		west.go_north = 1;
	end
    if(next_position.x < destination.x) 
	begin
		east.go_east = 1; 
		local1.go_east = 1;
	end
	else begin
		
		east.go_local = 1;
		east.go_east = 0;
		east.go_west = 1;
		east.go_south = 1;
		east.go_north = 1;

	end
    
           // 00100 : 11011
           //noc::goWest : ~noc::goWest;


     if(next_position.y > destination.y) 
	begin
		north.go_north = 1;
		local1.go_north = 1;
	end
	else begin
		north.go_local = 1;
		north.go_east = 1; 
        	north.go_west = 1;
        	north.go_south = 1;
        	north.go_north = 0;
	end

     if(next_position.y < destination.y) 
	begin
		south.go_south = 1;
		local1.go_south = 1;
	end
	else
	begin

		south.go_local = 1;
		south.go_east = 1; 
        	south.go_west = 1;
        	south.go_south = 0;
        	south.go_north = 1;
	
	end


//    east = next_position.x < destination.x ?
//           // 01000 : 10111
//           noc::goEast : ~noc::goEast;
//    north = next_position.y > destination.y ?
//            // 01101 : 11110
//            noc::goNorth | noc::goWest | noc::goEast : ~noc::goNorth;
//    south = next_position.y < destination.y ?
//            // 01110 : 11101
//            noc::goSouth | noc::goWest | noc::goEast : ~noc::goSouth;
    if (next_position.y == destination.y && next_position.x == destination.x)
	local1.go_local = 1;
 

    // Result is go_local when none of the above is true
    //routing = west & east & north & south;

    routing = local1;

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
    next_routing = current_routing;
    routing_paths[0] = current_routing;
    routing_paths[1] = current_routing;

    //if (current_routing == noc::goNorth) 
    //begin
    //  for(int dest_num = 0; dest_num < 2; dest_num++) begin 
    //    if(val[dest_num])
    //      routing_paths[dest_num] = routing(next_position_q[noc::kNorthPort],destination[dest_num]);
    //  end
    //end

    //if(current_routing == noc::goSouth)
    //begin
    //  for(int dest_num = 0; dest_num < 2; dest_num++) begin
    //    if(val[dest_num])
    //      routing_paths[dest_num] = routing(next_position_q[noc::kSouthPort], destination[dest_num]);
    //  end
    //end
    //
    //if(current_routing == noc::goWest)
    //begin
    //  for(int dest_num = 0; dest_num < 2; dest_num++) begin
    //    if(val[dest_num])
    //      routing_paths[dest_num] = routing(next_position_q[noc::kWestPort], destination[dest_num]);
    //  end
    //end
    //
    //if(current_routing == noc::goEast)
    //begin
    //  for(int dest_num = 0; dest_num < 2; dest_num++) begin
    //    if(val[dest_num])
    //      routing_paths[dest_num] = routing(next_position_q[noc::kEastPort], destination[dest_num]);
    //  end
    //end
    //  // When current_routing is goLocal, we don't care about next_routing assignment

    for(int dest_num = 0; dest_num < 2; dest_num++) begin
      if(val[dest_num] && (position.x == destination[dest_num].x && position.y == destination[dest_num].y)) begin
        routing_paths[dest_num].go_local = 0;
        routing_paths[dest_num].go_east = 0;
        routing_paths[dest_num].go_west = 0;
        routing_paths[dest_num].go_south = 0;
        routing_paths[dest_num].go_north = 0;
        continue;
      end
	
      //if (current_routing == noc::goNorth) 
      if (current_routing.go_north) 
      begin
          if(val[dest_num])begin
            routing_paths[dest_num] = routing(next_position_q[noc::kNorthPort],destination[dest_num]);
	    continue;
	  end
      end
  
      //if(current_routing == noc::goSouth)
      if(current_routing.go_south)
      begin
          if(val[dest_num]) begin
            routing_paths[dest_num] = routing(next_position_q[noc::kSouthPort], destination[dest_num]);
	    continue;
 	  end
      end
      //
      //if(current_routing == noc::goWest)
      if(current_routing.go_west)
      begin
          if(val[dest_num]) begin
            routing_paths[dest_num] = routing(next_position_q[noc::kWestPort], destination[dest_num]);
	    continue;
	  end
      end
      //
      //if(current_routing == noc::goEast)
      if(current_routing.go_east)
      begin
          if(val[dest_num]) begin
            routing_paths[dest_num] = routing(next_position_q[noc::kEastPort], destination[dest_num]);
	    continue;
	  end
      end

      
      if(current_routing.go_local)
      begin
          if(val[dest_num]) begin
            routing_paths[dest_num] = routing(next_position_q[noc::kLocalPort], destination[dest_num]);
	    continue;
	  end
      end
    end
    next_routing = routing_paths[0] | routing_paths[1];
  end

endmodule
