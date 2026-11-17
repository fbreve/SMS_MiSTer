const fs=require('fs'),p=require('path'),assert=require('assert');const old=p.resolve(__dirname,'../ys_load_differential_audit/continuation_v4/candidate_v2');
let s=fs.readFileSync(p.join(old,'transport_tb.sv'),'utf8');
function sub(a,b){assert(s.includes(a),a.slice(0,70));s=s.replace(a,b);}
sub("ss_DDRAM_ADDR==29'h7c00005 && ss_DDRAM_DIN[43]","ss_DDRAM_ADDR==29'h7c0000e && ss_DDRAM_DIN[63] && full_expected");
const start=s.indexOf(' if((CANDIDATE&1)!=0||full_expected)'),end=s.indexOf(' if(full_expected)for',start);assert(start>0&&end>start);
s=s.slice(0,start)+` if(ddr[5][63:38]!==0)$fatal(1,"CPU context unexpectedly changed");
 if(ddr['h1a][63:40] !== (full_expected?24'h484314:24'h484311))$fatal(1,"FM/SRAM marker mismatch");
 if(ddr[14][63]!==1||ddr['h2997]!==64'h00640101464d5331)$fatal(1,"missing committed audio/FM descriptors");
`+s.slice(end);
const cs=s.indexOf(' case(FORMAT_CASE)'),ce=s.indexOf(' endcase',cs)+8;assert(cs>0&&ce>cs);
s=s.slice(0,cs)+` case(FORMAT_CASE)
 1:ddr['h1a][63:40]=24'h484311; // Valid older FM image: stale tail must not imply full SRAM.
 2:ddr['h1a][22]=1;
 3:ddr['h2997][0]=!ddr['h2997][0];
 4:ddr['h2998][31]=1;
 5:ddr['h20][39:32]=2;
 6:ddr['h29bf][6:0]=127; // Invalid FM slot counter, word78.
 7:begin if(!ELIGIBLE)ddr['h1a][63:40]=24'h484314;else ddr['h2997][47:40]=2;end
 8:begin ddr[0][63:32]=16382;ddr[14][63:56]=0;end
 endcase`+s.slice(ce);
const a=s.indexOf('  if((CANDIDATE&1)!=0&&FORMAT_CASE==0)'),b=s.indexOf('\n end\n $display',a);assert(a>0&&b>a);s=s.slice(0,a)+'  if(ss_restart_valid)$fatal(1,"CPU correction unexpectedly enabled");'+s.slice(b);
fs.writeFileSync(p.join(__dirname,'transport_tb.sv'),s,{flag:'wx'});
fs.writeFileSync(p.join(__dirname,'compile_transport.do'),'onerror {quit -code 1}\nvlog -sv -quiet transport_tb.sv\nquit -code 0\n',{flag:'wx'});
let runner=fs.readFileSync(p.join(old,'run_transport.js'),'utf8');runner=runner.replace("const tag=process.argv[2]||'';","const tag=process.argv[2]||'';");
const pos=runner.indexOf('const results=[];');assert(pos>0);runner=runner.slice(0,pos)+`for(const candidate of [2,3])for(const format of [1,8])for(const map of [1,2])add(candidate,format,map);
`+runner.slice(pos);
runner=runner.replace("scope:'Controller transport/metadata only, not a Ys graphics result'","scope:'51 ported controller cases; CPU-context fixtures are inert and malformed experimental CPU metadata cases are replaced by FM/SRAM format-validation cases. Not the unmodified old CPU-format test.'");
fs.writeFileSync(p.join(__dirname,'run_transport.js'),runner,{flag:'wx'});
console.log('Prepared 51-case matrix against production FM/SRAM format; CPU predecessor mechanisms absent.');
