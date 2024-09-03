// This package defines constants, data types and functions for the NoC

package noc;

  //
  // Configuration parameters
  //

  // Queues
  parameter int unsigned PortQueueDepth = 4;

  // Coordinates
  parameter int unsigned xMax = 16;
  parameter int unsigned yMax = 16;

  // Message Type
  parameter int unsigned messageTypeWidth = 5;

  //
  // Direction constants, types and functions
  //

  // Router ports enable
  parameter bit [4:0] AllPorts               = 5'b11111;
  parameter bit [4:0] TopLeftRouterPorts     = 5'b11010;
  parameter bit [4:0] TopRightRouterPorts    = 5'b10110;
  parameter bit [4:0] BottomLeftRouterPorts  = 5'b11001;
  parameter bit [4:0] BottomRightRouterPorts = 5'b10101;

  typedef enum logic [2:0] {
    kNorthPort = 3'd0,
    kSouthPort = 3'd1,
    kWestPort  = 3'd2,
    kEastPort  = 3'd3,
    kLocalPort = 3'd4
  } noc_port_t;

  // one-hot encoding of the ports for routing
  typedef struct packed {
    logic        go_local;
    logic        go_east;
    logic        go_west;
    logic        go_south;
    logic        go_north;
  } direction_t;

  function automatic direction_t get_onehot_port (
    input noc_port_t port);
    get_onehot_port.go_north = (port == kNorthPort);
    get_onehot_port.go_south = (port == kSouthPort);
    get_onehot_port.go_west  = (port == kWestPort);
    get_onehot_port.go_east  = (port == kEastPort);
    get_onehot_port.go_local = (port == kLocalPort);
  endfunction // get_onehot_port

  function automatic noc_port_t get_direction (
    input direction_t direction);
    if (direction.go_north) return kNorthPort;
    else if (direction.go_south) return kSouthPort;
    else if (direction.go_west) return kWestPort;
    else if (direction.go_east) return kEastPort;
    else if (direction.go_local) return kLocalPort;
    else return kNorthPort;
  endfunction // get_direction

  function automatic noc_port_t int2noc_port(
    input int i);
    case(i)
      0 : return kNorthPort;
      1 : return kSouthPort;
      2 : return kWestPort;
      3 : return kEastPort;
      4 : return kLocalPort;
      default : return kNorthPort;
    endcase
  endfunction // int2noc_port

  parameter direction_t goNorth = get_onehot_port(kNorthPort);
  parameter direction_t goSouth = get_onehot_port(kSouthPort);
  parameter direction_t goWest = get_onehot_port(kWestPort);
  parameter direction_t goEast = get_onehot_port(kEastPort);
  parameter direction_t goLocal = get_onehot_port(kLocalPort);

  //
  // Coordinates types
  //

  parameter int unsigned xWidth = $clog2(xMax);
  parameter int unsigned yWidth = $clog2(xMax);

  typedef struct packed {
    logic [yWidth-1:0] y;
    logic [xWidth-1:0] x;
  } xy_t;


  //
  // Flow control types
  //
  typedef enum logic {
    kFlowControlAckNack = 1'b0,
    kFlowControlCreditBased = 1'b1
  } noc_flow_control_t;

  parameter int unsigned CreditsWidth = $clog2(PortQueueDepth + 1);
  typedef logic [4:0][CreditsWidth-1:0] credits_t;

  //
  // Packet info encoding
  //

  typedef logic [messageTypeWidth-1:0] message_t;

  typedef struct packed {
    logic head;
    logic tail;
  } preamble_t;

endpackage
