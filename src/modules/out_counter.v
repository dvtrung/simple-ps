module out_counter(
  input clock, reset,
  input halting,
  output [7:0] led1, led2, led_sel
  );
  
  reg [31:0] counter;
  reg disp_led1;
  
  wire [3:0] num [4:0];
  wire [7:0] leds [4:0];

  
  integer i;
  genvar index;
  generate
    for (index = 0; index < 5; index = index + 1) 
    begin: gen_seg_led
      seg7 seg7_led (.num(num[index]), .seg(leds[index]), .display(disp_led1));
    end
  endgenerate
  
  function [7:0] show_mes;
    input halting;
    input [7:0] last_num;
    input [1:0] c;
    begin
      if (halting) begin
        case (c)
          3: show_mes = 8'b01101110; /*H*/
          0: show_mes = 8'b00011100; /*L*/
          1: show_mes = 8'b00011110; /*t*/
          2: show_mes = last_num;
        endcase
      end else begin
        case (c)
          3: show_mes = 8'b00001010; /*r*/
          0: show_mes = 8'b00111000; /*u*/
          1: show_mes = 8'b00101010; /*n*/
          2: show_mes = last_num;
        endcase
      end
    end
  endfunction
  
  reg [1:0] show_c;
  reg [7:0] led1_;
  always @(posedge clock) begin
    if (reset) begin
      disp_led1 <= 0;
      counter <= 0;
      show_c <= 0;
    end else begin
      disp_led1 <= 1;
      show_c <= show_c + 1;
      if (~halting) begin
        counter <= counter + 1;
      end
    end
    case (show_c)
      3: led1_ <= leds[1];
      0: led1_ <= leds[2];
      1: led1_ <= leds[3];
      2: led1_ <= leds[4];
    endcase
  end
  
  assign led_sel = ~{4'd1 << show_c, 4'd1 << show_c};
  assign num[0] = counter[19:16];
  assign num[1] = counter[15:12];
  assign num[2] = counter[11: 8];
  assign num[3] = counter[ 7: 4];
  assign num[4] = counter[ 3: 0];
  assign led1 = show_mes(halting, leds[0], show_c);
  assign led2 = led1_;
endmodule
