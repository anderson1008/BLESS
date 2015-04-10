// port allocator at last stage

`include "global.v"

module portAllocLast ( 
   req, avail, alloc
);

input    [`NUM_PORT-1:0]       req, avail;
output   [`NUM_PORT-1:0]       alloc;

wire [`NUM_PORT-1:0] tempAlloc, prodPort, deflectPort;
wire deflect;

assign tempAlloc = req & avail;
assign deflect = (|tempAlloc) ? 1'b0 : 1'b1;

highestBit allocProdPort (tempAlloc, prodPort);
highestBit deflectToPort ({1'b0,avail[3:0]}, deflectPort);

assign alloc = (|req) ? (deflect ?  deflectPort : prodPort) : 0;

endmodule