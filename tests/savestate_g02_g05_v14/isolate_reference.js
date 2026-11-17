// Apply after a family generator. Infrastructure only: DUT datapath unchanged;
// reference stops lending its CPU VRAM port to passive SAVE transport.
const fs=require('fs'),p=require('path');
for(const family of process.argv.slice(2)){const file=p.join(__dirname,family,'vdp_tb.sv');let s=fs.readFileSync(file,'utf8');
if(s.includes('AUDIT_IO_CONSUMPTION')){
const monitor=s.match(/always@\(posedge clk\)if\(!setup&&!frozen&&cpu_tick[\s\S]*?\nend\n/)[0];
const actual=s.includes(' vdp2(')?'(ca[2] ? vd2 : vd)':'vd';
const corrected=monitor.replace('$isunknown(vd)','$isunknown('+actual+')').replace('io_sample<=vd;','io_sample<='+actual+';');
s=s.replace(monitor,'').replace(/\nendmodule\s*$/, '\n'+corrected+'\nendmodule\n');fs.writeFileSync(file,s);continue;}
s=s.replaceAll('.ss_vram_en(vram_en|setup)','.ss_vram_en((vram_en&&(!REFERENCE||warming))|setup)').replaceAll('.ss_vram_en(vram2_en|setup)','.ss_vram_en((vram2_en&&(!REFERENCE||warming))|setup)');
// UI request pulses must wait for the actual 4-clock release settlement.
s=s.replace(' force dut.op_cooldown=0;', ' while(dut.state!=0)tick;\n force dut.op_cooldown=0;');
// Observe the value at the wrapper's real I/O input latch (TState2 + CEN),
// rather than an arbitrary early sample while RD is asserted. D_out itself is
// not serialized and need not equal a stale reference latch before consumption.
s=s.replace('reg hl=0;',`// AUDIT_IO_CONSUMPTION
reg[7:0]io_sample=0;integer io_count=0;integer ref_io_count[0:SAMPLES-1];
always@(posedge clk)if(!setup&&!frozen&&cpu_tick&&!ciq&&!crd&&ts_probe==2&&ca[7:6]==2'b10)begin
 if($isunknown(vd))$fatal(1,"unknown value actually consumed by CPU VDP IN");
 io_sample<=vd;io_count<=io_count+1;
end
reg hl=0;`);
s=s.replace('#1;release dut.op_cooldown;', '#1;io_count=0;release dut.op_cooldown;');
s=s.replace(/if\(EXT_REFERENCE\)begin n=\$fscanf\(f,"([^"]*)",([^;]+)\);if\(n!=(\d+)\)\$fatal\(1,"short extended reference"\);end/,(_,fmt,args,n)=>`if(EXT_REFERENCE)begin n=$fscanf(f,"${fmt.replace('\\n',' %h\\n')}",${args},ref_io_count[j]);if(n!=${+n+1})$fatal(1,"short extended reference");end`);
s=s.replace(/if\(EXT_REFERENCE\)\$fdisplay\(f,"([^"]*)",([^;]+)\);/,(_,fmt,args)=>`if(EXT_REFERENCE)$fdisplay(f,"${fmt} %h",${args.replace('x,y,vdp_regs,color,vd,','x,y,vdp_regs,color,io_sample,')},io_count);`);
s=s.replace('  savechecks++;', '  if(!REFERENCE&&EXT_REFERENCE&&(io_count!=ref_io_count[j]||(io_count>0&&io_sample!==readtrace[j])))$fatal(1,"SAVE consumed IN value/count differs xy%0d,%0d count%0d ref%0d value%h ref%h",x,y,io_count,ref_io_count[j],io_sample,readtrace[j]);\n  savechecks++;');
s=s.replace('   checks++;', '   if(EXT_REFERENCE&&(io_count!=ref_io_count[j]||(io_count>0&&io_sample!==readtrace[j])))$fatal(1,"LOAD consumed IN value/count differs xy%0d,%0d count%0d ref%0d value%h ref%h",x,y,io_count,ref_io_count[j],io_sample,readtrace[j]);\n   checks++;');
s=s.replace("if((vd[5]!==readtrace[j][5])&&!ciq&&!crd&&ca[7:0]==8'hbf)", "if(!EXT_REFERENCE&&(vd[5]!==readtrace[j][5])&&!ciq&&!crd&&ca[7:0]==8'hbf)");
if(!s.includes('ref_io_count[j]);if(n!='))throw Error('Extended oracle adapter failed '+family);
const monitor=s.match(/always@\(posedge clk\)if\(!setup&&!frozen&&cpu_tick[\s\S]*?\nend\n/)[0];
const actual=s.includes(' vdp2(')?'(ca[2] ? vd2 : vd)':'vd';
const corrected=monitor.replace('$isunknown(vd)','$isunknown('+actual+')').replace('io_sample<=vd;','io_sample<='+actual+';');
s=s.replace(monitor,'').replace(/\nendmodule\s*$/, '\n'+corrected+'\nendmodule\n');
fs.writeFileSync(file,s);console.log('Isolated reference DMA, idle request and real CPU IN consumption: '+family);
}
