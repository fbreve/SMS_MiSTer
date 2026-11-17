const fs=require('fs'),p=require('path'),d=__dirname,map=require('./state_map.json');
let seed=0x51f01;const rand=()=>{seed^=seed<<13;seed^=seed>>>17;seed^=seed<<5;return seed>>>0;};
const patterns=[];
for(let pass=0;pass<8;pass++)for(let i=0;i<104;i++){
 let v=BigInt(rand())&BigInt('0x'+map.masks[i]);
 for(const r of map.rows.filter(r=>r.stored)){
  const n=r.signal.split(' ')[0],limit=r.module==='opll/s0'?72:['regs_addr','fb_addr','faddr'].includes(n)?9:n==='slot_voice_addr'?38:['rslot','mo_addr','maddr'].includes(n)?18:0;
  if(limit)for(const x of r.slices.filter(x=>x.word===i)){const mask=((1n<<BigInt(x.width))-1n)<<BigInt(x.wordLo);v=(v&~mask)|(BigInt(rand()%limit)<<BigInt(x.wordLo));}
 }
 patterns.push(v.toString(16).padStart(8,'0'));
}
fs.writeFileSync(p.join(d,'patterns.hex'),patterns.join('\n')+'\n');
let s=fs.readFileSync(p.join(d,'legacy_fm_tb.sv'),'utf8');s=s.slice(0,s.indexOf('initial begin')).replace('module legacy_fm_tb;','module integrity_tb;').replace('reg reset_n=0,','reg apply_state=0,bulk_write=0;reg[63:0]bulk_wdata=0;reg reset_n=0,').replace(".apply_state(1'b0)",'.apply_state(apply_state)').replace(".bulk_write(1'b0)",'.bulk_write(bulk_write)').replace(".bulk_wdata(64'd0)",'.bulk_wdata(bulk_wdata)');
s+=`reg[31:0]patterns[0:831];integer writes=0,reads=0;reg[103:0]seen_w=0,seen_r=0;
always@(posedge clk)begin
 if(write_en)begin if(seen_w[addr])$fatal(1,"duplicate restore");seen_w[addr]=1;writes++;end
 if(read_en)begin if(seen_r[addr])$fatal(1,"duplicate capture");seen_r[addr]=1;reads++;end
end
initial begin
 $readmemh("patterns.hex",patterns);repeat(6)tick;reset_n=1;repeat(116)tick;hold=1;
 for(integer pass=0;pass<8;pass++)begin
  seen_w=0;seen_r=0;writes=0;reads=0;
  for(integer i=0;i<52;i++)begin
   bulk_addr=i;bulk_wdata={patterns[pass*104+2*i+1],patterns[pass*104+2*i]};bulk_write=1;tick;bulk_write=0;finish_op;repeat((i*7+pass)%13)tick;
  end
  apply_state=1;tick;apply_state=0;finish_op;
  if(writes!=104||seen_w!=={104{1'b1}})$fatal(1,"restore coverage");
  capture=1;tick;capture=0;finish_op;
  if(reads!=104||seen_r!=={104{1'b1}})$fatal(1,"capture coverage");
  for(integer i=0;i<52;i++)begin
   bulk_addr=i;bulk_read=1;tick;bulk_read=0;finish_op;
   if(bulk_rdata!=={patterns[pass*104+2*i+1],patterns[pass*104+2*i]})$fatal(1,"OPLL map alias/truncation pass%0d word%0d actual%h expected%h",pass,i,bulk_rdata,{patterns[pass*104+2*i+1],patterns[pass*104+2*i]});
  end
  $display("PASS INTEGRITY pass%0d words104",pass);
 end
 $display("PASS INTEGRITY ALL random_words832 exact_once");$finish;
end
initial begin #10000000;$fatal(1,"integrity watchdog");end
endmodule\n`;
fs.writeFileSync(p.join(d,'integrity_tb.sv'),s);
fs.writeFileSync(p.join(d,'integrity.do'),'onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib integrity_work\nvlog -work integrity_work -sv ../../rtl/opll_snapshot.sv integrity_tb.sv\nvsim -L local_work -t 1ps integrity_work.integrity_tb\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n');
