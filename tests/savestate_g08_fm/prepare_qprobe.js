const fs=require('fs'),p=require('path'),d=__dirname;
let s=fs.readFileSync(p.join(d,'candidate_known_tb.sv'),'utf8');
s=s.replace(/\nendmodule\s*$/,`
integer qfd,qloads=0,qp,qe,qf,qt;
initial begin
 qfd=$fopen("perturbed_state.dat","w");
 forever begin
  @(posedge clk);#1;
  if(dut.state==59&&dut.flush_cnt==0&&!dut.do_save)begin
   qloads++;qp=0;qe=0;qf=0;qt=0;
   tick;audit_busy=1;
   for(integer row=0;row<104;row++)begin
    audit_addr=row;audit_read=1;tick;
    audit_expected=row[0]?mem['h2998+row/2][63:32]:mem['h2998+row/2][31:0];
    $fdisplay(qfd,"load%0d row%0d actual%08h saved%08h",qloads,row,fm_state_rdata,audit_expected);
    if(fm_state_rdata!==audit_expected)begin
     qt++;if(row>=13&&row<=30)qp++;if(row>=31&&row<=48)qe++;if(row>=49&&row<=57)qf++;
    end
    audit_read=0;tick;
   end
   audit_busy=0;
   $display("Q_STRENGTH load%0d total%0d phase%0d envelope%0d feedback%0d",qloads,qt,qp,qe,qf);
   if(qp==0||qe==0||qf==0)$fatal(1,"weak OPLL perturbation");
   wait(dut.state!=59);
  end
 end
end
endmodule
`);
fs.writeFileSync(p.join(d,'qprobe_tb.sv'),s);
fs.writeFileSync(p.join(d,'qprobe_compile.do'),fs.readFileSync(p.join(d,'candidate_known_compile.do'),'utf8').replaceAll('known_candidate_work','qprobe_work').replace('candidate_known_tb.sv','qprobe_tb.sv'));
fs.writeFileSync(p.join(d,'qprobe_run.do'),fs.readFileSync(p.join(d,'candidate_known_run.do'),'utf8').replaceAll('known_candidate_work','qprobe_work'));
let ps=fs.readFileSync(p.join(d,'known.ps1'),'utf8').replace('"known_$($Variant)_work"',"'qprobe_work'").replaceAll('$($Variant)_known_compile','qprobe_compile').replaceAll('$($Variant)_known_run','qprobe_run');fs.writeFileSync(p.join(d,'qprobe.ps1'),ps);
