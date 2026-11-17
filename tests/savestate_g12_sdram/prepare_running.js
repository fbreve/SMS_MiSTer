const fs=require('fs'),p=require('path'),d=__dirname,dst=p.join(d,'running');fs.mkdirSync(dst,{recursive:true});
for(const f of ['audio_tb.sv','pin_model.sv','sdram.v','savestates_sim.sv','mapper_ctrl_sim.vhd','T80_sim.vhd','T80s_sim.vhd','pause_fixture.sv','jt89.v','rom.hex','compile.do'])fs.copyFileSync(p.join(d,f),p.join(dst,f));
let s=fs.readFileSync(p.join(dst,'audio_tb.sv'),'utf8').replace('parameter TAC=','parameter TAIL_DELAY=0,TAC=').replace("reg clk = '0;","reg load_started=0;\nreg clk = '0;");
s=s.replace('pending<=LATENCY;readaddr',"pending<=LATENCY+((DDRAM_ADDR-29'h07c00000)==29'h2900 ? TAIL_DELAY : 0);readaddr");
// Independent golden T80 receives the same restore, enables, mapper/RAM and
// immutable bytes directly; it bypasses only the live SDRAM temporal pipeline.
let line=s.split('\n').find(l=>l.startsWith('T80s #(.T2Write(0)) rcpu('));
let replacement=line.replace(/\.CEN\(.*?\),\.WAIT_n/,'.CEN((((DUAL==3||DUAL==5)?ce_cpu:ce_pix)&&!ss_freeze&&(!paused||ss_capture_progress))||(ce_cpu&&cpu_prepare&&replay)),.WAIT_n')
 .replace(".DIRSet(1'b0),.DIR(230'd0)",".NMIEnable(1'b1),.NMIDIR(dut.z80_nmi_dir),.NMIValid(dut.z80_nmi_valid),.NMIHold(dut.z80_nmi_hold),.RestoreHold(ss_freeze),.ReplayT2(replay_t2),.RestartContext(),.RestartDIR(dut.z80_restart_dir),.RestartValid(dut.z80_restart_valid),.DIRSet(z80_set),.DIR(z80_dir)");
s=s.replace(line,replacement);
line=s.split('\n').find(l=>l.startsWith('mapper_ctrl ref_mapper('));replacement=line.replace(".mapper_set(1'b0)",'.mapper_set(mapper_set)').replace(".mapper_in(64'd0)",'.mapper_in(mapper_in)').replace(".ss_freeze(1'b0)",'.ss_freeze(ss_freeze)').replace('.ce_z80(((DUAL==3||DUAL==5)?rce_cpu:rce_pix))','.ce_z80(cpu_ce&&!ss_freeze)');s=s.replace(line,replacement);
s=s.replace('.irom_D_out(rsd)', '.irom_D_out(rchip.byte_at(rphys))').replace('if(rrw)ref_bytes[ref_address]<=ro;',"if(!ss_freeze&&rrw)ref_bytes[ref_address]<=ro;if(wram_WE)ref_bytes[wram_WA]<=wram_WD;");
s=s.replace('if(reset_n&&!ss_freeze&&cpu_ce&&!crd', 'if(!load_started&&reset_n&&!ss_freeze&&cpu_ce&&!crd');
let start=s.indexOf('initial begin\nif(CACHEHISTORY)begin'),end=s.indexOf('initial begin #2000000000;',start);if(start<0||end<0)throw Error('main markers');
s=s.slice(0,start)+`
integer wrong_fetches=0,architectural_differences=0,preload_equal=0;
always@(posedge clk)if(reset_n&&!load_started&&cycle>BOOT+5000&&!ss_freeze&&cpu_ce)begin
 #1;if($isunknown({z80_reg,rr})||z80_reg!==rr||ca!==ra)$fatal(1,"golden CPU differs before LOAD");preload_equal++;
end
always@(posedge clk)if(load_started&&!ss_freeze&&cpu_ce)begin
 if(!crd&&!cmreq&&ca<16'hc000&&sd!==chip.byte_at(phys))begin wrong_fetches++;$display("WRONG_G12_FETCH cycle%0d A%h physical%h actual%h expected%h q%0d ready%b flight%b",cycle,ca,phys,sd,chip.byte_at(phys),live.q,ready,flight);end
 #1;if(z80_reg!==rr||ca!==ra)begin architectural_differences++;if(architectural_differences<=6)$display("G12_GUEST_DIVERGENCE cycle%0d actual%h golden%h A%h/%h",cycle,z80_reg,rr,ca,ra);end
end
initial begin
 for(j=0;j<12288;j++)mem[j]=0;
 systeme=1;ss_game_id=32'h12345678;repeat(BOOT)tick;reset_n=1;repeat(2)tick;program_sound;
 while(!(vb&&x==200))tick;button;wait(paused);repeat(64)tick;
 request(1);wait(ss_freeze);wait(!ss_freeze);
 $writememh("image.hex",mem);
 if(mem['h2f][3]!==0)$fatal(1,"not a suppressed-T capture");
 $display("PAUSED_IMAGE phase%0d tick%b PC%h",mem['h2f][1:0],mem['h2f][3],z80_reg[79:64]);
 button;wait(!paused);repeat(2000)tick;
 load_started=1;request(0);wait(ss_freeze);wait(!ss_freeze);
 $display("LOAD_RUNNING_RELEASE q%0d oldrd%b retained%h SD%h expected%h prepTick%b",live.q,live.access_manager.old_rd,live.a,sd,chip.byte_at(phys),mem['h2f][3]);
 repeat(1000)tick;
 if(wrong_fetches&&architectural_differences)$display("CONFIRMED G12 wrongFetches%0d guestDifferences%0d tailDelay%0d preloadEqual%0d",wrong_fetches,architectural_differences,TAIL_DELAY,preload_equal);
 else if(wrong_fetches||architectural_differences)$fatal(1,"incomplete characterization fetch%0d architecture%0d",wrong_fetches,architectural_differences);
 else $display("PASS G12 LOAD_RUNNING tailDelay%0d",TAIL_DELAY);
 $finish;
end
`+s.slice(end);
s=s.replace(/\nendmodule\s*$/,`
always@(posedge clk)if(cpu_prepare||audio_phase_set||(load_started&&!ss_freeze&&cycle%2==0))$display("RUNNING_TRACE cycle%0d prepare%b replay%b cpuCE%b pixelCE%b phase%0d A%h rd%b q%0d oldrd%b ready%b data%h golden%h",cycle,cpu_prepare,replay,ce_cpu,ce_pix,clkd,ca,rd,live.q,live.access_manager.old_rd,ready,sd,rchip.byte_at(rphys));
endmodule
`);
fs.writeFileSync(p.join(dst,'audio_tb.sv'),s);fs.writeFileSync(p.join(dst,'compile.do'),fs.readFileSync(p.join(dst,'compile.do'),'utf8').replaceAll('../../rtl/','../../../rtl/'));
const cases=[0,8,16,24].map(t=>({id:'delay_'+t,args:{DUAL:0,BOOT:1200,TAIL_DELAY:t}}));fs.writeFileSync(p.join(dst,'cases.json'),JSON.stringify(cases,null,2));
console.log('Prepared natural paused SAVE/current-running LOAD characterizer with independent golden CPU');
