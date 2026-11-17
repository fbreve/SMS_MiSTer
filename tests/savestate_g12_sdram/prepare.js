const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),d=__dirname,root=p.resolve(d,'../..'),src=p.join(root,'tests/savestate_g08_release_fix/modes'),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
fs.mkdirSync(d,{recursive:true});
if(cp.execFileSync('git',['diff','--name-only'],{cwd:root,encoding:'utf8'}).trim())throw Error('Investigation requires unchanged tracked source');
const files=cp.execFileSync('git',['ls-files'],{cwd:root,encoding:'utf8'}).trim().split(/\r?\n/).filter(f=>fs.statSync(p.join(root,f)).isFile());fs.writeFileSync(p.join(d,'baseline.json'),JSON.stringify({head:cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),files:Object.fromEntries(files.map(f=>[f,sha(fs.readFileSync(p.join(root,f)))]))},null,2));
for(const f of ['T80_sim.vhd','T80s_sim.vhd','pause_fixture.sv','rom.hex'])fs.copyFileSync(p.join(src,f),p.join(d,f));
fs.copyFileSync(p.join(root,'rtl/jt89/jt89.v'),p.join(d,'jt89.v'));
let sd=fs.readFileSync(p.join(root,'rtl/sdram.sv'),'utf8').replace('always @(posedge clk) begin','always @(posedge clk) begin : access_manager').replace('inout  reg [15:0] SDRAM_DQ','inout wire [15:0] SDRAM_DQ').replace('assign SDRAM_CKE = 1;',"reg [15:0] dq_drive;\nassign SDRAM_DQ=dq_drive;\nassign SDRAM_CKE = 1;").replaceAll('SDRAM_DQ <=','dq_drive <=');fs.writeFileSync(p.join(d,'sdram.v'),sd);
fs.writeFileSync(p.join(d,'savestates_sim.sv'),require('../savestate_g06_g10_fix/controller_adapter')(p.join(root,'rtl/savestates.sv')));
let mc=fs.readFileSync(p.join(root,'rtl/mapper_ctrl.vhd'),'utf8').replace(/(case A\(1 downto 0\) is[\s\S]*?)(\s*end case;)/g,(m,a,b)=>/when others/i.test(a)?m:a+'\n when others => null;'+b);fs.writeFileSync(p.join(d,'mapper_ctrl_sim.vhd'),mc);
let s=fs.readFileSync(p.join(src,'audio_tb.sv'),'utf8').replace(/\r\n/g,'\n');
s=s.replace('parameter DIVSEEK=', 'parameter TAC=1,REQUEST_DELAY=0,WAIT_WINDOW=0,HIST=0,CACHEHISTORY=0,TRANSFER=0,PATTERN=0,BANKS=0,ROMBANK=1,DIVSEEK=');
s=s.replace('always #5 clk=~clk;','always #10 clk=~clk;');
s=s.replace('.DI(rom(ca))',".DI(ciq?cdi:{7'd0,HIST[0]})").replace('.DI(rom(ra))',".DI(riq?rdi:{7'd0,HIST[0]})");
s=s.replace('reg [7:0] wram_D = \'0;', 'wire [7:0] wram_D;');
s=s.replace("reg [63:0] mapper_out = '0;",'wire [63:0] mapper_out;');
s=s.replace('systeme=DUAL<3;', 'systeme=DUAL<3;');
// Retain real CPU initialization; replace its repeating loop with nonuniform
// ROM data reads and guest signature stores. ROM is immutable after reset.
const rom=fs.readFileSync(p.join(src,'rom.hex'),'utf8').trim().split(/\r?\n/);const prog=[0x3e,0xff,0x32,0xff,0xff,0x78,0x32,0xfe,0xff,0x04,0x21,0xfd,0x3f,0x7e,0x32,0x00,0xc1,0x23,0x7e,0x32,0x01,0xc1,0x23,0x7e,0x32,0x02,0xc1,0x21,0xff,0x7f,0x7e,0x32,0x03,0xc1,0x23,0x7e,0x32,0x04,0xc1,0x23,0x7e,0x32,0x05,0xc1,0xc3,0x2e,0x00];prog.forEach((v,i)=>rom[46+i]=v.toString(16).padStart(2,'0'));fs.writeFileSync(p.join(d,'rom.hex'),rom.join('\n')+'\n');
const handler=[0x3a,0x01,0x40,0x32,0x10,0xc1,0xed,0x45];handler.forEach((v,i)=>rom[0x66+i]=v.toString(16).padStart(2,'0'));fs.writeFileSync(p.join(d,'rom.hex'),rom.join('\n')+'\n');
s=s.replaceAll(".NMI_n(1'b1)",'.NMI_n(nmi_future)').replace('task future(input integer n,input bit reference_run);begin','reg nmi_future=1;\ntask future(input integer n,input bit reference_run);begin\nif(CACHEHISTORY&&n==500)nmi_future=0;if(CACHEHISTORY&&n==504)nmi_future=1;');
const a=s.indexOf('if(SEEK)storage_busy=1;request(1);');s=s.slice(0,a)+s.slice(a).replace('if(SEEK)storage_busy=1;request(1);','if(WAIT_WINDOW)while(!(vb&&x<128))tick;repeat(REQUEST_DELAY)tick;if(SEEK)storage_busy=1;request(1);');
// Capture additional independent CPU/memory oracle from exact T+1.
s=s.replace('$fdisplay(fd,"%h %h %b",{rl,rr_audio},rraw,refphase);','$fdisplay(fd,"%h %h %b %h %h",{rl,rr_audio},rraw,refphase,cpu_ref,ref_signature);');
s=s.replace('scan=$fscanf(fd,"%h %h %b",oracle[k],raw_oracle[k],phase_oracle[k]);if(scan!=3)', 'scan=$fscanf(fd,"%h %h %b %h %h",oracle[k],raw_oracle[k],phase_oracle[k],cpu_oracle[k],sig_oracle[k]);if(scan!=5)');
s=s.replace('if(raw!==raw_oracle[k])', 'if(cpu_actual!==cpu_oracle[k]||signature!==sig_oracle[k])$fatal(1,"G12 CPU/memory mismatch pass%0d k%0d CPU%h/%h sig%h/%h",pass,k,cpu_actual,cpu_oracle[k],signature,sig_oracle[k]);\nif(raw!==raw_oracle[k])');
s=s.replace('if(PAUSE)begin while(!(vb&&x==200))tick;', 'if(PAUSE)begin while(!(vb&&x==200))tick;');
s=s.replace('initial begin\nfor(j=0;j<12288;', 'initial begin\nfor(j=0;j<12288;');
s=s.replace('qmode=1;put(', 'qmode=1;put('); // Q executes real ROM reads, never deposits controller state.
s=s.replace('if($isunknown({rl,rr_audio,rraw,refphase}))', 'if($isunknown({cpu_ref,ref_signature,rl,rr_audio,rraw,refphase}))');
s=s.replace('initial begin\nfor(j=0;j<12288;',`initial begin
if(CACHEHISTORY)begin
 pause_rom[46]=8'hc3;pause_rom[47]=0;pause_rom[48]=8'hc0;
end
for(j=0;j<12288;`);
const entity=fs.readFileSync(p.join(root,'rtl/mapper_ctrl.vhd'),'utf8').split('end entity;')[0],ports=[...entity.matchAll(/^\s*(\w+)\s*:\s*(in|out)\s+std_logic(?:_vector\((\d+) downto (\d+)\))?/gmi)];
let mapper='wire[7:0]db0,db1,db2,db3,rb0,rb1,rb2,rb3;\nassign mapper_out=(64\'d1<<54)|{32\'d0,db3,db2,db1,(systeme?{BANKS[1:0],2\'b0,ROMBANK[3:0]}:db0)};\n';
for(const ref of [false,true]){const m={RESET_n:'reset_n',clk_sys:'clk',mapper_set:ref?"1'b0":'mapper_set',mapper_in:ref?"64'd0":'mapper_in',systeme:'systeme',bootloader_n:"1'b1",rom_size_pages:"8'hff",ce_z80:ref?"((DUAL==3||DUAL==5)?rce_cpu:rce_pix)":"(cpu_ce&&!ss_freeze)",WR_n:ref?'rwr':'cwr',MREQ_n:ref?'rmreq':'cmreq',A:ref?'ra':'ca',ss_freeze:ref?"1'b0":'ss_freeze',D_in:ref?'ro':'co',mapper_manual_force:"1'b1",sega_mapper_write_seen:"1'b1",bank0_out:ref?'rb0':'db0',bank1_out:ref?'rb1':'db1',bank2_out:ref?'rb2':'db2',bank3_out:ref?'rb3':'db3'};mapper+=`mapper_ctrl ${ref?'ref_mapper':'live_mapper'}(`+ports.map(x=>'.'+x[1]+'('+(m[x[1]]??(x[2].toLowerCase()==='out'?'':(x[3]?((+x[3]-+x[4]+1)+"'d0"):"1'b0")))+')').join(',')+');\n';}
s=s.replace('T80s #(.T2Write(0)) cpu(',mapper+fs.readFileSync(p.join(d,'integration.svh'),'utf8').replace('.bank1(ROMBANK[7:0])','.bank1(db1)').replace('.bank1(ROMBANK[7:0])','.bank1(rb1)').replace('.bank2(8\'d255)','.bank2(db2)').replace('.bank2(8\'d255)','.bank2(rb2)')+'\nT80s #(.T2Write(0)) cpu(');
s=s.replace('T80s #(.T2Write(0)) cpu(',fs.readFileSync(p.join(d,'transfer.svh'),'utf8')+'\nT80s #(.T2Write(0)) cpu(');
s=s.replace('request(0);wait(ss_freeze);wait(!ss_freeze);','perturb_memory;request(0);wait(ss_freeze);wait(!ss_freeze);');
s=s.replace('$display("Q pass%0d raw%h outputs%h/%h",pass,raw,al,ar);','$display("Q pass%0d raw%h outputs%h/%h CPU%h dramAddr%h dramData%h",pass,raw,al,ar,z80_reg,live.a,live.sd_dat);');
fs.writeFileSync(p.join(d,'audio_tb.sv'),s);
let c=fs.readFileSync(p.join(src,'compile.do'),'utf8').replace('vlog -work pause_work -sv -quiet savestates_sim.sv pause_fixture.sv audio_tb.sv','vcom -work pause_work -2008 -quiet ../../rtl/memory_bus.vhd ../../rtl/memory_decode.vhd mapper_ctrl_sim.vhd\nvlog -work pause_work -sv -suppress 2244 -quiet sdram.v\nvlog -work pause_work -sv -suppress 2388 -quiet pin_model.sv savestates_sim.sv pause_fixture.sv audio_tb.sv').replaceAll('../../../rtl/','../../rtl/');fs.writeFileSync(p.join(d,'compile.do'),c);
console.log('Prepared current v16 CPU/controller/physical SDRAM integration; production untouched');
