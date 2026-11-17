const fs=require('fs'),path=require('path'),crypto=require('crypto');
const dir=__dirname,root=path.resolve(dir,'../..');
const read=f=>fs.readFileSync(path.join(root,f),'utf8').replace(/\r\n/g,'\n');
const sms=read('SMS.sv');
function inst(file,name,over){
 const txt=read(file).split(/end (?:entity|io);/i)[0],ports=[];
 for(const m of txt.matchAll(/\b(\w+)\s*:\s*(in|out)\s+std_logic(?:_vector\s*\((\d+) downto (\d+)\))?/gi)){
  const [_,n,d,hi,lo]=m;ports.push('.'+n+'('+(over[n]??(d.toLowerCase()==='out'?'':hi?`${Number(hi)-Number(lo)+1}'d0`:"1'b0"))+')');
 }return `${path.basename(file,'.vhd')} ${name}(${ports.join(',\n')});`;
}
const mapper=inst('rtl/mapper_ctrl.vhd','mapper',{
 RESET_n:'~reset_active',clk_sys:'clk_sys',bootloader_n:'bootloader_n',ce_z80:"1'b1",WR_n:'WR_n',MREQ_n:'MREQ_n',A:'A',D_in:'D_in',ss_freeze:'ss_freeze',
 mapper_lock:"1'b1",mapper_manual_force:"1'b1",nvram_e_out:'ne',nvram_ex_out:'nx',nvram_p_out:'np',nvram_cme_out:'nc',
 mapper_eeprom:'ee',sc3000_en:'sc',mapper_set:'mapper_set',mapper_in:'mapper_in',mapper_linear:'linear'
});
const bus=inst('rtl/memory_bus.vhd','bus',{
 A:'A',WR_n:'WR_n',RD_n:'RD_n',MREQ_n:'MREQ_n',ss_freeze:'ss_freeze',nvram_e:'ne',nvram_ex:'nx',nvram_cme:'nc',
 mapper_eeprom:'ee',sc3000_en:'sc',sc_cart_ram:'sc_size',nvram_D_out:'nvram_q',ram_D_out:"8'h66",irom_D_out:"8'h99",nvram_WR:'nvram_we',memory_D_out:'cpu_q'
});
const io=inst('rtl/io.vhd','io_inst',{clk:'clk_sys',ce_cpu:"1'b1",RESET_n:'~reset_active',WR_n:"1'b1",RD_n:"1'b0",A:"8'hdd",soft_reset:'soft_reset_btn',D_out:'io_q'});
const dirty=sms.slice(sms.indexOf('always @(posedge clk_sys) begin',sms.indexOf('wire bk_save_write')),sms.indexOf('wire downloading = cart_download;'));
const ena=sms.slice(sms.indexOf('always @(posedge clk_sys) begin',sms.indexOf(') nvram_inst')),sms.indexOf('wire bk_load    ='));
const start=sms.indexOf('always @(posedge clk_sys) begin\n\n\treg old_load'),end=sms.indexOf('wire [1:0] gun_mode',start);
const sys=read('rtl/system.vhd'),addr=sys.slice(sys.indexOf('\tnvram_a <='),sys.indexOf('\tnvram_we <='));
// ModelSim requires meta-value coverage for three binary-only register cases.
const original=read('rtl/mapper_ctrl.vhd');
const normalized=original.replace(/(when "11" =>[^]*?)(end case;)/g,(m,a,b)=>a.includes('when others')?m:a+'when others => null;\n'+b);
fs.writeFileSync(path.join(dir,'mapper_ctrl_sim.vhd'),normalized);
let tb=`\x60timescale 1ns/1ps
module characterization;
reg clk_sys=0;always #5 clk_sys=~clk_sys;
reg soft_reset_btn=0;wire[7:0]io_q;reg RESET=1;reg[127:0]status=0;reg[1:0]buttons=0;
reg cart_download=0,bios_download=0,gg_bios_download=0,bios_config_reset=0,eject_rom=0,evolution_reset_combo=0;
reg bk_loading=0,bk_state=0,bk_load_wait=0,bk_save_wait=0,osd_btn=0;
wire raw_reset=RESET|status[0]|buttons[1]|cart_download|bios_download|gg_bios_download|bios_config_reset|bk_loading|eject_rom|evolution_reset_combo;
wire reset_active=raw_reset;
reg bootloader_n=1,WR_n=1,RD_n=1,MREQ_n=1,ss_freeze=0,mapper_set=0;
reg[63:0]mapper_in=0;reg[15:0]A=0;reg[7:0]D_in=0;
reg ee=0,sc=0,linear=0;reg[1:0]sc_size=0;wire ne,nx,np,nc,nvram_we;wire[7:0]nvram_q,cpu_q;
wire[14:0]nvram_a=sc&&sc_size==1?{4'd0,A[10:0]}:sc&&sc_size==2?{1'b0,A[13:0]}:sc&&sc_size==3?A[14:0]:{np & ~A[14],A[13:0]};
reg old_downloading=0,bk_ena=0,bk_pending=0,OSD_STATUS=0;
wire downloading=cart_download;reg img_mounted=0,img_readonly=0;reg[63:0]img_size=0;
reg[31:0]sd_lba=0;reg sd_rd=0,sd_wr=0,sd_ack=0;reg[8:0]sd_buff_addr=0;reg sd_buff_wr=0;reg[7:0]sd_buff_dout=0;wire[7:0]sd_buff_din;
wire eeprom_active=ee,eeprom_ss_set=1'b0,eeprom_full=1'b0,ss_busy=1'b0;
wire ss_sc_ram_restored=1'b0;
wire bk_save_write=nvram_we & ~ss_freeze;
wire bk_load=status[6],bk_save=status[7]|(bk_pending&OSD_STATUS&&status[25]);
wire bk_queued_load=bk_load_wait&~reset_active,bk_queued_save=bk_save_wait&~reset_active;
${mapper}
${bus}
${io}
dpram #(.widthad_a(15),.init_file("../../rtl/nvram_ff.mif")) ram(.clock_a(clk_sys),.address_a(nvram_a),.wren_a(nvram_we),.data_a(D_in),.q_a(nvram_q),.clock_b(clk_sys),.address_b({sd_lba[5:0],sd_buff_addr}),.wren_b(sd_buff_wr & sd_ack),.data_b(sd_buff_dout),.q_b(sd_buff_din));
${dirty}
${ena}
${sms.slice(start,end)}
task tick;begin @(posedge clk_sys);#1;end endtask
task write_cpu(input[15:0]a,input[7:0]d);begin @(negedge clk_sys);A=a;D_in=d;MREQ_n=0;WR_n=0;tick;@(negedge clk_sys);WR_n=1;MREQ_n=1;tick;end endtask
task sel(input[7:0]v);begin write_cpu(16'hfffc,v);end endtask
task check(input[15:0]a,input[7:0]v);begin @(negedge clk_sys);A=a;MREQ_n=0;RD_n=0;repeat(3)tick;if(cpu_q!==v)$fatal(1,"a=%h expected=%h got=%h flags=%b%b%b",a,v,cpu_q,ne,nx,np);RD_n=1;MREQ_n=1;end endtask
function[7:0]pat(input integer i,input integer bank);pat=((i*73)^(i>>5)^(bank*167)^8'h35);endfunction
task scan;begin for(integer bank=0;bank<2;bank=bank+1)begin sel(bank?12:8);for(integer i=0;i<16384;i=i+1)check(16'h8000+i,pat(i,bank));end end endtask
task reset_check(input integer kind);begin
 case(kind)0:status[0]=1;1:RESET=1;2:bios_download=1;3:mapper_set=1;4:bootloader_n=0;endcase
 repeat(3)tick;
 case(kind)0:status[0]=0;1:RESET=0;2:bios_download=0;3:mapper_set=0;4:bootloader_n=1;endcase
 repeat(4)tick;
 if(ne||nx||np)$fatal(1,"reset/handoff flags not clear kind%0d",kind);scan;
 $display("PASS reset kind%0d retains both whole banks; ena%0d dirty%0d",kind,bk_ena,bk_pending);
end endtask
task service(input bit load);begin
 wait(bk_state);
 for(integer sector=0;sector<64;sector=sector+1)begin
 wait(sd_rd||sd_wr);@(negedge clk_sys);sd_ack=1;tick;
 if(load)begin for(integer byteidx=0;byteidx<512;byteidx=byteidx+1)begin @(negedge clk_sys);sd_buff_addr=byteidx;sd_buff_wr=1;sd_buff_dout=8'hc7;tick;end @(negedge clk_sys);sd_buff_wr=0;end
 repeat(2)tick;@(negedge clk_sys);sd_ack=0;repeat(3)tick;
 end
 if(bk_state)$fatal(1,"SD transfer unfinished");
end endtask
initial begin
 repeat(4)tick;RESET=0;repeat(4)tick;
 sel(8);check(16'h8000,8'hff);sel(12);check(16'hbfff,8'hff);
 $display("PASS power-up initialized FF both banks");
 for(integer bank=0;bank<2;bank=bank+1)begin sel(bank?12:8);for(integer i=0;i<16384;i=i+1)write_cpu(16'h8000+i,pat(i,bank));end
 sel(0);if(ne||nx||np||bk_ena||bk_pending)$fatal(1,"absent host save flags");
 $display("PASS disabled written SRAM has no ownership/persistence indicator");scan;
 $display("PASS whole two-bank independent patterns and disable/re-enable");
 sel(8);soft_reset_btn=1;repeat(4)tick;if(io_q[4]!==0||!ne||reset_active)$fatal(1,"console soft reset wiring");
 soft_reset_btn=0;repeat(4)tick;if(io_q[4]!==1||!ne)$fatal(1,"console reset release");scan;
 $display("PASS console soft-reset input changes DD.4, preserves mapper and both banks");
 for(integer kind=0;kind<5;kind=kind+1)reset_check(kind);
 cart_download=1;repeat(3)tick;cart_download=0;repeat(4)tick;scan;
 if(bk_ena||bk_pending)$fatal(1,"download flags");
 $display("PASS cartridge download without SAVE retains old physical bytes, flags zero");
 eject_rom=1;repeat(3)tick;eject_rom=0;repeat(4)tick;scan;
 $display("PASS eject does not clear backing");
 sel(0);cart_download=1;img_mounted=1;repeat(4)tick;cart_download=0;img_mounted=0;repeat(4)tick;
 if(!bk_ena||bk_pending)$fatal(1,"mount semantics");
 $display("PASS writable mount sets bk_ena with SRAM disabled and no writes");
 sel(8);write_cpu(16'h8000,pat(0,0));if(!bk_pending)$fatal(1,"write not dirty");sel(0);
 if(!bk_pending)$fatal(1,"disable loses dirty");
 status[0]=1;repeat(3)tick;status[0]=0;repeat(4)tick;if(!bk_pending||!bk_ena||ne||nx||np)$fatal(1,"soft reset persistence semantics");
 $display("PASS core status[0] reset retains enabled persistence and dirty flags, clears visibility");
 status[7]=1;tick;status[7]=0;service(0);
 if(bk_pending||!bk_ena)$fatal(1,"backup flag semantics");scan;
 $display("PASS save clears dirty, retains mount and both banks");
 status[6]=1;tick;status[6]=0;service(1);repeat(4)tick;
 if(ne||nx||np)$fatal(1,"SAVE load must reset mapper");
 for(integer bank=0;bank<2;bank=bank+1)begin sel(bank?12:8);for(integer i=0;i<16384;i=i+1)check(16'h8000+i,8'hc7);end
 $display("PASS host SAVE load overwrites all 32768 bytes and resets visibility");
 cart_download=1;img_mounted=1;img_readonly=1;repeat(4)tick;cart_download=0;img_mounted=0;repeat(4)tick;
 if(bk_ena)$fatal(1,"read-only mount enabled backup");
 $display("PASS readonly mounted file does not enable bk_ena");
 // Runtime classification can suppress new register writes without clearing old enables.
 sel(8);linear=1;sel(0);if(!ne)$fatal(1,"linear transition cleared old enable unexpectedly");
 $display("PASS runtime linear selection leaves prior SRAM enable latched (characterization only)");
 linear=0;sel(0);
 // Automatic load at download completion uses img_size and bk_ena.
 cart_download=1;img_mounted=1;img_readonly=0;img_size=32768;repeat(4)tick;cart_download=0;img_mounted=0;service(1);repeat(4)tick;
 sel(8);check(16'h8000,8'hc7);sel(12);check(16'hbfff,8'hc7);sel(0);img_size=0;
 $display("PASS writable SAVE automatic load at ROM completion");
 sc=1;sc_size=1;write_cpu(16'h8000,8'h21);write_cpu(16'h87ff,8'h43);check(16'h8800,8'h21);check(16'hbfff,8'h43);
 sc_size=2;write_cpu(16'h8000,8'h65);write_cpu(16'hbfff,8'h87);check(16'h8000,8'h65);check(16'hbfff,8'h87);
 sc_size=3;write_cpu(16'h8000,8'ha9);write_cpu(16'hffff,8'hcb);check(16'h8000,8'ha9);check(16'hffff,8'hcb);
 sc_size=0;check(16'h8000,8'h99);check(16'hc000,8'h66);
 $display("PASS SC explicit sizes, endpoint routing, 2K mirrors and no-cart-RAM control");
 $display("PASS SRAM ARCHITECTURE CHARACTERIZATION COMPLETE");$finish;
end
initial begin #50000000;$fatal(1,"watchdog");end
endmodule
`;
fs.writeFileSync(path.join(dir,'characterization.sv'),tb);
fs.writeFileSync(path.join(dir,'run.do'),['onerror {quit -code 1}','onbreak {quit -code 1}','vlib work','vcom -2008 -quiet ../../rtl/dpram.vhd mapper_ctrl_sim.vhd ../../rtl/memory_bus.vhd ../../rtl/io.vhd','vlog -sv -suppress 2244 -quiet characterization.sv','vsim -c -t 1ps -L altera_mf work.characterization','run -all','quit -code 0'].join('\n')+'\n');
fs.writeFileSync(path.join(dir,'sources.json'),JSON.stringify({base:'b0f4b71',files:Object.fromEntries(['SMS.sv','rtl/system.vhd','rtl/mapper_ctrl.vhd','rtl/mapper_detect.vhd','rtl/memory_bus.vhd','rtl/dpram.vhd','rtl/nvram_ff.mif','rtl/io.vhd'].map(f=>[f,crypto.createHash('sha256').update(fs.readFileSync(path.join(root,f))).digest('hex')])),addressExpression:addr},null,2)+'\n');
