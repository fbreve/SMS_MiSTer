const fs=require('fs'),p=require('path'),here=__dirname;
for(const family of ['nmi','g01']){
 const src=p.join(here,'protocol_'+family),d=p.join(here,'candidate_'+family);fs.mkdirSync(d,{recursive:true});
 const names=family==='nmi'?['T80_integrated.vhd','T80s_integrated.vhd','io_instance.sv','machine.sv','fixed_tb.sv']:['T80_integrated.vhd','T80s_integrated.vhd','io_instance.sv','integrated_machine.sv','mapping.sv','mapper_ctrl_observed.vhd','trace_tb.sv'];
 for(const n of names)fs.copyFileSync(p.join(src,n),p.join(d,n));
 const put=(f,s)=>fs.writeFileSync(p.join(d,f),s),read=f=>fs.readFileSync(p.join(src,f),'utf8').replace(/\r\n/g,'\n');
 let c=fs.readFileSync(p.join(here,'candidate/savestates_sim.sv'),'utf8').replace('module savestates #(parameter TB_FAST=0) (','module savestates (').replace('(TB_FAST?20\'d0:20\'d900000)',"20'd900000");put('savestates_integrated.sv',c);
 const file=family==='nmi'?'fixed_tb.sv':'trace_tb.sv';let s=read(file);
 s=s.slice(0,s.indexOf('\nalways@(posedge clk)if(dut.state==37'))+'\nendmodule\n';
 s=s.replace('wire transport_freeze;reg protocol_hold=0,protocol_prepare=0,protocol_commit=0;integer protocol_stage=0;reg[4:0]protocol_clock=0;', 'wire transport_freeze,protocol_prepare,protocol_commit;reg protocol_ready=0;reg[4:0]protocol_clock=0;')
 .replace('wire ss_freeze=transport_freeze||protocol_hold;', 'wire ss_freeze=transport_freeze;');
 // Test clocks represent a consumed capture enable by counter=1. The
 // production four-phase divider is exercised by the VDP integration fixture.
 s=s.replace('cpu_ce=!protocol_commit&&protocol_clock==0;', 'protocol_ready=protocol_commit;cpu_ce=!protocol_commit&&protocol_clock==0;');
 // Existing replay wire is declared after the controller; connect its actual
 // wrapper output through the earlier declared alias to avoid implicit nets.
 s=s.replace(',replay,',',').replace('wire replay,','wire ');
 s=s.replaceAll("!==24'h48430d", "!==24'h48430e").replaceAll('v13 writer tag','v14 writer tag').replaceAll('v13 payload','v14 payload');
 s=s.replace('if(FORMAT>=100&&ss_freeze&&', 'if(FORMAT>=100&&stage==2&&ss_freeze&&');
 s=s.replace('savestates dut(', `wire replay,replay_t2;
savestates dut(.ss_cpu_prepare(protocol_prepare),.z80_replay(replay),
 .z80_tick_active(1'b1),.z80_replay_t2(replay_t2),
 .clock_phase(2'd0),.clock_phase_in(),.clock_phase_set(protocol_commit),.clock_phase_ready(protocol_ready),
 .sprite_out(4778'd0),.sprite2_out(4778'd0),.sprite_in(),.sprite2_in(),.sprite_valid(),`);
 s=s.replace(' core(.prepare(protocol_prepare),', ' core(.prepare(protocol_prepare),.replay_t2(replay_t2),')
    .replace(' reference(.prepare(1\'b0),', ' reference(.prepare(1\'b0),.replay_t2(1\'b1),');
 const machine=family==='nmi'?'machine.sv':'integrated_machine.sv';
 put(machine,read(machine).replace(' input prepare,',' input replay_t2,\n input prepare,').replace('.RestoreHold(ss_freeze),','.RestoreHold(ss_freeze),.ReplayT2(replay_t2),'));
 put('T80s_integrated.vhd',read('T80s_integrated.vhd').replace("RestoreHold: in std_logic := '0';", "RestoreHold: in std_logic := '0';\n        ReplayT2: in std_logic := '1';")
 .replace('elsif CEN=\'1\' and nmi_restart="10" then nmi_restart <= "11";', 'elsif CEN=\'1\' and nmi_restart="10" then\n                if ReplayT2=\'1\' then nmi_restart <= "11";else nmi_restart <= "00";end if;'));
 put(file,s);put('run.do',read('run.do'));
}
console.log('Draft CPU regression fixtures prepared.');
