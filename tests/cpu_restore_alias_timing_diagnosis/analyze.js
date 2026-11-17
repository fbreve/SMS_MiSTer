const fs=require('fs'),p=require('path'),crypto=require('crypto'),cp=require('child_process'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),sha=b=>crypto.createHash('sha256').update(b).digest('hex'),read=f=>{let b=fs.readFileSync(f);return b.toString(b[0]===255?'utf16le':'utf8')};
const builds={baseline:p.join(root,'tests/savestate_g08_fm/quartus_early'),candidate:p.join(root,'tests/cpu_restore_output_alias/quartus_candidate1')};
let prov=require('../cpu_restore_output_alias/provenance.json');for(let r of prov.tracked)assert.equal(sha(fs.readFileSync(p.join(root,r.file))),r.sha256);
let hashes={};let manifests={};for(let [k,b]of Object.entries(builds)){let m=require(k==='baseline'?'../savestate_g08_fm/build_early_inputs.json':'../cpu_restore_output_alias/build_candidate1_inputs.json');manifests[k]=m;for(let[f,h]of Object.entries(m.inputs))assert.equal(sha(fs.readFileSync(p.join(b,f))),h,k+f);hashes[k]={};for(let f of fs.readdirSync(p.join(b,'output_files')).filter(f=>/\.(rpt|summary)$/.test(f)))hashes[k][f]=sha(fs.readFileSync(p.join(b,'output_files',f)));}
const changed=Object.keys(manifests.baseline.inputs).filter(f=>manifests.baseline.inputs[f]!==manifests.candidate.inputs[f]);assert.deepEqual(changed,['rtl/savestates.sv']);
let out={head:cp.execFileSync('git',['rev-parse','HEAD']).toString().trim(),branch:cp.execFileSync('git',['branch','--show-current']).toString().trim(),trackedVerified:prov.tracked.length,inputsVerified:Object.fromEntries(Object.entries(manifests).map(([k,m])=>[k,Object.keys(m.inputs).length])),changed,hashes};
fs.writeFileSync(p.join(d,'provenance.json'),JSON.stringify(out,null,2));
function parse(f){let s=read(f);let summary=s.split('Path #1:')[0];let rows=summary.split(/\r?\n/).filter(l=>/^;\s*-?\d+\.\d+\s*;/.test(l)).map(l=>{let a=l.split(';').slice(1,-1).map(x=>x.trim());return {slack:+a[0],from:a[1],to:a[2],launch:a[3],capture:a[4],relationship:+a[5],skew:+a[6],delay:+a[7]}});
let blocks=s.split(/Path #\d+:/).slice(1); rows.forEach((r,i)=>{let b=blocks[i];r.details=b;});return rows;}
let paths={};for(let f of fs.readdirSync(d).filter(f=>/^(baseline|candidate)_.*\.txt$/.test(f)))paths[f.replace('.txt','')]=parse(p.join(d,f));
fs.writeFileSync(p.join(d,'paths.json'),JSON.stringify(paths,null,2));
let hier={};for(let[k,b]of Object.entries(builds)){let s=read(p.join(b,'output_files/SMS.fit.rpt'));let rows={};for(let l of s.split(/\r?\n/)){let a=l.split(';').slice(1,-1).map(x=>x.trim());if(a[14]?.startsWith('|sys_top')&&a.length>14){rows[a[14]]=a;}}hier[k]=rows;}
fs.writeFileSync(p.join(d,'hierarchy.json'),JSON.stringify(hier,null,2));
let reg={};for(let k of Object.keys(builds)){let arr=read(p.join(d,k+'_registers.tsv')).trim().split(/\r?\n/);let counts={};for(let n of arr){let stem=n.replace(/\[\d+\]/g,'[]').replace(/~DUPLICATE(?:\d+)?/g,'~DUPLICATE');counts[stem]=(counts[stem]||0)+1;}reg[k]={count:arr.length,counts};}
let deltas=Object.keys({...reg.baseline.counts,...reg.candidate.counts}).map(stem=>({stem,baseline:reg.baseline.counts[stem]||0,candidate:reg.candidate.counts[stem]||0})).filter(x=>x.baseline!==x.candidate);fs.writeFileSync(p.join(d,'register_changes.json'),JSON.stringify({reg,deltas},null,2));
console.log(JSON.stringify({provenance:{...out,hashes:undefined},paths:Object.fromEntries(Object.entries(paths).map(([k,v])=>[k,{count:v.length,failing:v.filter(r=>r.slack<0).length,worst:v[0]&&{...v[0],details:undefined}}])),HDMIhier:Object.fromEntries(Object.entries(hier).map(([k,v])=>[k,Object.values(v).filter(a=>/\|(?:shadowmask:HDMI_shadowmask|osd:hdmi_osd)\|$/.test(a[0]))]))},null,2));


