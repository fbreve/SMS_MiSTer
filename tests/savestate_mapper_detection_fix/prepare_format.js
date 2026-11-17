const fs=require('fs'),path=require('path'),d=__dirname;
let s=fs.readFileSync(path.join(d,'history_tb.sv'),'utf8').replace('module history_tb;','module format_tb;');
s=s.slice(0,s.indexOf('initial begin\n reset_n=0;repeat(4)tick;reset_n=1;'));
s+=`reg[63:0]header,historyword,desc;reg[17:0]expected_history;integer k;integer checks=0;
initial begin
 reset_n=0;repeat(4)tick;reset_n=1;audio_quiescent=1;vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;ss_game_id=32'hf1300010;
 gg_out=128'h0001456789abcdef0011223344556677;md_out=46'h100000;tap_out=19'h40000;paddle_out=32'h123;gun_out=46'h123456;
 download(16,1);mrst=1;boot=1;repeat(4)tick;put(16'hfffd,0,30);operation(1);
 header=mem['h1a];historyword=mem['h2a];desc=mem['h2b];
 if(header[63:38]!=={24'h484309,2'd3}||historyword[63:18]!==0||desc!==64'h000000124d444839)$fatal(1,"new payload encoding");
 for(k=0;k<24;k=k+1)begin
  mem['h1a]=header;mem['h2a]=historyword;mem['h2b]=desc;mem[0][63:32]=24574;mem['he][63]=1;
  expected_history=18'h0ffff;
  if(k==0)mem['h1a][63:22]=0;
  if(k>=1&&k<=8)mem['h1a][63:38]={24'h484300+k[23:0],k==1?2'd0:k==2?2'd2:2'd3};
  case(k)
   9:expected_history=historyword[17:0];
   10:mem['h1a][63:40]=24'h48430a;
   11:mem['h2b][31:0]=0;
   12:mem['h2b][39:32]=17;
   13:mem['h2b][63]=1;
   14:mem['h2a][18]=1;
   15:mem['h2a][63]=1;
   16:mem['h1a][39:38]=2;
   17:begin mem[0][63:32]=16382;mem['he][63]=0;end
   18:begin mem['h2a]=0;expected_history=0;end
   19:begin mem['h2a]=18'h0ffff;expected_history=18'h0ffff;end
   20:begin mem['h2a]=18'h10042;expected_history=18'h10042;end
   21:begin mem['h2a]=18'h3fffe;expected_history=18'h3fffe;end
   22:mem['h2b]=0;
   23:mem['h1a][63:40]=24'h484308;
  endcase
  mrst=0;boot=0;repeat(3)tick;mrst=1;boot=1;repeat(4)tick;put(k%2?16'hfffd:16'h4000,0,30);
  operation(0);
  if(mapper_history_in!==expected_history)$fatal(1,"history format case%0d got%h expected%h",k,mapper_history_in,expected_history);
  if(k>=2&&k<=9||k>=11&&k<=15||k>=18)begin
   if(gg_in!==gg_out)$fatal(1,"GG payload moved case%0d",k);
  end
  if(k>=3&&k<=9||k>=11&&k<=15||k>=18)if(!md_valid||md_in!==md_out)$fatal(1,"MD payload moved case%0d",k);
  if(k>=6&&k<=9||k>=11&&k<=15||k>=18)if(!tap_valid||tap_in!==tap_out)$fatal(1,"Tap payload moved case%0d",k);
  if(k>=7&&k<=9||k>=11&&k<=15||k>=18)if(!paddle_valid||paddle_in!==paddle_out)$fatal(1,"Paddle payload moved case%0d",k);
  if(k==8||k==9||k>=11&&k<=15||k>=18)if(!gun_valid||gun_in!==gun_out)$fatal(1,"Gun payload moved case%0d",k);
  checks=checks+1;$display("PASS F13 format case%0d history%h",k,mapper_history_in);
 end
 $display("PASS F13 format cases%0d untagged v1-v9 future padding descriptor old64K previous payloads intact",checks);$finish;
end
initial begin repeat(30000000)tick;$fatal(1,"format watchdog");end
endmodule
`;
fs.writeFileSync(path.join(d,'format_tb.sv'),s);
let script=fs.readFileSync(path.join(d,'run.do'),'utf8').replaceAll('work','format_work').replace('vcom -2008','vcom -work format_work -2008').replace('vlog -sv','vlog -work format_work -sv').replace('history_tb.sv','format_tb.sv').replace('format_work.history_tb -gCASE=$env(F13_CASE)','format_work.format_tb');
fs.writeFileSync(path.join(d,'format.do'),script);
