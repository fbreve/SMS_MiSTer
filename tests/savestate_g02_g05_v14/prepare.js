const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto');
const root=p.resolve(__dirname,'../..'),d=p.join(__dirname,'fixture'),src=p.join(root,'tests/savestate_g06_g10_fix/candidate');
fs.mkdirSync(d,{recursive:true});fs.mkdirSync(p.join(d,'rtl'),{recursive:true});
const read=f=>fs.readFileSync(f,'utf8').replace(/\r\n/g,'\n'),put=(f,s)=>fs.writeFileSync(p.join(d,f),s);
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const tracked=cp.execFileSync('git',['ls-files','-z'],{cwd:root}).toString().split('\0').filter(f=>f&&fs.existsSync(p.join(root,f))&&fs.statSync(p.join(root,f)).isFile());
fs.writeFileSync(p.join(__dirname,'baseline.json'),JSON.stringify({head:cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root}).toString().trim(),files:Object.fromEntries(tracked.map(f=>[f,sha(fs.readFileSync(p.join(root,f)))]))},null,2));
put('header.svh',read(p.join(src,'header.svh')).replace('NATURAL_PHASE=0;','NATURAL_PHASE=0,SAMPLES=1000,CLONE=0,IRQ_ENABLE=0,REQUEST_Y=168,STALL=0;'));
put('savestates_sim.sv',require('../savestate_g06_g10_fix/controller_adapter.js')(p.join(root,'rtl/savestates.sv')));
for(const f of ['T80_sim.vhd','T80s_sim.vhd'])put(f,read(p.join(src,f)));
for(const f of ['vdp.vhd','vdp_main.vhd','vdp_sprites.vhd','vdp_sprite_shifter.vhd'])put('rtl/'+f,read(p.join(root,'rtl',f)));
let v=read(p.join(d,'rtl/vdp.vhd'));
v=v.replace('entity vdp is','entity vdp is');
v=v.replace('ss_freeze:', 'ss_freeze:');
// A read-only output exposes current bus-history/IRQ state. No transition edits.
v=v.replace(/port\s*\(/i,'port (\n audit: out std_logic_vector(63 downto 0);');
v=v.replace(/begin\s*\n/,'begin\n audit <= (63 downto 38 => \'0\') & xspr_collide_shift & IRQ_n & last_x0 & old_RD_n & old_WR_n & old_HL & old_WR_direct & cpu_write_data & data_write & xram_cpu_A_incr & vram_cpu_WE & cram_cpu_WE;\n');
// 14+1+1+4+8+4=32: correct explicit high padding to 32 bits.
v=v.replace('(63 downto 38 => \'0\')','(63 downto 32 => \'0\')');put('rtl/vdp.vhd',v);
let s=read(p.join(src,'vdp_tb.sv'));
s=s.replaceAll('[0:3000]','[0:SAMPLES-1]').replaceAll('j<1000','j<SAMPLES');
s=s.replace('.INT_n(1\'b1)','.INT_n(IRQ_ENABLE?irq:1\'b1)');
s=s.replace('.capture_cpu_edges(1\'b0)','.capture_cpu_edges(CLONE!=0)').replace('wire[31:0]probe,rprobe;','wire[31:0]probe,rprobe;wire[63:0]audit;');
s=s.replace('.clk_sys(clk),.ce_vdp(','.audit(audit),.clk_sys(clk),.ce_vdp(');
s=s.replaceAll('y==(GG?168:192)','y==REQUEST_Y').replace('accepted_y!=(GG?168:192)','accepted_y!=REQUEST_Y');
s=s.replace('80+pass*31','80+pass*1370');
s=s.replace('reg scoring=0;','reg scoring=0;reg[63:0] audit_trace[0:SAMPLES-1];reg irq_trace[0:SAMPLES-1];integer visible=0;');
s=s.replace('%h %h %h %h %h %h %h %h\\n",tx[j],ty[j],trace[j],pixels[j],readtrace[j],racc[j],rmem[j],rcpu[j]','%h %h %h %h %h %h %h %h %h %h\\n",tx[j],ty[j],trace[j],pixels[j],readtrace[j],racc[j],rmem[j],rcpu[j],audit_trace[j],irq_trace[j]').replace('if(n!=8)','if(n!=10)');
s=s.replace('%h %h %h %h %h %h %h %h",x,y,vdp_regs,color,vd,z80_reg[7:0],ram[256],z80_reg','%h %h %h %h %h %h %h %h %h %h",x,y,vdp_regs,color,vd,z80_reg[7:0],ram[256],z80_reg,audit,irq');
// Background values during cropped blanking are not architectural pixels.
// Keep status/CPU/IRQ checks at all positions; display pixels are checked active.
s=s.replaceAll('color!==pixels[j]','((y<((GG)?168:192)&&x<256)&&color!==pixels[j])');
s=s.replace('  savechecks++;','  if(y<192&&x<256)visible++;\n  if(!REFERENCE&&irq!==irq_trace[j])$fatal(1,"SAVE IRQ mismatch x%0d y%0d",x,y);\n  savechecks++;');
s=s.replace('   checks++;','   if(irq!==irq_trace[j])$fatal(1,"LOAD IRQ mismatch x%0d y%0d",x,y);\n   checks++;');
s=s.replace('DONE VDP gg','PASS V14 VDP gg');
s=s.replace(/^ if\(SPRITES>2&&PROTO\).*\n/m,'').replace(/ if\(SPRITES>2\)begin\n  if\(saveflags==0[\s\S]*?\n end\n/,'');
s=s.replace('integer last_issue_cycle=0','always@(negedge clk)if(STALL)DDRAM_BUSY<=((cycle%97)<(STALL==1?83:51));\ninteger last_issue_cycle=0');
s=s.replace(/\nendmodule\s*$/,`
integer boundaries=0,pending_clear=0,pending_incr=0,pending_write=0;
always@(posedge clk)if(!setup&&!frozen&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256)begin
 boundaries++;if(vdp_regs[103])pending_clear++;if(audit[2])pending_incr++;if(audit[3])pending_write++;
 if(dut.state==37)$display("BOUNDARY T cycle%0d xy%0d,%0d MC%0d TS%0d phase%0d ce_vdp%b audit%h reset%b",cycle,x,y,mc_probe,ts_probe,clkd,ce_vdp,audit,vdp_regs[103]);
end
reg[5:0]old_state=0;
always@(posedge clk)begin
 if(dut.state!=old_state&&(dut.state>=45||cpu_prepare||phase_set))$display("RESTART cycle%0d state%0d prep%b phaseSet%b ce%b%b%b%b",cycle,dut.state,cpu_prepare,phase_set,ce_cpu,ce_vdp,ce_pix,ce_sp);
 old_state<=dut.state;
end
final $display("AUDIT_COUNTS eligible%0d pendingClear%0d pendingIncr%0d pendingWrite%0d visiblePixels%0d",boundaries,pending_clear,pending_incr,pending_write,visible);
endmodule
`);put('vdp_tb.sv',s);
put('compile.do',read(p.join(src,'compile.do')));
put('.gitignore','vdp_work/\nmodelsim.ini\ntranscript\nvsim.wlf\n');
fs.copyFileSync(p.join(src,'rom.hex'),p.join(d,'rom.hex'));
console.log('Prepared current v14 fixture; historical CPU adapters will be hash-checked.');

