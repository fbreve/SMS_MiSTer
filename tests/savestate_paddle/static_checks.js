const fs=require('fs'),path=require('path'),cp=require('child_process'),crypto=require('crypto'),d=__dirname,r=path.resolve(d,'../..');
const read=p=>fs.readFileSync(path.join(r,p),'utf8').replace(/\r\n/g,'\n');
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const assert=(ok,m)=>{if(!ok)throw Error(m);};
const old=read('tests/savestate_paddle/baseline/SMS.sv'),now=read('SMS.sv');
let stripped=now.replace('wire [31:0] ss_paddle_out, ss_paddle_in;\nwire ss_paddle_set, ss_paddle_valid;\n','').replace(/\t\.paddle_(?:out|in|set|valid)\s+\(ss_paddle_(?:out|in|set|valid)\),\n/g,'');
const section=s=>s.slice(s.indexOf('// Paddle support'),s.indexOf('reg dbg_menu'));
stripped=stripped.replace(section(now),section(old));
assert(stripped===old,'Change outside F10 paddle region and four-port plumbing');
const core=s=>s.slice(s.indexOf('\tif (jp_region) begin',s.indexOf('// Paddle support')),s.indexOf('assign joya_th_rise')).trim();
assert(core(now).replace(/\nend$/,'')===core(old),'Ordinary paddle protocol changed');
assert(now.includes('cnt_en16khz <= cnt_en16khz + 1\'d1;\n\tif (cnt_en16khz == 3355) cnt_en16khz <= 0;'),'Ordinary divider changed');
const packed=now.match(/assign ss_paddle_out = ([\s\S]*?);/)[1].replace(/\s/g,'');
assert(packed==='{cnt_en16khz,joyb_th_out_q,joya_th_out_q,paddle_1_tr,paddle_0_tr,paddle_1_nib_q,paddle_1_nib,paddle_0_nib_q,paddle_0_nib}','Production state packing differs from replay probes');
assert(now.includes('wire [31:0] ss_paddle_out, ss_paddle_in;'),'State bus width');
assert(now.includes('ss_paddle_in[19:0]')&&now.includes('ss_paddle_in[31:20]'),'Complete restore slices');
const tb=read('tests/savestate_paddle/integration_tb.sv').toLowerCase();
for(const port of [1,2])for(const pin of ['up','down','left','right','tl','tr']){
 const idx=now.match(new RegExp('\\.j'+port+'_'+pin+'\\(joy'+(port===1?'a':'b')+'_pins\\[(\\d)\\]\\)'))[1];
 for(const ref of [false,true])assert(tb.includes('.j'+port+'_'+pin+'('+(ref?'ref':'')+'route'+(port===1?'a':'b')+'['+idx+'])'),'Guest pin order differs from production '+port+' '+pin);
}
const former=JSON.parse(read('tests/savestate_master_tap/results.json')),sources={};
for(const[f,v]of Object.entries(former.sources)){
 const before=sha(path.join(d,'baseline',f));assert(before===v.candidate,'Committed F09 baseline mismatch '+f);
 const current=sha(path.join(r,f));sources[f]={baseline:before,candidate:current};
 if(!['SMS.sv','rtl/savestates.sv'].includes(f))assert(current===before,'Unrelated source changed '+f);
}
const ss=read('rtl/savestates.sv'),oss=read('tests/savestate_paddle/baseline/rtl/savestates.sv');
const writes=s=>[...s.matchAll(/ddram_(?:cmd_)?write\(base_addr[^;]+;/g)].map(m=>m[0]);
for(const w of writes(oss))assert(writes(ss).includes(w),'Existing payload write changed '+w);
assert(ss.includes("{paddle_snap,32'h50414437}")&&ss.includes("dout_latch[63:52] <= 12'd3355"),'Paddle validation missing');
assert(ss.includes("PADDLE_EXT_MAGIC = 24'h484307")&&ss.includes("{PADDLE_EXT_MAGIC, 2'd3,"),'v7 tag/count missing');
assert(!ss.includes('paddle_0')&&!ss.includes('joy0_x'),'Raw inputs serialized');
const lines=read('tests/savestate_coverage/coverage_matrix.csv').split('\n').filter(l=>l.includes('Paddle'));
assert(lines.length&&lines.some(l=>l.includes('cnt_en16khz')),'Original F10 audit row absent');
fs.writeFileSync(path.join(d,'sources.json'),JSON.stringify(sources,null,2)+'\n');
console.log('PASS F10 static: 32 local bits, original protocol/divider unchanged, all '+Object.keys(sources).length+' baseline source hashes verified, existing DDR writes unchanged; F06, F11, MD6, Master Tap, ordinary/GG routing byte-identical outside F10 plumbing.');
console.log('Original audit calls the Paddle row S073; user request S072 refers to the same F10 state omissions.');
