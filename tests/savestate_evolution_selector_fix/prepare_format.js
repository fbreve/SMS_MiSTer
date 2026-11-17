const fs=require('fs'),path=require('path'),d=__dirname;
let s=fs.readFileSync(path.join(d,'evolution_fixed_tb.sv'),'utf8').split('integer lp0,lp1;')[0].replace('module evolution_fixed_tb;','module format_tb;');
s+=`integer formatcase,beforeloads,rejected=0,accepted=0;reg rejecting=0;reg[159:0]qext;reg[63:0]qmap;
always @(posedge clk)if(rejecting&&(mapper_set||evolution_set||z80_set||vdp_regs_set||vdp2_regs_set||io_set||gun_set||gg_set||md_set||tap_set||paddle_set||audio_ext_set||audio_phase_set||vram_WE||wram_WE||nvram_WE||vram2_WE||cram_wr||cram2_wr||psg_set||psg2_set))$fatal(1,"rejected snapshot performed restore write case%0d",formatcase);
initial begin
 repeat(4)tick;reset_n=1;mrst=1;audio_quiescent=1;vblank=1;x=0;ss_game_id='hf14000f0;perturb=1;
 selectbank('h2800);switchmode('h87);selectbank('h4800);switchmode('h87);operation(1);
 for(integer j=0;j<12288;j=j+1)snapshot[j]=mem[j];
 for(formatcase=0;formatcase<30;formatcase=formatcase+1)begin
  for(integer j=0;j<12288;j=j+1)mem[j]=snapshot[j];
  if(formatcase==1)mem['h1a][63:22]=0;
  if(formatcase>=2&&formatcase<=10)mem['h1a][63:38]={24'h4842ff+formatcase[23:0],formatcase==2?2'd0:formatcase==3?2'd2:2'd3};
  case(formatcase)
   11:mem['h1a][63:40]=24'h48430b;
   12:mem['h1a][39:38]=2;
   13:mem['h2d]=0;
   14:mem['h2d][31:0]=32'h45563131;
   15:mem['h2d][39:32]=56;
   16:mem['h2d][63]=1;
   17,18,19,20,21,22,23:mem['h2c][57+formatcase-17]=1;
   24:begin mem[0][63:32]=16382;mem['he][63]=0;end
   25:mem['h19][63:48]=0; // live Evolution cannot accept missing owner
   26:begin mem['h2a][18]=1;end // F13 independently normalizes; F14 remains valid
   27:begin mem['h2b]=0;end
   28:begin mem['h1a][63:38]={24'h484309,2'd3};mem['h2c]='1;end
   29:begin mem['h1a][63:38]={24'h484309,2'd3};mem['h2d]=64'h0000003945563130;end
  endcase
  selectbank(formatcase%2?'h9440:'h6000);switchmode('h87);outport('h8c,formatcase[7:0]);idle;
  qext=ext0;qmap=map0;beforeloads=loads;rejecting=(formatcase!=0&&formatcase!=26&&formatcase!=27);
  operation(0);
  if(rejecting)begin
   if(loads!=beforeloads||ext0!==qext||map0!==qmap)$fatal(1,"legacy/malformed changed runtime case%0d",formatcase);
   rejected=rejected+1;
  end else begin
   if(loads!=beforeloads+1||ext0!=={snapshot['h2c],snapshot['h1b],snapshot['h19][63:32]})$fatal(1,"valid v10 not restored case%0d",formatcase);
   if(formatcase>=26&&dut.mapper_history_in!==18'h0ffff)$fatal(1,"F13 fallback changed");
   accepted=accepted+1;
  end
  $display("PASS F14 format case%0d rejected=%0d loads=%0d",formatcase,rejecting,loads);rejecting=0;
 end
 $display("PASS F14 format cases30 rejected%0d accepted%0d, legacy/no-owner/bad-version/descriptor/all-padding fail before restore writes",rejected,accepted);$finish;
end
initial begin repeat(30000000)tick;$fatal(1,"format watchdog");end
endmodule
`;
fs.writeFileSync(path.join(d,'format_tb.sv'),s);
fs.writeFileSync(path.join(d,'format.do'),fs.readFileSync(path.join(d,'run.do'),'utf8').replaceAll('fixed_work','format_work').replaceAll('evolution_fixed_tb','format_tb').replace(' -gCASE=$env(F14_CASE)',''));
