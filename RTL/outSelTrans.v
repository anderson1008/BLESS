// translate the port allocation result to outSel signals

`include "global.v"

module outSelTrans (alloc, outSel);

input [`NUM_PORT-1:0] alloc;
output reg [`LOG_NUM_PORT-1:0] outSel;


always @ * begin
   casex (alloc)
      `NUM_PORT'b1xxxx: 
         outSel <= `LOG_NUM_PORT'd4;
      `NUM_PORT'b01xxx: 
         outSel <= `LOG_NUM_PORT'd3;
      `NUM_PORT'b001xx: 
         outSel <= `LOG_NUM_PORT'd2;
      `NUM_PORT'b0001x: 
         outSel <= `LOG_NUM_PORT'd1;
      `NUM_PORT'b00001: 
         outSel <= `LOG_NUM_PORT'd0;    
      default:
         outSel <= `LOG_NUM_PORT'd7;   
   endcase
end

endmodule
