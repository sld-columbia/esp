// Ring NoC look-ahead routing
//
// Computes the next routing direction for a unidirectional or bidirectional ring.
// Tiles are ordered in row-major fashion: ring_pos = y * XLen + x.
// The ring uses West (port 2) for counterclockwise and East (port 3) for clockwise.
//
// At each hop, the module determines whether the next router in the current
// direction is the destination (route to local) or not (keep going).
//
// Interface matches lookahead_routing so it can be a drop-in replacement.
//
// Parameters
// - XLen: number of columns in the grid
// - YLen: number of rows in the grid
//

module lookahead_routing_ring #(
    parameter int unsigned XLen = 2,
    parameter int unsigned YLen = 2
) (
    input  logic clk,
    input  noc::xy_t position,
    input  noc::xy_t destination,
    input  noc::direction_t current_routing,
    output noc::direction_t next_routing
);

    localparam int unsigned TilesNum = XLen * YLen;
    localparam int unsigned PosWidth = $clog2(TilesNum > 1 ? TilesNum : 2);

    // Sample position (static input, one-cycle delay to match mesh module timing)
    noc::xy_t position_q;
    always_ff @(posedge clk) begin
        position_q <= position;
    end

    // Compute ring positions
    logic [PosWidth-1:0] curr_ring_pos;
    logic [PosWidth-1:0] next_ring_pos_cw;
    logic [PosWidth-1:0] next_ring_pos_ccw;
    logic [PosWidth-1:0] dest_ring_pos;

    always_comb begin
        curr_ring_pos = PosWidth'(position_q.y) * PosWidth'(XLen) + PosWidth'(position_q.x);
        dest_ring_pos = PosWidth'(destination.y) * PosWidth'(XLen) + PosWidth'(destination.x);

        // Next position clockwise (East)
        if (curr_ring_pos == PosWidth'(TilesNum - 1))
            next_ring_pos_cw = '0;
        else
            next_ring_pos_cw = curr_ring_pos + 1'b1;

        // Next position counterclockwise (West)
        if (curr_ring_pos == '0)
            next_ring_pos_ccw = PosWidth'(TilesNum - 1);
        else
            next_ring_pos_ccw = curr_ring_pos - 1'b1;
    end

    // Determine next-hop routing
    always_comb begin
        unique case (current_routing)
            noc::goEast: begin
                // Clockwise: check if next CW node is destination
                if (next_ring_pos_cw == dest_ring_pos)
                    next_routing = noc::goLocal;
                else
                    next_routing = noc::goEast;
            end

            noc::goWest: begin
                // Counterclockwise: check if next CCW node is destination
                if (next_ring_pos_ccw == dest_ring_pos)
                    next_routing = noc::goLocal;
                else
                    next_routing = noc::goWest;
            end

            // goLocal or unexpected: pass through
            default: next_routing = current_routing;
        endcase
    end

endmodule
