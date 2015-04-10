// Xbar Control

`include "global.v"

module xbarCtrl (allocVector, outSelVector, inSelVector);

input [`NUM_PORT*`NUM_PORT-1:0] allocVector;

output [`NUM_PORT*`LOG_NUM_PORT-1:0] outSelVector, inSelVector;

//input [`NUM_PORT-1:0] alloc1, alloc2, alloc3, alloc4;

wire [`NUM_PORT-1:0] alloc [`NUM_PORT-1:0];
wire  [`LOG_NUM_PORT-1:0] outSel [0:`NUM_PORT-1]; // 4-LOCAL; 3-N; 2-S; 1-E; 0-W;
reg  [`LOG_NUM_PORT-1:0] inSel [0:`NUM_PORT-1]; // 4-LOCAL; 3-N; 2-S; 1-E; 0-W;

genvar j;
generate 
   for (j=0; j<`NUM_PORT; j=j+1) begin : outSelTranslate
      assign alloc[j] = allocVector [j*`NUM_PORT+:`NUM_PORT];
      outSelTrans outSelTranslation(alloc[j], outSel[j]);
   end
endgenerate

integer k;
initial 
   for (k=0; k<`NUM_PORT; k=k+1) 
      inSel[k] = `LOG_NUM_PORT'd0;
   
always @ * begin

   case (outSel[4])
      0: inSel[0] <= 4;
      1: inSel[1] <= 4;
      2: inSel[2] <= 4;
      3: inSel[3] <= 4;
      4: inSel[4] <= 4; 
   endcase  
   
   case (outSel[3])
      0: inSel[0] <= 3;
      1: inSel[1] <= 3;
      2: inSel[2] <= 3;
      3: inSel[3] <= 3;
      4: inSel[4] <= 3;    
   endcase
   
   case (outSel[2])
      0: inSel[0] <= 2;
      1: inSel[1] <= 2;
      2: inSel[2] <= 2;
      3: inSel[3] <= 2;
      4: inSel[4] <= 2;    
   endcase

   case (outSel[1])
      0: inSel[0] <= 1;
      1: inSel[1] <= 1;
      2: inSel[2] <= 1;
      3: inSel[3] <= 1;
      4: inSel[4] <= 1;    
   endcase
   
   case (outSel[0])
      0: inSel[0] <= 0;
      1: inSel[1] <= 0;
      2: inSel[2] <= 0;
      3: inSel[3] <= 0;
      4: inSel[4] <= 0;
   endcase   
end

generate 
   for (j=0; j<`NUM_PORT; j=j+1) begin : mergeOutput
      assign outSelVector[j*`LOG_NUM_PORT+:`LOG_NUM_PORT] = outSel[j];
      assign inSelVector[j*`LOG_NUM_PORT+:`LOG_NUM_PORT] = inSel[j];
   end
endgenerate



endmodule