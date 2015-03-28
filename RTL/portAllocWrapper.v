// port allocator wrapper

`include "global.v"

module portAllocWrapper (reqVector, allocVector);

input [`NUM_PORT*`NUM_PORT-1:0] reqVector; 
output [`NUM_PORT*`NUM_PORT-1:0] allocVector; 

wire [`NUM_PORT-1:0] req [0:`NUM_PORT-1];

genvar i;
generate 
   for (i=0; i<`NUM_PORT; i=i+1) begin : splitRequest
      assign req[i] = reqVector[i*`NUM_PORT+:`NUM_PORT];
   end
endgenerate

wire [`NUM_PORT-1:0] remain [`NUM_PORT-2:0];
wire [`NUM_PORT-1:0] alloc [`NUM_PORT-1:0]; 

portAllocTop portAlloc1( 
   req[0], alloc[0], remain[0]
);

portAlloc portAlloc2( 
   req[1], remain[0], alloc[1], remain[1]
);

portAlloc portAlloc3( 
   req[2], remain[1], alloc[2], remain[2]
);

portAlloc portAlloc4( 
   req[3], remain[2], alloc[3], remain[3]
);

portAllocLast portAlloc5( 
   req[4], remain[3], alloc[4]
);

generate 
   for (i=0; i<`NUM_PORT; i=i+1) begin : mergeAllocate
      assign allocVector[i*`NUM_PORT+:`NUM_PORT] = alloc[i];
   end
endgenerate

endmodule