module OutputMemory (
	clk,
	mo_wdatavalue_0,
	mo_wdatavalue_1,
	mo_wdatavalue_2,
	mo_wdatavalue_3,
	mo_wdatavalue_4,
	mo_wdatavalue_5,
	mo_wdatavalue_6,
	mo_wdatavalue_7,
	mo_wdatavalue_8,
	mo_wdatasign,
	ram_clr_run,
	raw_reset,
	raw_reset1,
	ss_mem_ready1,
	stateLEG_RESET,
	reset,
	index_6,
	index_1,
	index_7,
	index_3,
	index_2,
	index_5,
	index_4,
	stateAP_WRITE,
	state_addr_3,
	state_addr,
	LessThan1,
	state_addr_4,
	comb,
	state_addr_0,
	Mux56,
	state_addr_6,
	state_addr_2,
	dataout_reg_0,
	state_addr_7,
	ss_mem_active,
	LessThan11,
	dataout_reg_1,
	dataout_reg_2,
	dataout_reg_3,
	dataout_reg_4,
	dataout_reg_5,
	dataout_reg_6,
	dataout_reg_7,
	dataout_reg_8,
	dataout_reg_9,
	state_addr_1,
	state_wdata_0,
	Add1,
	state_wdata_1,
	maddr_0,
	mo_wr,
	state_wdata_2,
	maddr_1,
	state_wdata_3,
	maddr_2,
	state_wdata_4,
	maddr_3,
	state_wdata_5,
	maddr_4,
	state_wdata_6,
	mo_addr_0,
	state_wdata_7,
	mo_addr_1,
	state_wdata_8,
	mo_addr_2,
	state_wdata_9,
	mo_addr_3,
	mo_addr_4,
	dataout_reg_91,
	dataout_reg_01,
	dataout_reg_11,
	dataout_reg_21,
	dataout_reg_31,
	dataout_reg_41,
	dataout_reg_51,
	dataout_reg_61,
	dataout_reg_71,
	dataout_reg_81,
	devpor,
	devclrn,
	devoe);
input 	clk;
input 	mo_wdatavalue_0;
input 	mo_wdatavalue_1;
input 	mo_wdatavalue_2;
input 	mo_wdatavalue_3;
input 	mo_wdatavalue_4;
input 	mo_wdatavalue_5;
input 	mo_wdatavalue_6;
input 	mo_wdatavalue_7;
input 	mo_wdatavalue_8;
input 	mo_wdatasign;
input 	ram_clr_run;
input 	raw_reset;
input 	raw_reset1;
output 	ss_mem_ready1;
input 	stateLEG_RESET;
input 	reset;
input 	index_6;
input 	index_1;
input 	index_7;
input 	index_3;
input 	index_2;
input 	index_5;
input 	index_4;
input 	stateAP_WRITE;
input 	state_addr_3;
input 	state_addr;
input 	LessThan1;
input 	state_addr_4;
input 	comb;
input 	state_addr_0;
input 	Mux56;
input 	state_addr_6;
input 	state_addr_2;
output 	dataout_reg_0;
input 	state_addr_7;
output 	ss_mem_active;
input 	LessThan11;
output 	dataout_reg_1;
output 	dataout_reg_2;
output 	dataout_reg_3;
output 	dataout_reg_4;
output 	dataout_reg_5;
output 	dataout_reg_6;
output 	dataout_reg_7;
output 	dataout_reg_8;
output 	dataout_reg_9;
input 	state_addr_1;
input 	state_wdata_0;
output 	Add1;
input 	state_wdata_1;
input 	maddr_0;
input 	mo_wr;
input 	state_wdata_2;
input 	maddr_1;
input 	state_wdata_3;
input 	maddr_2;
input 	state_wdata_4;
input 	maddr_3;
input 	state_wdata_5;
input 	maddr_4;
input 	state_wdata_6;
input 	mo_addr_0;
input 	state_wdata_7;
input 	mo_addr_1;
input 	state_wdata_8;
input 	mo_addr_2;
input 	state_wdata_9;
input 	mo_addr_3;
input 	mo_addr_4;
output 	dataout_reg_91;
output 	dataout_reg_01;
output 	dataout_reg_11;
output 	dataout_reg_21;
output 	dataout_reg_31;
output 	dataout_reg_41;
output 	dataout_reg_51;
output 	dataout_reg_61;
output 	dataout_reg_71;
output 	dataout_reg_81;
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
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT1 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT2 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT3 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT4 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT5 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT6 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT7 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT8 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT9 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT10 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT11 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT12 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT13 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT14 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT15 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT16 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT17 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT18 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama9~PORTBDATAOUT19 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT1 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT2 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT3 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT4 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT5 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT6 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT7 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT8 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT9 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT10 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT11 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT12 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT13 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT14 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT15 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT16 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT17 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT18 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama0~PORTBDATAOUT19 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT1 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT2 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT3 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT4 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT5 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT6 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT7 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT8 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT9 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT10 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT11 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT12 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT13 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT14 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT15 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT16 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT17 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT18 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama1~PORTBDATAOUT19 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT1 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT2 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT3 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT4 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT5 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT6 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT7 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT8 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT9 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT10 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT11 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT12 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT13 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT14 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT15 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT16 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT17 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT18 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama2~PORTBDATAOUT19 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT1 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT2 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT3 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT4 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT5 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT6 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT7 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT8 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT9 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT10 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT11 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT12 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT13 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT14 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT15 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT16 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT17 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT18 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama3~PORTBDATAOUT19 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT1 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT2 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT3 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT4 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT5 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT6 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT7 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT8 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT9 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT10 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT11 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT12 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT13 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT14 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT15 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT16 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT17 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT18 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama4~PORTBDATAOUT19 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT1 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT2 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT3 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT4 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT5 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT6 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT7 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT8 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT9 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT10 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT11 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT12 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT13 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT14 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT15 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT16 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT17 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT18 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama5~PORTBDATAOUT19 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT1 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT2 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT3 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT4 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT5 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT6 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT7 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT8 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT9 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT10 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT11 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT12 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT13 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT14 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT15 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT16 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT17 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT18 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama6~PORTBDATAOUT19 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT1 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT2 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT3 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT4 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT5 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT6 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT7 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT8 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT9 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT10 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT11 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT12 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT13 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT14 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT15 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT16 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT17 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT18 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama7~PORTBDATAOUT19 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT1 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT2 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT3 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT4 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT5 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT6 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT7 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT8 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT9 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT10 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT11 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT12 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT13 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT14 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT15 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT16 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT17 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT18 ;
wire \data_array__dual_rtl_0|auto_generated|lutrama8~PORTBDATAOUT19 ;
wire \init_ch[0]~1_combout ;
wire \init_ch[1]~3_combout ;
wire \init_ch[2]~4_combout ;
wire \init_ch[3]~0_combout ;
wire \init_ch[4]~2_combout ;
wire \data_array~16_combout ;
wire \Equal0~0_combout ;
wire \data_array~17_combout ;
wire \data_array~18_combout ;
wire \data_array~19_combout ;
wire \LessThan1~0_combout ;
wire \ss_mem_active~0_combout ;
wire \ss_mem_index~0_combout ;
wire \data_array~20_combout ;
wire \data_array~21_combout ;
wire \data_array~22_combout ;
wire \data_array~23_combout ;
wire \data_array~24_combout ;
wire \data_array~25_combout ;
wire \data_array~26_combout ;
wire \data_array~27_combout ;
wire \data_array~28_combout ;
wire \data_array.raddr_a[0]~0_combout ;
wire \data_array.raddr_a[1]~1_combout ;
wire \data_array.raddr_a[2]~2_combout ;
wire \data_array.raddr_a[3]~3_combout ;
wire \data_array.raddr_a[4]~4_combout ;
wire \data_array~29_combout ;
wire \data_array~30_combout ;
wire \data_array~31_combout ;
wire \data_array~32_combout ;
wire \data_array~33_combout ;
wire \data_array~34_combout ;
wire \data_array~35_combout ;
wire \data_array~36_combout ;
wire \data_array~37_combout ;
wire [9:0] \data_array_rtl_0|auto_generated|dataout_wire ;
wire [9:0] \data_array__dual_rtl_0|auto_generated|dataout_wire ;
wire [4:0] init_ch;

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
wire [0:0] \data_array__dual_rtl_0|auto_generated|lutrama9_PORTBDATAOUT_bus ;
wire [0:0] \data_array__dual_rtl_0|auto_generated|lutrama0_PORTBDATAOUT_bus ;
wire [0:0] \data_array__dual_rtl_0|auto_generated|lutrama1_PORTBDATAOUT_bus ;
wire [0:0] \data_array__dual_rtl_0|auto_generated|lutrama2_PORTBDATAOUT_bus ;
wire [0:0] \data_array__dual_rtl_0|auto_generated|lutrama3_PORTBDATAOUT_bus ;
wire [0:0] \data_array__dual_rtl_0|auto_generated|lutrama4_PORTBDATAOUT_bus ;
wire [0:0] \data_array__dual_rtl_0|auto_generated|lutrama5_PORTBDATAOUT_bus ;
wire [0:0] \data_array__dual_rtl_0|auto_generated|lutrama6_PORTBDATAOUT_bus ;
wire [0:0] \data_array__dual_rtl_0|auto_generated|lutrama7_PORTBDATAOUT_bus ;
wire [0:0] \data_array__dual_rtl_0|auto_generated|lutrama8_PORTBDATAOUT_bus ;

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

