const fs=require('fs'),path=require('path');const d=__dirname,old=path.resolve(d,'../savestate_cpu_nmi_fix/candidate'),current=path.join(d,'candidate');
function read(p){let b=fs.readFileSync(p);return b.toString(b[0]===255?'utf16le':'utf8');}
function entity(root,name){const s=read(path.join(root,'output_files/SMS.map.rpt'));for(const line of s.split(/\r?\n/)){const c=line.split(';').map(x=>x.trim());if(c.length<11||!c[8].endsWith(name))continue;const a=c[2].match(/\((\d+)\)/),n=c[3].match(/\((\d+)\)/);if(a&&n)return{aluts:+a[1],registers:+n[1]};}throw Error(name);}
const components={};for(const[name,suffix]of Object.entries({controller:'|savestates:savestates_inst',cpu:'|T80:u0',wrapper:'|T80s:z80_inst',evolution:'|evolution_mapper:evolution_mapper_inst'})){const baseline=entity(old,suffix),candidate=entity(current,suffix);components[name]={baseline,candidate,delta:{aluts:candidate.aluts-baseline.aluts,registers:candidate.registers-baseline.registers}};}
const total=root=>+read(path.join(root,'output_files/SMS.map.summary')).match(/Total registers\s*:\s*([\d,]+)/)[1].replace(/,/g,'');const result={baselineRegisters:total(old),candidateRegisters:total(current),components};
const key='emu:emu|savestates:savestates_inst|cur_bios_mode';
const merged=root=>read(path.join(root,'output_files/SMS.map.rpt')).split(/\r?\n/).map(l=>l.split(';').map(x=>x.trim())).find(c=>c[1]===key&&/Merged with/.test(c[2]||''));
const assignments=root=>read(path.join(root,'rtl/savestates.sv')).split(/\r?\n/).filter(l=>/cur_(bios_mode|magic)\s*<=/.test(l)).map(l=>l.trim().replace(/\s+/g,' '));
if(merged(old)||!merged(current)||!merged(current)[2].includes('cur_magic[0]')||JSON.stringify(assignments(old))!==JSON.stringify(assignments(current)))throw Error('Unexpected BIOS merge ledger');
result.registerLedger={newContextSnapshot:3,newValidity:1,newPaddingCheck:1,existingEquivalentRegisterMerge:-1,mappedDelta:4,mergedRegister:key,reason:merged(current)[2],unchangedAssignments:assignments(current)};
if(result.candidateRegisters-result.baselineRegisters!==4)throw Error('Register total');
fs.writeFileSync(path.join(d,'prefit.json'),JSON.stringify(result,null,2));console.log(JSON.stringify(result,null,2));
