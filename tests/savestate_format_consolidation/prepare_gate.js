const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..'),src=p.join(d,'../savestate_f01_opll_fix'),adapter=require('../savestate_g06_g10_fix/controller_adapter');
const ctrl=adapter(p.join(d,'candidate/rtl/savestates.sv'));
const rows=require('../savestate_f01_opll_fix/regression_manifest.json');
for(const family of new Set(rows.map(r=>r.family))){
 const from=p.join(src,family),to=p.join(d,family);fs.mkdirSync(to,{recursive:true});
 for(const file of fs.readdirSync(from))if(fs.statSync(p.join(from,file)).isFile()&&/\.(sv|svh|v|vhd|hex|do)$/.test(file))fs.copyFileSync(p.join(from,file),p.join(to,file));
 if(fs.existsSync(p.join(from,'rtl')))fs.cpSync(p.join(from,'rtl'),p.join(to,'rtl'),{recursive:true});
 for(const r of rows.filter(r=>r.family===family)){const dst=p.join(to,r.name);fs.mkdirSync(dst,{recursive:true});for(const file of fs.readdirSync(p.join(from,r.name)))if(/\.(do|dat|hex|bin)$/.test(file))fs.copyFileSync(p.join(from,r.name,file),p.join(dst,file));}
 const controller=family==='reg_g01'?'savestates_integrated.sv':'savestates_sim.sv';assert(fs.existsSync(p.join(to,controller)),family);
 fs.writeFileSync(p.join(to,controller),ctrl.replace('900000','0'));
}
fs.writeFileSync(p.join(d,'regression_manifest.json'),JSON.stringify(rows,null,2));
let runner=fs.readFileSync(p.join(src,'regress.ps1'),'utf8');runner=runner.replace(/\$decision=.*?\r?\nif\(\$decision.*?\r?\n/,'');if(!fs.existsSync(p.join(d,'regress.ps1')))fs.writeFileSync(p.join(d,'regress.ps1'),runner);
// Full current-format rejection/packing suite, with intentional old-tag removals.
let tb=fs.readFileSync(p.join(src,'format/format_tb.sv'),'utf8');
const start=tb.indexOf(' // Every inherited tagged format'),end=tb.indexOf(' expect_background=1;mem[\'h1a]=oldtag;',start);assert(start>=0&&end>start);
tb=tb.slice(0,start)+` oldtag=mem['h1a];
 for(integer version=1;version<=16;version++)begin
  mem['h1a][63:40]=24'h484300+version;mem['h1a][39:38]=version==1?0:version==2?2:3;
  transfer(0);if(guest_writes)$fatal(1,"removed tag accepted version%0d",version);rejections++;
 end
`+tb.slice(end);
tb=tb.replace('PASS V17 FORMAT','PASS CONSOLIDATION FORMAT').replace('inherited1to14 old64','removed1to16 public64').replace('repeat(4)tick;reset_n=1;transfer(1);','repeat(4)tick;reset_n=1;transfer(1);\n for(integer w=0;w<12288;w++)if($isunknown(mem[w]))$fatal(1,"unknown current image word%h",w);');
for(const family of ['format','imports']){const dst=p.join(d,family);fs.mkdirSync(dst,{recursive:true});fs.writeFileSync(p.join(dst,'savestates_sim.sv'),ctrl);fs.copyFileSync(p.join(src,family,'run.do'),p.join(dst,'run.do'));}
fs.writeFileSync(p.join(d,'format/format_tb.sv'),tb.replace('assign replay=0;','assign replay=0;assign restart_out=0;'));
let imp=fs.readFileSync(p.join(src,'imports/imports_tb.sv'),'utf8');const a=imp.indexOf('for(integer version=1;version<=16;version++)'),b=imp.indexOf("for(integer i=0;i<12288;i++)mem[i]=image[i];\nmem['h1a][63:22]=0",a);assert(a>=0&&b>a);imp=imp.slice(0,a)+imp.slice(b);imp=imp.replace('loads20 tagged1to16 public96 public64','loads4 public96 public64');fs.writeFileSync(p.join(d,'imports/imports_tb.sv'),imp);
console.log({families:[...new Set(rows.map(r=>r.family))],regressions:rows.length});
