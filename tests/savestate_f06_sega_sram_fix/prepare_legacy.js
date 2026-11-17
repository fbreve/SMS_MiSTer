const fs=require('fs'),p=require('path'),d=__dirname,dst=p.join(d,'legacy');fs.mkdirSync(dst,{recursive:true});
let s=fs.readFileSync(p.join(d,'current/f06_tb.sv'),'utf8');s=s.slice(0,s.indexOf('integer mode,words,bytes,fd;'));
s+=`integer mode,words;reg[7:0]flags;
initial begin
 for(integer j=0;j<12288;j++)mem[j]=0;
 repeat(4)tick;reset_n=1;mapper_reset_n=1;repeat(4)tick;
 for(mode=0;mode<4;mode++)begin
  flags=mode==0?0:mode==1?8'h08:mode==2?8'h0c:8'h18;
  hostfill(0,mode+37);control(flags);if(flags[4])expected['h3ffc]=flags;a=0;di=0;repeat(3)tick;
  save_now(4096);mem['h1a][63:40]=24'h484311;
  // The legacy tag must retain its exact old prefix, even with a populated
  // modern tail. Tail bytes are deliberately poisoned against accidental use.
  words=(flags&8'h14)?4096:(flags&8)?2048:0;
  for(integer j=words;j<4096;j++)mem['hd01+j]=~mem['hd01+j];
  control(0);hostfill(1,0);load_now(words*8);physical_scan(words*8);
  $display("PASS LEGACY v17 flags%h restorebytes%0d missingbytesretained%0d",flags,restore_bytes,32768-restore_bytes);
 end
 $display("PASS LEGACY COMPLETE");$finish;
end
initial begin #100000000;$fatal(1,"legacy watchdog");end
endmodule
`;
fs.writeFileSync(p.join(dst,'f06_tb.sv'),s);
for(const f of ['savestates_sim.sv','mapper_sim.vhd','compile.do'])fs.copyFileSync(p.join(d,'current',f),p.join(dst,f));
fs.writeFileSync(p.join(dst,'run.do'),'onerror {quit -code 1}\nvsim -c -t 1ps -L altera_mf work.sram_tb\nset StdArithNoWarnings 1\nset NumericStdNoWarnings 1\nrun -all\nquit -code 0\n');
const psg=p.join(d,'psg');fs.mkdirSync(psg,{recursive:true});
for(const f of ['psg_replay_tb.sv','psg.do'])fs.copyFileSync(p.join(d,'../savestate_coverage',f),p.join(psg,f));
let ps=fs.readFileSync(p.join(psg,'psg.do'),'utf8').replaceAll('../../rtl/','../../../rtl/');fs.writeFileSync(p.join(psg,'psg.do'),ps);
