const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto'),d=__dirname,root=p.resolve(d,'../..'),adapter=require('../savestate_g06_g10_fix/controller_adapter');
const variant=process.argv[2]||'A',source=p.join(d,'candidate_'+variant+'.sv'),manifest=[];
function copyTop(src,dst){fs.mkdirSync(dst,{recursive:true});for(const f of fs.readdirSync(src)){const full=p.join(src,f);if(fs.statSync(full).isFile()&&/\.(sv|svh|vhd|do|json)$/.test(f))fs.copyFileSync(full,p.join(dst,f));}if(fs.existsSync(p.join(src,'rtl')))fs.cpSync(p.join(src,'rtl'),p.join(dst,'rtl'),{recursive:true});}
const specs=[
 ['sprites','savestate_g06_g10_fix/sprites',null],
 ['g05_original','savestate_g05_background_fix/integrated_original',['h0','h1']],
 ['g02','savestate_g05_background_fix/integrated_g02',['active']],
 ['g03','savestate_g05_background_fix/integrated_g03',['bus']],
 ['g04','savestate_g05_background_fix/integrated_g04',['pending']],
 ['phases','savestate_g05_background_fix/integrated_stalls',['phases','deterministic','lfsr','full_flush']],
 ['guest_q','savestate_g05_background_fix/integrated_q',['history']],
 ['dual','savestate_g05_background_fix/integrated_dual',['collision']]
];
for(const[key,relative,ids]of specs){const src=p.join(root,'tests',relative),dst=p.join(d,key);copyTop(src,dst);fs.writeFileSync(p.join(dst,'savestates_sim.sv'),adapter(source));
 if(key==='sprites'){
  fs.cpSync(p.join(root,'tests/savestate_g05_background_fix/integrated_g06/rtl'),p.join(dst,'rtl'),{recursive:true});
  let h=fs.readFileSync(p.join(dst,'header.svh'),'utf8');h=h.replace('savestates dut(',"wire[138:0]candidate_bg_live,candidate_bg_in;wire candidate_bg_valid;\nsavestates dut(.bg_out(candidate_bg_live),.bg2_out(139'd0),.bg_in(candidate_bg_in),.bg2_in(),.bg_valid(candidate_bg_valid),");fs.writeFileSync(p.join(dst,'header.svh'),h);
  let t=fs.readFileSync(p.join(dst,'vdp_tb.sv'),'utf8');t=t.replace('vdp1(', 'vdp1(.ss_bg_out(candidate_bg_live),.ss_bg_in(candidate_bg_in),.ss_bg_valid(candidate_bg_valid),');fs.writeFileSync(p.join(dst,'vdp_tb.sv'),t);
  let compile=fs.readFileSync(p.join(dst,'compile.do'),'utf8').replace('../../../rtl/vdp_background.vhd','rtl/vdp_background.vhd');fs.writeFileSync(p.join(dst,'compile.do'),compile);
  const cases=JSON.parse(fs.readFileSync(p.join(src,'cases.json')));for(const c of cases)for(const ref of [1,0]){const name=(ref?'reference_':'dut_')+c.id,cd=p.join(dst,name);fs.mkdirSync(cd,{recursive:true});fs.copyFileSync(p.join(src,name,'run.do'),p.join(cd,'run.do'));for(const file of fs.readdirSync(p.join(src,name)))if(/\.(hex|bin)$/.test(file))fs.copyFileSync(p.join(src,name,file),p.join(cd,file));manifest.push({family:key,name,reference:!!ref,referenceFrom:ref?null:p.join(dst,'reference_'+c.id,'reference.dat'),marker:ref?'PASS UNINTERRUPTED REFERENCE':'DONE VDP'});}
 }else{
  for(const id of ids){const name='dut_'+id,cd=p.join(dst,name),original=p.join(src,name);assert(fs.existsSync(original),original);fs.mkdirSync(cd,{recursive:true});fs.copyFileSync(p.join(original,'run.do'),p.join(cd,'run.do'));
   const fixtures=[];for(const file of fs.readdirSync(original))if(/\.(dat|hex|bin)$/.test(file)){fs.copyFileSync(p.join(original,file),p.join(cd,file));fixtures.push({file,sha256:crypto.createHash('sha256').update(fs.readFileSync(p.join(original,file))).digest('hex')});}
   const fixtureText=fs.readFileSync(p.join(dst,'vdp_tb.sv'),'utf8');
   const marker=fixtureText.includes('$display("PASS RICH V15 VDP')?'PASS RICH V15 VDP':'PASS V15 VDP';
   manifest.push({family:key,name,reference:false,fixtures,marker});
  }
 }
}
fs.writeFileSync(p.join(d,'regression_manifest.json'),JSON.stringify(manifest,null,2));console.log('Prepared'+manifest.length+' runtime rows; prior sources/results preserved.');
