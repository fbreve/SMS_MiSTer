const fs=require('fs'),p=require('path'),d=p.join(__dirname,'text_history'),src=p.join(__dirname,'bg_pair');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8');
const old=".DI(!ciq?(ca[7:0]==8'hdc ? ((!history_done&&HISTORY&&y==191&&x>=350)?8'd0:8'd4):vd):ca>=16'hc000 ? ram[ca[12:0]]:rom[ca])";
const next=".DI(!ciq?(ca[7:0]==8'hdc ? {6'd0,future_input,!warming}:ca[7:0]==8'hdd ? ((!history_done&&HISTORY)?8'd1:8'd0):vd):ca>=16'hc000 ? ram[ca[12:0]]:rom[ca])";
if(!s.includes(old))throw Error('CPU input mux anchor');s=s.replace(old,next);
s=s.replace('reg history_done=0;','reg history_done=0;reg future_input=0;');
s=s.replace('request(1);history_done=1;','request(1);history_done=1;future_input=1;');
s=s.replace('request(0);divs=0;guestdiv=0;','future_input=0;request(0);future_input=1;divs=0;guestdiv=0;pixel_divs=0;fetch_divs=0;');
s=s.replace('reg scoring=0;','reg scoring=0;integer pixel_divs=0,fetch_divs=0;');
const pixel='if((!vb&&x>0&&x<=256&&color!==pixels[j]))$fatal(1,"integrated LOAD pixel mismatch x%0d y%0d dut%h ref%h",x,y,color,pixels[j]);';
if(!s.includes(pixel))throw Error('pixel oracle anchor');
s=s.replace(pixel,`if(!vb&&x>0&&x<=256&&color!==pixels[j])begin
 if(pixel_divs<12)$display("G05_VISIBLE_PIXEL_DIVERGENCE pass%0d j%0d xy%0d,%0d dut%h ref%h shifts%h data%h CPU%h VDP%h",pass,j,x,y,color,pixels[j],bg_state[62:31],bg_state[94:63],z80_reg,vdp_regs);
 pixel_divs++;
end`);
s=s.replace('if(!vb&&x>0&&x<=256&&audit[63:32]!==audit_trace[j][63:32])$fatal(1,"LOAD background fetch/palette/priority mismatch xy%0d,%0d",x,y);','if(!vb&&x>0&&x<=256&&audit[63:32]!==audit_trace[j][63:32])fetch_divs++;');
s=s.replace('  $display("RESULT pass%0d', '  $display("TEXT_HISTORY_RESULT pass%0d visiblePixelDiff%0d fetchDiff%0d",pass,pixel_divs,fetch_divs);\n  if(pixel_divs)$display("CONFIRMED_G05 naturally accepted text-to-Mode4 visible divergence pass%0d",pass);\n  $display("RESULT pass%0d');
s=s.replace(/\nendmodule\s*$/,`
reg old_mode4=0;
always@(posedge clk)begin
 if(!setup&&vdp_regs[5]!=old_mode4)$display("MODE_EDGE mode4%b cycle%0d xy%0d,%0d shifts%h data%h BG%h",vdp_regs[5],cycle,x,y,bg_state[62:31],bg_state[94:63],bg_state);
 old_mode4<=vdp_regs[5];
 if(vdp_regs_set)begin #1;$display("BG_RESTORE mode4%b cycle%0d shifts%h data%h BG%h",vdp_regs[5],cycle,bg_state[62:31],bg_state[94:63],bg_state);end
end
endmodule
`);fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
let base=fs.readFileSync(p.join(__dirname,'fixture/rom.hex'),'utf8').trim().split(/\s+/).map(x=>parseInt(x,16)),rom=Array(65536).fill(0),a=0x100;
rom[0]=0xc3;rom[1]=0;rom[2]=1;for(let i=0;i<0x8b;i++)rom[a++]=base[i];
const emit=(...b)=>b.forEach(x=>rom[a++]=x),out=(val,r)=>emit(0x3e,val,0xd3,0xbf,0x3e,0x80|r,0xd3,0xbf);
const loop=(bytes,condition)=>{const start=a;emit(...bytes,0x20|condition,0);rom[a-1]=(start-a)&255;};
out(0x50,1); // Raw text select, with Mode4 still enabled.
loop([0xdb,0xdc,0xe6,1],8); // JR Z until genuine legacy normalization finished.
emit(0xdb,0xdd,0xd3,0xbf,0x3e,0x89,0xd3,0xbf); // past R9=0 or1
loop([0xdb,0x7e,0xfe,190],0); // wait real VCounter190 (JR NZ)
out(0,0); // ONE register change enters text; ordinary planes now hold.
out(0,9); // Restore identical architectural vertical scroll while text holds.
loop([0xdb,0xdc,0xe6,2],8); // JR Z until identical logical future begins.
loop([0xdb,0x7e,0xb7],0); // wait VCounter0 near the first visible line
out(4,0); // ONE register change exposes retained nontext history.
const poll=a;emit(0xdb,0xbf,0x32,0,0xc1,0xc3,poll&255,poll>>8);
fs.writeFileSync(p.join(d,'program.json'),JSON.stringify({poll,end:a,bytes:rom.slice(0x100,a)},null,2));
for(const hist of[0,1])for(const ref of[1,0]){const dir=p.join(d,(ref?'reference_':'dut_')+'h'+hist);fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p.join(dir,'rom.hex'),rom.map(x=>x.toString(16).padStart(2,'0')).join('\n')+'\n');fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gSLOTS=64 -gGG=0 -gREQUEST_Y=192 -gREQUEST_X=120 -gWARMUP=1 -gEXT_REFERENCE=1 -gHISTORY=${hist} -gREFERENCE=${ref} -gSPRITES=0 -gSAMPLES=42000 -gREPLAYS=3 -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}
console.log('Natural inactive-plane text-to-Mode4 witness and equal-image candidate prepared');
