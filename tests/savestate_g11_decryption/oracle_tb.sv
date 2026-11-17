module oracle_tb;
`include "crypto_functions.svh"
SEGASYS1_DECT2 dut(.clk(1'b0),.mrom_m1(1'b0),.mrom_ad(15'd0),.mrom_dt(),.rad(),.rdt(8'd0),.ROMCL(1'b0),.ROMAD(25'd0),.ROMDT(8'd0),.ROMEN(1'b0));
initial begin
 for(integer m=0;m<32;m++)for(integer v=0;v<256;v++)
  if(dut.bswp(m,v)!==swap_bits(v,m))$fatal(1,"oracle mismatch m%0d v%0d",m,v);
 $display("PASS SEGA ORACLE 8192 combinations");$finish;
end
endmodule
