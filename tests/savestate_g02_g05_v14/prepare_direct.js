const fs=require('fs'),p=require('path'),d=p.join(__dirname,'direct'),src=p.join(__dirname,'dual');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
let h=fs.readFileSync(p.join(d,'header.svh'),'utf8').replace('ON_IO=0;','ON_IO=0,DIRECT_OWNER=0;');fs.writeFileSync(p.join(d,'header.svh'),h);
let v=fs.readFileSync(p.join(d,'rtl/vdp.vhd'),'utf8').replace("(63 downto 32 => '0')","vram_cpu_A & cpu_write_data & vram_cpu_D_outl & '0'");fs.writeFileSync(p.join(d,'rtl/vdp.vhd'),v);
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8');
s=s.replace('.WR_direct(1\'b0)',".WR_direct(!frozen&&!cmreq&&!cwr&&ca[15:14]==2'b10&&DIRECT_OWNER==0)").replaceAll('.A_direct(6\'d0)','.A_direct(ca[13:8])');
// The second instance uses the complementary production CPU-bank selection.
const begin=s.indexOf(' vdp2(');s=s.slice(0,begin)+s.slice(begin).replace('&&DIRECT_OWNER==0)','&&DIRECT_OWNER==1)');
s=s.replaceAll('x>=REQUEST_X&&y==REQUEST_Y','x>=REQUEST_X&&x<256&&y==REQUEST_Y').replace('next_frame=frame+1','next_frame=frame').replace('reg[5:0]old_state=0;','reg[6:0]old_state=0;');
s=s.replace('reg scoring=0;','reg scoring=0;integer w1=0,w2=0;integer refw1[0:SAMPLES-1],refw2[0:SAMPLES-1];\nalways@(posedge clk)if(!setup)begin if(audit[1])w1++;if(audit2[1])w2++;if(frozen&&(audit[1:0]!=0||audit2[1:0]!=0))$fatal(1,"guest memory write while frozen");end\n');
s=s.replace('request(1);\n if(accepted_y','request(1);w1=0;w2=0;\n if(accepted_y').replace('request(0);divs=0;guestdiv=0;','request(0);w1=0;w2=0;divs=0;guestdiv=0;');
s=s.replace('%h %h %h %h\\n",tx[j]', '%h %h %h %h\\n",tx[j]');
s=s.replace('second_ram[j],second_audit[j]);if(n!=14)','second_ram[j],second_audit[j],refw1[j],refw2[j]);if(n!=16)');
s=s.replace('%h %h %h %h %h %h %h %h %h %h %h %h %h %h\\n",tx[j]','%h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h\\n",tx[j]');
s=s.replace('%h %h %h %h %h %h %h %h %h %h %h %h %h %h",x,y','%h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h",x,y').replace('color2,ram[257],audit2);','color2,ram[257],audit2,w1,w2);');
s=s.replace('  savechecks++;','  if(!REFERENCE&&(w1!=refw1[j]||w2!=refw2[j]))$fatal(1,"direct SAVE write count mismatch");\n  savechecks++;').replace('   checks++;','   if(w1!=refw1[j]||w2!=refw2[j])$fatal(1,"direct LOAD write count mismatch");\n   checks++;');
fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
let base=fs.readFileSync(p.join(src,'reference_bus/rom.hex'),'utf8').trim().split(/\s+/).map(x=>parseInt(x,16));
// Replace final JP with legal alternating direct byte writes then resume loop.
let end=base.findIndex((x,i)=>i>200&&x===0xc3);if(end<0)throw Error('loop jump');const dest=base[end+1]|base[end+2]<<8;
const code=[0x3e,0xa5,0x32,0x01,0x80,0x3e,0x6c,0x32,0x02,0x80,0xc3,dest&255,dest>>8];for(let i=0;i<code.length;i++)base[end+i]=code[i];
for(const owner of [0,1])for(const ref of [1,0]){const dir=p.join(d,(ref?'reference_':'dut_')+'owner'+owner);fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p.join(dir,'rom.hex'),base.map(x=>x.toString(16).padStart(2,'0')).join('\n')+'\n');fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gSLOTS=8 -gGG=0 -gREQUEST_Y=192 -gREQUEST_X=160 -gWARMUP=1 -gEXT_REFERENCE=1 -gREFERENCE=${ref} -gDIRECT_OWNER=${owner} -gREPLAYS=3 -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED -g/vdp_tb/vdp2/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}
console.log('Both System E direct-write owners prepared with exact write-count oracle');
