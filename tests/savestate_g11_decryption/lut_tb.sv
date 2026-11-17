module lut_tb;
reg clk=0,m1=0;reg[7:0]raw=0,key=0;wire[7:0]out;wire[12:0]ka;
MC8123_rom_decrypt dut(clk,m1,16'd0,out,raw,ka,key);
integer fd;initial begin fd=$fopen("mc_forward.hex","w");
for(integer op=0;op<2;op++)for(integer k=0;k<256;k++)for(integer v=0;v<256;v++)begin
 m1=op;key=k;raw=v;#2;clk=1;#1;if($isunknown(out))$fatal(1,"unknown decrypt");$fdisplay(fd,"%02h",out);clk=0;#1;
end
$fclose(fd);$display("PASS LUT entries131072");$finish;end
endmodule
