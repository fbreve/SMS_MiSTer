const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto');
const root=p.resolve(__dirname,'../..'),git=(...a)=>cp.execFileSync('git',a,{cwd:root}).toString().trim();
const dirs=['hcounter','gg_io','md6','eeprom','sc_ram','master_tap','paddle','lightgun_fix','systeme_pause_fix','mapper_detection_fix','evolution_selector_fix','evolution_pending_fix','cpu_nmi_fix','g01_cpu_restart_fix','g06_g10_fix','g05_background_fix','g08_release_fix','g12_sdram_fix'];
const commits=git('rev-list','--reverse','8443a0d..HEAD').split('\n');
const rows=[]; const num=s=>s?Number(s.replace(/,/g,'')):null;
for(let i=0;i<dirs.length;i++){
 const dir=p.join(root,'tests/savestate_'+dirs[i]);let builds=[];
 for(const sub of fs.readdirSync(dir,{withFileTypes:true}).filter(x=>x.isDirectory())){
  const out=p.join(dir,sub.name,'output_files'),f=p.join(out,'SMS.fit.summary');if(!fs.existsSync(f))continue;
  const s=fs.readFileSync(f,'utf8'),r=fs.readFileSync(p.join(out,'SMS.fit.rpt'),'utf8'),m=fs.existsSync(p.join(out,'SMS.map.summary'))?fs.readFileSync(p.join(out,'SMS.map.summary'),'utf8'):'';
  const n=(re,t=s)=>num(t.match(re)?.[1]);
  const b={tree:sub.name,needed:n(/Logic utilization.*?: ([\d,]+)/),placed:n(/ALMs used in final placement[^;\r\n]*;\s*([\d,]+)/,r),fitregs:n(/Total registers : ([\d,]+)/),synthregs:n(/Total registers : ([\d,]+)/,m),M10K:n(/Total RAM Blocks : ([\d,]+)/),memoryBits:n(/Total block memory bits : ([\d,]+)/),DSP:n(/Total DSP Blocks : ([\d,]+)/),tool:s.match(/Quartus Prime Version : (.*)/)?.[1].trim(),device:s.match(/Device : (.*)/)?.[1].trim(),evidence:p.relative(root,f).replaceAll('\\','/')};
  const sta=p.join(out,'SMS.sta.summary');if(fs.existsSync(sta)){const t=fs.readFileSync(sta,'utf8');for(const type of ['Setup','Hold']){const vals=[...t.matchAll(new RegExp('Type\\s*:\\s*'+type+'[^\\r\\n]*\\r?\\nSlack\\s*:\\s*(-?\\d+\\.\\d+)','g'))].map(x=>+x[1]);b[type.toLowerCase()]=vals.length?Math.min(...vals):null;}b.violations=[...t.matchAll(/TNS\s*:\s*(-?\d+\.\d+)/g)].filter(x=>+x[1]<0).length;}
  const q=p.join(dir,sub.name,'SMS.qsf');if(fs.existsSync(q)){const t=fs.readFileSync(q,'utf8');b.qsfSHA=crypto.createHash('sha256').update(t.replace(/\r\n/g,'\n')).digest('hex');b.seed=t.match(/-name SEED (\d+)/)?.[1]||'default 1';}builds.push(b);
 }
 rows.push({checkpoint:dirs[i],commit:commits[i],subject:git('show','-s','--format=%s',commits[i]),builds});
}
const hashes={};for(const f of git('ls-files').split('\n')){const file=p.join(root,f);if(fs.statSync(file).isFile())hashes[f]=crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');}
if(!fs.existsSync(p.join(__dirname,'tracked_baseline.json')))fs.writeFileSync(p.join(__dirname,'tracked_baseline.json'),JSON.stringify(hashes,null,2));
fs.writeFileSync(p.join(__dirname,'measurements.json'),JSON.stringify(rows,null,2));
for(const r of rows)console.log(r.checkpoint,r.commit.slice(0,7),JSON.stringify(r.builds.map(({tree,needed,placed,fitregs,synthregs,setup,hold,qsfSHA})=>({tree,needed,placed,fitregs,synthregs,setup,hold,qsfSHA}))));
