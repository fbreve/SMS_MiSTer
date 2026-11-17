const fs=require('fs'),p=require('path'),d=__dirname,pa=require('./paths.json'),hi=require('./hierarchy.json'),re=require('./register_changes.json');
const read=f=>{let b=fs.readFileSync(f);return b.toString(b[0]===255?'utf16le':'utf8')},out={};
for(let k of ['baseline','candidate']){
let f=read(p.join(d,k+'_fanout_valid.tsv')).trim().split(/\r?\n/).map(l=>{let [n,v]=l.split('\t');return {n,v:+v}});let snap=f.filter(x=>/z80_snap\[/.test(x.n)),dir=f.filter(x=>/z80_dir\[/.test(x.n));
let summary=a=>({bits:a.length,total:a.reduce((s,x)=>s+x.v,0),max:Math.max(...a.map(x=>x.v)),top:a.sort((a,b)=>b.v-a.v).slice(0,5)});
out[k]={hier:Object.values(hi[k]).filter(a=>/\|(?:osd:hdmi_osd|shadowmask:HDMI_shadowmask|ascal:ascal|T80s:z80_inst)$/.test(a[14])),fanout:{snap:summary(snap),dir:summary(dir)},coreTop:pa[k+'_core_setup'].slice(0,10).map(x=>({...x,details:undefined})),regs:{}};
for(let filter of ['osd:hdmi_osd|','shadowmask:HDMI_shadowmask|','emu:emu|system:system|T80s:z80_inst|','ascal:ascal|']){let rows=Object.entries(re.reg[k].counts).filter(([s,v])=>s.startsWith(filter));out[k].regs[filter]={nodes:rows.reduce((s,[n,v])=>s+v,0),duplicates:rows.filter(([n])=>/DUPLICATE/.test(n)).reduce((s,[n,v])=>s+v,0)};}
}
out.matched={};for(let kind of ['hdmi_setup','core_setup','cpu_all_setup','hcnt','width']){let b=pa['baseline_'+kind],c=pa['candidate_'+kind];let matches=b.map(x=>{let y=c.find(y=>x.from===y.from&&x.to===y.to);return y&&{from:x.from,to:x.to,baseline:x.slack,candidate:y.slack,delta:+(y.slack-x.slack).toFixed(3)}}).filter(Boolean);out.matched[kind]={exactMatches:matches.length,rows:matches};}
fs.writeFileSync(p.join(d,'comparison.json'),JSON.stringify(out,null,2));
console.log(JSON.stringify({baseline:{hier:out.baseline.hier,fanout:out.baseline.fanout,regs:out.baseline.regs},candidate:{hier:out.candidate.hier,fanout:out.candidate.fanout,regs:out.candidate.regs},matches:Object.fromEntries(Object.entries(out.matched).map(([k,v])=>[k,{count:v.exactMatches,first:v.rows[0]}]))},null,2));
