`include "global.v"

module portAllocTop ( 
   req, alloc, remain
);

input    [`NUM_PORT-1:0]       req;
output   [`NUM_PORT-1:0]       alloc, remain;

assign alloc = req;
assign remain = ~alloc;

endmodule