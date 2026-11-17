const fs=require('fs'),p=require('path'),d=__dirname;
let s=fs.readFileSync(p.join(d,'../savestate_f01_opll_fix/collect_build.js'),'utf8');
s=s.replace("process.argv[2]||'early'","process.argv[2]||'A'")
 .replace('fm_snapshot|VoiceMemory|EnvelopeMemory','sprite_memory|fm_snapshot|VoiceMemory|EnvelopeMemory')
 .replace('tests/savestate_g12_sdram_fix/quartus_candidate','tests/savestate_f01_opll_fix/quartus_final')
 .replace('savestate_g12_sdram_fix|savestate_f01_opll_fix','savestate_g06_sequential_architecture|savestate_f01_opll_fix')
 .replace("snapshotInferred:candidate.M10K===488&&candidate.memoryBits===3818050&&candidate.ramLines.some(l=>/fm_snapshot/.test(l)&&/8192/.test(l))","snapshotInferred:candidate.M10K===490&&candidate.memoryBits===3827650&&candidate.ramLines.some(l=>/sprite_memory/.test(l)&&/9600/.test(l)),placedRecovered:baseline.placed-candidate.placed,historicalRecoveredPercent:100*(baseline.placed-candidate.placed)/5458,savedPerExtraM10K:(baseline.placed-candidate.placed)/(candidate.M10K-baseline.M10K),M10KRemaining:553-candidate.M10K,seed:manifest.seed");
fs.writeFileSync(p.join(d,'collect_build.js'),s);
