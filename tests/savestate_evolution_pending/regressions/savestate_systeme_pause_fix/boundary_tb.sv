`timescale 1ns/1ps
module boundary_tb;
reg clk=0,reset_n=0,joy=0,vb=1,freeze=0;
wire paused,pp,up;
always #5 clk=~clk;
pause_fixture p(clk,reset_n,1'b1,joy,vb,freeze,1'b0,paused,pp,up);
task tick;begin @(negedge clk);#1;end endtask
task press;begin joy=1;repeat(3)tick;joy=0;repeat(3)tick;end endtask
task setup(input integer phase);begin
 reset_n=0;joy=0;vb=1;freeze=0;repeat(4)tick;reset_n=1;repeat(3)tick;
 if(phase!=0)press;
 if(phase>=2)begin vb=0;repeat(3)tick;end
 if(phase==3)press;
end endtask
function[2:0]bits(input integer phase);case(phase)0:bits=0;1:bits=2;2:bits=4;3:bits=5;endcase endfunction
integer phase,profile,anchor,off,pattern,h,release_at,edge_at,expected,tests=0,level;
reg initial_vb;
initial begin
 for(profile=0;profile<4;profile=profile+1)begin
  case(profile)0:release_at=60;1:release_at=77;2:release_at=109;3:release_at=277;endcase
  for(phase=0;phase<4;phase=phase+1)begin
   for(anchor=0;anchor<7;anchor=anchor+1)for(off=-3;off<=3;off=off+1)for(pattern=0;pattern<2;pattern=pattern+1)begin
    setup(phase);initial_vb=vb;
    case(anchor)0:edge_at=10+off;1:edge_at=14+off;2:edge_at=18+off;3:edge_at=20+off;4:edge_at=35+off;5:edge_at=release_at+off;6:edge_at=release_at+3+off;endcase
    expected=phase;
    // No genuine beam edge occurs outside transport in this interval.
    // Only a fresh rising host edge outside freeze can queue a transition.
    if(edge_at<20||edge_at>=release_at)begin if(phase==0)expected=1;if(phase==2)expected=3;end
    for(h=0;h<release_at+12;h=h+1)begin
     freeze=h>=20&&h<release_at;
     if(freeze&&h<release_at-1)vb=h%2;else vb=initial_vb;
     joy=pattern==0?h>=edge_at:(h>=edge_at&&h<edge_at+2);
     tick;
    end
    if({paused,pp,up}!==bits(expected))$fatal(1,"boundary phase%0d profile%0d anchor%0d offset%0d pattern%0d actual%0b expected%0b",phase,profile,anchor,off,pattern,{paused,pp,up},bits(expected));
    joy=0;repeat(3)tick;
    if(expected==1)begin vb=0;repeat(3)tick;if(!paused||pp)$fatal(1,"retained pause did not apply");end
    if(expected==3)begin vb=1;repeat(3)tick;if(paused||up)$fatal(1,"retained unpause did not apply");end
    tests=tests+1;
   end
   for(level=0;level<2;level=level+1)begin
    setup(phase);initial_vb=vb;
    freeze=1;joy=level;repeat(3)tick;freeze=0;repeat(3)tick;
    for(h=0;h<release_at+12;h=h+1)begin freeze=h>=20&&h<release_at;vb=freeze&&h<release_at-1?h%2:initial_vb;tick;end
    if({paused,pp,up}!==bits(phase))$fatal(1,"held input changed phase");tests=tests+1;
   end
  end
 end
 if(tests!=1600)$fatal(1,"wrong sweep count");
 $display("PASS BOUNDARY cases%0d phases4 anchors7 offsets7 patterns2 transportDurations4 heldCases32",tests);$finish;
end
endmodule
