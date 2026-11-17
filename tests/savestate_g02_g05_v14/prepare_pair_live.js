const fs=require('fs'),p=require('path'),d=p.join(__dirname,'pair_live'),src=p.join(__dirname,'pair');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8');
s=s.replace('warming=0;',`warming=0;
  // Wait for a NEW guest write after legacy normalization, then for the
  // completed read/XOR normalization of A. This is observation, not a force.
  while(!(audit[3]&&audit[11:4]==(HISTORY?8'hc3:8'h03)))tick;
  while(!(z80_reg[79:64]==16'h00a4&&!cm1&&!cmreq))tick;
  $display("LIVE_ALIAS_HISTORY WD%h xy%0d,%0d PC%h",audit[11:4],x,y,z80_reg[79:64]);`);
fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
for(const hist of[0,1])for(const ref of[1,0]){let name=(ref?'reference_':'dut_')+'h'+hist,dir=p.join(d,name);fs.mkdirSync(dir,{recursive:true});fs.copyFileSync(p.join(src,name,'rom.hex'),p.join(dir,'rom.hex'));let run=fs.readFileSync(p.join(src,name,'run.do'),'utf8').replace('-gREQUEST_X=200','-gREQUEST_X=40');fs.writeFileSync(p.join(dir,'run.do'),run);}
console.log('Post-normalization natural differing stale write-data pair prepared');
