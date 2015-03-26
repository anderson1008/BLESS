// route computation for Local port

`include "global.v"

module routeCompLocal (dstX, dstY, prodVector);

input [`WIDTH_COORDINATE-1:0] dstX, dstY;
output [`NUM_PORT-1:0] prodVector;

wire [`WIDTH_COORDINATE:0] deltaX, deltaY;
assign deltaX = {1'b0,dstX} - {1'b0,`CURRENT_POS_X};
assign deltaY = {1'b0,dstY} - {1'b0,`CURRENT_POS_Y};

// compute productive vector
wire doneX, doneY;
assign 	doneX = (deltaX == 0) ? 1 : 0;	
assign 	doneY = (deltaY == 0) ? 1 : 0;	
assign 	prodVector[1] = ~doneX & deltaX[`WIDTH_COORDINATE];  // +X -> East
assign 	prodVector[0] = ~doneX & ~deltaX[`WIDTH_COORDINATE];   // -X -> West
assign 	prodVector[3] = ~doneY & deltaY[`WIDTH_COORDINATE];  // +Y -> North
assign 	prodVector[2] = ~doneY & ~deltaY[`WIDTH_COORDINATE];   // -Y -> South
assign 	prodVector[4] = 1'b0;	// local port

endmodule