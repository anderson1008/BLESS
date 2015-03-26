// Top wrapper of baseline BLESS router with Look Ahead Routing

`include "global.v"

module topBLESS (clk, reset, dinW, dinE, dinS, dinN, dinLocal, doutW, doutE, doutS, doutN, doutLocal);

input clk, reset;
input [`WIDTH_PORT-1:0] dinW, dinE, dinS, dinN;
input [`WIDTH_PORT_NI-1:0] dinLocal;
output [`WIDTH_PORT-1:0] doutW, doutE, doutS, doutN;
output [`WIDTH_PORT_NI-1:0]  doutLocal;

reg  [`WIDTH_INTERNAL-1:0] r_dinW, r_dinE, r_dinS, r_dinN;
reg [`WIDTH_XBAR-1:0] r_dinLocal;
reg  [`WIDTH_INTERNAL-1:0] r_doutW, r_doutE, r_doutS, r_doutN;
reg [`WIDTH_XBAR-1:0] r_doutLocal;

always @ (posedge clk or negedge reset) begin
   if (~reset) begin
      r_dinW <= 0;
      r_dinE <= 0;
      r_dinS <= 0;
      r_dinN <= 0;
      r_dinLocal <= 0;
   end
   else begin
      if (dinW != 0)
         r_dinW <= {1'b1,dinW};
      else
         r_dinW <= 0;
         
      if (dinE != 0)
         r_dinE <= {1'b1,dinE};
      else
         r_dinE <= 0;
         
      if (dinS != 0)
         r_dinS <= {1'b1,dinS};
      else
         r_dinS <= 0;
         
      if (dinN != 0)
         r_dinN <= {1'b1,dinN};
      else
         r_dinN <= 0;
         
      if (dinLocal != 0)
         r_dinLocal <= {1'b1,dinLocal};
      else 
         r_dinLocal <= 0;
   end
end

wire [`WIDTH_INTERNAL-1:0] PNout0, PNout1, PNout2, PNout3;
permutationNetwork permutationNetwork (r_dinW, r_dinE, r_dinS, r_dinN, PNout0, PNout1, PNout2, PNout3);

wire [`NUM_PORT-1:0] reqLocal;
// r_dinLocal[WIDTH_INTERNAL] is the valid bit. 
routeCompLocal routeCompLocal (r_dinLocal[`WIDTH_XBAR-1], r_dinLocal[`POS_X_DST], r_dinLocal[`POS_Y_DST], reqLocal);

wire [`NUM_PORT*`NUM_PORT-1:0] reqVector, allocVector;
assign reqVector = {reqLocal,PNout3[`POS_PV],PNout2[`POS_PV],PNout1[`POS_PV],PNout0[`POS_PV]};

portAllocWrapper portAllocWrapper (reqVector, allocVector);

wire [`WIDTH_XBAR-1:0] XbarOutW, XbarOutE, XbarOutS, XbarOutN, XbarOutLocal;
// Strip off the reserved and PV fields.
// Flit Format pass through Xbar [valid, PktId, FlitId, Time, Xdst, Ydst, payload];
xbar5Ports xbar5Ports (allocVector, {PNout0[`WIDTH_INTERNAL-1],PNout0[`WIDTH_XBAR-2:0]}, {PNout1[`WIDTH_INTERNAL-1], PNout1[`WIDTH_XBAR-2:0]}, {PNout2[`WIDTH_INTERNAL-1], PNout2[`WIDTH_XBAR-2:0]}, {PNout3[`WIDTH_INTERNAL-1], PNout3[`WIDTH_XBAR-2:0]}, r_dinLocal, XbarOutW, XbarOutE, XbarOutS, XbarOutN, XbarOutLocal);

wire [`NUM_PORT-1:0] prodVector [0:`NUM_PORT-2];
routeCompWest routeCompWest (XbarOutW[`WIDTH_XBAR-1], XbarOutW[`POS_X_DST], XbarOutW[`POS_Y_DST], prodVector[0]);
routeCompEast routeCompEast (XbarOutE[`WIDTH_XBAR-1], XbarOutE[`POS_X_DST], XbarOutE[`POS_Y_DST], prodVector[1]);
routeCompSouth routeCompSouth (XbarOutS[`WIDTH_XBAR-1], XbarOutS[`POS_X_DST], XbarOutS[`POS_Y_DST], prodVector[2]);
routeCompNorth routeCompNorth (XbarOutN[`WIDTH_XBAR-1], XbarOutN[`POS_X_DST], XbarOutN[`POS_Y_DST], prodVector[3]);

wire [`WIDTH_RESERVE-1:0] reserve = 0;

always @ (posedge clk or negedge reset) begin
   if (~reset) begin
      r_doutW <= 0;
      r_doutE <= 0;
      r_doutS <= 0;
      r_doutN <= 0;
      r_doutLocal <= 0;
   end
   else begin
      r_doutW <= {reserve, prodVector[0], XbarOutW[`WIDTH_XBAR-2:0]};
      r_doutE <= {reserve, prodVector[1], XbarOutE[`WIDTH_XBAR-2:0]};
      r_doutS <= {reserve, prodVector[2], XbarOutS[`WIDTH_XBAR-2:0]};
      r_doutN <= {reserve, prodVector[3], XbarOutN[`WIDTH_XBAR-2:0]};
      r_doutLocal <= XbarOutLocal[`WIDTH_XBAR-2:0];
   end
end

assign doutW = r_doutW;
assign doutE = r_doutE;
assign doutS = r_doutS;
assign doutN = r_doutN;
assign doutLocal = r_doutLocal;

endmodule