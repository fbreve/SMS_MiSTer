const fs=require('fs'),p=require('path'),d=__dirname;
// Preserve and adapt the existing local continuation regression; no experimental RTL.
const fixture=p.join(d,'phase_fixture.vhd');
let s=fs.readFileSync(fixture,'utf8').replace(/original_work/g,'reference_work').replace(/local_work/g,'candidate_work');
s=s.replace('ic_n=>reset_n,mixout=>ry);','ic_n=>reset_n,mixout=>ry,ss_rdata=>open,ss_initialized=>open);');
// A local watchdog complements the test runner's process exit/PASS checks.
s=s.replace('begin\n clk<=',`begin
 process begin wait for 20 ms;assert false report "PHASE TIMEOUT" severity failure;end process;
 clk<=`);
s=s.replace(' type memory is'," signal completed:std_logic:='0';\n type memory is");
s=s.replace('report "PASS LOCAL ALL";std.env.finish;', 'completed<=\'1\';wait for 1 ns;report "PASS LOCAL ALL";std.env.finish;');
fs.writeFileSync(p.join(d,'phase_tb.vhd'),s);
fs.writeFileSync(p.join(d,'phase_compile.do'),`onerror {quit -code 1}
vcom -2008 -quiet -work candidate_work phase_tb.vhd
quit -code 0
`);
fs.writeFileSync(p.join(d,'phases.do'),`onerror {quit -code 1}
onbreak {}
for {set shift 0} {$shift<72} {incr shift} {
 vsim -onfinish stop -t 1ps candidate_work.phase_tb -gSHIFT=$shift -gSTALL=3 -gNCE=200 -gLOADS=3
 set NumericStdNoWarnings 1
 set StdArithNoWarnings 1
 run -all
 if {[examine /phase_tb/completed]!=1} {error "incomplete phase $shift"}
 quit -sim
}
echo "PASS PHASE SWEEP ALL 72 offsets SAVE and three LOAD continuations"
quit -code 0
`);
