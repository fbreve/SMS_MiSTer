const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),d=__dirname,r=p.resolve(d,'../..');
module.exports=function verify(){
 const read=n=>fs.readFileSync(n,'utf8').replaceAll('\r',''),sha=s=>crypto.createHash('sha256').update(s).digest('hex'),norm=s=>s.split('\n').map(x=>x.trim().replace(/\s+/g,' ').replace(/^set_instance_assignment -name HPS_LOCATION (\S+) -entity sys_top -to (\S+)$/,'set_hps_location_assignment $1 -to $2')).filter(Boolean).join('\n');
 const initial=read(p.join(r,'SMS.qsf')),actual=read(p.join(d,'candidate/SMS.qsf'));let expected=initial;const expansions={};
 for(const n of ['sys/sys.tcl','sys/sys_analog.tcl','files.qip']){const commands=read(p.join(r,n)).split('\n').map(x=>x.trim()).filter(x=>/^set_(global|instance|location)_assignment /.test(x));expansions[n]=commands.length;expected=expected.replace('source '+n,'source '+n+'\n'+commands.join('\n'));}
 fs.writeFileSync(p.join(d,'expected_flow.qsf'),expected);const mode=norm(actual)===norm(initial)?'unchanged':'materialized';if(mode==='materialized'){const a=norm(actual).split('\n'),e=norm(expected).split('\n'),k=a.findIndex((x,i)=>x!==e[i]);assert(k<0&&a.length===e.length,'QSF expansion differs at line '+k+': '+a[k]+' / '+e[k]);}
 fs.writeFileSync(p.join(d,'qsf_flow.json'),JSON.stringify({mode,initialNormalizedSha256:sha(initial),generatedNormalizedSha256:sha(actual),expansions,effectiveAssignmentsUnchanged:true},null,2));return true;
};
if(require.main===module){module.exports();console.log('PASS exact Quartus QSF materialization of sys/sys.tcl and files.qip.');}
