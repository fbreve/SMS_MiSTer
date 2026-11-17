const fs=require('fs'),p=require('path'),d=p.join(__dirname,'g04_native'),src=p.join(__dirname,'g04');fs.mkdirSync(d,{recursive:true});
for(const f of ['header.svh','savestates_sim.sv','T80_sim.vhd','T80s_sim.vhd','compile.do'])fs.copyFileSync(p.join(src,f),p.join(d,f));fs.cpSync(p.join(src,'rtl'),p.join(d,'rtl'),{recursive:true});
let s=fs.readFileSync(p.join(src,'vdp_tb.sv'),'utf8');
s=s.replace('reg scoring=0;','reg scoring=0;reg native_done=0;');
s=s.replace('$display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);','$display("REQUEST x%0d y%0d regs%h",x,y,vdp_regs);request(1);fork native_score;join_none');
s=s.replace('request(0);divs=0;guestdiv=0;','request(0);fork native_score;join_none divs=0;guestdiv=0;');
s=s.replace(' if(REFERENCE)begin $fclose(f);',' wait(native_done);\n if(REFERENCE)begin $fclose(f);');
s=s.replace('  for(n=0;n<12288;n++)if(mem[n]!==image_saved[n])','  wait(native_done);\n  for(n=0;n<12288;n++)if(mem[n]!==image_saved[n])');
s=s.replace(/\nendmodule\s*$/,`
task native_score;integer nf,k,n;reg[8:0]nx,ny;reg[135:0]nr;reg[15:0]na;reg[229:0]nc;reg[7:0]nm;bit seen_vdp;begin
 native_done=0;seen_vdp=0;nf=$fopen("native_reference.dat",REFERENCE?"w":"r");if(!nf)$fatal(1,"missing native reference");
 for(k=0;k<10000;k++)begin @(posedge clk);#1;
  if($isunknown({x,y,vdp_regs,audit[31:16],z80_reg,ram[256]}))$fatal(1,"unknown native G04 observation");
  if(ce_vdp)seen_vdp=1;
  if(REFERENCE)$fdisplay(nf,"%h %h %h %h %h %h",x,y,vdp_regs,audit[31:16],z80_reg,ram[256]);
  else begin n=$fscanf(nf,"%h %h %h %h %h %h\\n",nx,ny,nr,na,nc,nm);
   if(n!=6||{x,y,vdp_regs,audit[31:17],z80_reg,ram[256]}!=={nx,ny,nr,na[15:1],nc,nm})$fatal(1,"native G04 collision/IRQ/CPU/RAM mismatch host%0d",k);
   if(seen_vdp&&audit[16]!==na[0])$fatal(1,"last_x0 did not converge on first VDP enable");
  end
 end
 $fclose(nf);native_done=1;$display("PASS G04_NATIVE hostclocks10000 shift14 IRQ CPU230 VDP136 RAM lastXafterFirstVDP");
end endtask
endmodule
`);fs.writeFileSync(p.join(d,'vdp_tb.sv'),s);
for(const ref of[1,0]){const dir=p.join(d,(ref?'reference_':'dut_')+'pending');fs.mkdirSync(dir,{recursive:true});fs.copyFileSync(p.join(src,'reference_pending64/rom.hex'),p.join(dir,'rom.hex'));fs.writeFileSync(p.join(dir,'run.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gSLOTS=8 -gGG=1 -gREQUEST_Y=168 -gREQUEST_X=120 -gWARMUP=1 -gEXT_REFERENCE=1 -gREFERENCE=${ref} -gREPLAYS=3 -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}
console.log('Every-host-clock collision-delay/IRQ/CPU oracle prepared');
