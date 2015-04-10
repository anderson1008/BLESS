`include "global.v"

module portAllocTop ( 
   req, alloc, remain
);

input    [`NUM_PORT-1:0]       req;
output   [`NUM_PORT-1:0]       alloc, remain;

highestBit allocProdPort (req, alloc);

assign remain = (|req) ? ~alloc : 5'b11111;

endmodule