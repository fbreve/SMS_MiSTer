const fs=require('fs'),p=require('path');const dir=__dirname,root=p.resolve(dir,'../..');
const read=f=>fs.readFileSync(f,'utf8').replace(/\r\n/g,'\n');
for(const family of ['nmi','g01']){
 const src=p.join(root,'tests/savestate_g01_cpu_restart_fix',family==='nmi'?'nmi_final':''),d=p.join(dir,'protocol_'+family);fs.mkdirSync(d,{recursive:true});
 const names=family==='nmi'?['T80_integrated.vhd','T80s_integrated.vhd','io_instance.sv','savestates_integrated.sv','machine.sv','fixed_tb.sv']:['T80_integrated.vhd','T80s_integrated.vhd','io_instance.sv','savestates_integrated.sv','integrated_machine.sv','mapping.sv','mapper_ctrl_observed.vhd','trace_tb.sv'];
 for(const n of names)fs.copyFileSync(p.join(src,n),p.join(d,n));
 const put=(n,s)=>fs.writeFileSync(p.join(d,n),s);
 let w=read(p.join(src,'T80s_integrated.vhd')).replace("NMIHold    : in std_logic := '0';","NMIHold    : in std_logic := '0';\n        RestoreHold: in std_logic := '0';").replace("NMIHold='1' or nmi_restart/=\"00\"", "NMIHold='1' or RestoreHold='1' or nmi_restart/=\"00\"");put('T80s_integrated.vhd',w);
 const machine=family==='nmi'?'machine.sv':'integrated_machine.sv';let m=read(p.join(src,machine));
 m=m.replace(' input clk,',' input prepare,\n input clk,').replaceAll('cpu_ce&&!ss_freeze','cpu_ce&&(!ss_freeze||(prepare&&nmi_replay))');
 m=m.replace('if(!ss_freeze)rom_q<=','if(!ss_freeze||prepare)rom_q<=').replace("assign di=ss_freeze?8'hff:","assign di=(ss_freeze&&!prepare)?8'hff:");
 m=m.replace('.NMIHold(nmi_hold),','.NMIHold(nmi_hold),.RestoreHold(ss_freeze),');put(machine,m);
 const tb=family==='nmi'?'fixed_tb.sv':'trace_tb.sv',period=family==='nmi'?'15':'PERIOD';let s=read(p.join(src,tb));
 s=s.replace('wire ss_freeze;',`wire transport_freeze;reg protocol_hold=0,protocol_prepare=0,protocol_commit=0;integer protocol_stage=0;reg[4:0]protocol_clock=0;
wire ss_freeze=transport_freeze||protocol_hold;`);
 s=s.replace(/savestates dut\([^;]+;/,x=>x.replace('.ss_freeze(ss_freeze)','.ss_freeze(transport_freeze)'));
 s=s.replace(' core(', ' core(.prepare(protocol_prepare),').replace(' reference(', ' reference(.prepare(1\'b0),');
 s=s.replace(`cpu_ce=cycle%${period}==0;cycle=cycle+1;`,`cpu_ce=!protocol_commit&&protocol_clock==0;protocol_clock=protocol_commit?1:(protocol_clock+1==${period}?0:protocol_clock+1);cycle=cycle+1;`);
 s=s.replace(`d_index=(cycle-accepted_cycle)%${period};follow_d=1;`,'d_index=0;follow_d=1;');
 s=s.replaceAll('wait(!replay);#2;loads=', 'wait(!replay);wait(!ss_freeze);#2;loads=');
 const control=`
always@(posedge clk)if(dut.state==37&&cpu_ce&&!dm1&&!dmreq&&z80_iset==0&&vblank&&x<256)protocol_hold<=1;
always@(posedge transport_freeze)protocol_hold<=1;
always@(negedge transport_freeze)protocol_stage<=dut.do_save?2:1;
always@(posedge clk)begin
 if(!reset_n)begin protocol_hold<=0;protocol_prepare<=0;protocol_commit<=0;protocol_stage<=0;end
 else case(protocol_stage)
 1:begin protocol_prepare<=1;if(!replay)begin protocol_prepare<=0;protocol_stage<=2;end end
 2:begin protocol_prepare<=0;protocol_commit<=1;protocol_stage<=3;end
 3:begin protocol_commit<=0;protocol_hold<=0;protocol_stage<=0;end
 endcase
 if(protocol_prepare&&(!dwr||!diq))$fatal(1,"private CPU preparation wrote guest state or issued IO");
end
`;
 s=s.replace('endmodule',control+'\nendmodule');put(tb,s);
 const dofile=family==='nmi'?read(p.join(src,'compile.do')):read(p.join(root,'tests/savestate_g02_g06_vdp/sanity/g01.do'));
 // G01 retained sanity do-file uses current trace fixture and the same depth.
 put('run.do',dofile);
}
console.log('CPU protocol prototypes prepared; no production source edited.');
