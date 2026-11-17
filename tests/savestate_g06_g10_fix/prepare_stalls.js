const fs=require('fs'),p=require('path'),here=__dirname,src=p.join(here,'candidate'),d=p.join(here,'stalls');fs.mkdirSync(d,{recursive:true});
for(const f of fs.readdirSync(src))if(/\.(sv|svh|vhd|do|ps1|hex)$/.test(f)&&fs.statSync(p.join(src,f)).isFile())fs.copyFileSync(p.join(src,f),p.join(d,f));
fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
for(const f of ['reference_t0','reference_t1','reference_ext_t0','reference_ext_t1','reference9_t1']){fs.mkdirSync(p.join(d,f),{recursive:true});fs.copyFileSync(p.join(src,f,'reference.dat'),p.join(d,f,'reference.dat'));}
const read=f=>fs.readFileSync(p.join(src,f),'utf8').replace(/\r\n/g,'\n'),put=(f,s)=>fs.writeFileSync(p.join(d,f),s);
put('header.svh',read('header.svh').replace('NATURAL_PHASE=0;', 'NATURAL_PHASE=0,STALL_PROFILE=0;'));
let s=read('vdp_tb.sv');
s=s.replace(/\nendmodule\s*$/, `
reg[15:0]stall_rng=16'h1ace;reg[N+41:0]save_sprite_held;reg[135:0]save_vdp_held;reg[229:0]save_cpu_held;reg save_monitoring=0;integer frozen_samples=0;
always@(negedge clk)begin #0.001;
 stall_rng={stall_rng[14:0],stall_rng[15]^stall_rng[13]^stall_rng[12]^stall_rng[10]};
 DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL_PROFILE==1?cycle%97<83:STALL_PROFILE==2?stall_rng[3:0]<13:0);
end
always@(posedge clk)begin
 if(dut.state==41&&dut.do_save)begin save_sprite_held=g06_live;save_vdp_held=vdp_regs;save_cpu_held=z80_reg;save_monitoring=1;end
 if(save_monitoring&&frozen)begin
  frozen_samples++;
  if({g06_live,vdp_regs,z80_reg}!=={save_sprite_held,save_vdp_held,save_cpu_held})$fatal(1,"SAVE transport advanced guest state");
 end
 if(save_monitoring&&!frozen)begin save_monitoring=0;$display("SAVE_TRANSPORT_HOLD PASS profile%0d hostclocks%0d",STALL_PROFILE,frozen_samples);end
end
endmodule
`);put('vdp_tb.sv',s);
put('run.do',read('run.do').replace(' -gREFERENCE=', ' -gSTALL_PROFILE=$env(STALL_PROFILE) -gREFERENCE='));
put('run.ps1',read('run.ps1').replace("[string]$Label='case'", "[int]$Stall=0,[string]$Label='case'").replace('$env:PROTOCOL_FIX=$Fix;', '$env:STALL_PROFILE=$Stall;$env:PROTOCOL_FIX=$Fix;'));
console.log('Deterministic and seeded DDRAM stall profiles prepared.');
