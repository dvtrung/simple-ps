module out (
  input clock, reset,
  
  input [15:0] outval1,
  input [15:0] outval2,
  
  input [2:0] outsel,
  
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
  
  reg outdisplay_flag1_, outdisplay_flag2_;
  reg outdisplay_flag1[0:7];
  reg outdisplay_flag2[0:7];
  reg [3:0] outsel_flag = 4'b0000;
  
  reg [15:0] arr_outval1 [0:7];
  reg [15:0] arr_outval2 [0:7];
  
  reg [15:0] outval1_;
  reg [15:0] outval2_;
  
  reg [2:0] outsel2 = 3'b000;
  
  integer i;
  
  genvar index;
  generate
    for (index = 0; index < 8; index = index + 1) 
    begin: gen_seg
      seg7 seg7_led (.num(num[index]), .seg(led[index]), .display(index < 4 ? outdisplay_flag1_ : outdisplay_flag2_));
    end
  endgenerate
  
  always @(posedge clock or posedge reset) begin
    if (reset) begin
      outdisplay_flag1[0] <= 0; outdisplay_flag1[1] <= 0;
      outdisplay_flag1[2] <= 0; outdisplay_flag1[3] <= 0;
      outdisplay_flag1[4] <= 0; outdisplay_flag1[5] <= 0;
      outdisplay_flag1[6] <= 0; outdisplay_flag1[7] <= 0;
      outdisplay_flag2[0] <= 0; outdisplay_flag2[1] <= 0;
      outdisplay_flag2[2] <= 0; outdisplay_flag2[3] <= 0;
      outdisplay_flag2[4] <= 0; outdisplay_flag2[5] <= 0;
      outdisplay_flag2[6] <= 0; outdisplay_flag2[7] <= 0;
    end else begin
      arr_outval1[7] = 16'b1001110011100101;
      outdisplay_flag1[7] <= 1;
    
      if (outsel_flag == 4'b0000) begin 
        outsel2 <= outsel2 + 1;
      end else begin
        outval1_ <= arr_outval1[outsel2];
        outval2_ <= arr_outval2[outsel2];
        outdisplay_flag1_ <= outdisplay_flag1[outsel2];
        outdisplay_flag2_ <= outdisplay_flag2[outsel2];
      end
      outsel_flag <= outsel_flag + 1;
      
      num[0] <= outval1_[15:12];
      num[1] <= outval1_[11:08];
      num[2] <= outval1_[07:04];
      num[3] <= outval1_[03:00];
        
      for (i = 0; i < 8; i = i + 1) begin
        seg_sel_[i] <= (i == outsel2);
      end

      num[4] <= outval2_[15:12];
      num[5] <= outval2_[11:08];
      num[6] <= outval2_[07:04];
      num[7] <= outval2_[03:00];
      

      if (outsel !== 3'bXXX) begin
        if (outval1[15] !== 1'bX) begin
          arr_outval1[outsel] <= outval1;
          outdisplay_flag1[outsel] <= 1;
        end
        if (outval2[15] !== 1'bX) begin
          arr_outval2[outsel] <= outval2;
          outdisplay_flag2[outsel] <= 1;
        end
      end
    end
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