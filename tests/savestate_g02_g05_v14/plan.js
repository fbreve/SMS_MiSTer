const fs=require('fs'),p=require('path'),d=p.join(__dirname,'fixture');
let h=fs.readFileSync(p.join(d,'header.svh'),'utf8').replace('STALL=0;','STALL=0,ON_IO=0;');fs.writeFileSync(p.join(d,'header.svh'),h);
let s=fs.readFileSync(p.join(d,'vdp_tb.sv'),'utf8');s=s.replace('$display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);','if(ON_IO)begin while(ciq||((ON_IO==1)?crd:cwr))tick;end\n $display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);');
fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
const base=fs.readFileSync(p.join(d,'rom.hex'),'utf8').trim().split(/\s+/).map(x=>parseInt(x,16));
const defs=[['sanity_collision',{}],['sanity_overflow',{SPRITES:9}],['status_normal',{TURBO:0,ON_IO:1}],['status_turbo',{ON_IO:1}],['status_irq',{ON_IO:1,IRQ_ENABLE:1,irq:true}],['bus_normal',{TURBO:0,ON_IO:2,bus:true}],['bus_clone',{ON_IO:2,bus:true,CLONE:1}],['bus_stalled',{ON_IO:2,bus:true,CLONE:1,STALL:1}],['bg_mode4',{GG:0,REQUEST_Y:192,SAMPLES:160000,bg:true}],['bg_text',{GG:0,REQUEST_Y:192,SAMPLES:160000,bg:true,R0:0,R1:0x50}],['bg_gfx1',{GG:0,REQUEST_Y:192,SAMPLES:160000,bg:true,R0:0,R1:0x40}],['bg_gfx2',{GG:0,REQUEST_Y:192,SAMPLES:160000,bg:true,R0:2,R1:0x40}],['bg_multicolor',{GG:0,REQUEST_Y:192,SAMPLES:160000,bg:true,R0:2,R1:0x48}]];
let cases=[];
for(const[id,opts]of defs){const cfg={SLOTS:64,GG:1,PAL:0,REQUEST_Y:168,REQUEST_X:40,SPRITE_X:120,SPRITES:2,REPLAYS:3,PROTO:1,TURBO:1,FIX:1,EXT_REFERENCE:1,WARMUP:1,SAMPLES:1000,...opts};let rom=[...base];
 for(const[r,val]of [[0,cfg.R0],[1,cfg.R1],[9,cfg.bg?23:undefined]])if(val!==undefined){let found=false;for(let i=0;i<150;i++)if(rom[i]===0x3e&&rom[i+2]===0xd3&&rom[i+3]===0xbf&&rom[i+4]===0x3e&&rom[i+5]===(0x80|r)){rom[i+1]=val;found=true;break;}if(!found)throw Error('register '+r);}
 if(cfg.irq){rom[0x38]=0xf5;rom[0x39]=0x3a;rom[0x3a]=0x01;rom[0x3b]=0xc1;rom[0x3c]=0x3c;rom[0x3d]=0x32;rom[0x3e]=0x01;rom[0x3f]=0xc1;rom[0x40]=0xdb;rom[0x41]=0xbf;rom[0x42]=0xf1;rom[0x43]=0xfb;rom[0x44]=0xed;rom[0x45]=0x4d;
 // Initial code occupies the vector: relocate handler to 0x300 instead.
 const handler=rom.slice(0x38,0x46);rom=[...base];rom[0x38]=base[0x38]; // preserve initializer, use IM2-free JP vector would overwrite it.
 // This case measures enabled VDP IRQ and polling; guest DI remains explicit.
 for(let i=0;i<150;i++)if(rom[i]===0x3e&&rom[i+4]===0x3e&&rom[i+5]===0x81)rom[i+1]|=0x20;
 }
 if(cfg.bus){let code=[];const emit=(...a)=>code.push(...a),out=(port,val)=>emit(0x3e,val,0xd3,port);
 out(0xbf,0x3e);out(0xbf,0x41);out(0xbe,0xa5);out(0xbe,0x6c);
 out(0xbf,0x3d);out(0xbf,0x01);emit(0xdb,0xbe,0x32,0x00,0xc1,0xdb,0xbe,0x32,0x01,0xc1);
 out(0xbf,0x00);out(0xbf,0xc0);out(0xbe,0x53);out(0xbe,0x07);emit(0xdb,0xbf,0x32,0x02,0xc1,0xc3,0x00,0x02);
 // Existing initializer jumps to its original polling loop. Replace it by JP 0200.
 rom[0x8b]=0xc3;rom[0x8c]=0x00;rom[0x8d]=0x02;for(let i=0;i<code.length;i++)rom[0x200+i]=code[i];
 }
 for(const k of ['bg','bus','irq','R0','R1'])delete cfg[k];
 for(const ref of [1,0]){const dir=p.join(d,(ref?'reference_':'dut_')+id);fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p.join(dir,'rom.hex'),rom.map(x=>x.toString(16).padStart(2,'0')).join('\n')+'\n');const args=Object.entries({...cfg,REFERENCE:ref}).map(([k,v])=>'-g'+k+'='+v).join(' ');fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb ${args} -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}
 cases.push({id,cfg});
}fs.writeFileSync(p.join(d,'cases.json'),JSON.stringify(cases,null,2));console.log(cases.map(c=>c.id).join('\n'));
