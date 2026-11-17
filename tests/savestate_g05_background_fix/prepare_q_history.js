// Actual T80 NMI handler perturbs VRAM, CRAM, VDP registers and background
// history only during Q. Its immutable ROM bytes are installed before P.
const fs=require('fs'),p=require('path'),d=__dirname,src=p.join(d,'integrated_original'),dst=p.join(d,'integrated_q');fs.mkdirSync(dst,{recursive:true});
for(const f of ['header.svh','vdp_tb.sv','compile.do','T80_sim.vhd','T80s_sim.vhd','savestates_sim.sv'])fs.copyFileSync(p.join(src,f),p.join(dst,f));fs.cpSync(p.join(src,'rtl'),p.join(dst,'rtl'),{recursive:true});
let t=fs.readFileSync(p.join(dst,'vdp_tb.sv'),'utf8');
t=t.replace('reg hl=0;',`reg q_nmi_n=1,q_active=0;reg[7:0]q_seed=0;
reg hl=0;`);
t=t.replace(".NMI_n(1'b1)",'.NMI_n(q_nmi_n)');
t=t.replace("ca[7:0]==8'hdd ? ((!history_done&&HISTORY)?8'd1:8'd0)","ca[7:0]==8'hdd ? (q_active?q_seed:((!history_done&&HISTORY)?8'd1:8'd0))");
t=t.replace('  future_input=0;request(0);',`  q_seed=8'h11*(pass+1);q_active=1;q_nmi_n=0;repeat(80)tick;q_nmi_n=1;
  begin integer q_wait;q_wait=0;
   while(ram[16'h120]!==1&&q_wait<20000)begin tick;q_wait++;end
   if(ram[16'h120]!==1||ram[16'h121]!==q_seed||vdp_regs[35:28]!==q_seed||vdp_regs[43:36]!==(q_seed^8'h17))$fatal(1,"guest Q handler did not complete its memory/register changes");
   if(cram_out[11:0]!=={q_seed[5:4],q_seed[5:4],q_seed[3:2],q_seed[3:2],q_seed[1:0],q_seed[1:0]})$fatal(1,"guest Q CRAM write missing");
   $display("G05_DISTINCT_GUEST_Q index%0d VRAMreadback%h CRAM0%h R8%h R9%h BG%h",pass+1,ram[16'h121],cram_out[11:0],vdp_regs[35:28],vdp_regs[43:36],candidate_bg_live);
  end
  q_active=0;
  future_input=0;request(0);`);
if(!t.includes('G05_DISTINCT_GUEST_Q'))throw Error('Q call anchor');
fs.writeFileSync(p.join(dst,'vdp_tb.sv'),t);
let rom=fs.readFileSync(p.join(src,'reference_h0/rom.hex'),'utf8').trim().split(/\s+/).map(x=>parseInt(x,16));
if(rom.slice(0x66,0x69).some(x=>x!==0))throw Error('NMI vector is not unused by original P');
rom[0x66]=0xc3;rom[0x67]=0;rom[0x68]=8;let a=0x800;
const emit=(...b)=>b.forEach(v=>rom[a++]=v),out=val=>emit(0x3e,val,0xd3,0xbf);
emit(0xf5,0xc5,0xdb,0xdd,0x47); // save AF/BC, B=identical-for-Q seed
out(0x41);out(0x40);emit(0x78,0xd3,0xbe); // distinctive VRAM byte
out(0x41);out(0);emit(0xdb,0xbe,0x32,0x21,0xc1); // actual CPU readback
out(0);out(0xc0);emit(0x78,0xd3,0xbe); // SMS CRAM entry0
emit(0x78,0xd3,0xbf);out(0x88); // R8=seed
emit(0x78,0xee,0x17,0xd3,0xbf);out(0x89); // R9=seed XOR17
out(0);out(0x80); // enter text so inactive ordinary history also changes
emit(0x3e,1,0x32,0x20,0xc1,0xc1,0xf1,0xed,0x45); // completion, POP BC/AF, RETN
for(const ref of [1,0]){const dir=p.join(dst,(ref?'reference_':'dut_')+'history');fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p.join(dir,'rom.hex'),rom.map(x=>x.toString(16).padStart(2,'0')).join('\n')+'\n');fs.writeFileSync(p.join(dir,'run.do'),fs.readFileSync(p.join(src,(ref?'reference_':'dut_')+'h0/run.do'),'utf8').replace('-gSLOTS=64','-gSLOTS=8'));}
fs.writeFileSync(p.join(dst,'handler.json'),JSON.stringify({vector:0x66,start:0x800,end:a,bytes:rom.slice(0x800,a),note:'Only Q pulses NMI; P and S use inactive NMI and identical future inputs.'},null,2));
