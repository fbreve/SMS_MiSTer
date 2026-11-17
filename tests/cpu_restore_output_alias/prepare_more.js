const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname,r=p.resolve(d,'../..');
const {miter,shadowCPU}=require('./prepare');const read=f=>fs.readFileSync(f,'utf8').replace(/\r\n/g,'\n');
const mirror=s=>s.replace(/force dut\.(\w+)\s*=([^;]+);/g,(m,n,e)=>m+`force alias_ctl.${n}=${e};`).replace(/release dut\.(\w+);/g,(m,n)=>m+`release alias_ctl.${n};`);
function cpuPair(){let s='';for(const alias of[false,true]){const n=alias?'a':'b',ct=alias?'alias_ctl':'dut';s+=`wire[229:0]${n}_reg;wire[15:0]${n}_addr;wire[7:0]${n}_do;wire ${n}_m1,${n}_mreq,${n}_halt,${n}_replay;wire[2:0]${n}_nmi;\nT80s ${n}_cpu(.CLK(clk),.RESET_n(reset_n),.CEN(!${ct}.ss_freeze||(${ct}.ss_cpu_prepare&&${n}_replay)),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(1'b1),.BUSRQ_n(1'b1),.OUT0(1'b0),.DI(8'h00),.DIR(${ct}.z80_dir),.DIRSet(${ct}.z80_set),.NMIDIR(${ct}.z80_nmi_dir),.NMIValid(${ct}.z80_nmi_valid),.NMIHold(${ct}.z80_nmi_hold),.NMIEnable(1'b1),.RestoreHold(${ct}.ss_freeze),.ReplayT2(${ct}.z80_replay_t2),.RestartDIR(${ct}.z80_restart_dir),.RestartValid(${ct}.z80_restart_valid),.REG(${n}_reg),.A(${n}_addr),.DO(${n}_do),.M1_n(${n}_m1),.MREQ_n(${n}_mreq),.HALT_n(${n}_halt),.NMIReplay(${n}_replay),.NMIState(${n}_nmi));\n`;}
 s+='always@(posedge clk)begin #1;if({a_reg,a_addr,a_do,a_m1,a_mreq,a_halt,a_replay,a_nmi}!=={b_reg,b_addr,b_do,b_m1,b_mreq,b_halt,b_replay,b_nmi})$fatal(1,"ALIAS real format CPU/RegDIR");end\n';return s;}
