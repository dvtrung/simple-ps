module out (
  input clock, reset,
  
  //input [15:0] outval1,
  //input [15:0] outval2,
  
  //input [2:0] sel,
  
  output [7:0] led0,
  output [7:0] led1,
  output [7:0] led2,
  output [7:0] led3,
  output [7:0] led4,
  output [7:0] led5,
  output [7:0] led6,
  output [7:0] led7,
  
  output [7:0] seg_sel
  );
  
  reg [3:0] num [0:7];
  reg [7:0] seg_sel_;
  wire [7:0] led [0:7];
  
  reg [15:0] outval1;
  reg [15:0] outval2;
  reg [2:0] sel;
  integer i;
  
  genvar index;
  generate
    for (index = 0; index < 8; index = index + 1) 
    begin: gen_seg
      seg7 seg7_led (.num(num[index]), .seg(led[index]));
    end
  endgenerate
  
  initial begin
    sel = 3'b111;
    outval1 = 16'b0000000000000000;
    outval2 = 16'b0000100001011011;
  end
  
  always @(posedge clock) begin
    if (sel == 3'b111) sel <= 0;
    else sel <= sel + 1;
    
    outval1 <= outval1 + 1;
    outval2 <= outval2 + 1;
    
    num[0] <= outval1[15:12];
    num[1] <= outval1[11:08];
    num[2] <= outval1[07:04];
    num[3] <= outval1[03:00];
    
    for (i = 0; i < 8; i = i + 1) begin
      seg_sel_[i] <= (i == sel);
    end
    
    num[4] <= outval2[15:12];
    num[5] <= outval2[11:08];
    num[6] <= outval2[07:04];
    num[7] <= outval2[03:00];
  end
  
  assign led0 = led[0];
  assign led1 = led[1];
  assign led2 = led[2];
  assign led3 = led[3];
  assign led4 = led[4];
  assign led5 = led[5];
  assign led6 = led[6];
  assign led7 = led[7];
  
  assign seg_sel = seg_sel_;
  
endmodule