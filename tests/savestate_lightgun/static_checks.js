const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto'),d=__dirname,r=path.resolve(d,'../..');
const read=p=>fs.readFileSync(path.join(r,p),'utf8').replace(/\r\n/g,'\n'),compact=s=>s.replace(/\s/g,'');
const git=(...a)=>cp.execFileSync('git',a,{cwd:r,encoding:'utf8'}).trimEnd();
if(git('diff','--name-only')||git('diff','--cached','--name-only'))throw Error('Tracked changes are forbidden');
if(git('branch','--show-current')!=='investigate/savestate-lightgun')throw Error('Wrong branch');
const prior=JSON.parse(read('tests/savestate_paddle/results.json')),sources={};
for(const f of Object.keys(prior.sources)){
 const now=fs.readFileSync(path.join(r,f)),old=fs.readFileSync(path.join(r,'tests/savestate_paddle/candidate',f));
 if(now.toString('utf8').replace(/\r\n/g,'\n')!==old.toString('utf8').replace(/\r\n/g,'\n'))throw Error('Committed F10 source differs '+f);
 sources[f]=crypto.createHash('sha256').update(now).digest('hex');
}
const source=read('rtl/lightgun.sv').replace(/assign TARGET\s*=\s*~offscreen\s*&\s*draw;/,'');
let fixture=read('tests/savestate_lightgun/gun_fixture.sv').replace('module gun_fixture','module lightgun').replace('input CLK, input hold,','input        CLK,').replace('output reg   SENSOR','output       SENSOR').replace('output reg   TRIGGER','output       TRIGGER').replace('begin : beam','begin').replace('\tif (!hold) begin\n','').replace(/\nend\nend\n\nassign TARGET[^;]+;/,'\nend\n');
if(compact(fixture)!==compact(source))throw Error('Gun adaptation changed production expressions');
for(const n of ['T80','T80s'])if(compact(read('tests/savestate_lightgun/'+n+'_sim.vhd').replace(/:\s*entity work\./g,': work.'))!==compact(read('rtl/T80/'+n+'.vhd')))throw Error('CPU simulation copy changed logic');
const sv=read('tests/savestate_lightgun/boundary_tb.sv'),cpu=read('tests/savestate_lightgun/cpu_tb.sv');
if(/(?:live_gun|reference_gun)\.[\w.]+\s*(?:<=|=(?!=))/.test(sv+'\n'+cpu))throw Error('Lightgun state seeded/forced');
if(!sv.includes('th1<=PORT?1\'b1:!sensor')||!sv.includes('.J1_th(th1)'))throw Error('Missing production TH pipeline');
if(!read('SMS.sv').includes('.ce_pix(ce_pix)')||!read('SMS.sv').includes('.CE_PIX(ss_freeze ? 1\'b0 : ce_pix)'))throw Error('Freeze architecture changed');
fs.writeFileSync(path.join(d,'sources.json'),JSON.stringify({head:git('rev-parse','HEAD'),branch:git('branch','--show-current'),sources},null,2)+'\n');
console.log('PASS F11 source provenance: '+Object.keys(sources).length+' committed-F10 source/settings files unchanged; zero tracked diff; gun compiler/reference-hold adaptations reversible; T80 copies change entity syntax only; no gun register forcing; registered production TH path retained.');
