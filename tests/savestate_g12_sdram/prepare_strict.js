const fs=require('fs'),p=require('path'),d=__dirname,dst=p.join(d,'strict');fs.mkdirSync(dst,{recursive:true});
for(const f of ['audio_tb.sv','pin_model.sv','sdram.v','savestates_sim.sv','mapper_ctrl_sim.vhd','T80_sim.vhd','T80s_sim.vhd','pause_fixture.sv','jt89.v','rom.hex'])fs.copyFileSync(p.join(d,f),p.join(dst,f));
let s=fs.readFileSync(p.join(dst,'audio_tb.sv'),'utf8');
s=s.replace("ram_bytes[b]=(b*73)^(b>>5)^8'hd9", "ram_bytes[b]=(PATTERN==4)?(b^(b>>8)^(b>>11)^8'hd9):chip.byte_at(25'h100000+b)");
s=s.replace('if(CACHEHISTORY)begin\n // IN',`ram_bytes[0]=8'h1c;ram_bytes[7]=8'h7e;ram_bytes[8]=8'h80;ram_bytes[8191]=8'he1;ram_bytes[8192]=8'he2;ram_bytes[16383]=8'he3;
for(integer b=0;b<16384;b++)ref_bytes[b]=ram_bytes[b];
if(CACHEHISTORY)begin
 // IN`);
s=s.replace('pattern=h^(h>>8)^(h>>16)^(h>>24);','pattern=PATTERN==4?(addr^(addr>>8)^(addr>>14)^(owner*73)):(h^(h>>8)^(h>>16)^(h>>24));');
s=s.replace(/\nendmodule\s*$/,`
integer trace_after=0;
always@(posedge clk)begin
 if(audio_phase_set)trace_after=50;
 if(dut.state==37||cpu_prepare||trace_after>0)begin
  $display("G12_FULL_TRACE cycle%0d ss%0d freeze%b prepare%b ce%b m1%b mreq%b rd%b A%h physical%h q%0d oldrd%b flight%b ready%b data%h DDRbusy%b DDRread%b DDRwrite%b",cycle,dut.state,ss_freeze,cpu_prepare,cpu_ce,cm1,cmreq,crd,ca,phys,live.q,live.access_manager.old_rd,flight,ready,sd,DDRAM_BUSY,DDRAM_RD,DDRAM_WE);
  if(trace_after>0)trace_after--;
 end
end
endmodule
`);
fs.writeFileSync(p.join(dst,'audio_tb.sv'),s);
fs.writeFileSync(p.join(dst,'compile.do'),fs.readFileSync(p.join(d,'compile.do'),'utf8').replaceAll('../../rtl/','../../../rtl/'));
const cases=[],add=(id,args={})=>cases.push({id,args:{DUAL:3,BOOT:1200,N:4000,REPLAYS:1,TRANSFER:1,WAIT_WINDOW:1,PATTERN:4,...args}});
add('ordinary_address',{PATTERN:4});add('ordinary_random',{PATTERN:5,STALL:2,LATENCY:29});add('ordinary_canaries',{PATTERN:6,STALL:1,LATENCY:1});
for(const b of [0,1,2,3])add('systeme_banks_'+b,{DUAL:0,BANKS:b,ROMBANK:b*5,PATTERN:b===0?4:5,STALL:b%3,LATENCY:b?29:1});
for(const h of [0,1])add('cache_history_'+h,{CACHEHISTORY:1,HIST:h,PATTERN:5,N:12000,REPLAYS:3});
fs.writeFileSync(p.join(dst,'cases.json'),JSON.stringify(cases,null,2)+'\n');console.log('Prepared separate strict pattern/full-trace fixture; base campaign unchanged');
