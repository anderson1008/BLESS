// route computation for NORTH port

`include "global.v"

module routeCompNorth (dstX, dstY, prodVector);

input [`WIDTH_COORDINATE-1:0] dstX, dstY;
output [`NUM_PORT-1:0] prodVector;

wire [`WIDTH_COORDINATE-1:0] nextX, nextY;
assign nextX = `CURRENT_POS_X;
assign nextY = (`CURRENT_POS_Y+`WIDTH_COORDINATE'b1)%`SIZE_NETWORK;

wire [`WIDTH_COORDINATE:0] deltaX, deltaY;
assign deltaX = {1'b0,dstX} - {1'b0,nextX};
assign deltaY = {1'b0,dstY} - {1'b0,nextY};

// compute productive vector
wire doneX, doneY;
assign 	doneX = (deltaX == 0) ? 1 : 0;	
assign 	doneY = (deltaY == 0) ? 1 : 0;	
assign 	prodVector[1] = ~doneX & deltaX[`WIDTH_COORDINATE];  // +X -> East
assign 	prodVector[0] = ~doneX & ~deltaX[`WIDTH_COORDINATE];   // -X -> West
assign 	prodVector[3] = ~doneY & deltaY[`WIDTH_COORDINATE];  // +Y -> North
assign 	prodVector[2] = ~doneY & ~deltaY[`WIDTH_COORDINATE];   // -Y -> South
assign 	prodVector[4] = doneX & doneY;	// local port

endmodule