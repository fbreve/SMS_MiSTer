`timescale 1ns/1ps
module guard_protocol_tb;
`include "ports.svh"
reg ready=0;reg [31:0] mock_data=0;
assign fm_initialized=ready;assign fm_state_rdata=mock_data;
always #5 clk=~clk;
integer cycles=0,pending=0,applies=0,restores=0,reads=0,checkpoint=0;
reg [28:0] ra;reg [63:0] memory[0:12287];
always @(negedge clk)begin cycles++;cpu_ce=cycles%15==0;vdp_ce=cycles%5==0;pix_ce=cycles%10==0;sp_ce=cycles%2;DDRAM_BUSY=cycles%53<7;end
always @(posedge clk)begin
 mock_data<=fm_state_read&&fm_state_addr==78?71:0;
 DDRAM_DOUT_READY<=0;
 if(pending>0)begin pending<=pending-1;if(pending==1)begin DDRAM_DOUT<=memory[ra-29'h07c00000];DDRAM_DOUT_READY<=1;end end
 if(DDRAM_RD&&!DDRAM_BUSY)begin if(pending)$fatal(1,"protocol overlapping reads");pending<=3+cycles%9;ra<=DDRAM_ADDR;reads++;end
 if(DDRAM_WE&&!DDRAM_BUSY)for(integer b=0;b<8;b++)if(DDRAM_BE[b])memory[DDRAM_ADDR-29'h07c00000][8*b+:8]<=DDRAM_DIN[8*b+:8];
 if(fm_state_write)applies++;
 if(z80_set)restores++;
end
task tick;begin @(negedge clk);#2;end endtask
task operation(input bit saving);begin
 force dut.op_cooldown=0;
 ss_save=saving;ss_load=!saving;tick;ss_save=0;ss_load=0;
 wait(ss_freeze);wait(!ss_freeze);repeat(12)tick;
 release dut.op_cooldown;
end endtask
task reject(input integer kind);integer old_restores,old_applies;begin
 old_restores=restores;old_applies=applies;operation(0);
 if(restores!=old_restores||applies!=old_applies)$fatal(1,"malformed image applied case=%0d",kind);
 $display("PASS protocol malformed=%0d rejected before core/FM apply",kind);
end endtask
initial begin
 for(integer i=0;i<12288;i++)memory[i]=0;
 repeat(6)tick;reset_n=1;audio_quiescent=1;vblank=1;ss_game_id=32'h12345678;video_state_out=22'h12345;
 // Pending SAVE must wait for FM readiness even when disabled at the mixer.
 ss_save=1;tick;ss_save=0;repeat(150)tick;
 if(ss_freeze||dut.state!=dut.ST_WAIT_BOUNDARY)$fatal(1,"froze before FM initialized");
 ready=1;wait(ss_freeze);wait(!ss_freeze);repeat(12)tick;
 if(memory['h2997]!==64'h00681101464d5331)$fatal(1,"FM descriptor changed");
 if(memory['h1a][63:40]!==24'h484311)$fatal(1,"FM discovery marker");
 operation(0);if(applies!=104||restores!=1)$fatal(1,"full apply protocol");
 $display("PASS protocol startup guard, descriptor v17, full apply104");
 memory['h2998+39][31:0]=3;memory['h2998+50][31:0]=32'h7FE00402;reject(10);
 memory['h2998+39][31:0]=2;memory['h2998+50][31:0]=32'h7FE00042;memory['h2998+50][63:32]=32'h00000002;reject(11);
 // A legitimate pending write at stage zero must remain accepted after failures.
 memory['h2998+39][31:0]=0;memory['h2998+50][31:0]=32'h7FE00402;operation(0);
 if(applies!=208||restores!=2)$fatal(1,"stage-zero pending write recovery");
 // Repeat rejection after the stage-zero latch was true, then accept stage3/no-write.
 memory['h2998+39][31:0]=3;reject(12);
 memory['h2998+39][31:0]=71;memory['h2998+50]=0;operation(0);
 if(applies!=312||restores!=3)$fatal(1,"back-to-back valid recovery");
 $display("PASS guard atomic FM rejection A/B, stale-latch isolation and back-to-back recovery");
 memory['h2997]^=64'h100000000;reject(0);memory['h2997]^=64'h100000000;
 memory['h2998+'d39][31:0]=72;reject(1);memory['h2998+'d39][31:0]=71;
 memory['h2998+'d51][63:32]=1;reject(2);memory['h2998+'d51][63:32]=0;
 memory['h1a][22]=1;reject(3);memory['h1a][22]=0;
 // Untagged 96 KiB images must not consult stale or corrupt FM descriptors.
 memory['h1a]=video_state_out;memory['h2997]=~64'd0;
 applies=0;operation(0);if(applies!=28||restores!=4)$fatal(1,"legacy96 fallback");
 $display("PASS protocol legacy96 ignores stale FM tail; reference fallback writes76..103");
 memory[0][63:32]=16382;memory['he][63]=0;applies=0;operation(0);
 if(applies!=28||restores!=5)$fatal(1,"legacy64 fallback");
 $display("PASS protocol legacy64 fallback");
 $display("PASS protocol ALL cycles=%0d DDRreads=%0d",cycles,reads);$finish;
end
initial begin #100000000;$fatal(1,"protocol TIMEOUT state=%0d",dut.state);end
endmodule
