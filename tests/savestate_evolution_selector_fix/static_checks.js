const fs=require('fs'),path=require('path'),cp=require('child_process'),d=__dirname,r=path.resolve(d,'../..');
const git=(...a)=>cp.execFileSync('git',a,{cwd:r,encoding:'utf8',stdio:['ignore','pipe','pipe']});
const norm=s=>s.replace(/\s/g,'');const assert=(b,m)=>{if(!b)throw Error(m);};
const expected=['SMS.sv','rtl/evolution_mapper.vhd','rtl/savestates.sv','rtl/system.vhd'].sort();
assert(JSON.stringify(git('diff','--name-only').trim().split(/\r?\n/).sort())===JSON.stringify(expected),'production scope changed');
assert(!git('diff','--cached','--name-only').trim(),'index not empty');
assert(git('branch','--show-current').trim()==='fix/savestate-evolution-selector','wrong branch');
const ss=fs.readFileSync(path.join(r,'rtl/savestates.sv'),'utf8'),before=git('show','HEAD:rtl/savestates.sv');
const writes=s=>[...s.matchAll(/ddram_write\(([\s\S]*?)\);/g)].map(m=>norm(m[1]));
const now=writes(ss).filter(s=>!s.startsWith("base_addr+29'h02c,")&&!s.startsWith("base_addr+29'h02d,"));
assert(JSON.stringify(now)===JSON.stringify(writes(before)),'old saved word expression/order changed');
const evo=fs.readFileSync(path.join(r,'rtl/evolution_mapper.vhd'),'utf8'),oldevo=git('show','HEAD:rtl/evolution_mapper.vhd');
for(const n of ['switch_pending','switch_armed','record_read_pending_r','menu_launch_armed_r','old_m1_n','reg3ffe_pending','game_launch_r']){
 const assignments=s=>[...s.matchAll(new RegExp('\\b'+n+'\\s*<=\\s*[^;]+;','g'))].map(x=>norm(x[0]));
 assert(JSON.stringify(assignments(evo))===JSON.stringify(assignments(oldevo)),'F15/transient assignments changed '+n);
}
for(const n of ['rtl/mapper_detect.vhd','rtl/mapper_ctrl.vhd','rtl/evolution_rom_address.vhd','rtl/memory_decode.vhd'])assert(norm(fs.readFileSync(path.join(r,n),'utf8'))===norm(git('show','HEAD:'+n)),'unrelated production changed '+n);
assert(ss.includes("24'h48430a")&&ss.includes("64'h0000003945563130")&&ss.includes('dout_latch[63:57] == 0'),'v10 metadata incomplete');
assert(evo.includes('candidate_bank62_r         <= ss_in(7 downto 0)'),'candidate62 reconstruction changed');
assert(fs.readFileSync(path.join(r,'SMS.sv'),'utf8').includes('wire [159:0] ss_evolution_out, ss_evolution_in;'),'top history transport missing');
assert(fs.readFileSync(path.join(r,'rtl/system.vhd'),'utf8').includes('evolution_ss_in  : in  STD_LOGIC_VECTOR(159 downto 0)'),'system transport missing');
assert(fs.readFileSync(path.join(r,'rtl/system.vhd'),'utf8').includes('evolution_ss_in => evolution_ss_in(95 downto 0)'),'detector low96 binding missing');
for(const line of before.split(/\r?\n/).filter(s=>/localparam.*(NEW_SS_WORDS|OLD_SS_WORDS|SLOT_STRIDE)/.test(s)))assert(ss.includes(line),'slot format sizing changed');
console.log('PASS static scope: four RTL files, old payload writes identical, v10 transport/validation present, F13/F15 assignments unchanged, index empty.');
