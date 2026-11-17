const a=require('./paths.json'),h=require('./hierarchy.json'),r=require('./register_changes.json');
for(let k of ['baseline','candidate']){
console.log(k,'hier',Object.values(h[k]).filter(x=>/hdmi_osd|HDMI_shadowmask/.test(x[0])&&x[0].split('|').length<5));
let x=a[k+'_hcnt'].find(x=>x.to==='osd:hdmi_osd|h_cnt[2]~DUPLICATE');
for(let section of ['Data Arrival Time','Data Required Time','Number of Logic Levels'])console.log(section,x.details.split('\n').find(l=>l.includes(section))?.trim());
let data=x.details.split('; data path')[1]?.split('; Data Required Path')[0];
console.log(x.details.split(/\r?\n/).filter(l=>/M10K_X|LCCOMB_X|FF_X/.test(l)&&(/CELL|RR|FF/.test(l))).slice(0,12).map(l=>l.split(';').map(x=>x.trim()).filter(Boolean)));
let seg=x.details.split('Data Arrival Path')[1].split('Data Required Path')[0];let rows=seg.split(/\r?\n/).map(l=>l.split(';').slice(1,-1).map(x=>x.trim()));let n=rows.findIndex(x=>x[6]==='data path');console.log('DATA',rows.slice(n+1).filter(x=>x.length===7));
console.log('CPUTOP',a[k+'_core_setup'].slice(0,10).map(({slack,from,to})=>({slack,from,to})));
}
console.log('FFdelta',r.deltas.filter(x=>/hdmi_osd|HDMI_shadowmask|T80/.test(x.stem)));
