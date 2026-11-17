const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),d=__dirname;
const old=JSON.parse(fs.readFileSync(p.join(d,'pre_query_results.json'))),sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const read=f=>{const b=fs.readFileSync(f);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');};
const workflow=read(p.join(d,'workflow.log')),result={originalCompilationReportsUnchanged:true,reportsChecked:0,fullPathReports:{}};
for(const[key,build]of Object.entries(old.builds)){
 for(const stage of ['map','fit','asm','sta'])assert(workflow.includes(`${key} ${stage} ended exit=0`));
 for(const[f,h]of Object.entries(build.reportHashes)){assert.equal(sha(p.join(d,key,'output_files',f)),h,key+' report '+f);result.reportsChecked++;}
 const log=read(p.join(d,key,'paths.log'));assert(log.includes('Evaluation of Tcl script Z:/paths.tcl was successful')&&!/^Error \(/m.test(log),key+' query failed');
 result.fullPathReports[key]=Object.fromEntries(['physical_setup.rpt','physical_hold.rpt','physical_ignored_sdc.rpt','paths.log'].map(f=>[f,sha(p.join(d,key,f))]));
}
fs.writeFileSync(p.join(d,'report_verification.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
