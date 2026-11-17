`timescale 1ns/1ps
module mc_recovery_tb;
reg clk=0;always #10 clk=~clk;
reg[15:0]a=0;reg op=0;reg[7:0]raw=0;wire[7:0]data;wire loaded;
decrypt_path #(.MODE(1)) dut(clk,a,op,raw,data,loaded);
`include "crypto_functions.svh"
reg[7:0]forward[0:131071];initial $readmemh("mc_forward.hex",forward);
integer cases=0;
function[15:0]logical_a(input[12:0]ka);logical_a={ka[11:6],1'b0,ka[5],1'b0,ka[4],1'b0,ka[3],1'b0,ka[2:0]};endfunction
task edges(input integer n);begin repeat(n)begin @(posedge clk);#1;end end endtask
initial begin
 wait(loaded);edges(8);
 for(integer key_index=0;key_index<8192;key_index++)for(integer byte_value=0;byte_value<256;byte_value++)begin
  @(negedge clk);a=~logical_a(key_index);op=key_index[12];raw=byte_value^8'hb7;edges(3);
  @(negedge clk);a=logical_a(key_index);op=!key_index[12];raw=byte_value;edges(2);
  if(dut.mc!==forward[{op,key_byte(key_index),raw}])$fatal(1,"key reconstruction key%h byte%h A%h data%h keyA%h keyD%h",key_index,raw,a,dut.mc,dut.ka,dut.kd);
  @(negedge clk);raw=byte_value^8'h53;edges(1);
  if(dut.mc!==forward[{op,key_byte(key_index),raw}])$fatal(1,"raw reconstruction key%h",key_index);
  cases++;
 end
 $display("PASS MC RECOVERY cases%0d keyAddresses8192 allRawBytes256 addressBound2 rawBound1",cases);$finish;
end
endmodule
