module seg7 (
  input  [3:0] num,
  input  display,
  output [7:0] seg
);

  function [7:0] conv_seg7;
    input [3:0] num;
    input display;
  begin
    if (~display) begin
      conv_seg7 = 8'b0;
    end else begin
      case (num)
        4'h0: conv_seg7 = 8'b1111_1100;
        4'h1: conv_seg7 = 8'b0110_0000;
        4'h2: conv_seg7 = 8'b1101_1010;
        4'h3: conv_seg7 = 8'b1111_0010;
        4'h4: conv_seg7 = 8'b0110_0110;
        4'h5: conv_seg7 = 8'b1011_0110;
        4'h6: conv_seg7 = 8'b1011_1110;
        4'h7: conv_seg7 = 8'b1110_0000;
        4'h8: conv_seg7 = 8'b1111_1110;
        4'h9: conv_seg7 = 8'b1111_0110;
        4'hA: conv_seg7 = 8'b1110_1110;
        4'hB: conv_seg7 = 8'b0011_1110;
        4'hC: conv_seg7 = 8'b0001_1010;
        4'hD: conv_seg7 = 8'b0111_1010;
        4'hE: conv_seg7 = 8'b1001_1110;
        4'hF: conv_seg7 = 8'b1000_1110;
      endcase
    end
  end
  endfunction

  assign seg = conv_seg7(num, display);
endmodule
