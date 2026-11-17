const fs=require('fs'),path=require('path'),d=__dirname;
let s=fs.readFileSync(path.join(d,'../savestate_hcounter/controller_tb.sv'),'utf8').split('reg [63:0] video_saved;')[0].replace('module controller_tb;','module format_tb;parameter STALL=0;');
s=s.replace('cycle=cycle+1;end',"cycle=cycle+1;DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL==1?cycle%31<13:STALL==2?cycle%17<12:STALL==3?cycle%2048<2020:0);end");
s+=`
integer k,gunreads;reg[63:0]header,oldsize,payload,desc;reg[45:0]saved;
always@(posedge clk)if(DDRAM_RD&&!DDRAM_BUSY&&(DDRAM_ADDR==29'h07c00028||DDRAM_ADDR==29'h07c00029))gunreads=gunreads+1;
initial begin
reset_n=0;repeat(4)tick;reset_n=1;vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;ss_game_id=32'h12345678;video_state_out=22'h12345;
gun_out={9'd192,9'd191,16'h01ff,1'b1,1'b0,1'b1,8'd17,1'b1};paddle_out=32'h01234567;tap_out=19'h60023;md_out=46'h000001000001;
operation(1);header=mem['h1a];oldsize=mem[0];payload=mem['h28];desc=mem['h29];saved=gun_out;
if(header[63:38]!=={24'h484308,2'd3}||payload!=={18'd0,saved}||desc!==64'h0000002e4c475538)$fatal(1,"v8 layout mismatch");
for(k=0;k<18;k=k+1)begin
mem['h1a]=header;mem[0]=oldsize;mem['h28]=payload;mem['h29]=desc;gunreads=0;
if(k<8)begin
 if(k==0)mem['h1a][63:22]=0;
 else mem['h1a][63:38]={24'h484300+k[23:0],(k==1?2'd0:k==2?2'd2:2'd3)};
end
case(k)
9:mem['h1a][63:40]=24'h484309;
10:mem['h29][31:0]=0;
11:mem['h29][63]=1;
12:mem['h28][63]=1;
13:mem['h29][39:32]=8'd45;
14:mem['h1a][39:38]=2;
15:begin mem[0][63:32]=16382;mem['he][63]=0;end
16:mem['h1a][63:40]=24'h123456;
endcase
operation(0);
if(gun_valid!==(k==8||k==17))$fatal(1,"gun validation case%0d valid%b",k,gun_valid);
if((k==8||k==17)&&gun_in!==saved)$fatal(1,"exact gun payload mismatch");
if((k<8||k==9||k==14||k==15||k==16)&&gunreads!=0)$fatal(1,"legacy/unknown tag consumed gun payload");
if(k==7&&(!paddle_valid||paddle_in!==paddle_out||!tap_valid||tap_in!==tap_out||!md_valid||md_in!==md_out))$fatal(1,"v7 accessory payload regression");
$display("PASS F11 format case%0d stalls%0d gunValid%b gunReads%0d",k,STALL,gun_valid,gunreads);
end
$display("PASS F11 format untagged v1-v7 v8 and malformed/unknown metadata cases18");$finish;
end
initial begin #1000000000;$fatal(1,"format watchdog");end
endmodule
`;
fs.writeFileSync(path.join(d,'format_tb.sv'),s);
for(let i=0;i<4;i++)fs.writeFileSync(path.join(d,'format'+i+'.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib format${i}_work
vlog -work format${i}_work -sv -quiet savestates_sim.sv format_tb.sv
vsim -c -t 1ps -gSTALL=${i} format${i}_work.format_tb
run -all
quit -code 0
`);
