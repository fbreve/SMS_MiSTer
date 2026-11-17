const fs=require('fs'),path=require('path'),dir=__dirname,root=path.resolve(dir,'../..');
const sms=fs.readFileSync(path.join(root,'SMS.sv'),'utf8').replace(/\r\n/g,'\n');
const a=sms.indexOf('always @(posedge clk_sys) begin\n\n\treg old_load'),b=sms.indexOf('wire [1:0] gun_mode',a);
const dirty=sms.slice(sms.indexOf('always @(posedge clk_sys) begin',sms.indexOf('wire bk_save_write')),sms.indexOf('wire downloading = cart_download;')).trim();
let s=fs.readFileSync(path.join(root,'tests/savestate_hcounter/controller_tb.sv'),'utf8').split('reg [63:0] video_saved;')[0].replace('module controller_tb;','module persistence_tb;').replace("reg storage_busy = '0;",'wire storage_busy;');
s+=`wire clk_sys=clk;reg[127:0]status=0;reg RESET=0,OSD_STATUS=0;
reg old_downloading=0,downloading=0,bk_ena=1,bk_pending=0,reset_active=0;
reg bk_loading=0,bk_state=0,bk_load_wait=0,bk_save_wait=0,osd_btn=0;
reg[63:0]img_size=0;reg[31:0]sd_lba=0;reg sd_rd=0,sd_wr=0,sd_ack=0,nvram_we=0;
wire eeprom_active=eeprom_present;wire eeprom_ss_set=eeprom_set;
wire ss_sc_ram_restored=sc_ram_restored;
wire bk_save_write=nvram_we & ~ss_freeze;
wire bk_load=status[6];wire bk_save=status[7]|(bk_pending&OSD_STATUS&&status[25]);
wire bk_queued_load=bk_load_wait&~reset_active,bk_queued_save=bk_save_wait&~reset_active;
assign storage_busy=bk_state|sd_ack|sd_rd|sd_wr;
always @(posedge clk)old_downloading<=downloading;
${dirty}
${sms.slice(a,b)}
integer transfers=0,requests=0;reg prevrequest=0;
always @(posedge ss_freeze)$display("TRACE freeze time%0t busy%0d",$time,ss_busy);
always @(posedge bk_save_wait)$display("TRACE queued save time%0t",$time);
always @(posedge clk)begin
 if(ss_freeze&&storage_busy)$fatal(1,"SD transfer overlaps savestate memory ownership");
 if((sd_rd||sd_wr)&&!prevrequest)requests<=requests+1;
 prevrequest<=sd_rd||sd_wr;
end
task service;begin
 wait(bk_state);for(integer sector=0;sector<64;sector=sector+1)begin
 wait(sd_rd||sd_wr);repeat(2)tick;sd_ack=1;repeat(3)tick;sd_ack=0;repeat(3)tick;
 end
 if(bk_state)$fatal(1,"backup did not finish");transfers=transfers+1;
end endtask
initial begin
 reset_n=0;repeat(4)tick;reset_n=1;vblank=1;x=0;z80_m1_n=0;z80_mreq_n=0;audio_quiescent=1;
 ss_game_id=32'h12345678;video_state_out=22'h12345;eeprom_present=1;
 // Existing SD write must finish before a queued savestate freezes RAM.
 status[7]=1;tick;status[7]=0;wait(bk_state);
 fork operation(1);service;join
 $display("PASS persistence existing SD before save");
 if(requests!=64)$fatal(1,"initial backup sector count");
 // A one-clock manual save pulse during savestate is retained until release.
 fork
 operation(1);
 begin wait(ss_freeze);status[7]=1;tick;tick;status[7]=0;$display("TRACE manual save queue%0d busy%0d",bk_save_wait,ss_busy);end
 join
 $display("TRACE second save ended bk%0d queue%0d",bk_state,bk_save_wait);
 service;if(bk_save_wait)$fatal(1,"queued save not consumed");
 $display("PASS persistence queued save");
 // Likewise for a read/backup-load request.
 fork
 operation(1);
 begin wait(ss_freeze);status[6]=1;tick;tick;status[6]=0;end
 join
 wait(bk_loading);service;if(bk_load_wait)$fatal(1,"queued load not consumed");
 $display("PASS persistence queued load");
 // A full EEPROM restore marks the coherent image dirty; automatic backup
 // begins only after the complete savestate operation, never during DMA.
 OSD_STATUS=1;status[25]=1;operation(0);
 if(!eeprom_full)$fatal(1,"full restore setup missing");service;
 $display("PASS persistence restore autosave");
 // Ordinary guest dirty tracking and subsequent autosave remain functional.
 OSD_STATUS=0;nvram_we=1;tick;nvram_we=0;tick;
 if(!bk_pending)$fatal(1,"normal write not marked dirty");OSD_STATUS=1;service;
 if(transfers!=5||requests!=320)$fatal(1,"persistence operation count %0d/%0d",transfers,requests);
 OSD_STATUS=0;status[25]=0;
 fork
 operation(1);
 begin wait(ss_freeze);status[7]=1;repeat(2)tick;status[7]=0;tick;reset_active=1;tick;reset_active=0;end
 join
 if(bk_state||bk_load_wait||bk_save_wait)$fatal(1,"reset did not cancel queued request");
 $display("PASS persistence: existing SD/save exclusion, queued one-clock save/load, restored dirty autosave, normal guest write; 320 sectors");$finish;
end
initial begin #100000000;$fatal(1,"watchdog state%0d bk%0d busy%0d freeze%0d req%0d transfers%0d sd%0d%0d queue%0d%0d",dut.state,bk_state,ss_busy,ss_freeze,requests,transfers,sd_rd,sd_wr,bk_load_wait,bk_save_wait);end
endmodule
`;
fs.writeFileSync(path.join(dir,'persistence_tb.sv'),s);
fs.writeFileSync(path.join(dir,'persistence.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlib persistence_work
vlog -work persistence_work -sv -suppress 2244 -quiet savestates_sim.sv persistence_tb.sv
vsim -c -t 1ps persistence_work.persistence_tb
run -all
quit -code 0
`);
