// port allocator 2, 3

`include "global.v"

module portAlloc ( 
   req, avail, alloc, remain
);

input    [`NUM_PORT-1:0]       req, avail;
output   [`NUM_PORT-1:0]       alloc, remain;

wire [`NUM_PORT-1:0] tempAlloc, prodPort, deflectPort;
wire deflect;

assign tempAlloc = req & avail;
assign deflect = (|tempAlloc) ? 1'b0 : 1'b1;

highestBit allocProdPort (tempAlloc, prodPort);
highestBit deflectToPort ({1'b0,avail[3:0]}, deflectPort);

assign alloc = (|req) ? (deflect ?  deflectPort : prodPort) : 0;
assign remain = ~alloc & avail;

endmodule