module out_test();
  reg clock, reset;
  
  reg [15:0] outval;
  
  reg [2:0] sel;
  
  wire [7:0] led0;
  wire [7:0] led1;
  wire [7:0] led2;
  wire [7:0] led3;
  wire [7:0] led4;
  wire [7:0] led5;
  wire [7:0] led6;
  wire [7:0] led7;
  
  wire selA;
  wire selB;
  wire selC;
  wire selD;
  wire selE;
  wire selF;
  wire selG;
  wire selH;

  out out_(
    .clock(clock), .reset(reset),
    .sel(sel),
    .led0(led0), .led1(led1), .led2(led2), .led3(led3), .led4(led4), .led5(led5), .led6(led6), .led7(led7), 
    .selA(selA), .selB(selB), .selC(selC), .selD(selD), .selE(selE), .selF(selF), .selG(selG), .selH(selH)
  );
  
  initial begin
    outval = 16'b0;
    clock = 0; reset = 1;
    sel = 3'b000;
  end
  
  always @(posedge clock) begin
    sel = sel + 1;
    outval = outval + 1;
  end
endmodule