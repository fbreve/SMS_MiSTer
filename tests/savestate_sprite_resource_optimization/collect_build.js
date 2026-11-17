const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');
function read(file){const b=fs.readFileSync(file);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');}
function measure(base){const out=p.join(base,'output_files'),fit=read(p.join(out,'SMS.fit.rpt')),summary=read(p.join(out,'SMS.fit.summary')),map=read(p.join(out,'SMS.map.rpt')),ms=read(p.join(out,'SMS.map.summary')),sta=read(p.join(out,'SMS.sta.summary')),num=(re,s=fit)=>{const m=s.match(re);assert(m,'missing metric '+re);return +m[1].replace(/,/g,'');};
 const b={needed:num(/Logic utilization.*?: ([\d,]+)/,summary),placed:num(/ALMs used in final placement[^;\r\n]*;\s*([\d,]+)/),registers:num(/Total registers : ([\d,]+)/,summary),synthesisRegisters:num(/Total registers : ([\d,]+)/,ms),M10K:num(/Total RAM Blocks : ([\d,]+)/,summary),memoryBits:num(/Total block memory bits : ([\d,]+)/,summary),DSP:num(/Total DSP Blocks : ([\d,]+)/,summary),recoverable:num(/Estimate of ALMs recoverable[^;\r\n]*;\s*([\d,]+)/),unavailable:num(/Estimate of ALMs unavailable[^;\r\n]*;\s*([\d,]+)/),logicALUT:num(/Combinational ALUT usage for logic\s*;\s*([\d,]+)/,map),summary,warningTypes:[...new Set([...fit.matchAll(/(?:Critical )?Warning \((\d+)\)/g),...map.matchAll(/(?:Critical )?Warning \((\d+)\)/g)].map(x=>x[1]))].sort(),hierarchy:fit.split(/\r?\n/).filter(x=>/^;\s*\|/.test(x)&&/;\s*(savestates|vdp_sprites|vdp_background)\s*;/.test(x)),fanout:[]};
 for(const type of ['Setup','Hold']){const values=[...sta.matchAll(new RegExp('Type\\s*:\\s*'+type+'[^\\r\\n]*\\r?\\nSlack\\s*:\\s*(-?\\d+\\.\\d+)','g'))].map(x=>+x[1]);assert(values.length);b[type.toLowerCase()]=Math.min(...values);}
 b.violations=[...sta.matchAll(/TNS\s*:\s*(-?\d+\.\d+)/g)].filter(x=>+x[1]<0).length;
 const start=fit.indexOf('; Non-Global High Fan-Out Signals'),end=fit.indexOf('\n\n',start);b.fanout=fit.slice(start,end<0?start+8000:end).split(/\r?\n/).filter(x=>/;\s*\d+\s*;/.test(x));
 assert.equal(b.placed-b.recoverable+b.unavailable,b.needed,'global packing identity');return b;
}
const baselinePath=p.join(root,'tests/savestate_g12_sdram_fix/quartus_candidate'),candidatePath=p.join(d,'quartus_A');
const baseline=measure(baselinePath),candidate=measure(candidatePath),delta={};
for(const [base,metrics]of [[baselinePath,baseline],[candidatePath,candidate]]){
 const files=fs.readdirSync(p.join(base,'output_files')).filter(f=>/\.(rpt|summary)$/.test(f)).map(f=>p.join(base,'output_files',f));files.push(p.join(base,'compile.log'));
 metrics.warningTypes=[...new Set(files.flatMap(file=>[...read(file).matchAll(/(?:Critical )?Warning \((\d+)\)/g)].map(x=>x[1])))].sort();
 const fit=read(p.join(base,'output_files/SMS.fit.rpt'));
 metrics.fittedALUTLines=fit.split(/\r?\n/).filter(x=>/Combinational ALUT|ALUTs used for/.test(x)).slice(0,15);
 metrics.logicRegisterLines=fit.split(/\r?\n/).filter(x=>/Primary logic registers|Secondary logic registers|Design implementation registers|Routing optimization registers/.test(x)).slice(0,8);
}
for(const key of ['needed','placed','registers','synthesisRegisters','M10K','memoryBits','DSP','recoverable','unavailable','logicALUT','setup','hold','violations'])delta[key]=candidate[key]-baseline[key];
const manifest=JSON.parse(read(p.join(d,'build_inputs.json')));for(const[f,h]of Object.entries(manifest.inputs)){const bytes=fs.readFileSync(p.join(d,'quartus_A',f));assert.equal(crypto.createHash('sha256').update(bytes).digest('hex'),h,'build source '+f);}
assert.equal(crypto.createHash('sha256').update(fs.readFileSync(p.join(d,'quartus_A/build_id.v'))).digest('hex'),manifest.buildIdSHA,'matched generated date');
const result={baseline,candidate,delta,newWarningTypes:candidate.warningTypes.filter(x=>!baseline.warningTypes.includes(x)),recovered:-delta.placed,recoveredPercentage:100*(-delta.placed)/5458,sourceHashesVerified:true};fs.writeFileSync(p.join(d,'build_results.json'),JSON.stringify(result,null,2));console.log(JSON.stringify({delta,recovered:result.recovered,recoveredPercentage:result.recoveredPercentage,newWarningTypes:result.newWarningTypes},null,2));
