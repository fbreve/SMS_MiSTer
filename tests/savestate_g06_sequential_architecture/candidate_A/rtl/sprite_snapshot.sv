// Architectural experiment: two unchanged 4800-bit sprite records in RAM.
// No guest clock/enable is generated here. Local endpoint latency is one edge.
module sprite_snapshot(
 input clk,reset_n,capture,apply_state,legacy,systeme,
 input bulk_read,bulk_write,input[7:0]bulk_addr,input[63:0]bulk_wdata,
 output reg[63:0]bulk_rdata,output reg done,output busy,
 output[7:0]state_addr,output state_second,state_read,state_write,
 output[31:0]state_wdata,input[31:0]state_rdata
);
 localparam IDLE=0,CAP_READ=1,CAP_STORE=2,AP_READ=3,AP_WRITE=4,
 B_RD_LO=5,B_GET_LO=6,B_RD_HI=7,B_GET_HI=8,B_WR_LO=9,B_WR_HI=10;
 reg[3:0]state;
 reg[8:0]index;
 reg[63:0]incoming;
 reg legacy_mode,dual;
 (* ramstyle="M10K" *) reg[31:0]memory[0:299];
 reg[31:0]ram_q;
 wire[8:0]ram_addr=(state==B_RD_HI||state==B_GET_HI||state==B_WR_HI)?index+9'd1:index;
 wire ram_we=state==CAP_STORE||state==B_WR_LO||state==B_WR_HI;
 wire[31:0]ram_data=state==CAP_STORE?((state_second&&!dual)?32'd0:state_rdata):state==B_WR_LO?incoming[31:0]:incoming[63:32];
 always@(posedge clk)begin
  if(ram_we)memory[ram_addr]<=ram_data;
  ram_q<=memory[ram_addr];
 end
 assign busy=state!=IDLE;
 assign state_second=index>=150;
 assign state_addr=state_second?index-9'd150:index;
 assign state_read=state==CAP_READ&&(!state_second||dual);
 assign state_write=state==AP_WRITE;
 assign state_wdata=legacy_mode?32'd0:ram_q;
 always@(posedge clk or negedge reset_n)begin
  if(!reset_n)begin state<=IDLE;index<=0;incoming<=0;bulk_rdata<=0;done<=0;legacy_mode<=0;dual<=0;end
  else case(state)
   IDLE:begin
    if(capture)begin state<=CAP_READ;index<=0;dual<=systeme;done<=0;end
    else if(apply_state)begin state<=AP_READ;index<=0;dual<=systeme;legacy_mode<=legacy;done<=0;end
    else if(bulk_read)begin state<=B_RD_LO;index<={bulk_addr,1'b0};done<=0;end
    else if(bulk_write)begin state<=B_WR_LO;index<={bulk_addr,1'b0};incoming<=bulk_wdata;done<=0;end
   end
   CAP_READ:state<=CAP_STORE;
   CAP_STORE:if(index==299)begin state<=IDLE;done<=1;end else begin index<=index+9'd1;state<=CAP_READ;end
   AP_READ:state<=AP_WRITE;
   AP_WRITE:if(index==(dual?299:149))begin state<=IDLE;done<=1;end else begin index<=index+9'd1;state<=AP_READ;end
   B_RD_LO:state<=B_GET_LO;
   B_GET_LO:begin bulk_rdata[31:0]<=ram_q;state<=B_RD_HI;end
   B_RD_HI:state<=B_GET_HI;
   B_GET_HI:begin bulk_rdata[63:32]<=ram_q;state<=IDLE;done<=1;end
   B_WR_LO:state<=B_WR_HI;
   B_WR_HI:begin state<=IDLE;done<=1;end
   default:state<=IDLE;
  endcase
 end
endmodule