const bindCPU=()=>{
 let cpu=read(p.join(r,'rtl/T80/T80.vhd')).replace(/: work\.(T80_MCode|T80_ALU|T80_Reg)/g,': entity work.$1').replace('(ioq and x"7")','(ioq and "000000111")');
 let wrap=read(p.join(r,'rtl/T80/T80s.vhd')).replace(': work.T80',': entity work.T80');return {cpu,wrap};
};
const generic=[];
for(const[kind,src,file]of[['format','savestate_g08_fm/format','format_tb.sv'],['imports','savestate_g08_fm/imports','imports_tb.sv'],['images','cram_memory_inference/image_reference','image_tb.sv']]){
 const dst=p.join(d,kind);fs.mkdirSync(dst,{recursive:true});let s=read(p.join(r,'tests',src,file));
 const at=s.lastIndexOf('endmodule');s=s.slice(0,at)+miter()+cpuPair()+s.slice(at);s=mirror(s);
 // Random command stalls and unsolicited idle responses exercise both FSMs identically.
 s=s.replace('DDRAM_DOUT_READY<=0;','DDRAM_DOUT_READY<=0;\n if(pending==0&&!DDRAM_RD&&bus_rng[4:0]==0)begin DDRAM_DOUT_READY<=1;DDRAM_DOUT<=64\'hbaddecaf12345678;end');
 const m=s.indexOf('always #5');s=s.slice(0,m)+`reg[31:0]bus_rng=32'hca8b17e3;always@(negedge clk)begin bus_rng={bus_rng[30:0],bus_rng[31]^bus_rng[21]^bus_rng[1]^bus_rng[0]};DDRAM_BUSY=bus_rng[2:0]<3;end\n`+s.slice(m);
 // Image profiles have a separate deterministic stall driver; retain that driver instead.
 if(kind==='images')s=s.replace('DDRAM_BUSY=bus_rng[2:0]<3;','');
 fs.writeFileSync(p.join(dst,file),s);
 fs.copyFileSync(p.join(d,'baseline_sim.sv'),p.join(dst,'savestates_sim.sv'));fs.copyFileSync(p.join(d,'candidate_sim.sv'),p.join(dst,'candidate_sim.sv'));
 const {cpu,wrap}=bindCPU();fs.writeFileSync(p.join(dst,'T80_sim.vhd'),cpu);fs.writeFileSync(p.join(dst,'T80s_sim.vhd'),wrap);
 fs.writeFileSync(p.join(dst,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib test_work\nvcom -work test_work -2008 -quiet ../../../rtl/T80/T80_Reg.vhd ../../../rtl/T80/T80_MCode.vhd ../../../rtl/T80/T80_ALU.vhd T80_sim.vhd T80s_sim.vhd\nvlog -work test_work -sv ../../../rtl/opll_snapshot.sv savestates_sim.sv candidate_sim.sv ${file}\nvsim -t 1ps test_work.vdp_tb -g/vdp_tb/dut/TB_FAST=1\nset NumericStdNoWarnings 1\nrun -all\nquit -code 0\n`);generic.push({dir:kind,marker:kind==='format'?'PASS V19 FORMAT':kind==='imports'?'PASS IMPORT ALL':'PASS CRAM IMAGE ALL'});
}
// Modern full-controller CPU restart suite with registered ROM and existing trace oracles.
{
 const src=p.join(r,'tests/savestate_f01_opll_fix/reg_g01'),dst=p.join(d,'native_g01');fs.mkdirSync(dst,{recursive:true});
 for(const f of fs.readdirSync(src))if(fs.statSync(p.join(src,f)).isFile()&&/\.(sv|vhd|do|json)$/.test(f))fs.copyFileSync(p.join(src,f),p.join(dst,f));
 fs.copyFileSync(p.join(d,'baseline_sim.sv'),p.join(dst,'savestates_integrated.sv'));fs.copyFileSync(p.join(d,'candidate_sim.sv'),p.join(dst,'candidate_sim.sv'));
 let s=read(p.join(dst,'trace_tb.sv'));s=s.replaceAll("24'h484311","24'h484313");
 s=s.replace('savestates dut(',"savestates dut(.audio_last_out(16'd0),");
 const renamed=s.replace(/nmi_machine(\s*#\([\s\S]*?\))?\s+core\s*\(/,'T80s$1 cpu(');
 const names='wram_D cpu_reg nmi_snap nstate old_nmi nmi_replay ready gg_out io_out addr data di iset m1 mreq wr rd iq nmi_n restart_out ctx_view map_out hist_out last_read physical'.split(' ');
 const shadow=shadowCPU(renamed,names.map(n=>n+':out std_logic;').join('\n')).replace(/T80s\s*#/,'nmi_machine #');
 const at=s.lastIndexOf('endmodule');s=s.slice(0,at)+miter()+shadow+s.slice(at);fs.writeFileSync(p.join(dst,'trace_tb.sv'),mirror(s));
 let c=read(p.join(dst,'compile.do')).replace('savestates_integrated.sv','savestates_integrated.sv candidate_sim.sv');fs.writeFileSync(p.join(dst,'compile.do'),c);
 const cases=JSON.parse(read(p.join(src,'cases.json')));for(const item of cases){const name='p'+item.args.PROGRAM,to=p.join(dst,name);fs.mkdirSync(to,{recursive:true});let run=read(p.join(src,name,'run.do'));run=run.replace('trace_work.fixed_tb','trace_work.fixed_tb -g/fixed_tb/dut/TB_FAST=1');fs.writeFileSync(p.join(to,'run.do'),run);}
 fs.writeFileSync(p.join(d,'g01_cases.json'),JSON.stringify(cases,null,2));
}
fs.writeFileSync(p.join(d,'generic_cases.json'),JSON.stringify(generic,null,2));console.log('Prepared all-format, image, random DDR/stale response, real CPU pairs and retained G01 trace matrix.');