assign \data_array__dual_rtl_0|auto_generated|dataout_wire [9] = \data_array__dual_rtl_0|auto_generated|lutrama9_PORTBDATAOUT_bus [0];

assign \data_array__dual_rtl_0|auto_generated|dataout_wire [0] = \data_array__dual_rtl_0|auto_generated|lutrama0_PORTBDATAOUT_bus [0];

assign \data_array__dual_rtl_0|auto_generated|dataout_wire [1] = \data_array__dual_rtl_0|auto_generated|lutrama1_PORTBDATAOUT_bus [0];

assign \data_array__dual_rtl_0|auto_generated|dataout_wire [2] = \data_array__dual_rtl_0|auto_generated|lutrama2_PORTBDATAOUT_bus [0];

assign \data_array__dual_rtl_0|auto_generated|dataout_wire [3] = \data_array__dual_rtl_0|auto_generated|lutrama3_PORTBDATAOUT_bus [0];

assign \data_array__dual_rtl_0|auto_generated|dataout_wire [4] = \data_array__dual_rtl_0|auto_generated|lutrama4_PORTBDATAOUT_bus [0];

assign \data_array__dual_rtl_0|auto_generated|dataout_wire [5] = \data_array__dual_rtl_0|auto_generated|lutrama5_PORTBDATAOUT_bus [0];

assign \data_array__dual_rtl_0|auto_generated|dataout_wire [6] = \data_array__dual_rtl_0|auto_generated|lutrama6_PORTBDATAOUT_bus [0];

assign \data_array__dual_rtl_0|auto_generated|dataout_wire [7] = \data_array__dual_rtl_0|auto_generated|lutrama7_PORTBDATAOUT_bus [0];

assign \data_array__dual_rtl_0|auto_generated|dataout_wire [8] = \data_array__dual_rtl_0|auto_generated|lutrama8_PORTBDATAOUT_bus [0];

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

