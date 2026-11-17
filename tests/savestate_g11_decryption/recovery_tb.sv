`timescale 1ns/1ps
module recovery_tb;
`include "crypto_functions.svh"
reg clk=0;always #10 clk=~clk;
reg[15:0]a=0;reg op=0;reg[7:0]raw=0;wire[7:0]data;wire loaded;
decrypt_path #(.MODE(2)) dut(clk,a,op,raw,data,loaded);
integer cases=0;reg[1:0]phases=0;
function[15:0]logical_a(input[6:0]ix);logical_a={1'b0,ix[6],1'b0,ix[5],2'b0,ix[4],2'b0,ix[3],2'b0,ix[2],2'b0,ix[1]};endfunction
task edges(input integer n);begin repeat(n)begin @(posedge clk);#1;end end endtask
initial begin
 wait(loaded);edges(8);
 for(integer phase=0;phase<2;phase++)for(integer ix=0;ix<128;ix++)for(integer byte_value=0;byte_value<256;byte_value++)begin
  // Perturb with actual input transitions and free-running clocks only.
  @(negedge clk);a=~logical_a(ix);op=ix[0];raw=byte_value^8'hb7;edges(6);
  while(dut.segapipe.phase!=phase)edges(1);
  @(negedge clk);a=logical_a(ix);op=!ix[0];raw=byte_value;phases[dut.segapipe.phase]=1;
  edges(5);
  if(data!==(swap_bits(raw,swap_byte(ix))^xor_byte(ix)))$fatal(1,"address reconstruction ix%0d byte%h phase%0d A%h result%h",ix,raw,phase,a,data);
  @(negedge clk);raw=byte_value^8'h53;edges(2);
  if(data!==(swap_bits(raw,swap_byte(ix))^xor_byte(ix)))$fatal(1,"raw reconstruction ix%0d",ix);
  cases++;
 end
 if(phases!=3)$fatal(1,"missing phase");
 $display("PASS SEGA RECOVERY cases%0d phases%b addressBound5 rawBound2",cases,phases);$finish;
end
endmodule
