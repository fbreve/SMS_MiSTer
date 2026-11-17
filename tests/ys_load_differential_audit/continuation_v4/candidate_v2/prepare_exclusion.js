// Compare every public controller output when full SRAM is excluded.
const fs=require('fs'),assert=require('assert');
let base=fs.readFileSync('transport_tb.sv','utf8');
base=base.replace('module transport_tb;','module exclusion_case(output reg done=0,output wire[2047:0]observed);');
base=base.replace('parameter CANDIDATE=2,FORMAT_CASE=0,MAP_MODE=0,ELIGIBLE=1,CLASS=2;',
 'parameter CANDIDATE=0,SYSTEM_E=1,ELIGIBLE=1;\nlocalparam MAP_MODE=0,CLASS=0,FORMAT_CASE=0;');
base=base.replace('`include "controller.svh"','`include "exclusion_controller.svh"');
const hdr=fs.readFileSync('savestates_probe.sv','utf8').split('\n);')[0].replace(/\/\/[^\n]*/g,'');
const ports=[...hdr.matchAll(/\boutput(?:\s+reg)?\s*(\[[^\]]+\])?\s*(\w+)/g)];
const outputs=ports.map(m=>m[2]);
const bits=ports.reduce((sum,m)=>{if(!m[1])return sum+1;const r=m[1].match(/\[(\d+)\s*:\s*(\d+)\]/);assert(r);return sum+Number(r[1])-Number(r[2])+1;},0);
assert(bits<=2048,'observation vector would truncate outputs');
fs.writeFileSync('exclusion_observation.json',JSON.stringify({outputPorts:outputs.length,bits,observationWidth:2048,outputs},null,2)+'\n');
assert(outputs.length>40);
base=base.replace('integer expected_save_bytes,expected_load_bytes,mismatches=0;bit full_expected,reject_expected;',
 'assign observed={'+outputs.map(n=>'ss_'+n).join(',')+'};');
const start=base.indexOf('initial begin\n for(integer n=0;n<12288;'),end=base.indexOf('initial begin #100000000;');assert(start>0&&end>start);
base=base.slice(0,start)+`initial begin
 for(integer n=0;n<12288;n++)ddr[n]=0;
 for(integer n=0;n<32768;n++)begin vm[n]=pattern(n,0);sm[n]=pattern(n,2);end
 for(integer n=0;n<8192;n++)wm[n]=pattern(n,1);
 repeat(8)tick;reset_n=1;op(1);
 if(ddr[5][63:38]!==0)$fatal(1,"excluded save changed always-written metadata");
 reset_n=0;repeat(8)tick;reset_n=1;
 op(0);
 if(error_seen||restores!=1||sram_writes!=0)$fatal(1,"excluded operation failed or touched SRAM");
 done=1;
end
`+base.slice(end);
base+=`\nmodule exclusion_tb;
parameter SYSTEM_E=1,ELIGIBLE=1;
wire da,db;wire[2047:0]a,b;
exclusion_case #(.CANDIDATE(0),.SYSTEM_E(SYSTEM_E),.ELIGIBLE(ELIGIBLE))baseline(da,a);
exclusion_case #(.CANDIDATE(2),.SYSTEM_E(SYSTEM_E),.ELIGIBLE(ELIGIBLE))candidate(db,b);
always @(negedge baseline.clk)begin #1;if(a!==b)$fatal(1,"excluded outputs diverged baseline=%h candidate=%h",a,b);end
initial begin wait(da&&db);$display("PASS EXCLUSION all public outputs cycle-equal across SAVE/reset/LOAD SystemE=%0d eligible=%0d",SYSTEM_E,ELIGIBLE);$finish;end
endmodule
`;
fs.writeFileSync('exclusion_tb.sv',base);
const inc=fs.readFileSync('controller.svh','utf8').replace("assign ss_systeme='0;",'assign ss_systeme=SYSTEM_E;').replace("assign ss_eeprom_out='0;","assign ss_eeprom_out=64'hfedcba9876543210;");
fs.writeFileSync('exclusion_controller.svh',inc);
fs.writeFileSync('exclusion.do',`onerror {quit -code 1}
vlog -sv -quiet exclusion_tb.sv
vsim -c work.exclusion_tb -gSYSTEM_E=$env(YS_SYSTEM_E) -gELIGIBLE=$env(YS_ELIGIBLE)
run -all
quit -code 0
`);
