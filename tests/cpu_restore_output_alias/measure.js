const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');
const name=process.argv[2]||'early',dir=p.join(d,'quartus_'+name),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const read=f=>{const b=fs.readFileSync(f);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');};
function measure(folder){
 const fit=read(p.join(folder,'output_files/SMS.fit.summary')),rpt=read(p.join(folder,'output_files/SMS.fit.rpt')),map=read(p.join(folder,'output_files/SMS.map.rpt')),sta=read(p.join(folder,'output_files/SMS.sta.summary')),ms=read(p.join(folder,'output_files/SMS.map.summary'));
 const n=(re,s=fit)=>{const m=s.match(re);assert(m,'missing metric '+re);return +m[1].replaceAll(',','');};
 const out={needed:n(/Logic utilization[^:]*:\s*([\d,]+)/),placed:n(/\[A\] ALMs used in final placement[^;]*;\s*([\d,]+)/,rpt),registers:n(/Total registers\s*:\s*([\d,]+)/),synthesisRegisters:n(/Total registers\s*:\s*([\d,]+)/,ms),M10K:n(/Total RAM Blocks\s*:\s*([\d,]+)/),memoryBits:n(/Total block memory bits\s*:\s*([\d,]+)/),DSP:n(/Total DSP Blocks\s*:\s*([\d,]+)/),recoverable:n(/\[B\] Estimate of ALMs recoverable[^;]*;\s*([\d,]+)/,rpt),unavailable:n(/\[C\] Estimate of ALMs unavailable[^;]*;\s*([\d,]+)/,rpt),logicALUT:n(/Combinational ALUT usage for logic\s*;\s*([\d,]+)/,rpt),routingALUT:n(/Combinational ALUT usage for route-throughs\s*;\s*([\d,]+)/,rpt)};
 out.timing=[...sta.matchAll(/Type\s*:\s*([^\r\n]+)\r?\nSlack\s*:\s*(-?[\d.]+)\r?\nTNS\s*:\s*(-?[\d.]+)/g)].map(m=>({type:m[1],slack:+m[2],tns:+m[3]}));assert(out.timing.length);
 out.setup=Math.min(...out.timing.filter(x=>x.type.startsWith('Setup')).map(x=>x.slack));out.hold=Math.min(...out.timing.filter(x=>x.type.startsWith('Hold')).map(x=>x.slack));out.violations=out.timing.filter(x=>x.slack<0||x.tns<0).length;
 const files=fs.readdirSync(p.join(folder,'output_files')).filter(f=>/\.(rpt|summary)$/.test(f)).map(f=>p.join(folder,'output_files',f));
 for(const f of ['compile.log','map.log','fit.log','asm.log','sta.log'])if(fs.existsSync(p.join(folder,f)))files.push(p.join(folder,f));
 const all=files.map(read).join('\n');out.warningLines=[...new Set(all.split(/\r?\n/).map(l=>l.trim()).filter(l=>/^(Critical )?Warning(?: \(\d+\))?:/.test(l)))];
 out.warningTypes=[...new Set(out.warningLines.map(l=>(l.match(/Warning \((\d+)\)/)||[])[1]||'unnumbered'))].sort();out.criticalWarnings=out.warningLines.filter(l=>l.startsWith('Critical')).length;
 out.unconstrainedInfo=[...new Set([...all.matchAll(/Design is not fully constrained for (setup|hold) requirements/g)].map(m=>m[1]))];
 const at=rpt.indexOf('; Non-Global High Fan-Out Signals');out.fanout=rpt.slice(at,at+12000).split(/\r?\n/).filter(l=>/;\s*\d+\s*;/.test(l));
 out.ramLines=map.split(/\r?\n/).filter(l=>/M10K block/.test(l)&&/fm_snapshot|VoiceMemory|EnvelopeMemory|vdp_cram/i.test(l));out.buildDate=read(p.join(folder,'build_id.v')).trim();
 assert.equal(out.placed-out.recoverable+out.unavailable,out.needed);out.hashes={fit:sha(fit),sta:sha(sta),map:sha(map)};return out;
}

module.exports=measure;
