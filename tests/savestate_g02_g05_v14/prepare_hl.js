const fs=require('fs'),p=require('path'),d=p.join(__dirname,'hl'),src=p.join(__dirname,'bus');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8');
s=s.replace('reg hl=0;','reg hl=0;integer input_age=0;reg input_active=0;');
s=s.replace('$display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);','$display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);input_age=0;input_active=1;hl=0;');
s=s.replace('request(0);divs=0;guestdiv=0;','request(0);input_age=0;hl=0;divs=0;guestdiv=0;');
s=s.replace("ca[7:6]==2'b10", "(ca[7:6]==2'b10||ca[7:6]==2'b01)");
s=s.replace(/\nendmodule\s*$/,`
always@(posedge clk)if(input_active&&!setup&&!frozen&&ce_pix)begin
 input_age<=input_age+1;
 if(input_age==4||input_age==77)hl<=1;
 if(input_age==5||input_age==78)hl<=0;
end
integer release_cycle=-1;reg[3:0]first_seen=0;
always@(negedge ss_freeze)if(hadfreeze&&!REFERENCE)begin release_cycle=cycle;first_seen=0;end
always@(posedge clk)if(release_cycle>=0&&!frozen)begin
 if(ce_cpu&&!first_seen[0])begin first_seen[0]=1;$display("FIRST_CPU host%0d actualCPU%b MC%0d TS%0d A%h M1%b MREQ%b IO%b RD%b WR%b",cycle-release_cycle,cpu_tick,mc_probe,ts_probe,ca,cm1,cmreq,ciq,crd,cwr);end
 if(ce_vdp&&!first_seen[1])begin first_seen[1]=1;$display("FIRST_VDP host%0d xy%0d,%0d regs%h",cycle-release_cycle,x,y,vdp_regs);end
 if(ce_pix&&!first_seen[2])begin first_seen[2]=1;$display("FIRST_PIX host%0d xy%0d,%0d regs%h",cycle-release_cycle,x,y,vdp_regs);end
 if(ce_sp&&!first_seen[3])begin first_seen[3]=1;$display("FIRST_SP host%0d xy%0d,%0d",cycle-release_cycle,x,y);end
end
endmodule
`);fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
let rom=fs.readFileSync(p.join(__dirname,'fixture/rom.hex'),'utf8').trim().split(/\s+/).map(x=>parseInt(x,16));let a=0x8b;const emit=(...b)=>b.forEach(x=>rom[a++]=x);emit(0xdb,0x41,0x32,0,0xc1,0xdb,0xbf,0x32,1,0xc1,0xc3,0x8b,0);
for(const ref of[1,0]){const dir=p.join(d,(ref?'reference_':'dut_')+'edges');fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p.join(dir,'rom.hex'),rom.map(x=>x.toString(16).padStart(2,'0')).join('\n')+'\n');fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gSLOTS=8 -gQUICK=1 -gTURBO=0 -gREQUEST_X=80 -gWARMUP=1 -gEXT_REFERENCE=1 -gREFERENCE=${ref} -gREPLAYS=3 -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}
console.log('Real T80 HCounter/HL edge replay and first-event restart witness prepared');
