const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..'),adapter=require('../savestate_g06_g10_fix/controller_adapter');
const specs=[
 ['g03','savestate_g05_background_fix/integrated_g03',['dut_bus']],
 ['g02','savestate_g05_background_fix/integrated_g02',['dut_active']],
 ['g04','savestate_f01_opll_fix/reg_g04',['dut_pending']],
 ['g10','savestate_f01_opll_fix/reg_g10',['dut_phases','dut_deterministic','dut_full_flush']],
 ['dual','savestate_f01_opll_fix/reg_dual',['dut_collision']],
 ['g05','savestate_g05_background_fix/integrated_rich',['dut_mode4','dut_gg','dut_graphics1','dut_graphics2','dut_text','dut_mixed_m3','dut_scroll','dut_sms224','dut_pal240']]
];
const rows=[],sha=b=>crypto.createHash('sha256').update(b).digest('hex');
for(const [family,rel,cases]of specs){
 const src=p.join(root,'tests',rel),dst=p.join(d,'native_'+family);fs.mkdirSync(dst,{recursive:true});
 for(const name of fs.readdirSync(src)){const q=p.join(src,name);if(fs.statSync(q).isFile()&&/\.(sv|svh|vhd|v|do|hex)$/.test(name))fs.copyFileSync(q,p.join(dst,name));}
 fs.cpSync(p.join(src,'rtl'),p.join(dst,'rtl'),{recursive:true});
 // Preserve the original test-only read-only audit ports; change only CRAM
 // access exactly as production, adding a combinational simulation RAM tap.
 let vd=fs.readFileSync(p.join(dst,'rtl/vdp.vhd'),'utf8');
 assert(vd.includes('ss_cram_out    : out STD_LOGIC_VECTOR(383 downto 0);'));
 vd=vd.replace('ss_cram_out    : out STD_LOGIC_VECTOR(383 downto 0);',"ss_cram_out    : out STD_LOGIC_VECTOR(11 downto 0);\n ss_cram_read:in std_logic:='0';\n ss_cram_debug_out:out std_logic_vector(383 downto 0);");
 vd=vd.replace('ss_D             => ss_cram_out,','ss_Q             => ss_cram_out,ss_rd=>ss_cram_read,ss_debug_out=>ss_cram_debug_out,');
 fs.writeFileSync(p.join(dst,'rtl/vdp.vhd'),vd);
 let cm=fs.readFileSync(p.join(root,'rtl/vdp_cram.vhd'),'utf8');
 cm=cm.replace('ss_rd:in std_logic;', 'ss_debug_out:out std_logic_vector(383 downto 0);ss_rd:in std_logic;');
 cm=cm.replace('begin\n addr_a',"begin\n debug_tap:for i in 0 to 31 generate ss_debug_out(12*i+11 downto 12*i)<=ram(i);end generate;\n addr_a");
 fs.writeFileSync(p.join(dst,'rtl/vdp_cram.vhd'),cm);
 fs.writeFileSync(p.join(dst,'savestates_sim.sv'),adapter(p.join(root,'rtl/savestates.sv')));
 for(const name of fs.readdirSync(dst).filter(x=>/\.(sv|svh)$/.test(x)&&x!=='savestates_sim.sv')){
  const file=p.join(dst,name);let s=fs.readFileSync(file,'utf8');
  if(s.includes('wire [383:0] cram_out;'))s=s.replace('wire [383:0] cram_out;','wire [383:0] cram_out;wire cram_scan;wire[11:0]cram_serial,cram2_serial;');
  if(/savestates\s+dut\(/.test(s)){
   let pins=".cram_read(cram_scan),";if(!s.includes('.fm_initialized('))pins+=".fm_initialized(1'b1),.fm_state_rdata(32'd0),";
   if(!s.includes('.audio_last_out('))pins+=".audio_last_out(16'd0),";
   s=s.replace(/savestates\s+dut\(/,'savestates dut('+pins);
  }
  s=s.replace(/\.cram_out\(cram_out\)/g,'.cram_out(cram_serial)').replace(/\.cram2_out\(cram2_out\)/g,'.cram2_out(cram2_serial)');
  s=s.replace(/\.ss_cram_out\(cram_out\)/g,'.ss_cram_out(cram_serial),.ss_cram_read(cram_scan),.ss_cram_debug_out(cram_out)');
  s=s.replace(/\.ss_cram_out\(cram2_out\)/g,'.ss_cram_out(cram2_serial),.ss_cram_read(cram_scan),.ss_cram_debug_out(cram2_out)');
  s=s.replace("mem[26][63:40]=24'h48430d;","mem[26][63:40]=24'h48430d;mem[32][39:32]=8'd1;mem[34][63:32]=0;");
  if(name==='vdp_tb.sv'){
   const at=s.lastIndexOf('endmodule');assert(at>=0);
   const secondary=s.includes(' vdp2(');
   const monitor=`\nreg[383:0]cram_at_arm,cram2_at_arm;reg cram_monitor_active=0;integer cram_scans_checked=0;\nalways @(posedge clk)begin
 if(reset_n && dut.state==41 && dut.do_save)begin
  cram_at_arm=cram_out;${secondary?'cram2_at_arm=cram2_out;':''}cram_monitor_active=1;
 end
 if(cram_monitor_active && cram_scan && (vdp1.cram_cpu_WE!==1'b0 ${secondary?"||vdp2.cram_cpu_WE!==1'b0":''}))$fatal(1,"CPU palette write during snapshot ownership");
 if(cram_monitor_active && dut.state==1)begin
  if(dut.cram_snap!==cram_at_arm)$fatal(1,"primary scan differs from ARM snapshot");
  ${secondary?'if(dut.cram2_snap!==cram2_at_arm)$fatal(1,"secondary scan differs from ARM snapshot");':''}
  cram_scans_checked++;cram_monitor_active=0;$display("PASS CRAM NATIVE SNAPSHOT bothOwners%0d",${secondary?2:1});
 end
end\n`;
   // ST_FREEZE is 1 in the original controller's localparam map.
   s=s.slice(0,at)+monitor+s.slice(at);
  }
  if(family==='g10')s=s.replace('always@(posedge cpu_prepare)if(NATURAL_PHASE)begin','always@(posedge cpu_prepare)if(NATURAL_PHASE&&!warming)begin');
  fs.writeFileSync(file,s);
 }
 let compile=fs.readFileSync(p.join(dst,'compile.do'),'utf8').replace('../../../rtl/vdp_cram.vhd','rtl/vdp_cram.vhd');
 if(!compile.includes('opll_snapshot.sv'))compile=compile.replace('savestates_sim.sv','../../../rtl/opll_snapshot.sv savestates_sim.sv');
 fs.writeFileSync(p.join(dst,'compile.do'),compile);
 for(const name of cases){const from=p.join(src,name),to=p.join(dst,name);assert(fs.existsSync(from),from);fs.mkdirSync(to,{recursive:true});let fixtures=[];
  for(const f of fs.readdirSync(from))if(f==='run.do'||/\.(dat|hex|bin)$/.test(f)){fs.copyFileSync(p.join(from,f),p.join(to,f));fixtures.push({file:f,sha256:sha(fs.readFileSync(p.join(from,f)))});}
  rows.push({family,name,dir:p.relative(root,to).replaceAll('\\','/'),fixtures,marker:family==='g05'?'PASS RICH V15 VDP':'PASS V15 VDP'});
 }
}
fs.writeFileSync(p.join(d,'native_manifest.json'),JSON.stringify(rows,null,2)+'\n');console.log('Prepared '+rows.length+' native cases with actual serial palette data and simulation-only full RAM observation.');
