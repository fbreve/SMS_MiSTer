module FeedbackMemory (
	clk,
	ram_clr_run,
	raw_reset,
	raw_reset1,
	ss_mem_ready1,
	stateLEG_RESET,
	reset,
	index_1,
	index_0,
	stateAP_WRITE,
	state_addr,
	state_addr_4,
	comb,
	state_addr_0,
	LessThan1,
	Add1,
	state_addr_6,
	state_addr_2,
	state_addr_3,
	Mux56,
	state_addr_7,
	ss_mem_active,
	dataout_reg_0,
	dataout_reg_1,
	dataout_reg_2,
	dataout_reg_3,
	dataout_reg_4,
	dataout_reg_5,
	dataout_reg_6,
	dataout_reg_7,
	dataout_reg_8,
	dataout_reg_9,
	state_wdata_0,
	state_addr_1,
	Mux28,
	fb_wr,
	faddr_0,
	state_wdata_1,
	faddr_1,
	state_wdata_2,
	fb_addr_0,
	faddr_2,
	fb_addr_1,
	faddr_3,
	state_wdata_3,
	fb_addr_2,
	state_wdata_4,
	state_wdata_5,
	fb_addr_3,
	state_wdata_6,
	state_wdata_7,
	state_wdata_8,
	state_wdata_9,
	fb_wdatavalue_0,
	fb_wdatavalue_1,
	fb_wdatavalue_2,
	fb_wdatavalue_3,
	fb_wdatavalue_4,
	fb_wdatavalue_5,
	fb_wdatavalue_6,
	fb_wdatavalue_7,
	fb_wdatavalue_8,
	fb_wdatasign,
	devpor,
	devclrn,
	devoe);
input 	clk;
input 	ram_clr_run;
input 	raw_reset;
input 	raw_reset1;
output 	ss_mem_ready1;
input 	stateLEG_RESET;
input 	reset;
input 	index_1;
input 	index_0;
input 	stateAP_WRITE;
input 	state_addr;
input 	state_addr_4;
input 	comb;
input 	state_addr_0;
input 	LessThan1;
output 	Add1;
input 	state_addr_6;
input 	state_addr_2;
input 	state_addr_3;
input 	Mux56;
input 	state_addr_7;
output 	ss_mem_active;
output 	dataout_reg_0;
output 	dataout_reg_1;
output 	dataout_reg_2;
output 	dataout_reg_3;
output 	dataout_reg_4;
output 	dataout_reg_5;
output 	dataout_reg_6;
output 	dataout_reg_7;
output 	dataout_reg_8;
output 	dataout_reg_9;
input 	state_wdata_0;
input 	state_addr_1;
input 	Mux28;
input 	fb_wr;
input 	faddr_0;
input 	state_wdata_1;
input 	faddr_1;
input 	state_wdata_2;
input 	fb_addr_0;
input 	faddr_2;
input 	fb_addr_1;
input 	faddr_3;
input 	state_wdata_3;
input 	fb_addr_2;
input 	state_wdata_4;
input 	state_wdata_5;
input 	fb_addr_3;
input 	state_wdata_6;
input 	state_wdata_7;
input 	state_wdata_8;
input 	state_wdata_9;
input 	fb_wdatavalue_0;
input 	fb_wdatavalue_1;
input 	fb_wdatavalue_2;
input 	fb_wdatavalue_3;
input 	fb_wdatavalue_4;
input 	fb_wdatavalue_5;
input 	fb_wdatavalue_6;
input 	fb_wdatavalue_7;
input 	fb_wdatavalue_8;
input 	fb_wdatasign;
input 	devpor;
input 	devclrn;
input 	devoe;

wire gnd;
wire vcc;
wire unknown;

assign gnd = 1'b0;
assign vcc = 1'b1;
assign unknown = 1'bx;

wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT1 ;
wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT2 ;
wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT3 ;
wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT4 ;
wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT5 ;
wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT6 ;
wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT7 ;
wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT8 ;
wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT9 ;
wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT10 ;
wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT11 ;
wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT12 ;
wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT13 ;
wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT14 ;
wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT15 ;
wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT16 ;
wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT17 ;
wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT18 ;
wire \data_array_rtl_0|auto_generated|lutrama0~PORTBDATAOUT19 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT1 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT2 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT3 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT4 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT5 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT6 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT7 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT8 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT9 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT10 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT11 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT12 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT13 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT14 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT15 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT16 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT17 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT18 ;
wire \data_array_rtl_0|auto_generated|lutrama1~PORTBDATAOUT19 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT1 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT2 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT3 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT4 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT5 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT6 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT7 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT8 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT9 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT10 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT11 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT12 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT13 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT14 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT15 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT16 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT17 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT18 ;
wire \data_array_rtl_0|auto_generated|lutrama2~PORTBDATAOUT19 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT1 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT2 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT3 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT4 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT5 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT6 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT7 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT8 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT9 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT10 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT11 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT12 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT13 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT14 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT15 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT16 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT17 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT18 ;
wire \data_array_rtl_0|auto_generated|lutrama3~PORTBDATAOUT19 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT1 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT2 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT3 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT4 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT5 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT6 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT7 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT8 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT9 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT10 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT11 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT12 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT13 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT14 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT15 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT16 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT17 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT18 ;
wire \data_array_rtl_0|auto_generated|lutrama4~PORTBDATAOUT19 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT1 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT2 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT3 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT4 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT5 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT6 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT7 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT8 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT9 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT10 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT11 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT12 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT13 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT14 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT15 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT16 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT17 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT18 ;
wire \data_array_rtl_0|auto_generated|lutrama5~PORTBDATAOUT19 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT1 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT2 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT3 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT4 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT5 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT6 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT7 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT8 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT9 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT10 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT11 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT12 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT13 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT14 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT15 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT16 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT17 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT18 ;
wire \data_array_rtl_0|auto_generated|lutrama6~PORTBDATAOUT19 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT1 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT2 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT3 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT4 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT5 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT6 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT7 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT8 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT9 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT10 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT11 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT12 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT13 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT14 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT15 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT16 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT17 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT18 ;
wire \data_array_rtl_0|auto_generated|lutrama7~PORTBDATAOUT19 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT1 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT2 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT3 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT4 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT5 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT6 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT7 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT8 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT9 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT10 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT11 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT12 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT13 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT14 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT15 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT16 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT17 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT18 ;
wire \data_array_rtl_0|auto_generated|lutrama8~PORTBDATAOUT19 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT1 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT2 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT3 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT4 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT5 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT6 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT7 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT8 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT9 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT10 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT11 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT12 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT13 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT14 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT15 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT16 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT17 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT18 ;
wire \data_array_rtl_0|auto_generated|lutrama9~PORTBDATAOUT19 ;
wire \init_ch[0]~3_combout ;
wire \init_ch[1]~2_combout ;
wire \init_ch[2]~1_combout ;
wire \init_ch[3]~0_combout ;
wire \Equal0~0_combout ;
wire \ss_mem_index[1]~0_combout ;
wire \ss_mem_index[1]~1_combout ;
wire \data_array~15_combout ;
wire \data_array~16_combout ;
wire \data_array~17_combout ;
wire \data_array~18_combout ;
wire \data_array~19_combout ;
wire \data_array~20_combout ;
wire \data_array~21_combout ;
wire \data_array~22_combout ;
wire \data_array~23_combout ;
wire \data_array~24_combout ;
wire \data_array.raddr_a[0]~0_combout ;
wire \data_array.raddr_a[1]~1_combout ;
wire \data_array.raddr_a[2]~2_combout ;
wire \data_array.raddr_a[3]~3_combout ;
wire \data_array~25_combout ;
wire \data_array~26_combout ;
wire \data_array~27_combout ;
wire \data_array~28_combout ;
wire \data_array~29_combout ;
wire \data_array~30_combout ;
wire \data_array~31_combout ;
wire \data_array~32_combout ;
wire \data_array~33_combout ;
wire [9:0] \data_array_rtl_0|auto_generated|dataout_wire ;
wire [3:0] init_ch;

wire [0:0] \data_array_rtl_0|auto_generated|lutrama0_PORTBDATAOUT_bus ;
wire [0:0] \data_array_rtl_0|auto_generated|lutrama1_PORTBDATAOUT_bus ;
wire [0:0] \data_array_rtl_0|auto_generated|lutrama2_PORTBDATAOUT_bus ;
wire [0:0] \data_array_rtl_0|auto_generated|lutrama3_PORTBDATAOUT_bus ;
wire [0:0] \data_array_rtl_0|auto_generated|lutrama4_PORTBDATAOUT_bus ;
wire [0:0] \data_array_rtl_0|auto_generated|lutrama5_PORTBDATAOUT_bus ;
wire [0:0] \data_array_rtl_0|auto_generated|lutrama6_PORTBDATAOUT_bus ;
wire [0:0] \data_array_rtl_0|auto_generated|lutrama7_PORTBDATAOUT_bus ;
wire [0:0] \data_array_rtl_0|auto_generated|lutrama8_PORTBDATAOUT_bus ;
wire [0:0] \data_array_rtl_0|auto_generated|lutrama9_PORTBDATAOUT_bus ;

assign \data_array_rtl_0|auto_generated|dataout_wire [0] = \data_array_rtl_0|auto_generated|lutrama0_PORTBDATAOUT_bus [0];

assign \data_array_rtl_0|auto_generated|dataout_wire [1] = \data_array_rtl_0|auto_generated|lutrama1_PORTBDATAOUT_bus [0];

assign \data_array_rtl_0|auto_generated|dataout_wire [2] = \data_array_rtl_0|auto_generated|lutrama2_PORTBDATAOUT_bus [0];

assign \data_array_rtl_0|auto_generated|dataout_wire [3] = \data_array_rtl_0|auto_generated|lutrama3_PORTBDATAOUT_bus [0];

assign \data_array_rtl_0|auto_generated|dataout_wire [4] = \data_array_rtl_0|auto_generated|lutrama4_PORTBDATAOUT_bus [0];

assign \data_array_rtl_0|auto_generated|dataout_wire [5] = \data_array_rtl_0|auto_generated|lutrama5_PORTBDATAOUT_bus [0];

assign \data_array_rtl_0|auto_generated|dataout_wire [6] = \data_array_rtl_0|auto_generated|lutrama6_PORTBDATAOUT_bus [0];

assign \data_array_rtl_0|auto_generated|dataout_wire [7] = \data_array_rtl_0|auto_generated|lutrama7_PORTBDATAOUT_bus [0];

assign \data_array_rtl_0|auto_generated|dataout_wire [8] = \data_array_rtl_0|auto_generated|lutrama8_PORTBDATAOUT_bus [0];

