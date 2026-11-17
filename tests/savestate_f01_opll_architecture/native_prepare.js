const fs=require('fs'),p=require('path'),d=__dirname;
let s=fs.readFileSync(p.join(d,'audio_tb.sv'),'utf8').replace('module pause_tb;','module native_tb;').replace('FASTVIDEO=1','FASTVIDEO=0').replace('"rom.hex"','"native_rom.hex"');
s=s.replace('fmsetup; repeat(SEED)tick;','repeat(100000)tick; repeat(SEED)tick;');
s=s.replace("if(!ss_freeze&&fwr)begin fm_a<=fa;fm_d<=fbus;end",`if(!ss_freeze)begin if(qmode&&fwr)begin fm_a<=fa;fm_d<=fbus;end else if(!ciq&&cm1&&!cwr&&ca[7:1]==7'b1111000)begin fm_a<=ca[0];fm_d<=co;end end`);
s=s.replace('if(!qmode&&fwr)begin rfm_a<=fa;rfm_d<=fbus;end',`if(!qmode&&!riq&&rm1&&!rwr&&ra[7:1]==7'b1111000)begin rfm_a<=ra[0];rfm_d<=ro;end`);
s=s.replace("{fmout[12:0],3'b0}","{((fmout[13]==fmout[12])?fmout[12:0]:{fmout[13],{12{fmout[12]}}}),3'b0}").replaceAll("{rfmout[12:0],3'b0}","{((rfmout[13]==rfmout[12])?rfmout[12:0]:{rfmout[13],{12{rfmout[12]}}}),3'b0}");
// One original native-video oracle followed by SAVE and three independent LOADs.
fs.writeFileSync(p.join(d,'native_tb.sv'),s);
const rom=Buffer.alloc(65536,0);const original=fs.readFileSync(p.join(d,'rom.hex'),'utf8').trim().split(/\s+/).map(n=>parseInt(n,16));let code=original.slice(0,40);
const wr=(a,b)=>code.push(0x3e,a,0xd3,0xf0,0x3e,b,0xd3,0xf1,...Array(24).fill(0));
for(const[a,b]of [[0,0x21],[1,0x21],[2,0x10],[3,7],[4,0xf4],[5,0xf4],[6,4],[7,4],[0x30,0],[0x10,0x91],[0x20,0x19],[0xf2,1]])if(a!==0xf2)wr(a,b);
const loop=code.length;code.push(0xc3,loop&255,loop>>8);Buffer.from(code).copy(rom);fs.writeFileSync(p.join(d,'native_rom.hex'),[...rom].map(b=>b.toString(16).padStart(2,'0')).join('\n')+'\n');
fs.writeFileSync(p.join(d,'native_compile.do'),fs.readFileSync(p.join(d,'compile.do'),'utf8').replaceAll('work_fast','work_native').replace('audio_tb.sv','native_tb.sv'));
fs.writeFileSync(p.join(d,'native_run.do'),fs.readFileSync(p.join(d,'run.do'),'utf8').replaceAll('work_fast.pause_tb','work_native.native_tb').replaceAll('/pause_tb','/native_tb'));
const dir=p.join(d,'native');fs.mkdirSync(dir,{recursive:true});for(const f of ['native_rom.hex'])fs.copyFileSync(p.join(d,f),p.join(dir,f));fs.writeFileSync(p.join(dir,'modelsim.ini'),fs.readFileSync(p.join(d,'modelsim.ini'),'utf8').replace('[Library]','[Library]\nwork_native = '+p.join(d,'work_native').replaceAll('\\','/')));
