module component_tb;
reg clk=0;always #5 clk=~clk;
reg we=0,sw=0,sr=0;reg[4:0]wa=0,ra=0,sa=0;
reg[11:0]wd=0,sd=0;wire[11:0]q,refq,sq;wire[383:0]image;
vdp_cram_reference refmem(.cpu_clk(clk),.cpu_WE(we),.cpu_A(wa),.cpu_D(wd),.vdp_clk(clk),.vdp_A(ra),.vdp_D(refq),.ss_D(image),.ss_wr(sw),.ss_A(sa),.ss_wD(sd));
vdp_cram_candidate dut(.cpu_clk(clk),.cpu_WE(we),.cpu_A(wa),.cpu_D(wd),.vdp_clk(clk),.vdp_A(ra),.vdp_D(q),.ss_Q(sq),.ss_rd(sr),.ss_wr(sw),.ss_A(sa),.ss_wD(sd));
reg[31:0]rng=32'h47199115;
function[31:0]rnd;begin rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};rnd=rng;end endfunction
integer checks=0,same_addr=0,priority_checks=0,scans=0,loads=0;
reg[11:0]expected;reg[383:0]saved,scan;
task tick;begin
 expected=image[12*((sr||sw)?sa:wa)+:12];
 @(posedge clk);#1;
 if(q!==refq)$fatal(1,"renderer mismatch check%0d address%0d",checks,ra);
 if(sr && !sw && !we && sq!==expected)$fatal(1,"readA mismatch check%0d",checks);
 if((we||sw)&&ra==(sw?sa:wa))same_addr++;
 if(we&&sw)priority_checks++;
 checks++;@(negedge clk);
end endtask
task capture;begin
 we=0;sw=0;sr=1;saved=image;
 for(integer a=0;a<32;a++)begin sa=a;ra=31-a;tick;scan[12*a+:12]=sq;end
 sr=0;if(scan!==saved)$fatal(1,"snapshot mismatch");scans++;
end endtask
task restore;begin
 we=0;sr=0;sw=1;
 for(integer a=0;a<32;a++)begin sa=a;sd=saved[12*a+:12];ra=a;tick;end
 sw=0;if(image!==saved)$fatal(1,"restore contents");loads++;capture;
end endtask
initial begin
 @(negedge clk);tick;
 if(image!=={384{1'b1}})$fatal(1,"initial content");
 for(integer a=0;a<32;a++)begin we=1;wa=a;ra=a;wd=(a*113)^12'hca7;tick;end
 we=0;capture;
 for(integer rep=0;rep<3;rep++)begin
  for(integer k=0;k<257;k++)begin we=1;sw=(k%3==0);wa=rnd();sa=rnd();wd=rnd();sd=rnd();ra=k%2?wa:sa;tick;end
  restore;
 end
 for(integer k=0;k<200000;k++)begin
  sr=0;we=rnd()&1;sw=(rnd()%7==0);wa=rnd();ra=k%4==0?wa:rnd();sa=rnd();wd=rnd();sd=rnd();tick;
  if(k%997==0)capture;
 end
 we=0;sw=0;capture;
 if(same_addr<1000||priority_checks<1000)$fatal(1,"coverage");
 $display("PASS CRAM COMPONENT checks%0d same_address%0d priority_checks%0d scans%0d loads%0d",checks,same_addr,priority_checks,scans,loads);$finish;
end
endmodule
