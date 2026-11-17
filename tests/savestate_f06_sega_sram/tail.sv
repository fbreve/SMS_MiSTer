reg mapper_reset_n=0; reg[15:0]a=0;reg[7:0]di=0;reg wr=1,mreq=1;
wire en,ext,bank,cme,we;wire[7:0]q,b0,b1,b2,b3,pak,nem;
wire[14:0]pa={bank & ~a[14],a[13:0]};
// Exact ordinary-Sega slice of system.vhd mapper_out (non-Sega flags zero).
assign mapper_out={10'd0,cme,bank,ext,en,2'd0,nem,pak,b3,b2,b1,b0};
__MAPPER__
memory_bus bus(.A(a),.sc3000_en(1'b0),.sc_cart_ram(2'd0),.mapper_castle(1'b0),.sc_multicart_en(1'b0),.WR_n(wr),.RD_n(1'b0),.MREQ_n(mreq),.ss_freeze(ss_freeze),.mapper_eeprom(1'b0),.nvram_e(en),.nvram_ex(ext),.nvram_cme(cme),.dahjee_cart_access(1'b0),.eeprom_bus_active(1'b0),.eeprom_D_out(8'd0),.nvram_D_out(nvram_D),.ram_D_out(8'h66),.irom_D_out(8'h99),.ram_WR(),.rom_RD(),.nvram_WR(we),.memory_D_out(q));
dpram #(.widthad_a(15),.init_file("../../rtl/nvram_ff.mif")) ram(.clock_a(clk),.address_a(ss_freeze?(nvram_WE?nvram_WA:nvram_A):pa),.data_a(ss_freeze?nvram_WD:di),.wren_a(ss_freeze?nvram_WE:we),.q_a(nvram_D),.clock_b(clk),.address_b(15'd0),.data_b(8'd0),.wren_b(1'b0),.q_b());
task put(input[15:0]addr,input[7:0]value);begin a=addr;di=value;mreq=0;wr=0;repeat(2)tick;wr=1;mreq=1;tick;end endtask
task control(input[7:0]v);begin put(16'hfffc,v);end endtask
task readbank(input bit upper,input[7:0]expected);begin control(upper?8'h0c:8'h08);a=16'h8000;mreq=0;repeat(3)tick;if(q!==expected)$fatal(1,"read bank%0d got%h expected%h",upper,q,expected);mreq=1;end endtask
task fill(input[7:0]lo,hi);begin
 control(8'h08);for(integer j=0;j<16384;j++)put(16'h8000+j,lo);
 control(8'h0c);for(integer j=0;j<16384;j++)put(16'h8000+j,hi);control(0);
end endtask
integer payload=0;always@(posedge clk)if(DDRAM_WE&&!DDRAM_BUSY&&DDRAM_ADDR>=29'h07c00d01&&DDRAM_ADDR<=29'h07c01d00)payload++;
task saveimage;begin payload=0;transfer(1);for(integer j=0;j<12288;j++)if((^mem[j])===1'bx)$fatal(1,"unknown image %h",j);end endtask
integer fd;task dump(input string name);begin fd=$fopen(name,"wb");for(integer j=0;j<12288;j++)for(integer b=0;b<8;b++)$fwrite(fd,"%c",mem[j][8*b+:8]);$fclose(fd);end endtask
integer mode,expected_words,divergent;
initial begin
 for(integer j=0;j<12288;j++)mem[j]=0;
 repeat(4)tick;reset_n=1;mapper_reset_n=1;repeat(4)tick;
 // Real guest writes create both histories; no direct RAM pokes.
 for(mode=0;mode<11;mode++)begin
  fill(8'h31,8'h72);
  if(mode==8||mode==9||mode==10)begin mapper_reset_n=0;repeat(4)tick;mapper_reset_n=1;repeat(4)tick;end
  // J/K are the cartridge-load reset effect; actual host lifecycle tested separately.
  case(mode)
   0,2,4,7:control(8'h08);
   3:control(8'h0c);
   5:control(8'h18);
   default:control(0);
  endcase
  a=0;di=0;repeat(4)tick;
  expected_words=(mode==0||mode==2||mode==4||mode==7)?2048:(mode==3||mode==5)?4096:0;
  saveimage;if(payload!=expected_words)$fatal(1,"case%0d words%0d expected%0d",mode,payload,expected_words);
  fill(8'ha1,8'hb2);transfer(0);
  readbank(0,expected_words>0?8'h31:8'ha1);
  readbank(1,expected_words==4096?8'h72:8'hb2);
  $display("PASS witness %0d captured_bytes=%0d bank0_exact=%0d bank1_exact=%0d",mode,payload*8,expected_words>0,expected_words==4096);
 end
 // Smallest collision: one byte differs; all other physical bytes and complete
 // current payload inputs agree after real mapper reset. Both images start zero.
 fill(8'h31,8'h72);control(8'h08);put(16'h8000,8'h41);control(0);
 a=0;di=0;repeat(4)tick;for(integer j=0;j<12288;j++)mem[j]=0;
 saveimage;for(integer j=0;j<12288;j++)saved_image[j]=mem[j];dump("pair_a.bin");
 readbank(0,8'h41);control(8'h08);put(16'h8000,8'h42);control(0);
 a=0;di=0;repeat(4)tick;for(integer j=0;j<12288;j++)mem[j]=0;
 saveimage;for(integer j=0;j<12288;j++)if(mem[j]!==saved_image[j])$fatal(1,"noninjective image differs word%h",j);
 dump("pair_b.bin");readbank(0,8'h42);
 $display("PASS NONINJECTIVE full98304bytes one_retained_byte future41_vs42");
 $display("PASS SRAM COMPLETE");$finish;
end
initial begin #200000000;$fatal(1,"watchdog state%0d",dut.state);end
endmodule

