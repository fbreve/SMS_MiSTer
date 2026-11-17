const fs=require('fs'),p=require('path'),d=__dirname,root=p.resolve(d,'../..'),src=p.join(root,'tests/savestate_g12_sdram_fix/final_matrix'),dst=p.join(d,'matrix');fs.mkdirSync(dst,{recursive:true});
const forward=fs.readFileSync(p.join(d,'mc_forward.hex'),'utf8').trim().split(/\r?\n/).map(x=>parseInt(x,16));if(forward.length!==131072)throw Error('missing MC LUT');
const inverse=new Array(131072);for(let block=0;block<512;block++){const seen=new Set();for(let v=0;v<256;v++){const out=forward[block*256+v];if(seen.has(out))throw Error('non-bijective key '+block);seen.add(out);inverse[block*256+out]=v;}}
fs.writeFileSync(p.join(d,'mc_inverse.hex'),inverse.map(v=>v.toString(16).padStart(2,'0')).join('\n')+'\n');
for(const f of ['audio_tb.sv','pin_model.sv','sdram.v','savestates_sim.sv','mapper_ctrl_sim.vhd','T80_sim.vhd','T80s_sim.vhd','pause_fixture.sv','jt89.v','rom.hex','compile.do'])fs.copyFileSync(p.join(src,f),p.join(dst,f));
for(const f of ['crypto_functions.svh','decrypt_path.sv','mc_forward.hex','mc_inverse.hex'])fs.copyFileSync(p.join(d,f),p.join(dst,f));
const startup=fs.readFileSync(p.join(src,'rom.hex'),'utf8').trim().split(/\r?\n/).map(x=>parseInt(x,16));
const opcodes=new Set([0,4,8,0xd9,0xaf,0xf3,0xfb,0x76,0x7e,0x78,0x23,0xc5,0xc1,0xf5,0xf1,0xc9]);
function mark(bytes,flags,start,end){let i=start;while(i<end){let op=bytes[i];flags[i]=1;if([0xdd,0xfd].includes(op)){flags[i+1]=1;i+=4;}else if([0xcb,0xed].includes(op)){flags[i+1]=1;i+=2;}else if([0x31,1,0x11,0x21,0x32,0x3a,0xc3,0xcd].includes(op))i+=3;else if([0x3e].includes(op))i+=2;else if(opcodes.has(op))i++;else throw Error('unknown fixture opcode '+op.toString(16)+' at '+i.toString(16));}}
for(let program=0;program<3;program++){
 const bytes=[...startup],flags=Array(65536).fill(0);mark(bytes,flags,0,46);
 if(program===0)mark(bytes,flags,46,94);
 else{
 bytes[46]=0xc3;bytes[47]=0;bytes[48]=1;flags[46]=1;
 const body=program===1?[0x3e,0xff,0x32,0xff,0xff,0x78,0x32,0xfe,0xff,4,0xcb,7,0xed,0x44,0xdd,0x21,0x34,0x12,0xfd,0x21,0x78,0x56,0xfb,0xf3,0x21,0xfd,0x3f,0x7e,0x32,0,0xc1,0x23,0x7e,0x32,1,0xc1,0x23,0x7e,0x32,2,0xc1,0x21,0xff,0x7f,0x7e,0x32,3,0xc1,0x23,0x7e,0x32,4,0xc1,0x23,0x7e,0x32,5,0xc1,0xcd,0,2,0xc3,0,1]:[0xfb,0x76,0xf3,0xc3,0,1];
 body.forEach((v,i)=>bytes[256+i]=v);mark(bytes,flags,256,256+body.length);
 const sub=[0xc5,0xf5,0x3a,3,0x40,0x32,6,0xc1,0xf1,0xc1,0xc9];sub.forEach((v,i)=>bytes[512+i]=v);mark(bytes,flags,512,512+sub.length);
 }
 mark(bytes,flags,0x66,0x6e);
 fs.writeFileSync(p.join(dst,`program_${program}.hex`),bytes.map(v=>v.toString(16).padStart(2,'0')).join('\n')+'\n');
 fs.writeFileSync(p.join(dst,`opmask_${program}.hex`),flags.join('\n')+'\n');
}
let pm=fs.readFileSync(p.join(dst,'pin_model.sv'),'utf8');
pm=pm.replace('parameter TAC=1,','parameter MODE=0,PROGRAM=0,TAC=1,');
pm=pm.replace('reg[7:0]program_bytes',`\`include "crypto_functions.svh"
reg[7:0]forward[0:131071],inverse[0:131071];reg opmask[0:65535];
initial begin $readmemh("mc_forward.hex",forward);$readmemh("mc_inverse.hex",inverse);$readmemh($sformatf("opmask_%0d.hex",PROGRAM),opmask);end
function[7:0]plain_byte(input[15:0]a,input[24:0]physical,input bit op);reg[7:0]v;begin
 v=byte_at(physical);
 if(MODE==2&&!a[15])plain_byte=swap_bits(v,swap_byte(sega_index(a,op)))^xor_byte(sega_index(a,op));
 else if(((MODE&1)&&!a[15])||(MODE==3&&!a[14]))plain_byte=forward[{op,key_byte(key_address(a,op)),v}];
 else plain_byte=v;
end endfunction
function[7:0]encode(input[15:0]a,input[7:0]v,input bit op);reg[7:0]r;begin
 encode=v;
 if(MODE==2&&!a[15])begin for(integer n=0;n<256;n++)if((swap_bits(n,swap_byte(sega_index(a,op)))^xor_byte(sega_index(a,op)))==v)encode=n;end
 else if(((MODE&1)&&!a[15])||(MODE==3&&!a[14]))encode=inverse[{op,key_byte(key_address(a,op)),v}];
end endfunction
reg[7:0]program_bytes`);
pm=pm.replace('$readmemh("rom.hex",program_bytes)','$readmemh($sformatf("program_%0d.hex",PROGRAM),program_bytes)');
pm=pm.replace('program_bytes[46]=',"opmask[46]=1;opmask[47]=0;opmask[48]=0;program_bytes[46]=");
pm=pm.replace('addr<256','addr<1024').replace("addr<25'h40100","addr<25'h40400").replace('byte_at=program_bytes[addr[7:0]]','byte_at=encode({6\'d0,addr[9:0]},program_bytes[addr[9:0]],opmask[addr[9:0]])');
fs.writeFileSync(p.join(dst,'pin_model.sv'),pm);
let s=fs.readFileSync(p.join(dst,'audio_tb.sv'),'utf8');
s=s.replace('parameter TAC=','parameter MODE=0,PROGRAM=0,CONTEXT=-1,TAIL_DELAY=0,TAC=');
s=s.replace('repeat(BOOT)tick','repeat(BOOT+8200)tick');
s=s.replaceAll('pin_model #(.TAC(TAC)', 'pin_model #(.MODE(MODE),.PROGRAM(PROGRAM),.TAC(TAC)');
s=s.replace('.irom_D_out(sd)','.irom_D_out(decoded)').replace('.irom_D_out(rsd)','.irom_D_out(rchip.plain_byte(ra,rphys,!rm1))');
s=s.replace('tri[15:0]dq,rdq;',`wire[7:0]decoded;wire decrypt_loaded;
decrypt_path #(.MODE(MODE)) crypt(clk,ca,!cm1,sd,decoded,decrypt_loaded);
tri[15:0]dq,rdq;`);
s=s.replace('if(CACHEHISTORY&&n==500)','if((CACHEHISTORY||PROGRAM==2)&&n==500)').replace('if(CACHEHISTORY&&n==504)','if((CACHEHISTORY||PROGRAM==2)&&n==504)');
s=s.replace('pending<=LATENCY;readaddr',"pending<=LATENCY+((DDRAM_ADDR-29'h07c00000)==29'h2900 ? TAIL_DELAY : 0);readaddr");
s=s.replace('if(SEEK)storage_busy=1;request(1);','if(SEEK||CONTEXT>=0)storage_busy=1;request(1);\nif(CONTEXT>=0)begin while(!(dut.state==37&&vb&&x<256&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&restart_out==CONTEXT))tick;storage_busy=0;end');
s=s.replace('G12 CPU/memory mismatch','G11 CPU/memory mismatch');
s=s.replace(/\nendmodule\s*$/,`
integer baseline_consumptions=0,decrypt_consumptions=0;reg[1:0]seen_phase=0;integer trace_left=0;
always@(posedge clk)begin
 if(cpu_prepare)trace_left=36;
 if((cpu_prepare&&replay&&ce_cpu)||(!ss_freeze&&cpu_ce&&(!paused||ss_capture_progress)))begin
  if(reset_n&&!crd&&!cmreq&&ca<16'hc000)begin
   if(sd!==chip.byte_at(phys))$fatal(1,"CONTRADICTORY_G12 raw cycle%0d address%h raw%h expected%h",cycle,phys,sd,chip.byte_at(phys));
   if(decoded!==chip.plain_byte(ca,phys,!cm1))begin
    $display("DECRYPT_INPUT_MATCH cycle%0d A%h physical%h raw%h goldenRaw%h M1%b MC%0d TS%0d CPU%h",cycle,ca,phys,sd,chip.byte_at(phys),cm1,cpu.MCycle,cpu.TState,z80_reg);
    $fatal(1,"G11_DECRYPT_BYTE cycle%0d freeze%b prepare%b actual%h expected%h phase%b madr%h xd%h sd%h mc%h ka%h kd%h",cycle,ss_freeze,cpu_prepare,decoded,chip.plain_byte(ca,phys,!cm1),crypt.segapipe.phase,crypt.segapipe.madr,crypt.segapipe.xd,crypt.segapipe.sd,crypt.mc,crypt.ka,crypt.kd);
   end
   decrypt_consumptions++;if(!ss_busy)baseline_consumptions++;
  end
 end
 seen_phase[crypt.segapipe.phase]=1;
 if(trace_left>0)begin
  $display("G11_TRACE cycle%0d state%0d freeze%b prep%b rawPhase%0d MC%0d TS%0d A%h phys%h M1%b RD%b req%b q%0d ready%b raw%h decode%h expected%h dphase%b madr%h xd%h swp%h mc%h keyA%h keyD%h",cycle,dut.state,ss_freeze,cpu_prepare,clkd,cpu.MCycle,cpu.TState,ca,phys,cm1,crd,rd,live.q,ready,sd,decoded,chip.plain_byte(ca,phys,!cm1),crypt.segapipe.phase,crypt.segapipe.madr,crypt.segapipe.xd,crypt.segapipe.sd,crypt.mc,crypt.ka,crypt.kd);trace_left--;
 end
end
always@(posedge ss_freeze)$display("G11_CAPTURE cycle%0d CPU%h A%h raw%h decode%h phase%b madr%h xd%h sd%h mc%h keyD%h context%0d baselineReads%0d",cycle,z80_reg,ca,sd,decoded,crypt.segapipe.phase,crypt.segapipe.madr,crypt.segapipe.xd,crypt.segapipe.sd,crypt.mc,crypt.kd,restart_out,baseline_consumptions);
final $display("G11_CONSUMERS total%0d baseline%0d phaseValues%b",decrypt_consumptions,baseline_consumptions,seen_phase);
endmodule\n`);
fs.writeFileSync(p.join(dst,'audio_tb.sv'),s);
let compile=fs.readFileSync(p.join(dst,'compile.do'),'utf8').replace('../../../rtl/AudioMix.vhd','../../../rtl/spram.vhd ../../../rtl/AudioMix.vhd');
compile=compile.replace('vlog -work pause_work -sv -suppress 2244', 'vlog -work pause_work -sv -quiet ../../../rtl/parts.v ../../../rtl/MC8123.v ../../../rtl/SEGASYS1_PRGDEC.v decrypt_path.sv\nvlog -work pause_work -sv -suppress 2244');
fs.writeFileSync(p.join(dst,'compile.do'),compile);
console.log('Prepared real T80/live SDRAM/production key RAM and decrypt pipelines; v16 unchanged.');