cyclonev_lcell_comb \ss_mem_active~1 (
// Equation(s):
// ss_mem_active = ( !\ss_mem_active~0_combout  & ( (!state_addr_7 & (\comb~2_combout  & ((!index_6) # (\LessThan1~0_combout )))) ) )

	.dataa(!index_6),
	.datab(!state_addr_7),
	.datac(!comb),
	.datad(!\LessThan1~0_combout ),
	.datae(!\ss_mem_active~0_combout ),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(ss_mem_active),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \ss_mem_active~1 .extended_lut = "off";
defparam \ss_mem_active~1 .lut_mask = 64'h080C0000080C0000;
defparam \ss_mem_active~1 .shared_arith = "off";
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

cyclonev_lcell_comb \Add1~0 (
// Equation(s):
// Add1 = (state_addr_2 & state_addr_1)

	.dataa(!state_addr_2),
	.datab(!state_addr_1),
	.datac(gnd),
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
defparam \Add1~0 .lut_mask = 64'h1111111111111111;
defparam \Add1~0 .shared_arith = "off";
// synopsys translate_on

dffeas \data_array__dual_rtl_0|auto_generated|dataout_reg[9] (
	.clk(clk),
	.d(\data_array__dual_rtl_0|auto_generated|dataout_wire [9]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_91),
	.prn(vcc));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[9] .is_wysiwyg = "true";
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[9] .power_up = "low";
// synopsys translate_on

dffeas \data_array__dual_rtl_0|auto_generated|dataout_reg[0] (
	.clk(clk),
	.d(\data_array__dual_rtl_0|auto_generated|dataout_wire [0]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_01),
	.prn(vcc));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[0] .is_wysiwyg = "true";
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[0] .power_up = "low";
// synopsys translate_on

dffeas \data_array__dual_rtl_0|auto_generated|dataout_reg[1] (
	.clk(clk),
	.d(\data_array__dual_rtl_0|auto_generated|dataout_wire [1]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_11),
	.prn(vcc));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[1] .is_wysiwyg = "true";
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[1] .power_up = "low";
// synopsys translate_on

dffeas \data_array__dual_rtl_0|auto_generated|dataout_reg[2] (
	.clk(clk),
	.d(\data_array__dual_rtl_0|auto_generated|dataout_wire [2]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_21),
	.prn(vcc));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[2] .is_wysiwyg = "true";
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[2] .power_up = "low";
// synopsys translate_on

dffeas \data_array__dual_rtl_0|auto_generated|dataout_reg[3] (
	.clk(clk),
	.d(\data_array__dual_rtl_0|auto_generated|dataout_wire [3]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_31),
	.prn(vcc));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[3] .is_wysiwyg = "true";
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[3] .power_up = "low";
// synopsys translate_on

dffeas \data_array__dual_rtl_0|auto_generated|dataout_reg[4] (
	.clk(clk),
	.d(\data_array__dual_rtl_0|auto_generated|dataout_wire [4]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_41),
	.prn(vcc));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[4] .is_wysiwyg = "true";
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[4] .power_up = "low";
// synopsys translate_on

dffeas \data_array__dual_rtl_0|auto_generated|dataout_reg[5] (
	.clk(clk),
	.d(\data_array__dual_rtl_0|auto_generated|dataout_wire [5]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_51),
	.prn(vcc));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[5] .is_wysiwyg = "true";
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[5] .power_up = "low";
// synopsys translate_on

dffeas \data_array__dual_rtl_0|auto_generated|dataout_reg[6] (
	.clk(clk),
	.d(\data_array__dual_rtl_0|auto_generated|dataout_wire [6]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_61),
	.prn(vcc));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[6] .is_wysiwyg = "true";
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[6] .power_up = "low";
// synopsys translate_on

dffeas \data_array__dual_rtl_0|auto_generated|dataout_reg[7] (
	.clk(clk),
	.d(\data_array__dual_rtl_0|auto_generated|dataout_wire [7]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_71),
	.prn(vcc));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[7] .is_wysiwyg = "true";
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[7] .power_up = "low";
// synopsys translate_on

dffeas \data_array__dual_rtl_0|auto_generated|dataout_reg[8] (
	.clk(clk),
	.d(\data_array__dual_rtl_0|auto_generated|dataout_wire [8]),
	.asdata(vcc),
	.clrn(vcc),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(!reset),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(dataout_reg_81),
	.prn(vcc));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[8] .is_wysiwyg = "true";
defparam \data_array__dual_rtl_0|auto_generated|dataout_reg[8] .power_up = "low";
// synopsys translate_on

cyclonev_lcell_comb \init_ch[0]~1 (
// Equation(s):
// \init_ch[0]~1_combout  = !init_ch[0] $ (((\Equal0~0_combout ) # (\comb~2_combout )))

	.dataa(!init_ch[0]),
	.datab(!comb),
	.datac(!\Equal0~0_combout ),
	.datad(gnd),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\init_ch[0]~1_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \init_ch[0]~1 .extended_lut = "off";
defparam \init_ch[0]~1 .lut_mask = 64'h9595959595959595;
defparam \init_ch[0]~1 .shared_arith = "off";
// synopsys translate_on

dffeas \init_ch[0] (
	.clk(clk),
	.d(\init_ch[0]~1_combout ),
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

cyclonev_lcell_comb \init_ch[1]~3 (
// Equation(s):
// \init_ch[1]~3_combout  = !init_ch[1] $ (((!init_ch[0]) # ((\Equal0~0_combout ) # (\comb~2_combout ))))

	.dataa(!init_ch[1]),
	.datab(!init_ch[0]),
	.datac(!comb),
	.datad(!\Equal0~0_combout ),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\init_ch[1]~3_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \init_ch[1]~3 .extended_lut = "off";
defparam \init_ch[1]~3 .lut_mask = 64'h6555655565556555;
defparam \init_ch[1]~3 .shared_arith = "off";
// synopsys translate_on

dffeas \init_ch[1] (
	.clk(clk),
	.d(\init_ch[1]~3_combout ),
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

cyclonev_lcell_comb \init_ch[2]~4 (
// Equation(s):
// \init_ch[2]~4_combout  = !init_ch[2] $ ((((!init_ch[0]) # (!init_ch[1])) # (\comb~2_combout )))

	.dataa(!comb),
	.datab(!init_ch[0]),
	.datac(!init_ch[1]),
	.datad(!init_ch[2]),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\init_ch[2]~4_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \init_ch[2]~4 .extended_lut = "off";
defparam \init_ch[2]~4 .lut_mask = 64'h02FD02FD02FD02FD;
defparam \init_ch[2]~4 .shared_arith = "off";
// synopsys translate_on

dffeas \init_ch[2] (
	.clk(clk),
	.d(\init_ch[2]~4_combout ),
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
// \init_ch[3]~0_combout  = ( init_ch[0] & ( \comb~2_combout  & ( init_ch[3] ) ) ) # ( !init_ch[0] & ( \comb~2_combout  & ( init_ch[3] ) ) ) # ( init_ch[0] & ( !\comb~2_combout  & ( !init_ch[3] $ (((!init_ch[2]) # (!init_ch[1]))) ) ) ) # ( !init_ch[0] & ( 
// !\comb~2_combout  & ( init_ch[3] ) ) )

	.dataa(gnd),
	.datab(!init_ch[3]),
	.datac(!init_ch[2]),
	.datad(!init_ch[1]),
	.datae(!init_ch[0]),
	.dataf(!comb),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\init_ch[3]~0_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \init_ch[3]~0 .extended_lut = "off";
defparam \init_ch[3]~0 .lut_mask = 64'h3333333C33333333;
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

cyclonev_lcell_comb \init_ch[4]~2 (
// Equation(s):
// \init_ch[4]~2_combout  = ( init_ch[0] & ( \comb~2_combout  & ( init_ch[4] ) ) ) # ( !init_ch[0] & ( \comb~2_combout  & ( init_ch[4] ) ) ) # ( init_ch[0] & ( !\comb~2_combout  & ( !init_ch[4] $ (((!init_ch[3]) # ((!init_ch[2]) # (!init_ch[1])))) ) ) ) # ( 
// !init_ch[0] & ( !\comb~2_combout  & ( init_ch[4] ) ) )

	.dataa(!init_ch[4]),
	.datab(!init_ch[3]),
	.datac(!init_ch[2]),
	.datad(!init_ch[1]),
	.datae(!init_ch[0]),
	.dataf(!comb),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\init_ch[4]~2_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \init_ch[4]~2 .extended_lut = "off";
defparam \init_ch[4]~2 .lut_mask = 64'h5555555655555555;
defparam \init_ch[4]~2 .shared_arith = "off";
// synopsys translate_on

dffeas \init_ch[4] (
	.clk(clk),
	.d(\init_ch[4]~2_combout ),
	.asdata(vcc),
	.clrn(!reset),
	.aload(gnd),
	.sclr(gnd),
	.sload(gnd),
	.ena(vcc),
	.devclrn(devclrn),
	.devpor(devpor),
	.q(init_ch[4]),
	.prn(vcc));
// synopsys translate_off
defparam \init_ch[4] .is_wysiwyg = "true";
defparam \init_ch[4] .power_up = "low";
// synopsys translate_on

cyclonev_lcell_comb \data_array~16 (
// Equation(s):
// \data_array~16_combout  = (init_ch[4] & init_ch[1])

	.dataa(!init_ch[4]),
	.datab(!init_ch[1]),
	.datac(gnd),
	.datad(gnd),
	.datae(gnd),
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
defparam \data_array~16 .lut_mask = 64'h1111111111111111;
defparam \data_array~16 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \Equal0~0 (
// Equation(s):
// \Equal0~0_combout  = (!init_ch[3] & (!init_ch[2] & (!init_ch[0] & \data_array~16_combout )))

	.dataa(!init_ch[3]),
	.datab(!init_ch[2]),
	.datac(!init_ch[0]),
	.datad(!\data_array~16_combout ),
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
defparam \Equal0~0 .lut_mask = 64'h0080008000800080;
defparam \Equal0~0 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~17 (
// Equation(s):
// \data_array~17_combout  = ( \mo_wr~q  & ( (!\comb~2_combout ) # ((stateAP_WRITE & ss_mem_active)) ) ) # ( !\mo_wr~q  & ( (!\comb~2_combout  & (((!\Equal0~0_combout )))) # (\comb~2_combout  & (stateAP_WRITE & ((ss_mem_active)))) ) )

	.dataa(!stateAP_WRITE),
	.datab(!comb),
	.datac(!\Equal0~0_combout ),
	.datad(!ss_mem_active),
	.datae(!mo_wr),
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
defparam \data_array~17 .lut_mask = 64'hC0D1CCDDC0D1CCDD;
defparam \data_array~17 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~18 (
// Equation(s):
// \data_array~18_combout  = ( \data_array~17_combout  & ( (!\ram_clr_run~q  & (!\raw_reset~8_combout  & (!\raw_reset~9_combout  & !stateLEG_RESET))) ) )

	.dataa(!ram_clr_run),
	.datab(!raw_reset),
	.datac(!raw_reset1),
	.datad(!stateLEG_RESET),
	.datae(!\data_array~17_combout ),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~18_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~18 .extended_lut = "off";
defparam \data_array~18 .lut_mask = 64'h0000800000008000;
defparam \data_array~18 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~19 (
// Equation(s):
// \data_array~19_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\mo_wdata.value [0])))) # (\comb~2_combout  & (((state_wdata_0))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_0),
	.datad(!mo_wdatavalue_0),
	.datae(gnd),
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
defparam \data_array~19 .lut_mask = 64'h0527052705270527;
defparam \data_array~19 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \LessThan1~0 (
// Equation(s):
// \LessThan1~0_combout  = (LessThan1 & (state_addr_4 & ((!index_3) # (!index_2))))

	.dataa(!index_3),
	.datab(!index_2),
	.datac(!LessThan1),
	.datad(!state_addr_4),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\LessThan1~0_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \LessThan1~0 .extended_lut = "off";
defparam \LessThan1~0 .lut_mask = 64'h000E000E000E000E;
defparam \LessThan1~0 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \ss_mem_active~0 (
// Equation(s):
// \ss_mem_active~0_combout  = ( index_4 & ( index_1 & ( (state_addr_6 & ((!index_3) # (!index_5))) ) ) ) # ( !index_4 & ( index_1 & ( state_addr_6 ) ) ) # ( index_4 & ( !index_1 & ( (state_addr_6 & ((!index_3) # ((!index_2) # (!index_5)))) ) ) ) # ( 
// !index_4 & ( !index_1 & ( state_addr_6 ) ) )

	.dataa(!state_addr_6),
	.datab(!index_3),
	.datac(!index_2),
	.datad(!index_5),
	.datae(!index_4),
	.dataf(!index_1),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\ss_mem_active~0_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \ss_mem_active~0 .extended_lut = "off";
defparam \ss_mem_active~0 .lut_mask = 64'h5555555455555544;
defparam \ss_mem_active~0 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \ss_mem_index~0 (
// Equation(s):
// \ss_mem_index~0_combout  = ( !\ss_mem_active~0_combout  & ( (!state_addr & (!index_7 & ((!index_6) # (\LessThan1~0_combout )))) ) )

	.dataa(!index_6),
	.datab(!state_addr),
	.datac(!index_7),
	.datad(!\LessThan1~0_combout ),
	.datae(!\ss_mem_active~0_combout ),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\ss_mem_index~0_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \ss_mem_index~0 .extended_lut = "off";
defparam \ss_mem_index~0 .lut_mask = 64'h80C0000080C00000;
defparam \ss_mem_index~0 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~20 (
// Equation(s):
// \data_array~20_combout  = (!init_ch[3] & (!init_ch[2] & (\data_array~16_combout  & mo_addr[0])))

	.dataa(!init_ch[3]),
	.datab(!init_ch[2]),
	.datac(!\data_array~16_combout ),
	.datad(!mo_addr_0),
	.datae(gnd),
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
defparam \data_array~20 .lut_mask = 64'h0008000800080008;
defparam \data_array~20 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~21 (
// Equation(s):
// \data_array~21_combout  = ( \data_array~20_combout  & ( (!\comb~2_combout ) # ((!state_addr_0 & \ss_mem_index~0_combout )) ) ) # ( !\data_array~20_combout  & ( (!\comb~2_combout  & (((init_ch[0])))) # (\comb~2_combout  & (!state_addr_0 & 
// ((\ss_mem_index~0_combout )))) ) )

	.dataa(!state_addr_0),
	.datab(!init_ch[0]),
	.datac(!comb),
	.datad(!\ss_mem_index~0_combout ),
	.datae(!\data_array~20_combout ),
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
defparam \data_array~21 .lut_mask = 64'h303AF0FA303AF0FA;
defparam \data_array~21 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~22 (
// Equation(s):
// \data_array~22_combout  = ( \ss_mem_index~0_combout  & ( mo_addr[1] & ( (!\comb~2_combout  & (((\Equal0~0_combout ) # (init_ch[1])))) # (\comb~2_combout  & (!state_addr_1)) ) ) ) # ( !\ss_mem_index~0_combout  & ( mo_addr[1] & ( (!\comb~2_combout  & 
// ((\Equal0~0_combout ) # (init_ch[1]))) ) ) ) # ( \ss_mem_index~0_combout  & ( !mo_addr[1] & ( (!\comb~2_combout  & (((init_ch[1] & !\Equal0~0_combout )))) # (\comb~2_combout  & (!state_addr_1)) ) ) ) # ( !\ss_mem_index~0_combout  & ( !mo_addr[1] & ( 
// (init_ch[1] & (!\comb~2_combout  & !\Equal0~0_combout )) ) ) )

	.dataa(!state_addr_1),
	.datab(!init_ch[1]),
	.datac(!comb),
	.datad(!\Equal0~0_combout ),
	.datae(!\ss_mem_index~0_combout ),
	.dataf(!mo_addr_1),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~22_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~22 .extended_lut = "off";
defparam \data_array~22 .lut_mask = 64'h30003A0A30F03AFA;
defparam \data_array~22 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~23 (
// Equation(s):
// \data_array~23_combout  = ( mo_addr[2] & ( (!init_ch[2] & (((!\data_array~16_combout ) # (init_ch[0])) # (init_ch[3]))) ) ) # ( !mo_addr[2] & ( !init_ch[2] ) )

	.dataa(!init_ch[3]),
	.datab(!init_ch[2]),
	.datac(!init_ch[0]),
	.datad(!\data_array~16_combout ),
	.datae(!mo_addr_2),
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
defparam \data_array~23 .lut_mask = 64'hCCCCCC4CCCCCCC4C;
defparam \data_array~23 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~24 (
// Equation(s):
// \data_array~24_combout  = ( \data_array~23_combout  & ( (\comb~2_combout  & (\ss_mem_index~0_combout  & (!state_addr_2 $ (state_addr_1)))) ) ) # ( !\data_array~23_combout  & ( (!\comb~2_combout ) # ((\ss_mem_index~0_combout  & (!state_addr_2 $ 
// (state_addr_1)))) ) )

	.dataa(!state_addr_2),
	.datab(!state_addr_1),
	.datac(!comb),
	.datad(!\ss_mem_index~0_combout ),
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
defparam \data_array~24 .lut_mask = 64'hF0F90009F0F90009;
defparam \data_array~24 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~25 (
// Equation(s):
// \data_array~25_combout  = ( mo_addr[3] & ( (!init_ch[3] & (((!\data_array~16_combout ) # (init_ch[0])) # (init_ch[2]))) ) ) # ( !mo_addr[3] & ( !init_ch[3] ) )

	.dataa(!init_ch[3]),
	.datab(!init_ch[2]),
	.datac(!init_ch[0]),
	.datad(!\data_array~16_combout ),
	.datae(!mo_addr_3),
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
defparam \data_array~25 .lut_mask = 64'hAAAAAA2AAAAAAA2A;
defparam \data_array~25 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~26 (
// Equation(s):
// \data_array~26_combout  = ( \data_array~25_combout  & ( (\comb~2_combout  & (\ss_mem_index~0_combout  & (!state_addr_3 $ (Mux56)))) ) ) # ( !\data_array~25_combout  & ( (!\comb~2_combout ) # ((\ss_mem_index~0_combout  & (!state_addr_3 $ (Mux56)))) ) )

	.dataa(!state_addr_3),
	.datab(!comb),
	.datac(!Mux56),
	.datad(!\ss_mem_index~0_combout ),
	.datae(!\data_array~25_combout ),
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
defparam \data_array~26 .lut_mask = 64'hCCED0021CCED0021;
defparam \data_array~26 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~27 (
// Equation(s):
// \data_array~27_combout  = (!\Equal0~0_combout  & (init_ch[4])) # (\Equal0~0_combout  & ((mo_addr[4])))

	.dataa(!init_ch[4]),
	.datab(!\Equal0~0_combout ),
	.datac(!mo_addr_4),
	.datad(gnd),
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
defparam \data_array~27 .lut_mask = 64'h4747474747474747;
defparam \data_array~27 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array~28 (
// Equation(s):
// \data_array~28_combout  = ( \data_array~27_combout  & ( (!\comb~2_combout ) # ((\ss_mem_index~0_combout  & (!state_addr_4 $ (LessThan1)))) ) ) # ( !\data_array~27_combout  & ( (\comb~2_combout  & (\ss_mem_index~0_combout  & (!state_addr_4 $ (LessThan1)))) 
// ) )

	.dataa(!state_addr_4),
	.datab(!comb),
	.datac(!LessThan11),
	.datad(!\ss_mem_index~0_combout ),
	.datae(!\data_array~27_combout ),
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
defparam \data_array~28 .lut_mask = 64'h0021CCED0021CCED;
defparam \data_array~28 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array.raddr_a[0]~0 (
// Equation(s):
// \data_array.raddr_a[0]~0_combout  = (!ss_mem_active & (((mo_addr[0])))) # (ss_mem_active & (!state_addr_0 & (\ss_mem_index~0_combout )))

	.dataa(!state_addr_0),
	.datab(!ss_mem_active),
	.datac(!\ss_mem_index~0_combout ),
	.datad(!mo_addr_0),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array.raddr_a[0]~0_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array.raddr_a[0]~0 .extended_lut = "off";
defparam \data_array.raddr_a[0]~0 .lut_mask = 64'h02CE02CE02CE02CE;
defparam \data_array.raddr_a[0]~0 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array.raddr_a[1]~1 (
// Equation(s):
// \data_array.raddr_a[1]~1_combout  = (!ss_mem_active & (((mo_addr[1])))) # (ss_mem_active & (!state_addr_1 & (\ss_mem_index~0_combout )))

	.dataa(!state_addr_1),
	.datab(!ss_mem_active),
	.datac(!\ss_mem_index~0_combout ),
	.datad(!mo_addr_1),
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
defparam \data_array.raddr_a[1]~1 .lut_mask = 64'h02CE02CE02CE02CE;
defparam \data_array.raddr_a[1]~1 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array.raddr_a[2]~2 (
// Equation(s):
// \data_array.raddr_a[2]~2_combout  = ( mo_addr[2] & ( (!ss_mem_active) # ((\ss_mem_index~0_combout  & (!state_addr_2 $ (state_addr_1)))) ) ) # ( !mo_addr[2] & ( (ss_mem_active & (\ss_mem_index~0_combout  & (!state_addr_2 $ (state_addr_1)))) ) )

	.dataa(!state_addr_2),
	.datab(!state_addr_1),
	.datac(!ss_mem_active),
	.datad(!\ss_mem_index~0_combout ),
	.datae(!mo_addr_2),
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
defparam \data_array.raddr_a[2]~2 .lut_mask = 64'h0009F0F90009F0F9;
defparam \data_array.raddr_a[2]~2 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array.raddr_a[3]~3 (
// Equation(s):
// \data_array.raddr_a[3]~3_combout  = ( mo_addr[3] & ( (!ss_mem_active) # ((\ss_mem_index~0_combout  & (!state_addr_3 $ (Mux56)))) ) ) # ( !mo_addr[3] & ( (ss_mem_active & (\ss_mem_index~0_combout  & (!state_addr_3 $ (Mux56)))) ) )

	.dataa(!state_addr_3),
	.datab(!ss_mem_active),
	.datac(!Mux56),
	.datad(!\ss_mem_index~0_combout ),
	.datae(!mo_addr_3),
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
defparam \data_array.raddr_a[3]~3 .lut_mask = 64'h0021CCED0021CCED;
defparam \data_array.raddr_a[3]~3 .shared_arith = "off";
// synopsys translate_on

cyclonev_lcell_comb \data_array.raddr_a[4]~4 (
// Equation(s):
// \data_array.raddr_a[4]~4_combout  = ( mo_addr[4] & ( (!ss_mem_active) # ((\ss_mem_index~0_combout  & (!state_addr_4 $ (LessThan1)))) ) ) # ( !mo_addr[4] & ( (ss_mem_active & (\ss_mem_index~0_combout  & (!state_addr_4 $ (LessThan1)))) ) )

	.dataa(!state_addr_4),
	.datab(!ss_mem_active),
	.datac(!LessThan11),
	.datad(!\ss_mem_index~0_combout ),
	.datae(!mo_addr_4),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array.raddr_a[4]~4_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array.raddr_a[4]~4 .extended_lut = "off";
defparam \data_array.raddr_a[4]~4 .lut_mask = 64'h0021CCED0021CCED;
defparam \data_array.raddr_a[4]~4 .shared_arith = "off";
// synopsys translate_on

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama0 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~19_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[4]~4_combout ,\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama0_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama0 .address_width = 5;
defparam \data_array_rtl_0|auto_generated|lutrama0 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama0 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama0 .first_bit_number = 0;
defparam \data_array_rtl_0|auto_generated|lutrama0 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama0 .last_address = 18;
defparam \data_array_rtl_0|auto_generated|lutrama0 .logical_ram_depth = 19;
defparam \data_array_rtl_0|auto_generated|lutrama0 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama0 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama0 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_lcell_comb \data_array~29 (
// Equation(s):
// \data_array~29_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\mo_wdata.value [1])))) # (\comb~2_combout  & (((state_wdata_1))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_1),
	.datad(!mo_wdatavalue_1),
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

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama1 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~29_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[4]~4_combout ,\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama1_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama1 .address_width = 5;
defparam \data_array_rtl_0|auto_generated|lutrama1 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama1 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama1 .first_bit_number = 1;
defparam \data_array_rtl_0|auto_generated|lutrama1 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama1 .last_address = 18;
defparam \data_array_rtl_0|auto_generated|lutrama1 .logical_ram_depth = 19;
defparam \data_array_rtl_0|auto_generated|lutrama1 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama1 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama1 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_lcell_comb \data_array~30 (
// Equation(s):
// \data_array~30_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\mo_wdata.value [2])))) # (\comb~2_combout  & (((state_wdata_2))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_2),
	.datad(!mo_wdatavalue_2),
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

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama2 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~30_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[4]~4_combout ,\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama2_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama2 .address_width = 5;
defparam \data_array_rtl_0|auto_generated|lutrama2 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama2 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama2 .first_bit_number = 2;
defparam \data_array_rtl_0|auto_generated|lutrama2 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama2 .last_address = 18;
defparam \data_array_rtl_0|auto_generated|lutrama2 .logical_ram_depth = 19;
defparam \data_array_rtl_0|auto_generated|lutrama2 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama2 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama2 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_lcell_comb \data_array~31 (
// Equation(s):
// \data_array~31_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\mo_wdata.value [3])))) # (\comb~2_combout  & (((state_wdata_31))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_3),
	.datad(!mo_wdatavalue_3),
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

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama3 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~31_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[4]~4_combout ,\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama3_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama3 .address_width = 5;
defparam \data_array_rtl_0|auto_generated|lutrama3 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama3 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama3 .first_bit_number = 3;
defparam \data_array_rtl_0|auto_generated|lutrama3 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama3 .last_address = 18;
defparam \data_array_rtl_0|auto_generated|lutrama3 .logical_ram_depth = 19;
defparam \data_array_rtl_0|auto_generated|lutrama3 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama3 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama3 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_lcell_comb \data_array~32 (
// Equation(s):
// \data_array~32_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\mo_wdata.value [4])))) # (\comb~2_combout  & (((state_wdata_4))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_4),
	.datad(!mo_wdatavalue_4),
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

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama4 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~32_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[4]~4_combout ,\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama4_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama4 .address_width = 5;
defparam \data_array_rtl_0|auto_generated|lutrama4 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama4 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama4 .first_bit_number = 4;
defparam \data_array_rtl_0|auto_generated|lutrama4 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama4 .last_address = 18;
defparam \data_array_rtl_0|auto_generated|lutrama4 .logical_ram_depth = 19;
defparam \data_array_rtl_0|auto_generated|lutrama4 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama4 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama4 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_lcell_comb \data_array~33 (
// Equation(s):
// \data_array~33_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\mo_wdata.value [5])))) # (\comb~2_combout  & (((state_wdata_5))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_5),
	.datad(!mo_wdatavalue_5),
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

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama5 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~33_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[4]~4_combout ,\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama5_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama5 .address_width = 5;
defparam \data_array_rtl_0|auto_generated|lutrama5 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama5 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama5 .first_bit_number = 5;
defparam \data_array_rtl_0|auto_generated|lutrama5 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama5 .last_address = 18;
defparam \data_array_rtl_0|auto_generated|lutrama5 .logical_ram_depth = 19;
defparam \data_array_rtl_0|auto_generated|lutrama5 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama5 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama5 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_lcell_comb \data_array~34 (
// Equation(s):
// \data_array~34_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\mo_wdata.value [6])))) # (\comb~2_combout  & (((state_wdata_6))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_6),
	.datad(!mo_wdatavalue_6),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~34_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~34 .extended_lut = "off";
defparam \data_array~34 .lut_mask = 64'h0527052705270527;
defparam \data_array~34 .shared_arith = "off";
// synopsys translate_on

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama6 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~34_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[4]~4_combout ,\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama6_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama6 .address_width = 5;
defparam \data_array_rtl_0|auto_generated|lutrama6 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama6 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama6 .first_bit_number = 6;
defparam \data_array_rtl_0|auto_generated|lutrama6 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama6 .last_address = 18;
defparam \data_array_rtl_0|auto_generated|lutrama6 .logical_ram_depth = 19;
defparam \data_array_rtl_0|auto_generated|lutrama6 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama6 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama6 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_lcell_comb \data_array~35 (
// Equation(s):
// \data_array~35_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\mo_wdata.value [7])))) # (\comb~2_combout  & (((state_wdata_7))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_7),
	.datad(!mo_wdatavalue_7),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~35_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~35 .extended_lut = "off";
defparam \data_array~35 .lut_mask = 64'h0527052705270527;
defparam \data_array~35 .shared_arith = "off";
// synopsys translate_on

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama7 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~35_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[4]~4_combout ,\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama7_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama7 .address_width = 5;
defparam \data_array_rtl_0|auto_generated|lutrama7 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama7 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama7 .first_bit_number = 7;
defparam \data_array_rtl_0|auto_generated|lutrama7 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama7 .last_address = 18;
defparam \data_array_rtl_0|auto_generated|lutrama7 .logical_ram_depth = 19;
defparam \data_array_rtl_0|auto_generated|lutrama7 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama7 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama7 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_lcell_comb \data_array~36 (
// Equation(s):
// \data_array~36_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\mo_wdata.value [8])))) # (\comb~2_combout  & (((state_wdata_8))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_8),
	.datad(!mo_wdatavalue_8),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~36_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~36 .extended_lut = "off";
defparam \data_array~36 .lut_mask = 64'h0527052705270527;
defparam \data_array~36 .shared_arith = "off";
// synopsys translate_on

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama8 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~36_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[4]~4_combout ,\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama8_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama8 .address_width = 5;
defparam \data_array_rtl_0|auto_generated|lutrama8 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama8 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama8 .first_bit_number = 8;
defparam \data_array_rtl_0|auto_generated|lutrama8 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama8 .last_address = 18;
defparam \data_array_rtl_0|auto_generated|lutrama8 .logical_ram_depth = 19;
defparam \data_array_rtl_0|auto_generated|lutrama8 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama8 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama8 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_lcell_comb \data_array~37 (
// Equation(s):
// \data_array~37_combout  = (!\comb~2_combout  & (\Equal0~0_combout  & ((\mo_wdata.sign~q )))) # (\comb~2_combout  & (((state_wdata_9))))

	.dataa(!comb),
	.datab(!\Equal0~0_combout ),
	.datac(!state_wdata_9),
	.datad(!mo_wdatasign),
	.datae(gnd),
	.dataf(gnd),
	.datag(gnd),
	.cin(gnd),
	.sharein(gnd),
	.combout(\data_array~37_combout ),
	.sumout(),
	.cout(),
	.shareout());
// synopsys translate_off
defparam \data_array~37 .extended_lut = "off";
defparam \data_array~37 .lut_mask = 64'h0527052705270527;
defparam \data_array~37 .shared_arith = "off";
// synopsys translate_on

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama9 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~37_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({\data_array.raddr_a[4]~4_combout ,\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout }),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array_rtl_0|auto_generated|lutrama9_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array_rtl_0|auto_generated|lutrama9 .address_width = 5;
defparam \data_array_rtl_0|auto_generated|lutrama9 .data_width = 1;
defparam \data_array_rtl_0|auto_generated|lutrama9 .first_address = 0;
defparam \data_array_rtl_0|auto_generated|lutrama9 .first_bit_number = 9;
defparam \data_array_rtl_0|auto_generated|lutrama9 .init_file = "none";
defparam \data_array_rtl_0|auto_generated|lutrama9 .last_address = 18;
defparam \data_array_rtl_0|auto_generated|lutrama9 .logical_ram_depth = 19;
defparam \data_array_rtl_0|auto_generated|lutrama9 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array_rtl_0|auto_generated|lutrama9 .logical_ram_width = 10;
defparam \data_array_rtl_0|auto_generated|lutrama9 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama9 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~37_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({maddr_4,maddr_3,maddr_2,maddr_1,maddr_0}),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array__dual_rtl_0|auto_generated|lutrama9_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|lutrama9 .address_width = 5;
defparam \data_array__dual_rtl_0|auto_generated|lutrama9 .data_width = 1;
defparam \data_array__dual_rtl_0|auto_generated|lutrama9 .first_address = 0;
defparam \data_array__dual_rtl_0|auto_generated|lutrama9 .first_bit_number = 9;
defparam \data_array__dual_rtl_0|auto_generated|lutrama9 .init_file = "none";
defparam \data_array__dual_rtl_0|auto_generated|lutrama9 .last_address = 18;
defparam \data_array__dual_rtl_0|auto_generated|lutrama9 .logical_ram_depth = 19;
defparam \data_array__dual_rtl_0|auto_generated|lutrama9 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array__dual_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array__dual_rtl_0|auto_generated|lutrama9 .logical_ram_width = 10;
defparam \data_array__dual_rtl_0|auto_generated|lutrama9 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama0 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~19_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({maddr_4,maddr_3,maddr_2,maddr_1,maddr_0}),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array__dual_rtl_0|auto_generated|lutrama0_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|lutrama0 .address_width = 5;
defparam \data_array__dual_rtl_0|auto_generated|lutrama0 .data_width = 1;
defparam \data_array__dual_rtl_0|auto_generated|lutrama0 .first_address = 0;
defparam \data_array__dual_rtl_0|auto_generated|lutrama0 .first_bit_number = 0;
defparam \data_array__dual_rtl_0|auto_generated|lutrama0 .init_file = "none";
defparam \data_array__dual_rtl_0|auto_generated|lutrama0 .last_address = 18;
defparam \data_array__dual_rtl_0|auto_generated|lutrama0 .logical_ram_depth = 19;
defparam \data_array__dual_rtl_0|auto_generated|lutrama0 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array__dual_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array__dual_rtl_0|auto_generated|lutrama0 .logical_ram_width = 10;
defparam \data_array__dual_rtl_0|auto_generated|lutrama0 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama1 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~29_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({maddr_4,maddr_3,maddr_2,maddr_1,maddr_0}),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array__dual_rtl_0|auto_generated|lutrama1_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|lutrama1 .address_width = 5;
defparam \data_array__dual_rtl_0|auto_generated|lutrama1 .data_width = 1;
defparam \data_array__dual_rtl_0|auto_generated|lutrama1 .first_address = 0;
defparam \data_array__dual_rtl_0|auto_generated|lutrama1 .first_bit_number = 1;
defparam \data_array__dual_rtl_0|auto_generated|lutrama1 .init_file = "none";
defparam \data_array__dual_rtl_0|auto_generated|lutrama1 .last_address = 18;
defparam \data_array__dual_rtl_0|auto_generated|lutrama1 .logical_ram_depth = 19;
defparam \data_array__dual_rtl_0|auto_generated|lutrama1 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array__dual_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array__dual_rtl_0|auto_generated|lutrama1 .logical_ram_width = 10;
defparam \data_array__dual_rtl_0|auto_generated|lutrama1 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama2 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~30_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({maddr_4,maddr_3,maddr_2,maddr_1,maddr_0}),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array__dual_rtl_0|auto_generated|lutrama2_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|lutrama2 .address_width = 5;
defparam \data_array__dual_rtl_0|auto_generated|lutrama2 .data_width = 1;
defparam \data_array__dual_rtl_0|auto_generated|lutrama2 .first_address = 0;
defparam \data_array__dual_rtl_0|auto_generated|lutrama2 .first_bit_number = 2;
defparam \data_array__dual_rtl_0|auto_generated|lutrama2 .init_file = "none";
defparam \data_array__dual_rtl_0|auto_generated|lutrama2 .last_address = 18;
defparam \data_array__dual_rtl_0|auto_generated|lutrama2 .logical_ram_depth = 19;
defparam \data_array__dual_rtl_0|auto_generated|lutrama2 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array__dual_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array__dual_rtl_0|auto_generated|lutrama2 .logical_ram_width = 10;
defparam \data_array__dual_rtl_0|auto_generated|lutrama2 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama3 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~31_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({maddr_4,maddr_3,maddr_2,maddr_1,maddr_0}),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array__dual_rtl_0|auto_generated|lutrama3_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|lutrama3 .address_width = 5;
defparam \data_array__dual_rtl_0|auto_generated|lutrama3 .data_width = 1;
defparam \data_array__dual_rtl_0|auto_generated|lutrama3 .first_address = 0;
defparam \data_array__dual_rtl_0|auto_generated|lutrama3 .first_bit_number = 3;
defparam \data_array__dual_rtl_0|auto_generated|lutrama3 .init_file = "none";
defparam \data_array__dual_rtl_0|auto_generated|lutrama3 .last_address = 18;
defparam \data_array__dual_rtl_0|auto_generated|lutrama3 .logical_ram_depth = 19;
defparam \data_array__dual_rtl_0|auto_generated|lutrama3 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array__dual_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array__dual_rtl_0|auto_generated|lutrama3 .logical_ram_width = 10;
defparam \data_array__dual_rtl_0|auto_generated|lutrama3 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama4 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~32_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({maddr_4,maddr_3,maddr_2,maddr_1,maddr_0}),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array__dual_rtl_0|auto_generated|lutrama4_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|lutrama4 .address_width = 5;
defparam \data_array__dual_rtl_0|auto_generated|lutrama4 .data_width = 1;
defparam \data_array__dual_rtl_0|auto_generated|lutrama4 .first_address = 0;
defparam \data_array__dual_rtl_0|auto_generated|lutrama4 .first_bit_number = 4;
defparam \data_array__dual_rtl_0|auto_generated|lutrama4 .init_file = "none";
defparam \data_array__dual_rtl_0|auto_generated|lutrama4 .last_address = 18;
defparam \data_array__dual_rtl_0|auto_generated|lutrama4 .logical_ram_depth = 19;
defparam \data_array__dual_rtl_0|auto_generated|lutrama4 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array__dual_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array__dual_rtl_0|auto_generated|lutrama4 .logical_ram_width = 10;
defparam \data_array__dual_rtl_0|auto_generated|lutrama4 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama5 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~33_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({maddr_4,maddr_3,maddr_2,maddr_1,maddr_0}),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array__dual_rtl_0|auto_generated|lutrama5_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|lutrama5 .address_width = 5;
defparam \data_array__dual_rtl_0|auto_generated|lutrama5 .data_width = 1;
defparam \data_array__dual_rtl_0|auto_generated|lutrama5 .first_address = 0;
defparam \data_array__dual_rtl_0|auto_generated|lutrama5 .first_bit_number = 5;
defparam \data_array__dual_rtl_0|auto_generated|lutrama5 .init_file = "none";
defparam \data_array__dual_rtl_0|auto_generated|lutrama5 .last_address = 18;
defparam \data_array__dual_rtl_0|auto_generated|lutrama5 .logical_ram_depth = 19;
defparam \data_array__dual_rtl_0|auto_generated|lutrama5 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array__dual_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array__dual_rtl_0|auto_generated|lutrama5 .logical_ram_width = 10;
defparam \data_array__dual_rtl_0|auto_generated|lutrama5 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama6 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~34_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({maddr_4,maddr_3,maddr_2,maddr_1,maddr_0}),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array__dual_rtl_0|auto_generated|lutrama6_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|lutrama6 .address_width = 5;
defparam \data_array__dual_rtl_0|auto_generated|lutrama6 .data_width = 1;
defparam \data_array__dual_rtl_0|auto_generated|lutrama6 .first_address = 0;
defparam \data_array__dual_rtl_0|auto_generated|lutrama6 .first_bit_number = 6;
defparam \data_array__dual_rtl_0|auto_generated|lutrama6 .init_file = "none";
defparam \data_array__dual_rtl_0|auto_generated|lutrama6 .last_address = 18;
defparam \data_array__dual_rtl_0|auto_generated|lutrama6 .logical_ram_depth = 19;
defparam \data_array__dual_rtl_0|auto_generated|lutrama6 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array__dual_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array__dual_rtl_0|auto_generated|lutrama6 .logical_ram_width = 10;
defparam \data_array__dual_rtl_0|auto_generated|lutrama6 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama7 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~35_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({maddr_4,maddr_3,maddr_2,maddr_1,maddr_0}),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array__dual_rtl_0|auto_generated|lutrama7_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|lutrama7 .address_width = 5;
defparam \data_array__dual_rtl_0|auto_generated|lutrama7 .data_width = 1;
defparam \data_array__dual_rtl_0|auto_generated|lutrama7 .first_address = 0;
defparam \data_array__dual_rtl_0|auto_generated|lutrama7 .first_bit_number = 7;
defparam \data_array__dual_rtl_0|auto_generated|lutrama7 .init_file = "none";
defparam \data_array__dual_rtl_0|auto_generated|lutrama7 .last_address = 18;
defparam \data_array__dual_rtl_0|auto_generated|lutrama7 .logical_ram_depth = 19;
defparam \data_array__dual_rtl_0|auto_generated|lutrama7 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array__dual_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array__dual_rtl_0|auto_generated|lutrama7 .logical_ram_width = 10;
defparam \data_array__dual_rtl_0|auto_generated|lutrama7 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama8 (
	.clk0(clk),
	.clk1(gnd),
	.ena0(\data_array~18_combout ),
	.ena1(vcc),
	.ena2(vcc),
	.clr(gnd),
	.portadatain({\data_array~36_combout }),
	.portaaddr({\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout }),
	.portabyteenamasks(1'b1),
	.portbaddr({maddr_4,maddr_3,maddr_2,maddr_1,maddr_0}),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(\data_array__dual_rtl_0|auto_generated|lutrama8_PORTBDATAOUT_bus ));
// synopsys translate_off
defparam \data_array__dual_rtl_0|auto_generated|lutrama8 .address_width = 5;
defparam \data_array__dual_rtl_0|auto_generated|lutrama8 .data_width = 1;
defparam \data_array__dual_rtl_0|auto_generated|lutrama8 .first_address = 0;
defparam \data_array__dual_rtl_0|auto_generated|lutrama8 .first_bit_number = 8;
defparam \data_array__dual_rtl_0|auto_generated|lutrama8 .init_file = "none";
defparam \data_array__dual_rtl_0|auto_generated|lutrama8 .last_address = 18;
defparam \data_array__dual_rtl_0|auto_generated|lutrama8 .logical_ram_depth = 19;
defparam \data_array__dual_rtl_0|auto_generated|lutrama8 .logical_ram_name = "emu:emu|system:system|opll:fm|outputgenerator:og|outputmemory:mmem|altdpram:data_array__dual_rtl_0|dpram_vpp1:auto_generated|altdpram_instance";
defparam \data_array__dual_rtl_0|auto_generated|lutrama8 .logical_ram_width = 10;
defparam \data_array__dual_rtl_0|auto_generated|lutrama8 .mixed_port_feed_through_mode = "dont care";
// synopsys translate_on

endmodule
