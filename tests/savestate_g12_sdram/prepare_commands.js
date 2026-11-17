const fs=require('fs'),p=require('path'),d=__dirname,src=p.join(d,'strict'),dst=p.join(d,'commands');fs.mkdirSync(dst,{recursive:true});
for(const f of ['audio_tb.sv','pin_model.sv','sdram.v','savestates_sim.sv','mapper_ctrl_sim.vhd','T80_sim.vhd','T80s_sim.vhd','pause_fixture.sv','jt89.v','rom.hex','compile.do'])fs.copyFileSync(p.join(src,f),p.join(dst,f));
let s=fs.readFileSync(p.join(dst,'audio_tb.sv'),'utf8');s=s.replace(/\nendmodule\s*$/,`
integer ddr_writes_by_word[0:12287],ddr_reads_by_word[0:12287];
initial for(integer n=0;n<12288;n++)begin ddr_writes_by_word[n]=0;ddr_reads_by_word[n]=0;end
always@(posedge ss_freeze)if(!dut.do_save)for(integer n=0;n<12288;n++)ddr_reads_by_word[n]=0;
always@(posedge clk)begin
 if(DDRAM_WE&&!DDRAM_BUSY)begin
  if(DDRAM_BURSTCNT!==1||((DDRAM_ADDR-29'h07c00000)>='h101&&(DDRAM_ADDR-29'h07c00000)<='h2900&&DDRAM_BE!==8'hff))$fatal(1,"payload command mask/burst contract");
  ddr_writes_by_word[DDRAM_ADDR-29'h07c00000]++;
 end
 if(DDRAM_RD&&!DDRAM_BUSY)ddr_reads_by_word[DDRAM_ADDR-29'h07c00000]++;
end
task check_range(input integer offset,input integer bytes,input integer owner,input integer basebyte);reg[7:0]expected;begin
 for(integer w=0;w<bytes/8;w++)begin
  if(ddr_writes_by_word[offset+w]!=1||(!dut.do_save&&ddr_reads_by_word[offset+w]!=1))$fatal(1,"duplicate/missing DDR command offset%h word%0d writes%0d reads%0d",offset,w,ddr_writes_by_word[offset+w],ddr_reads_by_word[offset+w]);
  for(integer b=0;b<8;b++)begin
   case(owner)0:expected=saved_ram[basebyte+w*8+b];1:expected=saved_v1[basebyte+w*8+b];2:expected=saved_v2[basebyte+w*8+b];endcase
   if(mem[offset+w][b*8+:8]!==expected)$fatal(1,"SAVE image transfer byte wrong owner%0d address%0d",owner,basebyte+w*8+b);
  end
 end
end endtask
always@(negedge ss_freeze)if(reset_n)begin
 check_range('h901,systeme?16384:8192,0,0);
 check_range('h101,16384,1,systeme?(BANKS[1]?16384:0):0);
 if(systeme)begin
  check_range('h1901,16384,1,BANKS[1]?0:16384);
  check_range('h1101,16384,2,BANKS[0]?16384:0);
  check_range('h2101,16384,2,BANKS[0]?0:16384);
 end
 $display("PASS DDR_COMMANDS save%b SystemE%b everyPayloadWordExactlyOnce imageBytesExact",dut.do_save,systeme);
end
endmodule
`);fs.writeFileSync(p.join(dst,'audio_tb.sv'),s);
fs.writeFileSync(p.join(dst,'cases.json'),JSON.stringify([
 {id:'ordinary_commands',args:{DUAL:3,BOOT:1200,N:4000,REPLAYS:1,TRANSFER:1,WAIT_WINDOW:1,PATTERN:5,STALL:2,LATENCY:29}},
 {id:'systeme_commands',args:{DUAL:0,BOOT:1200,N:4000,REPLAYS:1,TRANSFER:1,WAIT_WINDOW:1,PATTERN:5,BANKS:2,STALL:3,LATENCY:29}}
],null,2)+'\n');console.log('Prepared independent exact payload-command/image-byte fixture');
