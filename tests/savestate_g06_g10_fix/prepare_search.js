// Construct two legal guest histories that differ in the omitted evaluator
// index, then restore identical SAT bytes before capture. No register forcing.
const fs=require('fs'),p=require('path'),crypto=require('crypto'),here=__dirname,src=p.join(here,'candidate'),d=p.join(here,'search');fs.mkdirSync(d,{recursive:true});
const calibrated=process.argv.includes('--calibrated');
const delay=calibrated?Number(fs.readFileSync(p.join(d,'calibration/calibration.txt'),'utf8').trim()):0;
if(!Number.isInteger(delay)||delay<0||delay>=89604)throw Error('Invalid calibration delay');
for(const f of fs.readdirSync(src))if(/\.(sv|svh|vhd|do)$/.test(f)&&fs.statSync(p.join(src,f)).isFile())fs.copyFileSync(p.join(src,f),p.join(d,f));
fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
const put=(f,s)=>fs.writeFileSync(p.join(d,f),s),read=f=>fs.readFileSync(p.join(src,f),'utf8').replace(/\r\n/g,'\n');
const prefix=JSON.parse(fs.readFileSync(p.join(src,'rom.json'),'utf8')).bytes.slice(0,139),rom=Array(65536).fill(0);let a=0;const emit=(...b)=>b.forEach(x=>rom[a++]=x);emit(...prefix);
let extraLoads=0;while((delay-7*extraLoads)%4!==0)extraLoads++;
if(delay<7*extraLoads)throw Error('Delay cannot be encoded');
for(let i=0;i<extraLoads;i++)emit(0x3e,0);for(let i=0;i<(delay-7*extraLoads)/4;i++)emit(0);
const frameStart=a,setAddress=()=>emit(0x3e,2,0xd3,0xbf,0x3e,0x7f,0xd3,0xbf);
setAddress();emit(0xdb,0xdc,0xd3,0xbe,0xd3,0xbe);
// Total body cost is89604 CPU ticks: one complete NTSC frame at /10.
for(let i=0;i<22356;i++)emit(0);
emit(0x3e,0,0x3e,0,0x3e,0,0xdb,0xbf,0xaf); // clear old status/flags legally
setAddress();emit(0x3e,0xd0);const late=a;emit(0xd3,0xbe,0xd3,0xbe,0xc3,frameStart&255,frameStart>>8);
if(a>=0xc000)throw Error('Program exceeded directly mapped ROM');
const romText=rom.map(x=>x.toString(16).padStart(2,'0')).join('\n')+'\n';put('rom.hex',romText);
put('program.json',JSON.stringify({delay,frameStart,late,bytes:a,frameCycles:89604,sha256:crypto.createHash('sha256').update(romText).digest('hex')},null,2));
let h=read('header.svh').replace('NATURAL_PHASE=0;', 'NATURAL_PHASE=0,PAST_HISTORY=0,CALIBRATION=0,LATE_PC='+late+';');
h=h.replace('savestates dut(', "reg past_inputs=1,search_active=0;wire[7:0]history_byte=past_inputs&&PAST_HISTORY?8'h00:8'hd0;\nsavestates dut(");put('header.svh',h);
let s=read('vdp_tb.sv');
s=s.replace('.DI(!ciq?vd:', ".DI(!ciq?(ca[7:0]==8'hdc ? history_byte : vd):");
const v=s.match(/vdp #\(\.MAX_SPPL\(SLOTS-1\)\) vdp1\([^;]+;/)[0];
s=s.replace(v, `generate if(CALIBRATION)begin:cal_stub
assign m1=0;assign m2=0;assign m3=0;assign m4=1;assign vd=8'h1f;assign irq=1;assign color=0;assign vdp_regs=0;assign cram_out=0;assign vram_D=0;assign g06_live=0;
end else begin:real_vdp
${v.replace('.ss_sprite_out(g06_live)', '.probe_capture(dut.state==41&&dut.do_save),.ss_sprite_out(g06_live)')}
end endgenerate`);
s=s.replace('reg[7:0]rom[0:65535]', 'reg[7:0]rom[0:65535]');
s=s.replace('setup=0;runvideo=1;', `setup=0;runvideo=1;
 if(CALIBRATION)begin wait(cal_target>=0&&cal_out>=0);f=$fopen("calibration.txt","w");
  if((cal_target-cal_out)%10!=0)$fatal(1,"calibration clocks not on CPU/pixel cadence");
  $fdisplay(f,"%0d",(((cal_target-cal_out)/10)+89604)%89604);$fclose(f);
  $display("CALIBRATION PASS target%0d out%0d delayTicks%0d",cal_target,cal_out,(((cal_target-cal_out)/10)+89604)%89604);$finish;
 end`);
const needle='$display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);';const pos=s.indexOf(needle);if(pos<0)throw Error('Missing search capture');
s=s.slice(0,pos)+'search_active=1;'+needle+`
 f=$fopen("image.hex","w");for(n=0;n<12288;n++)begin if($isunknown(mem[n]))$fatal(1,"unknown complete search image word%h",n);$fdisplay(f,"%016h",mem[n]);end $fclose(f);
 f=$fopen("suffix.dat","w");
 for(j=0;j<3000;j++)begin do tick;while(!ce_pix);@(posedge clk);#1;
  if($isunknown({z80_reg,vdp_regs,color,ram[256]}))$fatal(1,"unknown search suffix");
  $fdisplay(f,"%h %h %h %h %h %h",x,y,z80_reg,vdp_regs,color,ram[256]);
 end
 $fclose(f);$display("PASS NATURAL G06 SEARCH history%0d pixels3000",PAST_HISTORY);$finish;
end
integer cal_target=-1,cal_out=-1;reg last_cwr=1;
always@(posedge clk)begin #1;
 if(runvideo&&ce_pix&&x==498&&y==168&&cal_target<0)cal_target=cycle;
 if(runvideo&&!ciq&&!cwr&&last_cwr&&ca[7:0]==8'hbe&&z80_reg[79:64]==LATE_PC+2)begin
  $display("LATE_RESTORE_STROBE cycle%0d x%0d y%0d PC%h",cycle,x,y,z80_reg[79:64]);if(cal_out<0)cal_out=cycle;
 end
 last_cwr=cwr;
end
always@(posedge clk)if(dut.state==41&&dut.do_save&&search_active)past_inputs<=0;
initial begin #100000000;$fatal(1,"search watchdog");end
endmodule
`;
// ModelSim requires these observation declarations before initial/task uses.
s=s.replace('integer cal_target=-1,cal_out=-1;reg last_cwr=1;','');
h=fs.readFileSync(p.join(d,'header.svh'),'utf8').replace('reg past_inputs=1,search_active=0;', 'integer cal_target=-1,cal_out=-1;reg last_cwr=1;reg past_inputs=1,search_active=0;');put('header.svh',h);put('vdp_tb.sv',s);
// Observation-only VHDL ports; none participates in next-state logic.
for(const file of ['vdp.vhd','vdp_main.vhd','vdp_sprites.vhd']){
 let v=fs.readFileSync(p.join(src,'rtl',file),'utf8').replace(/\r\n/g,'\n');
 v=v.replace('ss_sprite_out: out', "probe_capture: in std_logic := '0';\n ss_sprite_out: out");
 if(file==='vdp_sprites.vhd')v=v.replace(/end Behavioral;\s*$/, `process(clk_sys)begin if rising_edge(clk_sys) and probe_capture='1' then
report "G06_OMITTED state="&integer'image(conv_integer(state))&" count="&integer'image(count)&" index="&integer'image(conv_integer(index));
end if;end process;\nend Behavioral;\n`);
 else v=v.replace('ss_sprite_out=>ss_sprite_out', 'probe_capture=>probe_capture,ss_sprite_out=>ss_sprite_out');
 put('rtl/'+file,v);
}
for(const [label,cal,history]of [['calibration',1,0],['history0',0,0],['history1',0,1]]){
 const dir=p.join(d,label);fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p.join(dir,'rom.hex'),romText);
 fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gCALIBRATION=${cal} -gPAST_HISTORY=${history} -gWARMUP=1 -gTURBO=1 -gREFERENCE=0 -gPROTO=1 -gEXT_REFERENCE=0 -g/vdp_tb/dut/TB_FAST=1 ${cal?'':'-g/vdp_tb/real_vdp/vdp1/vdp_vram_inst/init_file=UNUSED'}\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);
 fs.writeFileSync(p.join(dir,'run.ps1'),`Set-Location $PSScriptRoot\n$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'\n& "$bin/vmap.exe" -c|Out-Null\n& "$bin/vmap.exe" vdp_work ../vdp_work|Out-Null\n& "$bin/vsim.exe" -c -do 'do run.do' -l simulation.log\n`);
}
console.log('Natural G06 index-history search prepared; delayTicks='+delay+' latePC='+late.toString(16));
