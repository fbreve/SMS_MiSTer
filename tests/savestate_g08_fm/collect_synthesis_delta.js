const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname;
const old=fs.readFileSync(p.join(d,'../savestate_f06_sega_sram_fix/quartus_early/output_files/SMS.map.rpt'),'utf8'),now=fs.readFileSync(p.join(d,'quartus_early/output_files/SMS.map.rpt'),'utf8');
function entity(text,name){const line=text.split(/\r?\n/).find(l=>l.split(';')[8]?.trim()===name);assert(line,name);const c=line.split(';');return {ALUTs:+c[2].trim().match(/^\d+/)[0],registers:+c[3].trim().match(/^\d+/)[0]};}
const rows=['|sys_top|emu:emu|savestates:savestates_inst','|sys_top|emu:emu|system:system|AudioMix:mix','|sys_top|audio_out:audio_out'].map(name=>{const baseline=entity(old,name),candidate=entity(now,name);return {name,baseline,candidate,delta:{ALUTs:candidate.ALUTs-baseline.ALUTs,registers:candidate.registers-baseline.registers}};});
assert.deepEqual(rows.map(x=>x.delta.registers),[17,4,16]);
const merges=s=>s.split(/\r?\n/).filter(l=>l.includes('Merged with')&&l.includes('[1,2]')&&/AudioMix:mix|audio_out:audio_out/.test(l)).map(l=>l.replace(/\s+/g,' ').trim());
const n=new Set(merges(now)),removedMerges=merges(old).filter(l=>!n.has(l));assert.equal(removedMerges.length,10);
fs.writeFileSync(p.join(d,'synthesis_delta.json'),JSON.stringify({synthesisRegisterDelta:37,rows,removedMerges,explanation:'17 controller registers are16 historical sample bits plus presence. The other20 registers correspond exactly to10 former low-bit[1,2] merges: AudioMix4 and downstream audio_out16. A restored signed16-bit sample can carry independent low bits; the old arithmetic-only input had equal low three bits. No OPLL state bank, DSP or memory growth.'},null,2));
console.log(JSON.stringify(rows,null,2));
