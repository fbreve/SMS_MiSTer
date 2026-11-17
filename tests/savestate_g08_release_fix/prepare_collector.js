// Reuse the prior controlled-build parser with explicit version substitutions.
const fs=require('fs'),p=require('path'),d=__dirname;
let s=fs.readFileSync(p.join(d,'../savestate_g05_background_fix/collect_build.js'),'utf8');
s=s.replaceAll('savestate_g05_background_fix','savestate_g08_release_fix')
 .replaceAll('v14','__BASE__').replaceAll('v15','v16').replaceAll('__BASE__','v15')
 .replaceAll('retainedV14','retainedV15').replaceAll('v1[45]','v1[56]');
s=s.replace('substantialLogicGrowth:deltas.ALMsNeeded.fresh>1000','substantialLogicGrowth:deltas.ALMsNeeded.fresh>1000,substantialPlacementGrowth:deltas.ALMsPlaced.fresh>419');
s=s.replace("/^\\s*(Critical )?Warning \\(\\d+\\):/", "/^\\s*(Critical )?Warning(?: \\(\\d+\\))?:/")
 .replace("+l.match(/Warning \\((\\d+)\\)/)[1]", "(l.match(/Warning \\((\\d+)\\)/)||[])[1]||'unnumbered'")
 .replace('.sort((a,b)=>a-b)', ".sort((a,b)=>String(a).localeCompare(String(b),'en',{numeric:true}))");
fs.writeFileSync(p.join(d,'collect_build.js'),s);
console.log('Prepared controlled v15/v16 build collector');
