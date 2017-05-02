module controller(
  input clock, reset, exec,
  output reg [2:0] phase, 
  output reg [4:0] phase_bus,
  output reg [4:0] fill_bus
  );
  
  always @(clock) begin
    if(reset) begin
      phase <= 4;
      phase_bus <= 5'd4;
    end else begin
      if(clock) begin
        phase <= phase;
        phase_bus <= {
          phase == 4,
          phase == 3,
          phase == 2,
          phase == 1,
          phase == 0};
        fill_bus <= {
          phase == 4,
          phase == 3,
          phase == 2,
          phase == 1,
          phase == 0};
      end else begin
        if(phase >= 4) begin
          phase <= 0;
        end else begin
          phase <= phase + 3'd1;
        end
        phase_bus <= 5'd0;
        fill_bus <= {
          phase == 4,
          phase == 3,
          phase == 2,
          phase == 1,
          phase == 0};
      end
    end
  end
endmodule
