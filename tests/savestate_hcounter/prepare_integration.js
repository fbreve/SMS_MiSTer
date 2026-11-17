const fs=require('fs'),path=require('path');const dir=__dirname,root=path.resolve(dir,'../..');
let s=fs.readFileSync(path.join(dir,'controller_tb.sv'),'utf8');
s=s.replace('module controller_tb;','module integration_tb;');
for(const n of ['vdp_regs','vdp2_regs'])s=s.replace(new RegExp('reg (\\[135:0\\]\\s*)'+n+" = '0;"),'wire $1'+n+';');
const entity=fs.readFileSync(path.join(root,'rtl/vdp.vhd'),'utf8').split('architecture')[0];
const ports=[...entity.matchAll(/\b(\w+)\s*:\s*(in|out)\s+(STD_LOGIC(?:_VECTOR\s*\([^)]*\))?)/gi)];
function vdp(i){const o={clk_sys:'clk',reset_n:'reset_n',ce_vdp:'io_ce',hl:'hl'+i,x:'x'+i,y:"9'd200",rd_n:'io_rd',wr_n:"1'b1",a:"8'h41",d_out:'hdata'+i,ss_regs_out:i===1?'vdp_regs':'vdp2_regs',ss_regs_in:i===1?'vdp_regs_in':'vdp2_regs_in',ss_regs_set:i===1?'vdp_regs_set':'vdp2_regs_set',se_bank:i===1?"1'b0":"1'b1"};
return 'vdp vdp'+i+'('+ports.map(m=>{const range=m[3].match(/\((\d+)\s+downto\s+(\d+)\)/i);const width=range?Number(range[1])-Number(range[2])+1:1;return '.'+m[1]+'('+(o[m[1].toLowerCase()]??(m[2].toLowerCase()==='out'?'':width+"'b0"))+')';}).join(',')+');';}
s=s.replace('always #5 clk=~clk;',`always #5 clk=~clk;
reg hl1=0,hl2=0,io_ce=0,io_rd=1;reg [8:0]x1=0,x2=0;wire [7:0]hdata1,hdata2;
${vdp(1)}
${vdp(2)}
task latch_both(input [8:0]a,b);begin hl1=0;hl2=0;tick;x1=a;x2=b;hl1=1;hl2=1;tick;hl1=0;hl2=0;tick;end endtask
task check_guest(input [7:0]a,b);begin io_ce=1;io_rd=1;tick;io_rd=0;tick;
if(hdata1!==a||hdata2!==b)$fatal(1,"Guest HCounter H1=%h H2=%h expected %h %h",hdata1,hdata2,a,b);
io_rd=1;tick;io_ce=0;end endtask`);
s=s.replace('for(testno=0;testno<10;testno=testno+1)','for(testno=1;testno<3;testno=testno+1)');
s=s.replace(/  vdp_regs=\{[^;]+;\n  vdp2_regs=\{[^;]+;/,'  latch_both(180,330);check_guest(8\'h5a,8\'ha5);');
s=s.replace("  vdp_regs='1;vdp2_regs='1;restored=0;seen1='x;seen2='x;","  latch_both(24,48);check_guest(8'h0c,8'h18);restored=0;seen1='x;seen2='x;");
s=s.replace(/^  if\(seen1\[127:0\].*\n/m,'').replace(/^  if\(systeme&&seen2\[127:0\].*\n/m,'');
s=s.replace('  $display("PASS controller case',"  check_guest((testno==1)?8'h5a:8'h00,(testno==1)?8'ha5:8'h00);\n  latch_both(510,256);check_guest(8'hff,8'h80);\n  $display(\"PASS integrated dual VDP case");
s=s.replace('$display("PASS controller: modern SMS/System E plus previous96K, random padding, unknown version, invalid reserved, old64K")','$display("PASS integrated System E: two real VDPs -> DDRAM -> restore -> guest HCounter, modern and legacy96K")');
fs.writeFileSync(path.join(dir,'integration_tb.sv'),s);
fs.writeFileSync(path.join(dir,'integration.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vcom -2008 -quiet ../../rtl/dpram.vhd ../../rtl/vdp_cram.vhd ../../rtl/vdp_background.vhd ../../rtl/vdp_sprite_shifter.vhd ../../rtl/vdp_sprites.vhd ../../rtl/vdp_main.vhd ../../rtl/vdp.vhd
vlog -sv -quiet savestates_sim.sv integration_tb.sv
vsim -c -t 1ps -L altera_mf work.integration_tb -g/integration_tb/vdp1/vdp_vram_inst/init_file=UNUSED -g/integration_tb/vdp2/vdp_vram_inst/init_file=UNUSED
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
`);
