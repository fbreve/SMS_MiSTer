const fs=require('fs'),p=require('path'),crypto=require('crypto'),d=__dirname,root=p.resolve(d,'../..');
const hash=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const rows={};for(const [seed,folder]of [[1,'register_memory_auto'],[2,'register_memory_auto_seed2']])for(const v of ['baseline','candidate']){
 const dir=p.join(root,'tests',folder,v),fit=fs.readFileSync(p.join(dir,'output_files/SMS.fit.rpt'),'utf8'),map=fs.readFileSync(p.join(dir,'output_files/SMS.map.rpt'),'utf8'),lines=fit.split(/\r?\n/);
 const retimed=lines.filter(l=>/^;/.test(l)&&/Retimed Register/.test(l));
 const selected=lines.filter(l=>/^;/.test(l)&&/o_poly_lum|o_[hv]_lum_pix/.test(l)&&/Physical Synthesis/.test(l));
 const pointLines=fs.readFileSync(p.join(d,'seed'+seed+'_'+v+'_points.tsv'),'utf8').split(/\r?\n/).slice(1).map(l=>l.split('\t'));
 rows['seed'+seed+'_'+v]={sdcSHA256:hash(p.join(dir,'sys/sys_top.sdc')),qsfSHA256:hash(p.join(dir,'SMS.qsf')),registerRetimingEnabled:/-name PHYSICAL_SYNTHESIS_REGISTER_RETIMING ON/.test(fs.readFileSync(p.join(dir,'SMS.qsf'),'utf8')),retimedRows:retimed.length,scalerRetimedRows:retimed.filter(l=>l.includes('ascal:ascal|')).length,luminanceRetimedRows:retimed.filter(l=>/o_poly_lum|o_[hv]_lum_pix/.test(l)).length,selectedTransformationRows:selected,optimizationMessages:lines.filter(l=>/Info \(12800|Info \(176220|Info \(14951/.test(l)),criticalWarnings:map.split(/\r?\n/).filter(l=>/Critical Warning \(/.test(l)),fitterWarnings:lines.filter(l=>/^Warning \(/.test(l)),worstClockAdjustments:pointLines.filter(r=>r[0]==='1'&&r[1]==='required'&&['ccpp','unc'].includes(r[2])).map(r=>({type:r[2],delay:+r[3]}))};
}
fs.writeFileSync(p.join(d,'implementation_evidence.json'),JSON.stringify(rows,null,2)+'\n');
console.log(Object.fromEntries(Object.entries(rows).map(([k,v])=>[k,{retimed:v.retimedRows,scalerRetimed:v.scalerRetimedRows,luminanceRetimed:v.luminanceRetimedRows,clockAdjustments:v.worstClockAdjustments,retimingMessages:v.optimizationMessages.filter(l=>l.includes('register retiming complete')),sdcSHA256:v.sdcSHA256}])));
