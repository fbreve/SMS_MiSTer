// Read-only extraction of TimeQuest's completed full-path reports.
const fs=require('fs'),p=require('path'),assert=require('assert');
const d=process.argv[2]?p.resolve(process.argv[2]):__dirname;
const read=f=>{const b=fs.readFileSync(f);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');};
function paths(file){
 return read(file).split(/Path #\d+: Setup slack is /).slice(1).map(s=>{
  const prop=name=>{const row=s.split(/\r?\n/).find(l=>l.startsWith(';')&&l.split(';')[1].trim()===name);return row?row.split(';').slice(2,-1).map(x=>x.trim()):null;};
  const arrival=s.match(/;\s+Data\s*;[^\n]*\n([\s\S]*?);\s+Required Path\s*;/);
  const delay=type=>{const row=arrival&&arrival[1].split(/\r?\n/).find(l=>l.startsWith(';')&&l.split(';')[1].trim()===type);return row?+row.split(';')[4].trim():null;};
  return {slack:+s.split(/\s/)[0],from:prop('From Node')[0],to:prop('To Node')[0],launch:prop('Launch Clock')[0],latch:prop('Latch Clock')[0],relationship:+prop('Setup Relationship')[0],skew:+prop('Clock Skew')[0],dataDelay:+prop('Data Delay')[0],levels:+prop('Number of Logic Levels')[1],dataCell:delay('Cell'),dataRouting:delay('Routing Element')};
 });
}
const r={};for(const v of ['baseline','candidate']){
 r[v]={worst:paths(p.join(d,v+'_setup.rpt'))};
 const lum=p.join(d,v+'_poly_lum.rpt');if(fs.existsSync(lum))r[v].luminance=paths(lum);
 assert(r[v].worst.length>0);
}
fs.writeFileSync(p.join(d,'path_summary.json'),JSON.stringify(r,null,2)+'\n');
console.log(JSON.stringify(Object.fromEntries(Object.entries(r).map(([k,x])=>[k,x.worst[0]])),null,2));
