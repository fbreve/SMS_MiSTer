const fs=require('fs'),p=require('path'),d=__dirname;
const out={note:'Hierarchy ALMs are fitter allocation estimates, not additive causal measurements. Failed-fit routing/placement counts are provisional and cannot establish usable resource or timing improvement.',builds:{}};
for(const [name,folder]of [['baseline',p.join(d,'../savestate_f01_opll_fix/quartus_final')],['A',p.join(d,'quartus_A')],['confirmation',p.join(d,'quartus_confirmation')]]){
 const file=p.join(folder,'output_files/SMS.fit.rpt');if(!fs.existsSync(file))continue;
 const text=fs.readFileSync(file,'utf8'),lines=text.split(/\r?\n/),start=text.indexOf('; Compilation Hierarchy Node'),fields=['node','neededEstimate','placedEstimate','recoverableEstimate','unavailableEstimate','memoryALMEstimate','logicALUT','dedicatedRegisters','IORegisters','blockMemoryBits'];
 const hierarchy=text.slice(start).split(/\r?\n/).map(l=>l.split(';').slice(1).map(x=>x.trim())).filter(a=>/^\|(savestates:savestates_inst|vdp:vdp2?_inst|vdp_sprites:vdp_spr_inst|sprite_snapshot:sprite_memory)\|$/.test(a[0])).map(a=>({...Object.fromEntries(fields.map((k,i)=>[k,a[i]])),fullHierarchy:a[13]}));
 const holdAt=text.indexOf('; Estimated Delay Added for Hold Timing Summary',start),detailsAt=text.indexOf('; Estimated Delay Added for Hold Timing Details',holdAt),fanAt=text.indexOf('; Non-Global High Fan-Out Signals',start);
 out.builds[name]={hierarchy,footprint:lines.filter(l=>/Total LABs:|Average interconnect usage|Peak interconnect usage/.test(l)).slice(0,3),holdRepairSummary:text.slice(holdAt,detailsAt).split(/\r?\n/).filter(l=>l.startsWith(';')&&!/Summary|Source Clock/.test(l)),highFanout:text.slice(fanAt,fanAt+18000).split(/\r?\n/).filter(l=>/;\s*\d+\s*;/.test(l)).slice(0,20)};
}
fs.writeFileSync(p.join(d,'physical_diagnostics.json'),JSON.stringify(out,null,2)+'\n');console.log({builds:Object.keys(out.builds)});
