// Additional actual-controller tests; never mutate libraries being simulated.
const fs=require('fs'),p=require('path'),d=__dirname;
function clone(src,name){const dst=p.join(d,name);fs.mkdirSync(dst,{recursive:true});for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do','vdp_tb.sv'])fs.copyFileSync(p.join(d,src,f),p.join(dst,f));fs.cpSync(p.join(d,src,'rtl'),p.join(dst,'rtl'),{recursive:true});return dst;}
function caseCopy(dst,src,id,old,edit){for(const ref of [true,false]){const label=(ref?'reference_':'dut_'),dir=p.join(dst,label+id);fs.mkdirSync(dir,{recursive:true});for(const f of ['rom.hex','run.do']){let s=fs.readFileSync(p.join(d,src,label+old,f),'utf8');if(f==='run.do')s=edit(s,ref);fs.writeFileSync(p.join(dir,f),s);}}}
const dst=clone('integrated_g04','integrated_stalls');let s=fs.readFileSync(p.join(dst,'vdp_tb.sv'),'utf8').replace(/always@\(negedge clk\)if\(STALL\)DDRAM_BUSY<=.*?;\n/,'');
s=s.replace(/\nendmodule\s*$/,`
reg[15:0]stall_rng=16'h1ace;integer frozen_start=0;
always@(negedge clk)begin #0.001;
 stall_rng={stall_rng[14:0],stall_rng[15]^stall_rng[13]^stall_rng[12]^stall_rng[10]};
 DDRAM_BUSY=(DDRAM_RD||DDRAM_WE)&&(STALL==1?cycle%97<83:STALL==2?stall_rng[3:0]<13:0);
end
always@(posedge ss_freeze)frozen_start=cycle;
always@(negedge ss_freeze)if(hadfreeze)$display("TRANSPORT_DURATION save%b profile%0d hostclocks%0d",dut.do_save,STALL,cycle-frozen_start);
endmodule
`);fs.writeFileSync(p.join(dst,'vdp_tb.sv'),s);
for(const [id,profile,phases,fast] of [['deterministic',1,0,1],['lfsr',2,0,1],['phases',0,1,1],['full_flush',0,0,0]])caseCopy(dst,'integrated_g04',id,'pending',(s,ref)=>s.replace('-gREPLAYS=3','-gREPLAYS='+(phases?13:3)).replace('-gREFERENCE=',`-gSTALL=${profile} -gNATURAL_PHASE=${phases} -gREFERENCE=`).replace('TB_FAST=1','TB_FAST='+fast));
const mask=clone('integrated_rich','integrated_masked');let t=fs.readFileSync(p.join(mask,'vdp_tb.sv'),'utf8').replace('.black_column(1\'b0)',".black_column(1'b1)").replace('.black_column(0)',".black_column(1'b1)");
if(!t.includes(".black_column(1'b1)"))throw Error('black column anchor');fs.writeFileSync(p.join(mask,'vdp_tb.sv'),t);
caseCopy(mask,'integrated_rich','masked','scroll',(s)=>s.replace('-gSAMPLES=42000','-gSAMPLES=42000'));
// CPU R0 write in the immutable ROM: enable hardware left-column masking.
for(const pre of ['reference_','dut_']){const f=p.join(mask,pre+'masked','rom.hex');let b=fs.readFileSync(f,'utf8').trim().split(/\s+/);let n=0;for(let i=0;i<b.length-7;i++)if(b.slice(i,i+8).join(' ').toLowerCase()==='3e 04 d3 bf 3e 80 d3 bf'){b[i+1]='24';n++;}if(n!==1)throw Error('R0 ROM anchor '+n);fs.writeFileSync(f,b.join('\n')+'\n');}
console.log('Prepared actual v15 stalls, natural phases, full flush, masked scrolling');
