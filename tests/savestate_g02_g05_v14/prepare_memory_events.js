const fs=require('fs'),p=require('path');
const base=__dirname,src=p.join(base,'ops'),dst=p.join(base,'memory_events');
fs.mkdirSync(dst,{recursive:true});
for(const f of ['header.svh','vdp_tb.sv','compile.do','T80_sim.vhd','T80s_sim.vhd','savestates_sim.sv'])fs.copyFileSync(p.join(src,f),p.join(dst,f));
fs.cpSync(p.join(src,'rtl'),p.join(dst,'rtl'),{recursive:true});
let v=fs.readFileSync(p.join(dst,'rtl/vdp.vhd'),'utf8');
v=v.replace(' audit: out',' audit_memory: out std_logic_vector(47 downto 0);\n audit: out');
v=v.replace(' audit <=',` audit_memory(23 downto 0) <= vram_portA_wren & vram_portA_address & vram_portA_data when vram_portA_wren='1' else (others=>'0');
 audit_memory(41 downto 24) <= '1' & ss_cram_A & ss_cram_D when ss_cram_wr='1' else cram_cpu_WE & cram_vdp_A_in & cram_vdp_D_in when cram_cpu_WE='1' else (others=>'0');
 audit_memory(47 downto 42) <= (others=>'0');
 audit <=`);
fs.writeFileSync(p.join(dst,'rtl/vdp.vhd'),v);
let t=fs.readFileSync(p.join(dst,'vdp_tb.sv'),'utf8');
t=t.replace('wire[135:0]refregs;','wire[47:0]audit_memory;wire[135:0]refregs;').replace('vdp1(.audit(audit),','vdp1(.audit_memory(audit_memory),.audit(audit),');
t=t.replace('io_count=0;release','io_count=0;if(!warming)memory_begin;release');
t=t.replace('if(REFERENCE)begin $fclose(f);','memory_finish;\n if(REFERENCE)begin $fclose(f);');
t=t.replace('for(n=0;n<12288;n++)if(mem[n]','memory_finish;\n  for(n=0;n<12288;n++)if(mem[n]');
t=t.replace('\nendmodule',`
// Read-only observer of the actual production RAM input ports. No feedback.
reg[7:0] memory_shadow[0:32767],memory_expected[0:32767];
reg[383:0] cram_shadow=0,cram_expected;
reg[47:0] expected_event[0:9999];
integer event_count=0,event_total=0,event_file,event_read,content_file;
reg memory_active=0;
always@(posedge clk)begin
 if(audit_memory[23]===1'b1)memory_shadow[audit_memory[22:8]]=audit_memory[7:0];
 if(audit_memory[41]===1'b1)cram_shadow[audit_memory[40:36]*12+:12]=audit_memory[35:24];
 if(memory_active&&(audit_memory[23]===1'b1||audit_memory[41]===1'b1))begin
  if($isunknown(audit_memory))$fatal(1,"unknown actual RAM write event");
  if(REFERENCE)$fdisplay(event_file,"%h",audit_memory);
  else if(event_count>=event_total||audit_memory!==expected_event[event_count])$fatal(1,"physical write event mismatch index%0d dut%h ref%h",event_count,audit_memory,expected_event[event_count]);
  event_count++;
 end
end
task memory_begin;begin
 event_count=0;
 if(REFERENCE)event_file=$fopen("reference_events.dat","w");
 else begin
  event_file=$fopen("reference_events.dat","r");if(!event_file)$fatal(1,"missing reference write events");event_total=0;
  while(!$feof(event_file))begin event_read=$fscanf(event_file,"%h\\n",expected_event[event_total]);if(event_read==1)event_total++;end
  $fclose(event_file);$readmemh("reference_memory.hex",memory_expected);
  content_file=$fopen("reference_cram.hex","r");event_read=$fscanf(content_file,"%h",cram_expected);$fclose(content_file);if(event_read!=1)$fatal(1,"missing CRAM reference");
 end
 memory_active=1;
end endtask
task memory_finish;begin
 memory_active=0;
 if(cram_shadow!==cram_out)$fatal(1,"CRAM shadow differs from actual production RAM");
 if(REFERENCE)begin
  $fclose(event_file);$writememh("reference_memory.hex",memory_shadow);
  content_file=$fopen("reference_cram.hex","w");$fdisplay(content_file,"%h",cram_out);$fclose(content_file);
 end else begin
  if(event_count!=event_total)$fatal(1,"missing physical write events %0d expected%0d",event_count,event_total);
  for(integer k=0;k<32768;k++)if($isunknown(memory_shadow[k])||memory_shadow[k]!==memory_expected[k])$fatal(1,"VRAM content differs at%h",k);
  if(cram_out!==cram_expected)$fatal(1,"actual CRAM content differs");
 end
 $display("MEMORY_CONTENTS events%0d VRAMbytes32768 CRAMentries32 reference%0d",event_count,REFERENCE);
end endtask
endmodule`);
fs.writeFileSync(p.join(dst,'vdp_tb.sv'),t);
for(const ref of [1,0]){
 const label=(ref?'reference_':'dut_')+'bus',target=p.join(dst,label);fs.mkdirSync(target,{recursive:true});
 fs.copyFileSync(p.join(src,(ref?'reference_':'dut_')+'cram_low','rom.hex'),p.join(target,'rom.hex'));
 let d=fs.readFileSync(p.join(src,(ref?'reference_':'dut_')+'cram_low','run.do'),'utf8');fs.writeFileSync(p.join(target,'run.do'),d);
}
