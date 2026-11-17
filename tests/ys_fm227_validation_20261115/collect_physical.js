const fs=require('fs'),path=require('path'),crypto=require('crypto');
const out=path.join(__dirname,'physical_r2'),hash=b=>crypto.createHash('sha256').update(b).digest('hex');
function read(p){return fs.readFileSync(p,'utf8');}
function field(t,name){const line=t.split(/\r?\n/).find(l=>l.split(';')[1]?.trim()===name);if(!line)throw Error('Missing '+name);const s=line.split(';')[2].trim();return {value:Number(s.split('/')[0].replaceAll(',','')),text:s};}
const results=[];
for(let seed=1;seed<=3;seed++)for(const label of ['candidate']){
 const dir=path.join(out,`seed${seed}`,label,'output_files');if(!fs.existsSync(path.join(dir,'SMS.sta.summary')))continue;
 const fit=read(path.join(dir,'SMS.fit.rpt')),map=read(path.join(dir,'SMS.map.rpt')),sta=read(path.join(dir,'SMS.sta.rpt')),summary=read(path.join(dir,'SMS.sta.summary'));
 const metrics={};for(const [key,name] of Object.entries({neededALMs:'ALMs needed [=A-B+C]',placedALMs:'[A] ALMs used in final placement [=a+b+c+d]',fittedRegisters:'Total registers',logicALUTs:'Combinational ALUT usage for logic',routingALUTs:'Combinational ALUT usage for route-throughs',M10K:'M10K blocks',memoryBits:'Total block memory bits',DSP:'Total DSP Blocks'}))metrics[key]=field(fit,name).value;
 metrics.mappedRegisters=field(map,'Total registers').value;
 const timing=[];for(const m of summary.matchAll(/Type\s*:\s*([^\r\n]+)\s+Slack\s*:\s*([-\d.]+)\s+TNS\s*:\s*([-\d.]+)/g))timing.push({type:m[1],slack:+m[2],tns:+m[3]});
 for(const type of ['Setup','Hold']){const rows=timing.filter(r=>r.type.startsWith(type+' '));if(!rows.length)throw Error('No '+type);metrics['worst'+type]=Math.min(...rows.map(r=>r.slack));metrics[type.toLowerCase()+'TNS']=rows.reduce((s,r)=>s+r.tns,0);}
 const unconstrained=sta.split(/\r?\n/).filter(l=>/^; Unconstrained (Clocks|Input Ports |Input Port Paths|Output Ports |Output Port Paths)/.test(l)&&/;\s*\d+\s*;/.test(l));
 const warnings=[];for(const f of fs.readdirSync(dir).filter(f=>f.endsWith('.rpt'))){for(const l of read(path.join(dir,f)).split(/\r?\n/))if(l.trimStart().startsWith('Critical Warning')||l.includes('; Critical Warning ;'))warnings.push({report:f,text:l.trim()});}
 const reportHashes={};for(const f of fs.readdirSync(dir).filter(f=>/\.(rpt|summary)$/.test(f)))reportHashes[f]=hash(fs.readFileSync(path.join(dir,f)));
 const hierarchy=[];for(const line of fit.split(/\r?\n/)){const c=line.split(';').map(x=>x.trim());if(c.length===19&&c[15].startsWith('|sys_top|emu:emu'))hierarchy.push({path:c[15],entity:c[16],neededALMs:c[2],placedALMs:c[3],logicALUTs:c[7],registers:c[8],memoryBits:c[10],M10K:c[11],DSP:c[12]});}
 const unconstrainedPorts=[];let portSection=false;for(const line of sta.split(/\r?\n/)){if(/^; Unconstrained (Input|Output) Ports\s*;\s*$/.test(line)){portSection=true;continue;}if(portSection&&line.startsWith('; ')&&!line.includes('; Comment ')){const cols=line.split(';').map(x=>x.trim());if(cols[1]&&cols[2]&&cols[1]!=='Output Port'&&cols[1]!=='Input Port')unconstrainedPorts.push({port:cols[1],reason:cols[2]});}if(portSection&&line==='')portSection=false;}
 results.push({seed,label,metrics,timing,unconstrained,unconstrainedPorts,criticalWarnings:warnings,hierarchy,fitSuccessful:/Fitter Status\s*:\s*Successful/.test(read(path.join(dir,'SMS.fit.summary'))),timingSuccessful:/Timing Analyzer was successful/.test(sta),reportHashes});
}
fs.writeFileSync(path.join(out,'measurements.json'),JSON.stringify(results,null,2));
if(results.length){const keys=Object.keys(results[0].metrics);fs.writeFileSync(path.join(out,'measurements.csv'),['seed,revision,'+keys.join(','),...results.map(r=>[r.seed,r.label,...keys.map(k=>r.metrics[k])].join(','))].join('\n')+'\n');}
console.log(JSON.stringify(results.map(({seed,label,metrics,fitSuccessful,timingSuccessful,unconstrained})=>({seed,label,metrics,fitSuccessful,timingSuccessful,unconstrained})),null,2));
