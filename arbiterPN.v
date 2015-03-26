// arbiter for permutation network

`include "global.v"

module arbiterPN (time0, time1, mode, swap);

input [`WIDTH_TIME-1:0] time0, time1;
input    mode;
output   swap;

/*
   mode
   0: flit0 has higher priority
   1: flit1 has higher priority
*/

assign swap = (mode == 0) ? (time1 <= time0) : (time0 <= time1);

endmodule