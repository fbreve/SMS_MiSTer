`timescale 1ns/1ps
module nmi_machine #(parameter SOURCE=0,PROGRAM=0)(
 input replay_t2,
 input prepare,
 input clk,mrst,cpu_ce,ss_freeze,pause_n,input[6:0]link_pins,
 input[2:0]restart_dir,input restart_valid,output[2:0]restart_out,input[229:0]cpu_dir,input cpu_set,input[2:0]nmi_dir,input nmi_valid,nmi_hold,
 input[127:0]gg_in,input gg_set,input[31:0]io_in,input io_set,
 input[13:0]wram_A,wram_WA,input[7:0]wram_WD,input wram_WE,output reg[7:0]wram_D,
 output[229:0]cpu_reg,output[2:0]nmi_snap,output[12:0]nstate,output old_nmi,nmi_replay,ready,
 output[127:0]gg_out,output[31:0]io_out,output[15:0]addr,output[7:0]data,di,output[1:0]iset,output m1,mreq,wr,rd,iq,nmi_n);
 wire effective_gg=SOURCE==1;wire link_nmi;wire[7:0]io_data;
 assign nmi_n=(pause_n|effective_gg)&link_nmi;
 wire io_port=(addr[7:6]==0)&&(addr[0]||(effective_gg&&addr[5:3]==0));
 wire io_wr=wr|iq|!io_port,io_rd=rd|iq|!io_port;
 `include "io_instance.sv"
 reg[7:0]ram[0:8191];initial for(integer i=0;i<8192;i=i+1)ram[i]=0;
 reg[7:0]rom_q;
 always @(posedge clk)begin
  wram_D<=ram[wram_A[12:0]];
  if(wram_WE)ram[wram_WA[12:0]]<=wram_WD;
  if(!ss_freeze||prepare)rom_q<=rom(addr);
  if(!mreq&&!wr&&!ss_freeze&&addr[15:14]==3)ram[addr[12:0]]<=data;
 end
 assign ready=!iq&&!wr&&addr[7:0]=='h7e;
 function[7:0]rom(input[15:0]a);
 case(a)
 // Known primary/alternate registers, I/R/IM and SP before timing starts.
  0:rom='hf3;1:rom='h31;2:rom='he0;3:rom='hdf;
  4:rom='haf;5:rom='h08;6:rom='haf;7:rom='h08;
  8:rom='h01;9:rom=0;10:rom=0;11:rom='h11;12:rom=0;13:rom=0;14:rom='h21;15:rom=0;16:rom=0;
  17:rom='hd9;18:rom='h01;19:rom=0;20:rom=0;21:rom='h11;22:rom=0;23:rom=0;24:rom='h21;25:rom=0;26:rom=0;27:rom='hd9;
  28:rom='hdd;29:rom='h21;30:rom=0;31:rom=0;32:rom='hfd;33:rom='h21;34:rom=0;35:rom=0;
  36:rom='hed;37:rom='h47;38:rom='hed;39:rom='h4f;
  40:rom='h32;41:rom=0;42:rom='hc1;43:rom='h32;44:rom=1;45:rom='hc1;46:rom='h32;47:rom=2;48:rom='hc1;
  49:rom='h21;50:rom=1;51:rom='hc1;
  52:rom='h3e;53:rom='h7f;54:rom=effective_gg?'hd3:0;55:rom=effective_gg?2:0;
  56:rom='hd3;57:rom='h7e;58:rom='hc3;59:rom=0;60:rom=1;
 // Handler: increment counter and store current loop progress; acknowledge GG.
  'h66:rom='hf5;'h67:rom='h3a;'h68:rom=0;'h69:rom='hc1;'h6a:rom='h3c;
  'h6b:rom='h32;'h6c:rom=0;'h6d:rom='hc1;'h6e:rom='h3a;'h6f:rom=1;'h70:rom='hc1;
  'h71:rom='h32;'h72:rom=2;'h73:rom='hc1;
  'h74:rom='h3e;'h75:rom='hff;'h76:rom=effective_gg?'hd3:0;'h77:rom=effective_gg?2:0;
  'h78:rom='h3e;'h79:rom='h7f;'h7a:rom=effective_gg?'hd3:0;'h7b:rom=effective_gg?2:0;
  'h7c:rom='hf1;'h7d:rom='hed;'h7e:rom='h45;
  'h100:rom=PROGRAM==1?'hfb:PROGRAM==2?'h76:PROGRAM==3?'hdd:'h34;
  'h101:rom=PROGRAM==3?'h21:PROGRAM==0?'hc3:'h34;
  'h102:rom=PROGRAM==3?0:PROGRAM==0?0:'hc3;
  'h103:rom=PROGRAM==3?0:PROGRAM==0?1:0;
  'h104:rom=PROGRAM==3?'h34:1;
  'h105:rom='hc3;'h106:rom=0;'h107:rom=1;
  default:rom=0;
 endcase
endfunction

 // CPU reads are unavailable while the savestate owns memory. T1 must occur
 // after handoff and provide ordinary setup time for this registered ROM port.
 assign di=(ss_freeze&&!prepare)?8'hff:!iq?io_data:addr[15:14]==3?ram[addr[12:0]]:rom_q;
 T80s #(.T2Write(0)) cpu(.RESET_n(mrst),.CLK(clk),.CEN(cpu_ce&&(!ss_freeze||(prepare&&nmi_replay))),.WAIT_n(1'b1),.INT_n(1'b1),.NMI_n(nmi_n),.BUSRQ_n(1'b1),.M1_n(m1),.MREQ_n(mreq),.IORQ_n(iq),.RD_n(rd),.WR_n(wr),.RFSH_n(),.HALT_n(),.BUSAK_n(),.OUT0(1'b0),.A(addr),.DI(di),.DO(data),.REG(cpu_reg),.RestartContext(restart_out),.RestartDIR(restart_dir),.RestartValid(restart_valid),.DIRSet(cpu_set),.DIR(cpu_dir),.ISet_out(iset),.NMIState(nmi_snap),.NMIDIR(nmi_dir),.NMIValid(nmi_valid),.NMIEnable(1'b1),.NMIHold(nmi_hold),.RestoreHold(ss_freeze),.ReplayT2(replay_t2),.NMIReplay(nmi_replay),.debug_nmi(nstate),.debug_old(old_nmi));
endmodule