assign \data_array_rtl_0|auto_generated|dataout_wire [9] = \data_array_rtl_0|auto_generated|lutrama9_PORTBDATAOUT_bus [0];

dffeas ss_mem_ready(
	.clk(clk),
	.d(\Equal0~0_combout ),
	.asdata(vcc),
	.clrn(!reset),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(vcc),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(ss_mem_ready1),
	.prn(vcc));
// synopsys translate_off
defparam ss_mem_ready.is_wysiwyg = "true";
defparam ss_mem_ready.power_up = "low";
// synopsys translate_on

cyclonev_lcell_comb \Add1~0 (
// Equation(s):
// Add1 = (!state_addr & ((!index_1) # (!index_0)))

	.dataa(!state_addr),
	.datab(!index_1),
	.datac(!index_0),
	.datad(gnd),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(Add1),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \Add1~0 .extended_lut = "off";
defparam \Add1~0 .lut_mask = 64'hA8A8A8A8A8A8A8A8;
defparam \Add1~0 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \ss_mem_active~0 (
// Equation(s):
// ss_mem_active = (\comb~2_combout  & (\ss_mem_index[1]~1_combout  & ((!state_addr_3) # (Mux56))))

	.dataa(!state_addr_3),
	.datab(!comb),
	.datac(!Mux56),
	.datad(!\ss_mem_index[1]~1_combout ),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(ss_mem_active),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \ss_mem_active~0 .extended_lut = "off";
defparam \ss_mem_active~0 .lut_mask = 64'h0023002300230023;
defparam \ss_mem_active~0 .shared_arith = "off";
// synopsys translate_on

dffeas \data_array_rtl_0|auto_generated|dataout_reg[0] (
	.clk(clk),
	.d(\data_array_rtl_0|auto_generated|dataout_wire [0]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_0),
	.prn(vcc));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|dataout_reg[0] .is_wysiwyg = "true";
defparam \data_array_rtl_0|auto_generated|dataout_reg[0] .power_up = "low";
// synopsys translate_on

dffeas \data_array_rtl_0|auto_generated|dataout_reg[1] (
	.clk(clk),
	.d(\data_array_rtl_0|auto_generated|dataout_wire [1]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_1),
	.prn(vcc));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|dataout_reg[1] .is_wysiwyg = "true";
defparam \data_array_rtl_0|auto_generated|dataout_reg[1] .power_up = "low";
// synopsys translate_on

dffeas \data_array_rtl_0|auto_generated|dataout_reg[2] (
	.clk(clk),
	.d(\data_array_rtl_0|auto_generated|dataout_wire [2]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_2),
	.prn(vcc));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|dataout_reg[2] .is_wysiwyg = "true";
defparam \data_array_rtl_0|auto_generated|dataout_reg[2] .power_up = "low";
// synopsys translate_on

dffeas \data_array_rtl_0|auto_generated|dataout_reg[3] (
	.clk(clk),
	.d(\data_array_rtl_0|auto_generated|dataout_wire [3]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_3),
	.prn(vcc));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|dataout_reg[3] .is_wysiwyg = "true";
defparam \data_array_rtl_0|auto_generated|dataout_reg[3] .power_up = "low";
// synopsys translate_on

dffeas \data_array_rtl_0|auto_generated|dataout_reg[4] (
	.clk(clk),
	.d(\data_array_rtl_0|auto_generated|dataout_wire [4]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_4),
	.prn(vcc));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|dataout_reg[4] .is_wysiwyg = "true";
defparam \data_array_rtl_0|auto_generated|dataout_reg[4] .power_up = "low";
// synopsys translate_on

dffeas \data_array_rtl_0|auto_generated|dataout_reg[5] (
	.clk(clk),
	.d(\data_array_rtl_0|auto_generated|dataout_wire [5]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_5),
	.prn(vcc));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|dataout_reg[5] .is_wysiwyg = "true";
defparam \data_array_rtl_0|auto_generated|dataout_reg[5] .power_up = "low";
// synopsys translate_on

dffeas \data_array_rtl_0|auto_generated|dataout_reg[6] (
	.clk(clk),
	.d(\data_array_rtl_0|auto_generated|dataout_wire [6]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_6),
	.prn(vcc));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|dataout_reg[6] .is_wysiwyg = "true";
defparam \data_array_rtl_0|auto_generated|dataout_reg[6] .power_up = "low";
// synopsys translate_on

dffeas \data_array_rtl_0|auto_generated|dataout_reg[7] (
	.clk(clk),
	.d(\data_array_rtl_0|auto_generated|dataout_wire [7]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_7),
	.prn(vcc));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|dataout_reg[7] .is_wysiwyg = "true";
defparam \data_array_rtl_0|auto_generated|dataout_reg[7] .power_up = "low";
// synopsys translate_on

dffeas \data_array_rtl_0|auto_generated|dataout_reg[8] (
	.clk(clk),
	.d(\data_array_rtl_0|auto_generated|dataout_wire [8]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_8),
	.prn(vcc));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|dataout_reg[8] .is_wysiwyg = "true";
defparam \data_array_rtl_0|auto_generated|dataout_reg[8] .power_up = "low";
// synopsys translate_on

dffeas \data_array_rtl_0|auto_generated|dataout_reg[9] (
	.clk(clk),
	.d(\data_array_rtl_0|auto_generated|dataout_wire [9]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_9),
	.prn(vcc));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|dataout_reg[9] .is_wysiwyg = "true";
defparam \data_array_rtl_0|auto_generated|dataout_reg[9] .power_up = "low";
// synopsys translate_on

cyclonev_lcell_comb \init_ch[0]~3 (
// Equation(s):
// \init_ch[0]~3_combout  = !init_ch[0] $ (((\Equal0~0_combout ) # (\comb~2_combout )))

	.dataa(!init_ch[0]),
	.datab(!comb),
	.datac(!\Equal0~0_combout ),
	.datad(gnd),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\init_ch[0]~3_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \init_ch[0]~3 .extended_lut = "off";
defparam \init_ch[0]~3 .lut_mask = 64'h9595959595959595;
defparam \init_ch[0]~3 .shared_arith = "off";
// synopsys translate_on

dffeas \init_ch[0] (
	.clk(clk),
	.d(\init_ch[0]~3_combout ),
	.asdata(vcc),
	.clrn(!reset),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(vcc),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(init_ch[0]),
	.prn(vcc));
// synopsys translate_off
defparam \init_ch[0] .is_wysiwyg = "true";
defparam \init_ch[0] .power_up = "low";
// synopsys translate_on

cyclonev_lcell_comb \init_ch[1]~2 (
// Equation(s):
// \init_ch[1]~2_combout  = !init_ch[1] $ (((!init_ch[0]) # ((\Equal0~0_combout ) # (\comb~2_combout ))))

	.dataa(!init_ch[1]),
	.datab(!init_ch[0]),
	.datac(!comb),
	.datad(!\Equal0~0_combout ),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\init_ch[1]~2_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \init_ch[1]~2 .extended_lut = "off";
defparam \init_ch[1]~2 .lut_mask = 64'h6555655565556555;
defparam \init_ch[1]~2 .shared_arith = "off";
// synopsys translate_on

dffeas \init_ch[1] (
	.clk(clk),
	.d(\init_ch[1]~2_combout ),
	.asdata(vcc),
	.clrn(!reset),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(vcc),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(init_ch[1]),
	.prn(vcc));
// synopsys translate_off
defparam \init_ch[1] .is_wysiwyg = "true";
defparam \init_ch[1] .power_up = "low";
// synopsys translate_on

cyclonev_lcell_comb \init_ch[2]~1 (
// Equation(s):
// \init_ch[2]~1_combout  = ( \comb~2_combout  & ( init_ch[2] ) ) # ( !\comb~2_combout  & ( !init_ch[2] $ (((!init_ch[1]) # (!init_ch[0]))) ) )

	.dataa(gnd),
	.datab(!init_ch[2]),
	.datac(!init_ch[1]),
	.datad(!init_ch[0]),
	.datae(!comb),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\init_ch[2]~1_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \init_ch[2]~1 .extended_lut = "off";
defparam \init_ch[2]~1 .lut_mask = 64'h333C3333333C3333;
defparam \init_ch[2]~1 .shared_arith = "off";
// synopsys translate_on

dffeas \init_ch[2] (
	.clk(clk),
	.d(\init_ch[2]~1_combout ),
	.asdata(vcc),
	.clrn(!reset),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(vcc),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(init_ch[2]),
	.prn(vcc));
// synopsys translate_off
defparam \init_ch[2] .is_wysiwyg = "true";
defparam \init_ch[2] .power_up = "low";
// synopsys translate_on

cyclonev_lcell_comb \init_ch[3]~0 (
// Equation(s):
// \init_ch[3]~0_combout  = ( \comb~2_combout  & ( init_ch[3] ) ) # ( !\comb~2_combout  & ( !init_ch[3] $ (((!init_ch[2]) # ((!init_ch[1]) # (!init_ch[0])))) ) )

	.dataa(!init_ch[3]),
	.datab(!init_ch[2]),
	.datac(!init_ch[1]),
	.datad(!init_ch[0]),
	.datae(!comb),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\init_ch[3]~0_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \init_ch[3]~0 .extended_lut = "off";
defparam \init_ch[3]~0 .lut_mask = 64'h5556555555565555;
defparam \init_ch[3]~0 .shared_arith = "off";
// synopsys translate_on

dffeas \init_ch[3] (
	.clk(clk),
	.d(\init_ch[3]~0_combout ),
	.asdata(vcc),
	.clrn(!reset),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(vcc),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(init_ch[3]),
	.prn(vcc));
// synopsys translate_off
defparam \init_ch[3] .is_wysiwyg = "true";
defparam \init_ch[3] .power_up = "low";
// synopsys translate_on

cyclonev_lcell_comb \Equal0~0 (
// Equation(s):
// \Equal0~0_combout  = (init_ch[3] & (!init_ch[2] & (!init_ch[1] & init_ch[0])))

	.dataa(!init_ch[3]),
	.datab(!init_ch[2]),
	.datac(!init_ch[1]),
	.datad(!init_ch[0]),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\Equal0~0_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \Equal0~0 .extended_lut = "off";
defparam \Equal0~0 .lut_mask = 64'h0040004000400040;
defparam \Equal0~0 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \ss_mem_index[1]~0 (
// Equation(s):
// \ss_mem_index[1]~0_combout  = (!state_addr_7 & (state_addr_6 & (!LessThan11 & !state_addr_4)))

	.dataa(!state_addr_7),
	.datab(!state_addr_6),
	.datac(!LessThan1),
	.datad(!state_addr_4),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\ss_mem_index[1]~0_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \ss_mem_index[1]~0 .extended_lut = "off";
defparam \ss_mem_index[1]~0 .lut_mask = 64'h2000200020002000;
defparam \ss_mem_index[1]~0 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \ss_mem_index[1]~1 (
// Equation(s):
// \ss_mem_index[1]~1_combout  = (\ss_mem_index[1]~0_combout  & ((!state_addr_0) # ((!Mux56) # (state_addr_3))))

	.dataa(!state_addr_0),
	.datab(!state_addr_3),
	.datac(!Mux56),
	.datad(!\ss_mem_index[1]~0_combout ),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\ss_mem_index[1]~1_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \ss_mem_index[1]~1 .extended_lut = "off";
defparam \ss_mem_index[1]~1 .lut_mask = 64'h00FB00FB00FB00FB;
defparam \ss_mem_index[1]~1 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~15 (
// Equation(s):
// \data_array~15_combout  = ( \fb_wr~q  & ( (!\comb~2_combout ) # ((stateAP_WRITE & ss_mem_active)) ) ) # ( !\fb_wr~q  & ( (!\comb~2_combout  & (((!\Equal0~0_combout )))) # (\comb~2_combout  & (stateAP_WRITE & ((ss_mem_active)))) ) )

	.dataa(!stateAP_WRITE),
	.datab(!comb),
	.datac(!\Equal0~0_combout ),
	.datad(!ss_mem_active),
	.datae(!fb_wr),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~15_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~15 .extended_lut = "off";
defparam \data_array~15 .lut_mask = 64'hC0D1CCDDC0D1CCDD;
defparam \data_array~15 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~16 (
// Equation(s):
// \data_array~16_combout  = ( \data_array~15_combout  & ( (!\ram_clr_run~q  & (!\raw_reset~8_combout  & (\raw_reset~9_combout  & !stateLEG_RESET))) ) )

	.dataa(!ram_clr_run),
	.datab(!raw_reset),
	.datac(!raw_reset1),
	.datad(!stateLEG_RESET),
	.datae(!\data_array~15_combout ),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~16_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~16 .extended_lut = "off";
defparam \data_array~16 .lut_mask = 64'h0000080000000800;
defparam \data_array~16 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~17 (
// Equation(s):
// \data_array~17_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\fb_wdata.value [0])))) # (\comb~2_combout  & (((state_wdata_0))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_0),
	.datad(!fb_wdatavalue_0),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~17_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~17 .extended_lut = "off";
defparam \data_array~17 .lut_mask = 64'h0527052705270527;
defparam \data_array~17 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~18 (
// Equation(s):
// \data_array~18_combout  = ( ss_mem_active & ( fb_addr[0] & ( ((!\comb~2_combout  & ((\Equal0~0_combout ) # (init_ch[0])))) # (state_addr_0) ) ) ) # ( !ss_mem_active & ( fb_addr[0] & ( (!\comb~2_combout  & ((\Equal0~0_combout ) # (init_ch[0]))) ) ) ) # ( 
// ss_mem_active & ( !fb_addr[0] & ( ((init_ch[0] & (!\comb~2_combout  & !\Equal0~0_combout ))) # (state_addr_0) ) ) ) # ( !ss_mem_active & ( !fb_addr[0] & ( (init_ch[0] & (!\comb~2_combout  & !\Equal0~0_combout )) ) ) )

	.dataa(!state_addr_0),
	.datab(!init_ch[0]),
	.datac(!comb),
	.datad(!\Equal0~0_combout ),
	.datae(!ss_mem_active),
	.dataf(!fb_addr_0),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~18_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~18 .extended_lut = "off";
defparam \data_array~18 .lut_mask = 64'h3000755530F075F5;
defparam \data_array~18 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~19 (
// Equation(s):
// \data_array~19_combout  = ( fb_addr[1] & ( (!init_ch[1] & ((!init_ch[3]) # ((!init_ch[0]) # (init_ch[2])))) ) ) # ( !fb_addr[1] & ( !init_ch[1] ) )

	.dataa(!init_ch[3]),
	.datab(!init_ch[2]),
	.datac(!init_ch[1]),
	.datad(!init_ch[0]),
	.datae(!fb_addr_1),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~19_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~19 .extended_lut = "off";
defparam \data_array~19 .lut_mask = 64'hF0F0F0B0F0F0F0B0;
defparam \data_array~19 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~20 (
// Equation(s):
// \data_array~20_combout  = ( \data_array~19_combout  & ( (ss_mem_active & (!state_addr_1 $ (!state_addr_0))) ) ) # ( !\data_array~19_combout  & ( (!\comb~2_combout ) # ((ss_mem_active & (!state_addr_1 $ (!state_addr_0)))) ) )

	.dataa(!state_addr_1),
	.datab(!state_addr_0),
	.datac(!comb),
	.datad(!ss_mem_active),
	.datae(!\data_array~19_combout ),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~20_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~20 .extended_lut = "off";
defparam \data_array~20 .lut_mask = 64'hF0F60066F0F60066;
defparam \data_array~20 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~21 (
// Equation(s):
// \data_array~21_combout  = ( fb_addr[2] & ( (!init_ch[2] & ((!init_ch[3]) # ((!init_ch[0]) # (init_ch[1])))) ) ) # ( !fb_addr[2] & ( !init_ch[2] ) )

	.dataa(!init_ch[3]),
	.datab(!init_ch[2]),
	.datac(!init_ch[1]),
	.datad(!init_ch[0]),
	.datae(!fb_addr_2),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~21_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~21 .extended_lut = "off";
defparam \data_array~21 .lut_mask = 64'hCCCCCC8CCCCCCC8C;
defparam \data_array~21 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~22 (
// Equation(s):
// \data_array~22_combout  = ( ss_mem_active & ( (!\comb~2_combout  & ((!\data_array~21_combout ) # (!state_addr_2 $ (!Mux28)))) # (\comb~2_combout  & (!state_addr_2 $ ((!Mux28)))) ) ) # ( !ss_mem_active & ( (!\comb~2_combout  & !\data_array~21_combout ) ) )

	.dataa(!state_addr_2),
	.datab(!Mux28),
	.datac(!comb),
	.datad(!\data_array~21_combout ),
	.datae(!ss_mem_active),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~22_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~22 .extended_lut = "off";
defparam \data_array~22 .lut_mask = 64'hF000F666F000F666;
defparam \data_array~22 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~23 (
// Equation(s):
// \data_array~23_combout  = (!\comb~2_combout  & ((!\Equal0~0_combout  & (init_ch[3])) # (\Equal0~0_combout  & ((fb_addr[3])))))

	.dataa(!init_ch[3]),
	.datab(!comb),
	.datac(!\Equal0~0_combout ),
	.datad(!fb_addr_3),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~23_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~23 .extended_lut = "off";
defparam \data_array~23 .lut_mask = 64'h404C404C404C404C;
defparam \data_array~23 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~24 (
// Equation(s):
// \data_array~24_combout  = ( \data_array~23_combout  ) # ( !\data_array~23_combout  & ( (ss_mem_active & (!state_addr_3 $ (((!Mux28) # (state_addr_2))))) ) )

	.dataa(!state_addr_2),
	.datab(!Mux28),
	.datac(!state_addr_3),
	.datad(!ss_mem_active),
	.datae(!\data_array~23_combout ),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~24_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~24 .extended_lut = "off";
defparam \data_array~24 .lut_mask = 64'h002DFFFF002DFFFF;
defparam \data_array~24 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array.raddr_a[0]~0 (
// Equation(s):
// \data_array.raddr_a[0]~0_combout  = ( \ss_mem_index[1]~0_combout  & ( faddr_0 & ( ((!\comb~2_combout ) # ((state_addr_3 & !Mux56))) # (state_addr_0) ) ) ) # ( !\ss_mem_index[1]~0_combout  & ( faddr_0 ) ) # ( \ss_mem_index[1]~0_combout  & ( !faddr_0 & ( 
// (state_addr_0 & (\comb~2_combout  & (!state_addr_3 $ (Mux56)))) ) ) )

	.dataa(!state_addr_0),
	.datab(!state_addr_3),
	.datac(!comb),
	.datad(!Mux56),
	.datae(!\ss_mem_index[1]~0_combout ),
	.dataf(!faddr_0),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array.raddr_a[0]~0_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array.raddr_a[0]~0 .extended_lut = "off";
defparam \data_array.raddr_a[0]~0 .lut_mask = 64'h00000401FFFFF7F5;
defparam \data_array.raddr_a[0]~0 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array.raddr_a[1]~1 (
// Equation(s):
// \data_array.raddr_a[1]~1_combout  = (!ss_mem_active & (((faddr_1)))) # (ss_mem_active & (!state_addr_1 $ ((!state_addr_0))))

	.dataa(!state_addr_1),
	.datab(!state_addr_0),
	.datac(!faddr_1),
	.datad(!ss_mem_active),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array.raddr_a[1]~1_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array.raddr_a[1]~1 .extended_lut = "off";
defparam \data_array.raddr_a[1]~1 .lut_mask = 64'h0F660F660F660F66;
defparam \data_array.raddr_a[1]~1 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array.raddr_a[2]~2 (
// Equation(s):
// \data_array.raddr_a[2]~2_combout  = (!ss_mem_active & (((faddr_2)))) # (ss_mem_active & (!state_addr_2 $ ((!Mux28))))

	.dataa(!state_addr_2),
	.datab(!Mux28),
	.datac(!ss_mem_active),
	.datad(!faddr_2),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array.raddr_a[2]~2_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array.raddr_a[2]~2 .extended_lut = "off";
defparam \data_array.raddr_a[2]~2 .lut_mask = 64'h06F606F606F606F6;
defparam \data_array.raddr_a[2]~2 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array.raddr_a[3]~3 (
// Equation(s):
// \data_array.raddr_a[3]~3_combout  = ( faddr_3 & ( (!ss_mem_active) # (!state_addr_3 $ (((!Mux28) # (state_addr_2)))) ) ) # ( !faddr_3 & ( (ss_mem_active & (!state_addr_3 $ (((!Mux28) # (state_addr_2))))) ) )

	.dataa(!state_addr_2),
	.datab(!Mux28),
	.datac(!state_addr_3),
	.datad(!ss_mem_active),
	.datae(!faddr_3),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array.raddr_a[3]~3_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array.raddr_a[3]~3 .extended_lut = "off";
defparam \data_array.raddr_a[3]~3 .lut_mask = 64'h002DFF2D002DFF2D;
defparam \data_array.raddr_a[3]~3 .shared_arith = "off";
// synopsys translate_on

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama0 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~16_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~17_combout }),
	.portaaddr({\data_array~24_combout ,\data_array~22_combout ,\data_array~20_combout ,\data_array~18_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama0_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama0 .address_width = 4;
defparam \data_array_rtl_0|auto_generated|lutrama0 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama0 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama0 .first_bit_number = 0;
defparam \data_array_rtl_0|auto_generated|lutrama0 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama0 .last_address = 8;
defparam \data_array_rtl_0|auto_generated|lutrama0 .logical_ram_depth = 9;
defparam \data_array_rtl_0|auto_generated|lutrama0 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|feedbackmemory:fmem|altdpram:data_array_rtl_0|dpram_dop1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama0 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama0 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_lcell_comb \data_array~25 (
// Equation(s):
// \data_array~25_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\fb_wdata.value [1])))) # (\comb~2_combout  & (((state_wdata_1))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_1),
	.datad(!fb_wdatavalue_1),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~25_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~25 .extended_lut = "off";
defparam \data_array~25 .lut_mask = 64'h0527052705270527;
defparam \data_array~25 .shared_arith = "off";
// synopsys translate_on

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama1 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~16_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~25_combout }),
	.portaaddr({\data_array~24_combout ,\data_array~22_combout ,\data_array~20_combout ,\data_array~18_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama1_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama1 .address_width = 4;
defparam \data_array_rtl_0|auto_generated|lutrama1 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama1 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama1 .first_bit_number = 1;
defparam \data_array_rtl_0|auto_generated|lutrama1 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama1 .last_address = 8;
defparam \data_array_rtl_0|auto_generated|lutrama1 .logical_ram_depth = 9;
defparam \data_array_rtl_0|auto_generated|lutrama1 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|feedbackmemory:fmem|altdpram:data_array_rtl_0|dpram_dop1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama1 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama1 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_lcell_comb \data_array~26 (
// Equation(s):
// \data_array~26_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\fb_wdata.value [2])))) # (\comb~2_combout  & (((state_wdata_2))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_2),
	.datad(!fb_wdatavalue_2),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~26_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~26 .extended_lut = "off";
defparam \data_array~26 .lut_mask = 64'h0527052705270527;
defparam \data_array~26 .shared_arith = "off";
// synopsys translate_on

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama2 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~16_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~26_combout }),
	.portaaddr({\data_array~24_combout ,\data_array~22_combout ,\data_array~20_combout ,\data_array~18_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama2_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama2 .address_width = 4;
defparam \data_array_rtl_0|auto_generated|lutrama2 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama2 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama2 .first_bit_number = 2;
defparam \data_array_rtl_0|auto_generated|lutrama2 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama2 .last_address = 8;
defparam \data_array_rtl_0|auto_generated|lutrama2 .logical_ram_depth = 9;
defparam \data_array_rtl_0|auto_generated|lutrama2 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|feedbackmemory:fmem|altdpram:data_array_rtl_0|dpram_dop1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama2 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama2 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_lcell_comb \data_array~27 (
// Equation(s):
// \data_array~27_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\fb_wdata.value [3])))) # (\comb~2_combout  & (((state_wdata_3))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_3),
	.datad(!fb_wdatavalue_3),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~27_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~27 .extended_lut = "off";
defparam \data_array~27 .lut_mask = 64'h0527052705270527;
defparam \data_array~27 .shared_arith = "off";
// synopsys translate_on

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama3 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~16_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~27_combout }),
	.portaaddr({\data_array~24_combout ,\data_array~22_combout ,\data_array~20_combout ,\data_array~18_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama3_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama3 .address_width = 4;
defparam \data_array_rtl_0|auto_generated|lutrama3 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama3 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama3 .first_bit_number = 3;
defparam \data_array_rtl_0|auto_generated|lutrama3 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama3 .last_address = 8;
defparam \data_array_rtl_0|auto_generated|lutrama3 .logical_ram_depth = 9;
defparam \data_array_rtl_0|auto_generated|lutrama3 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|feedbackmemory:fmem|altdpram:data_array_rtl_0|dpram_dop1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama3 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama3 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_lcell_comb \data_array~28 (
// Equation(s):
// \data_array~28_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\fb_wdata.value [4])))) # (\comb~2_combout  & (((state_wdata_4))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_4),
	.datad(!fb_wdatavalue_4),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~28_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~28 .extended_lut = "off";
defparam \data_array~28 .lut_mask = 64'h0527052705270527;
defparam \data_array~28 .shared_arith = "off";
// synopsys translate_on

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama4 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~16_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~28_combout }),
	.portaaddr({\data_array~24_combout ,\data_array~22_combout ,\data_array~20_combout ,\data_array~18_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama4_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama4 .address_width = 4;
defparam \data_array_rtl_0|auto_generated|lutrama4 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama4 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama4 .first_bit_number = 4;
defparam \data_array_rtl_0|auto_generated|lutrama4 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama4 .last_address = 8;
defparam \data_array_rtl_0|auto_generated|lutrama4 .logical_ram_depth = 9;
defparam \data_array_rtl_0|auto_generated|lutrama4 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|feedbackmemory:fmem|altdpram:data_array_rtl_0|dpram_dop1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama4 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama4 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_lcell_comb \data_array~29 (
// Equation(s):
// \data_array~29_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\fb_wdata.value [5])))) # (\comb~2_combout  & (((state_wdata_5))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_5),
	.datad(!fb_wdatavalue_5),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~29_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~29 .extended_lut = "off";
defparam \data_array~29 .lut_mask = 64'h0527052705270527;
defparam \data_array~29 .shared_arith = "off";
// synopsys translate_on

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama5 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~16_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~29_combout }),
	.portaaddr({\data_array~24_combout ,\data_array~22_combout ,\data_array~20_combout ,\data_array~18_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama5_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama5 .address_width = 4;
defparam \data_array_rtl_0|auto_generated|lutrama5 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama5 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama5 .first_bit_number = 5;
defparam \data_array_rtl_0|auto_generated|lutrama5 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama5 .last_address = 8;
defparam \data_array_rtl_0|auto_generated|lutrama5 .logical_ram_depth = 9;
defparam \data_array_rtl_0|auto_generated|lutrama5 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|feedbackmemory:fmem|altdpram:data_array_rtl_0|dpram_dop1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama5 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama5 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_lcell_comb \data_array~30 (
// Equation(s):
// \data_array~30_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\fb_wdata.value [6])))) # (\comb~2_combout  & (((state_wdata_6))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_6),
	.datad(!fb_wdatavalue_6),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~30_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~30 .extended_lut = "off";
defparam \data_array~30 .lut_mask = 64'h0527052705270527;
defparam \data_array~30 .shared_arith = "off";
// synopsys translate_on

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama6 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~16_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~30_combout }),
	.portaaddr({\data_array~24_combout ,\data_array~22_combout ,\data_array~20_combout ,\data_array~18_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama6_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama6 .address_width = 4;
defparam \data_array_rtl_0|auto_generated|lutrama6 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama6 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama6 .first_bit_number = 6;
defparam \data_array_rtl_0|auto_generated|lutrama6 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama6 .last_address = 8;
defparam \data_array_rtl_0|auto_generated|lutrama6 .logical_ram_depth = 9;
defparam \data_array_rtl_0|auto_generated|lutrama6 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|feedbackmemory:fmem|altdpram:data_array_rtl_0|dpram_dop1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama6 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama6 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_lcell_comb \data_array~31 (
// Equation(s):
// \data_array~31_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\fb_wdata.value [7])))) # (\comb~2_combout  & (((state_wdata_7))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_7),
	.datad(!fb_wdatavalue_7),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~31_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~31 .extended_lut = "off";
defparam \data_array~31 .lut_mask = 64'h0527052705270527;
defparam \data_array~31 .shared_arith = "off";
// synopsys translate_on

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama7 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~16_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~31_combout }),
	.portaaddr({\data_array~24_combout ,\data_array~22_combout ,\data_array~20_combout ,\data_array~18_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama7_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama7 .address_width = 4;
defparam \data_array_rtl_0|auto_generated|lutrama7 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama7 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama7 .first_bit_number = 7;
defparam \data_array_rtl_0|auto_generated|lutrama7 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama7 .last_address = 8;
defparam \data_array_rtl_0|auto_generated|lutrama7 .logical_ram_depth = 9;
defparam \data_array_rtl_0|auto_generated|lutrama7 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|feedbackmemory:fmem|altdpram:data_array_rtl_0|dpram_dop1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama7 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama7 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_lcell_comb \data_array~32 (
// Equation(s):
// \data_array~32_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\fb_wdata.value [8])))) # (\comb~2_combout  & (((state_wdata_8))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_8),
	.datad(!fb_wdatavalue_8),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~32_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~32 .extended_lut = "off";
defparam \data_array~32 .lut_mask = 64'h0527052705270527;
defparam \data_array~32 .shared_arith = "off";
// synopsys translate_on

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama8 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~16_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~32_combout }),
	.portaaddr({\data_array~24_combout ,\data_array~22_combout ,\data_array~20_combout ,\data_array~18_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama8_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama8 .address_width = 4;
defparam \data_array_rtl_0|auto_generated|lutrama8 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama8 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama8 .first_bit_number = 8;
defparam \data_array_rtl_0|auto_generated|lutrama8 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama8 .last_address = 8;
defparam \data_array_rtl_0|auto_generated|lutrama8 .logical_ram_depth = 9;
defparam \data_array_rtl_0|auto_generated|lutrama8 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|feedbackmemory:fmem|altdpram:data_array_rtl_0|dpram_dop1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama8 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama8 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_lcell_comb \data_array~33 (
// Equation(s):
// \data_array~33_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\fb_wdata.sign~q )))) # (\comb~2_combout  & (((state_wdata_9))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_9),
	.datad(!fb_wdatasign),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~33_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~33 .extended_lut = "off";
defparam \data_array~33 .lut_mask = 64'h0527052705270527;
defparam \data_array~33 .shared_arith = "off";
// synopsys translate_on

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama9 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~16_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~33_combout }),
	.portaaddr({\data_array~24_combout ,\data_array~22_combout ,\data_array~20_combout ,\data_array~18_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama9_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama9 .address_width = 4;
defparam \data_array_rtl_0|auto_generated|lutrama9 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama9 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama9 .first_bit_number = 9;
defparam \data_array_rtl_0|auto_generated|lutrama9 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama9 .last_address = 8;
defparam \data_array_rtl_0|auto_generated|lutrama9 .logical_ram_depth = 9;
defparam \data_array_rtl_0|auto_generated|lutrama9 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|feedbackmemory:fmem|altdpram:data_array_rtl_0|dpram_dop1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama9 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama9 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

endmodule
