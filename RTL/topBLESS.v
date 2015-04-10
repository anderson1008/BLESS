// Top wrapper of baseline BLESS router with Look Ahead Routing

`include "global.v"

module topBLESS (clk, reset, dinW, dinE, dinS, dinN, dinLocal, doutW, doutE, doutS, doutN, doutLocal);

input clk, reset;
input [`WIDTH_PORT-1:0] dinW, dinE, dinS, dinN;
input [`WIDTH_PORT-1:0] dinLocal;
output [`WIDTH_PORT-1:0] doutW, doutE, doutS, doutN;
output [`WIDTH_PORT-1:0]  doutLocal;

reg  [`WIDTH_INTERNAL-1:0] r_dinW, r_dinE, r_dinS, r_dinN;
reg [`WIDTH_INTERNAL-1:0] r_dinLocal;
reg  [`WIDTH_PORT-1:0] r_doutW, r_doutE, r_doutS, r_doutN;
reg [`WIDTH_PORT-1:0] r_doutLocal;

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


wire [`NUM_PORT-1:0] prodVector [0:`NUM_PORT-1];
routeComp routeCompWest (r_dinW[`WIDTH_INTERNAL-1], r_dinW[`POS_X_DST], r_dinW[`POS_Y_DST], prodVector[0]);
routeComp routeCompEast (r_dinE[`WIDTH_INTERNAL-1], r_dinE[`POS_X_DST], r_dinE[`POS_Y_DST], prodVector[1]);
routeComp routeCompSouth (r_dinS[`WIDTH_INTERNAL-1], r_dinS[`POS_X_DST], r_dinS[`POS_Y_DST], prodVector[2]);
routeComp routeCompNorth (r_dinN[`WIDTH_INTERNAL-1], r_dinN[`POS_X_DST], r_dinN[`POS_Y_DST], prodVector[3]);

wire [`WIDTH_INTERNAL_PV-1:0] PNout0, PNout1, PNout2, PNout3;
wire [`WIDTH_INTERNAL_PV-1:0] PNin  [0:`NUM_PORT-2];
assign PNin[0] = {prodVector[0],r_dinW};
assign PNin[1] = {prodVector[1],r_dinE};
assign PNin[2] = {prodVector[2],r_dinS};
assign PNin[3] = {prodVector[3],r_dinN};

permutationNetwork permutationNetwork (PNin[0], PNin[1], PNin[2], PNin[3], PNout0, PNout1, PNout2, PNout3);

reg [`WIDTH_INTERNAL_PV-1:0] pipeline_reg1  [0:3];
always @ (posedge clk or negedge reset) begin
   if (~reset) begin
      pipeline_reg1[0] <= 0;
      pipeline_reg1[1] <= 0;
      pipeline_reg1[2] <= 0;
      pipeline_reg1[3] <= 0;
   end
   else begin
      pipeline_reg1[0] <= PNout0;
      pipeline_reg1[1] <= PNout1;
      pipeline_reg1[2] <= PNout2;
      pipeline_reg1[3] <= PNout3;
   end
end

// Local Inject
wire [`WIDTH_INTERNAL_PV-1:0] w_dinLocal;
wire [3:0] validVector;
routeComp routeCompLocal (r_dinLocal[`WIDTH_INTERNAL-1], r_dinLocal[`POS_X_DST], r_dinLocal[`POS_Y_DST], prodVector[4]);
assign validVector = {pipeline_reg1[3][`POS_VALID],pipeline_reg1[2][`POS_VALID],pipeline_reg1[1][`POS_VALID],pipeline_reg1[0][`POS_VALID]};
assign w_dinLocal = (&validVector) ? 0 : {prodVector[4],r_dinLocal}; // check inject condition

wire [`NUM_PORT*`NUM_PORT-1:0] reqVector, allocVector;
assign reqVector = {w_dinLocal[`POS_PV],pipeline_reg1[3][`POS_PV],pipeline_reg1[2][`POS_PV],pipeline_reg1[1][`POS_PV],pipeline_reg1[0][`POS_PV]};
portAllocWrapper portAllocWrapper (reqVector, allocVector);

// Strip off PV and valid fields.
// Flit Format pass through Xbar [PktId, FlitId, Time, Xdst, Ydst, payload];

// Second Stage: PA + XT;
wire [`WIDTH_XBAR-1:0] XbarOutW, XbarOutE, XbarOutS, XbarOutN, XbarOutLocal;
xbar5Ports xbar5Ports (allocVector, pipeline_reg1[0][`WIDTH_XBAR-1:0], pipeline_reg1[1][`WIDTH_XBAR-1:0], pipeline_reg1[2][`WIDTH_XBAR-1:0], pipeline_reg1[3][`WIDTH_XBAR-1:0], w_dinLocal[`WIDTH_XBAR-1:0], XbarOutW, XbarOutE, XbarOutS, XbarOutN, XbarOutLocal);


always @ (posedge clk or negedge reset) begin
   if (~reset) begin
      r_doutW <= 0;
      r_doutE <= 0;
      r_doutS <= 0;
      r_doutN <= 0;
      r_doutLocal <= 0;
   end
   else begin
      r_doutW <= XbarOutW;
      r_doutE <= XbarOutE;
      r_doutS <= XbarOutS;
      r_doutN <= XbarOutN;
      r_doutLocal <= XbarOutLocal;
   end
end

assign doutW = r_doutW;
assign doutE = r_doutE;
assign doutS = r_doutS;
assign doutN = r_doutN;
assign doutLocal = r_doutLocal;

endmodule