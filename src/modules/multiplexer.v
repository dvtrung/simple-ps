module multiplexer(
  input x, t, f,
  output res
  );
  
  assign res = (t & x) || (f & (~x));
endmodule

