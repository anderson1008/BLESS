//DFF

`include "global.v"

module dff(clk, reset, din, dout);

input [`WIDTH_INTERNAL_PV-1:0] din;
output [`WIDTH_INTERNAL_PV-1:0] dout;
input clk, reset;

reg [`WIDTH_INTERNAL_PV-1:0] r_dout;

always @ (negedge reset or posedge clk) begin
   if (~reset)
      r_dout <= 0;
   else
      r_dout <= din;
end

assign dout = r_dout;

endmodule