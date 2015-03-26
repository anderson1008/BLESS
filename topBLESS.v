// Top wrapper of baseline BLESS router with Look Ahead Routing

`include "global.v"

module topBLESS (dinW, dinE, dinS, dinN, dinLocal, doutW, doutE, doutS, doutN, doutLocal);

input [`WIDTH_INTERNAL-1:0] dinW, dinE, dinS, dinN, dinLocal;
output [`WIDTH_INTERNAL-1:0] doutW, doutE, doutS, doutN;
output [`WIDTH_XBAR-1:0]  doutLocal;

wire [`WIDTH_INTERNAL-1:0] PNout0, PNout1, PNout2, PNout3;
permutationNetwork permutationNetwork (dinW, dinE, dinS, dinN, PNout0, PNout1, PNout2, PNout3);

wire [`NUM_PORT-1:0] reqLocal;
routeCompLocal routeCompLocal (dinLocal[`POS_X_DST], dinLocal[`POS_Y_DST], reqLocal);

wire [`NUM_PORT*`NUM_PORT-1:0] reqVector, allocVector;
assign reqVector = {reqLocal,PNout3[`POS_PV],PNout2[`POS_PV],PNout1[`POS_PV],PNout0[`POS_PV]};

portAllocWrapper portAllocWrapper (reqVector, allocVector);

wire [`WIDTH_XBAR-1:0] XbarOutW, XbarOutE, XbarOutS, XbarOutN, XbarOutLocal;
// Strip off the reserved and PV fields.
xbar5Ports xbar5Ports (allocVector, PNout0[`WIDTH_XBAR-1:0], PNout1[`WIDTH_XBAR-1:0], PNout2[`WIDTH_XBAR-1:0], PNout3[`WIDTH_XBAR-1:0], dinLocal[`WIDTH_XBAR-1:0], XbarOutW, XbarOutE, XbarOutS, XbarOutN, doutLocal);

wire [`NUM_PORT-1:0] prodVector [0:`NUM_PORT-2];
routeCompWest routeCompWest (XbarOutW[`POS_X_DST], XbarOutW[`POS_Y_DST], prodVector[0]);
routeCompEast routeCompEast (XbarOutE[`POS_X_DST], XbarOutE[`POS_Y_DST], prodVector[1]);
routeCompSouth routeCompSouth (XbarOutS[`POS_X_DST], XbarOutS[`POS_Y_DST], prodVector[2]);
routeCompNorth routeCompNorth (XbarOutN[`POS_X_DST], XbarOutN[`POS_Y_DST], prodVector[3]);

wire [`WIDTH_RESERVE-1:0] reserve = 0;

assign doutW = {reserve, prodVector[0], XbarOutW};
assign doutE = {reserve, prodVector[1], XbarOutE};
assign doutS = {reserve, prodVector[2], XbarOutS};
assign doutN = {reserve, prodVector[3], XbarOutN};

endmodule