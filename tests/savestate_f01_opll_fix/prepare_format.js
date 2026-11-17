const fs=require('fs'),p=require('path'),d=__dirname,root=p.resolve(d,'../..'),map=require('./state_map.json'),dst=p.join(d,'format');fs.mkdirSync(dst,{recursive:true});
let s=fs.readFileSync(p.join(d,'../savestate_g08_release_fix/format/format_tb.sv'),'utf8');
s=s.replace('wire ss_freeze;', 'wire fm_write,fm_reset;wire ss_freeze;').replace(/savestates\s+dut\s*\(/,`savestates dut(.fm_initialized(1'b1),.fm_state_rdata(32'd0),.fm_state_write(fm_write),.fm_legacy_reset(fm_reset),`);
s=s.replace('if(loading&&(wram_WE', 'if(loading&&(fm_write||fm_reset||wram_WE');
s=s.replace("mem['h1a][63:40]!==24'h484310", "mem['h1a][63:40]!==24'h484311");
let tests="\n// Every FM descriptor/padding bit is rejected before any guest write.\nfor(integer bitnum=0;bitnum<64;bitnum++)reject_bit('h2997,bitnum);\n";
let pads=0;for(let i=0;i<map.words;i++)for(let bit=0;bit<32;bit++)if(!(BigInt('0x'+map.masks[i])&(1n<<BigInt(bit)))){tests+=`reject_bit('h${(0x2998+Math.floor(i/2)).toString(16)},${bit+(i%2)*32});\n`;pads++;}
for(const r of map.rows.filter(r=>r.stored)){
 const n=r.signal.split(' ')[0],limit=r.module==='opll/s0'?72:['regs_addr','fb_addr','faddr'].includes(n)?9:n==='slot_voice_addr'?38:['rslot','mo_addr','maddr'].includes(n)?18:0;
 if(limit){const x=r.slices[0],word=0x2998+Math.floor(x.word/2),lo=x.wordLo+(x.word%2)*32,mask=((1n<<BigInt(x.width))-1n)<<BigInt(lo);tests+=`begin reg[63:0]beforeword;beforeword=mem['h${word.toString(16)}];mem['h${word.toString(16)}]=(beforeword&~64'h${mask.toString(16)})|(64'd${limit}<<${lo});transfer(0);if(guest_writes)$fatal(1,"FM semantic bound ${r.module}.${n}");mem['h${word.toString(16)}]=beforeword;rejections++;end\n`;}
}
s=s.replace("if(audio_phase_in!==1)$fatal(1,\"v16 historical phase1 lost\");", "if(audio_phase_in!==1)$fatal(1,\"v17 historical phase1 lost\");"+tests);
s=s.replace("expect_background=1;mem['h1a]=oldtag;mem['h2f][3]=0;", `expect_background=1;mem['h1a][63:40]=24'h484310;
 transfer(0);if(!guest_writes||audio_phase_in!==1||dut.has_fm)$fatal(1,"v16 compatibility");accepted++;
 expect_background=1;mem['h1a]=oldtag;mem['h2f][3]=0;`);
s=s.replace('PASS V16 FORMAT','PASS V17 FORMAT');
fs.writeFileSync(p.join(dst,'format_tb.sv'),s);fs.writeFileSync(p.join(dst,'savestates_sim.sv'),require('../savestate_g06_g10_fix/controller_adapter')(p.join(root,'rtl/savestates.sv')));
fs.writeFileSync(p.join(dst,'run.do'),'onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib format_work\nvlog -work format_work -sv ../../../rtl/opll_snapshot.sv savestates_sim.sv format_tb.sv\nvsim -t 1ps format_work.vdp_tb -g/vdp_tb/dut/TB_FAST=1\nrun -all\nquit -code 0\n');
fs.writeFileSync(p.join(dst,'manifest.json'),JSON.stringify({source:'savestate_g08_release_fix/format/format_tb.sv',baseline:911,fmPaddingBits:pads,fmDescriptorBits:64,additionalV16Acceptance:1},null,2));
console.log({fmPaddingBits:pads});
