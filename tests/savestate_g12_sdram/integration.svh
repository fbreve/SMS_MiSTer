wire[7:0]sd,rsd,cdi,rdi;wire rd,rrd_mem;wire[21:0]mapped,rmapped;wire[24:0]phys={3'd0,mapped},rphys={3'd0,rmapped};
memory_decode decoder(.gg(1'b0),.mapper_evolution(1'b0),.gg_bios_en(1'b0),.bios_en(1'b0),.ext_bios_sel(1'b0),.ext_bios_loaded(1'b0),.dbr(1'b1),.bootloader_n(1'b1),.ext_gg_bios_loaded(1'b0),.mapper_dahjee_a(1'b0),.use_zem(1'b0),.mapper_4pak(1'b0),.mapper_codies(1'b0),.systeme(systeme),.sc3000_en(1'b0),.sc_multicart_en(1'b0),.mapper_linear(1'b0),.mapper_janggun(1'b0),.A(ca),.media_control(3'b0),.bank0(8'd0),.bank1(ROMBANK[7:0]),.bank2(8'd255),.bank3(8'd3),.nem_bank0(8'd0),.rom_bank(ROMBANK[3:0]),.sc_multicart_page(7'd0),.jang_bank1(6'd0),.jang_bank2(6'd0),.jang_bank3(6'd0),.jang_bank4(6'd0),.cart_precedence_out(),.cart_memory_selected_out(),.dahjee_cart_access_out(),.rom_a_i_out(mapped));
memory_decode rdecoder(.gg(1'b0),.mapper_evolution(1'b0),.gg_bios_en(1'b0),.bios_en(1'b0),.ext_bios_sel(1'b0),.ext_bios_loaded(1'b0),.dbr(1'b1),.bootloader_n(1'b1),.ext_gg_bios_loaded(1'b0),.mapper_dahjee_a(1'b0),.use_zem(1'b0),.mapper_4pak(1'b0),.mapper_codies(1'b0),.systeme(systeme),.sc3000_en(1'b0),.sc_multicart_en(1'b0),.mapper_linear(1'b0),.mapper_janggun(1'b0),.A(ra),.media_control(3'b0),.bank0(8'd0),.bank1(ROMBANK[7:0]),.bank2(8'd255),.bank3(8'd3),.nem_bank0(8'd0),.rom_bank(ROMBANK[3:0]),.sc_multicart_page(7'd0),.jang_bank1(6'd0),.jang_bank2(6'd0),.jang_bank3(6'd0),.jang_bank4(6'd0),.cart_precedence_out(),.cart_memory_selected_out(),.dahjee_cart_access_out(),.rom_a_i_out(rmapped));
tri[15:0]dq,rdq;wire[12:0]sa,rsa;wire[1:0]sb,rsb;wire sc,sras,scas,swe,rsc,rras,rcas,rswe;wire ready,rready;
sdram live(.SDRAM_DQ(dq),.SDRAM_A(sa),.SDRAM_BA(sb),.SDRAM_nCS(sc),.SDRAM_nRAS(sras),.SDRAM_nCAS(scas),.SDRAM_nWE(swe),.init(1'b0),.clk(clk),.clkref(cpu_ce),.raddr(phys),.rd(rd),.rd_rdy(ready),.dout(sd),.waddr(25'd0),.din(8'd0),.we(1'b0),.we_ack());
sdram reference_live(.SDRAM_DQ(rdq),.SDRAM_A(rsa),.SDRAM_BA(rsb),.SDRAM_nCS(rsc),.SDRAM_nRAS(rras),.SDRAM_nCAS(rcas),.SDRAM_nWE(rswe),.init(1'b0),.clk(clk),.clkref((DUAL==3||DUAL==5)?rce_cpu:rce_pix),.raddr(rphys),.rd(rrd_mem),.rd_rdy(rready),.dout(rsd),.waddr(25'd0),.din(8'd0),.we(1'b0),.we_ack());
pin_model #(.TAC(TAC),.SYSTEME(DUAL<3),.CACHEHISTORY(CACHEHISTORY)) chip(clk,sa,sb,sc,sras,scas,swe,dq),rchip(clk,rsa,rsb,rsc,rras,rcas,rswe,rdq);
wire rw,nw,rrw,rnw;reg[7:0]ram_bytes[0:16383],ref_bytes[0:16383];reg[7:0]ram_q=0,ref_q=0;
initial begin
for(integer b=0;b<16384;b++)begin ram_bytes[b]=(b*73)^(b>>5)^8'hd9;ref_bytes[b]=ram_bytes[b];end
if(CACHEHISTORY)begin
 // IN A,(7c); ADD A,40; LD H,A; LD L,fd; LD A,(HL).
 // Erase the distinct input/read history, then execute a fixed RAM-only loop.
 ram_bytes[0]=8'hdb;ram_bytes[1]=8'h7c;ram_bytes[2]=8'hc6;ram_bytes[3]=8'h40;ram_bytes[4]=8'h67;ram_bytes[5]=8'h2e;ram_bytes[6]=8'hfd;ram_bytes[7]=8'h7e;
 ram_bytes[8]=8'haf;ram_bytes[9]=8'h01;ram_bytes[10]=0;ram_bytes[11]=0;ram_bytes[12]=8'h11;ram_bytes[13]=0;ram_bytes[14]=0;ram_bytes[15]=8'h21;ram_bytes[16]=0;ram_bytes[17]=0;
 ram_bytes[18]=8'hc3;ram_bytes[19]=8'h20;ram_bytes[20]=8'hc0;
 ram_bytes[32]=8'h00;ram_bytes[33]=8'hc3;ram_bytes[34]=8'h20;ram_bytes[35]=8'hc0;
 for(integer b=0;b<16384;b++)ref_bytes[b]=ram_bytes[b];
end
end
wire[13:0]ram_address=systeme?ca[13:0]:{1'b0,ca[12:0]},ref_address=systeme?ra[13:0]:{1'b0,ra[12:0]};
always@(posedge clk)begin
 if(reset_n&&!ss_freeze&&cpu_ce&&!crd&&!cmreq&&ca<16'hc000&&sd!==chip.byte_at(phys))$fatal(1,"ordinary SDRAM timing/model error cycle%0d A%h actual%h expected%h q%0d a%h rd%b ready%b",cycle,ca,sd,chip.byte_at(phys),live.q,live.a,rd,ready);
 ram_q<=ram_bytes[(ss_freeze&&!cpu_prepare)?(wram_WE?wram_WA:wram_A):ram_address];
 if(ss_freeze?wram_WE:rw)ram_bytes[ss_freeze?wram_WA:ram_address]<=ss_freeze?wram_WD:co;
 ref_q<=ref_bytes[ref_address];if(rrw)ref_bytes[ref_address]<=ro;
end
assign wram_D=ram_q;
memory_bus bus(.A(ca),.sc3000_en(1'b0),.sc_cart_ram(2'b0),.mapper_castle(1'b0),.sc_multicart_en(1'b0),.WR_n(cwr),.RD_n(crd),.MREQ_n(cmreq),.ss_freeze(ss_freeze),.mapper_eeprom(1'b0),.nvram_e(1'b0),.nvram_ex(1'b0),.nvram_cme(1'b0),.dahjee_cart_access(1'b0),.eeprom_bus_active(1'b0),.eeprom_D_out(8'd0),.nvram_D_out(8'd0),.ram_D_out(ram_q),.irom_D_out(sd),.ram_WR(rw),.nvram_WR(nw),.rom_RD(rd),.memory_D_out(cdi));
memory_bus rbus(.A(ra),.sc3000_en(1'b0),.sc_cart_ram(2'b0),.mapper_castle(1'b0),.sc_multicart_en(1'b0),.WR_n(rwr),.RD_n(rrd),.MREQ_n(rmreq),.ss_freeze(1'b0),.mapper_eeprom(1'b0),.nvram_e(1'b0),.nvram_ex(1'b0),.nvram_cme(1'b0),.dahjee_cart_access(1'b0),.eeprom_bus_active(1'b0),.eeprom_D_out(8'd0),.nvram_D_out(8'd0),.ram_D_out(ref_q),.irom_D_out(rsd),.ram_WR(rrw),.nvram_WR(rnw),.rom_RD(rrd_mem),.memory_D_out(rdi));
wire[47:0]signature={ram_bytes[256],ram_bytes[257],ram_bytes[258],ram_bytes[259],ram_bytes[260],ram_bytes[261]},ref_signature={ref_bytes[256],ref_bytes[257],ref_bytes[258],ref_bytes[259],ref_bytes[260],ref_bytes[261]};
wire[250:0]cpu_actual={z80_reg,ca,cm1,cmreq,ciq,crd,cwr},cpu_ref={rr,ra,rm1,rmreq,riq,rrd,rwr};
reg[250:0]cpu_oracle[0:N-1];reg[47:0]sig_oracle[0:N-1];
integer consumed=0,refconsumed=0;reg[7:0]seen_q=0;integer edge_left=0;
integer dram_accepts=0,returns=0,refresh_count=0;reg flight=0;reg[24:0]flight_addr;reg[15:0]phase_seen=0;
always@(posedge clk)begin
 if(live.mode==0&&live.q==0&&!live.access_manager.old_rd&&rd)begin
  if(flight)$fatal(1,"overlap accepted transaction");flight=1;flight_addr=phys;dram_accepts++;
 end
 if(live.mode==0&&live.q==6&&live.ram_req&&!live.wr)begin
  if(!flight)$fatal(1,"duplicate/unowned return");flight=0;returns++;
  #1;if(sd!==chip.byte_at(flight_addr))$fatal(1,"wrong returned transaction address/data");
 end
end
always@(posedge ss_freeze)begin
 phase_seen[live.q]=1;
 $display("G12_ACCEPT q%0d flight%b ready%b accepted%0d returned%0d phyReads%0d A%h retainedAddr%h retainedData%h",live.q,flight,ready,dram_accepts,returns,chip.reads,phys,live.a,live.sd_dat);
end
final $display("G12_LEDGER accepted%0d returned%0d physical%0d flight%b refresh%0d captures%h",dram_accepts,returns,chip.reads,flight,chip.refreshes,phase_seen);
always@(posedge clk)begin
 if(reset_n&&!ss_freeze&&cpu_ce&&!crd&&!cmreq)consumed++;
 if(reset_n&&((DUAL==3||DUAL==5)?rce_cpu:rce_pix)&&!rrd&&!rmreq)refconsumed++;
 if(reset_n&&dut.state==37&&cpu_ce&&!cm1&&!cmreq&&z80_iset==0&&vb&&x<256&&!storage_busy)edge_left=12;
 if(edge_left>0)begin $display("G12_EDGE cycle%0d state%0d freeze%b prep%b cpu%h addr%h rd%b q%0d pending%b wr%b ready%b data%h DDR%0b%0b%0b",cycle,dut.state,ss_freeze,cpu_prepare,z80_reg,phys,rd,live.q,live.ram_req,live.wr,ready,sd,DDRAM_BUSY,DDRAM_RD,DDRAM_WE);edge_left--;end
 if(cpu_prepare&&cpu_ce)$display("G12_PREP cycle%0d A%h rd%b q%0d ready%b data%h",cycle,ca,rd,live.q,ready,sd);
end
