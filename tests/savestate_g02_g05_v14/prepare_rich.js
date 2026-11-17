const fs=require('fs'),p=require('path'),d=p.join(__dirname,'rich'),src=p.join(__dirname,'fixture');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
// Observe actual fetch address, palette, priority and CRAM selection without
// changing a production transition or driving any internal register.
let main=fs.readFileSync(p.join(d,'rtl/vdp_main.vhd'),'utf8');
main=main.replace(/port\s*\(/i,'port (\n audit_main_probe: out std_logic_vector(19 downto 0);').replace(/begin\s*\n/,'begin\n audit_main_probe <= bg_color & bg_priority & bg_vram_A;\n');
fs.writeFileSync(p.join(d,'rtl/vdp_main.vhd'),main);
let top=fs.readFileSync(p.join(d,'rtl/vdp.vhd'),'utf8');
top=top.replace('architecture Behavioral of vdp is','architecture Behavioral of vdp is\n signal audit_main_probe: std_logic_vector(19 downto 0);').replace("(63 downto 32 => '0')",'audit_main_probe & cram_vdp_A & "0000000"').replace('vdp_main_inst: entity work.vdp_main\n','vdp_main_inst: entity work.vdp_main\n');
top=top.replace(/(vdp_main_inst: entity work\.vdp_main[\s\S]*?port map\s*\()/,'$1\n audit_main_probe => audit_main_probe,');
fs.writeFileSync(p.join(d,'rtl/vdp.vhd'),top);
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8');
s=s.replaceAll('x>=REQUEST_X&&y==REQUEST_Y','x>=REQUEST_X&&x<256&&y==REQUEST_Y').replace('next_frame=frame+1','next_frame=frame');
s=s.replace(" if(n>=14'h3800&&n<14'h3f00)pattern=n[0]?8'h08:8'h01;"," if(n>=14'h3800&&n<14'h3f00)pattern=n[0]?((n>>3)&31):((n>>1)*13)^(n>>5);");
s=s.replace(" if(n>=14'h2000&&n<14'h2040)pattern=n[1:0]==0?8'hff:8'h00;",'');
s=s.replaceAll('((y<((GG)?168:192)&&x<256)&&color!==pixels[j])','(!vb&&x>0&&x<=256&&color!==pixels[j])');
s=s.replace('reg[5:0]old_state=0;','reg[6:0]old_state=0;');
s=s.replace('if(y<192&&x<256)visible++;','if(!vb&&x>0&&x<=256)visible++;');
s=s.replace('PASS V14 VDP gg','PASS RICH V14 VDP gg');
s=s.replace('  savechecks++;','  if(!REFERENCE&&!vb&&x>0&&x<=256&&audit[63:32]!==audit_trace[j][63:32])$fatal(1,"SAVE background fetch/palette/priority mismatch xy%0d,%0d",x,y);\n  savechecks++;');
s=s.replace('   checks++;','   if(!vb&&x>0&&x<=256&&audit[63:32]!==audit_trace[j][63:32])$fatal(1,"LOAD background fetch/palette/priority mismatch xy%0d,%0d",x,y);\n   checks++;');
s=s.replace(' if(REFERENCE)begin $fclose(f);', ' if(visible<512)$fatal(1,"did not observe complete visible lines");\n if(REFERENCE)begin $fclose(f);');
fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
const base=fs.readFileSync(p.join(src,'rom.hex'),'utf8').trim().split(/\s+/).map(x=>parseInt(x,16));
const defs=[['mode4',{SAMPLES:170000}],['gg',{GG:1,REQUEST_Y:168,SAMPLES:65000}],['text',{R0:0,R1:0x50}],['graphics1',{R0:0}],['graphics2',{R0:2}],['mixed_m3',{R0:2,R1:0x48,REQUEST_Y:240}],['sms224',{R0:6,R1:0x50,REQUEST_Y:224}],['pal240',{R0:6,R1:0x48,REQUEST_Y:240,PAL:1,SAMPLES:60000}],['scroll',{scroll:true,REQUEST_X:250}]];
let cases=[];
for(const[id,opts]of defs){const cfg={SLOTS:8,GG:0,PAL:0,REQUEST_Y:192,REQUEST_X:40,SPRITES:0,REPLAYS:3,PROTO:1,TURBO:1,FIX:1,EXT_REFERENCE:1,WARMUP:1,SAMPLES:42000,...opts};let rom=[...base];
for(const[r,val]of [[0,cfg.R0],[1,cfg.R1],[9,23]])if(val!==undefined){let found=false;for(let i=0;i<150;i++)if(rom[i]===0x3e&&rom[i+2]===0xd3&&rom[i+3]===0xbf&&rom[i+4]===0x3e&&rom[i+5]===(0x80|r)){rom[i+1]=val;found=true;break;}if(!found)throw Error('register '+r);}
if(cfg.scroll){const code=[0x3e,9,0xd3,0xbf,0x3e,0x88,0xd3,0xbf,0x3e,241,0xd3,0xbf,0x3e,0x88,0xd3,0xbf,0x3e,23,0xd3,0xbf,0x3e,0x89,0xd3,0xbf,0xdb,0xbf,0x32,0,0xc1,0xc3,0x8b,0];for(let i=0;i<code.length;i++)rom[0x8b+i]=code[i];}
for(const k of ['R0','R1','scroll'])delete cfg[k];
for(const ref of [1,0]){const dir=p.join(d,(ref?'reference_':'dut_')+id);fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p.join(dir,'rom.hex'),rom.map(x=>x.toString(16).padStart(2,'0')).join('\n')+'\n');const args=Object.entries({...cfg,REFERENCE:ref}).map(([k,v])=>'-g'+k+'='+v).join(' ');fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb ${args} -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}
cases.push({id,cfg});}fs.writeFileSync(p.join(d,'cases.json'),JSON.stringify(cases,null,2));
console.log('Nine nonuniform background/crop/height/scroll fixtures prepared');
