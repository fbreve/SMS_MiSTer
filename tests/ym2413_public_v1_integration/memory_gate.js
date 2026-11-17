const fs=require('fs'),p=require('path'),assert=require('assert');
const stage=process.argv[2],dir=p.join(__dirname,'quartus_seed1/v1/output_files'),s=fs.readFileSync(p.join(dir,'SMS.'+stage+'.rpt'),'utf8');
if(stage==='map'){
 const logic=s.split(/\r?\n/).filter(x=>/Info \(276006\)/.test(x)&&/RegisterMemory|FeedbackMemory/.test(x));assert.equal(logic.length,2);assert(logic.every(x=>x.includes('"logic" being set as ramstyle')));
 const ml=s.split(/\r?\n/).filter(x=>x.startsWith(';')&&/OutputMemory:Mmem/.test(x)&&/;\s*MLAB\s*;/.test(x));assert.equal(ml.length,2,'OutputMemory MLAB inference changed');
}else{
 const n=re=>{const m=s.match(re);assert(m);return +m[1].replaceAll(',','');};
 assert.equal(n(/Total MLAB memory bits\s*;\s*([\d,]+)/),380);
 assert.equal(n(/; M10K blocks\s*;\s*([\d,]+)/),489);
 const text=s.slice(s.indexOf('; Fitter RAM Summary ')).split(/\r?\n\s*\r?\n/)[0];
 const rows=text.split(/\r?\n/).filter(x=>x.startsWith(';')).map(x=>x.split(';').slice(1,-1).map(x=>x.trim())),h=rows.find(x=>x.includes('MLAB cells'));
 const cells=rows.filter(x=>/OutputMemory:Mmem/.test(x[0])).reduce((a,x)=>a+ +x[h.indexOf('MLAB cells')],0);assert.equal(cells,20);
 assert(!rows.some(x=>/RegisterMemory|FeedbackMemory/.test(x[0])));
}
console.log('PASS '+stage+' memory inference gate');
