`timescale 1ns/1ps
module mapped_output_cut(input clk,input we,input out_en,input [4:0] wa,ra0,ra1,input [9:0] data,output [9:0] q0,q1);
wire dataout_reg_0;
wire dataout_reg_1;
wire dataout_reg_2;
wire dataout_reg_3;
wire dataout_reg_4;
wire dataout_reg_5;
wire dataout_reg_6;
wire dataout_reg_7;
wire dataout_reg_8;
wire dataout_reg_9;
wire mo_wdatavalue_0;
wire mo_wdatavalue_1;
wire mo_wdatavalue_2;
wire mo_wdatavalue_3;
wire mo_wdatavalue_4;
wire mo_wdatavalue_5;
wire mo_wdatavalue_6;
wire mo_wdatavalue_7;
wire mo_wdatavalue_8;
wire mo_wdatasign;
wire dataout_reg_91;
wire dataout_reg_01;
wire dataout_reg_11;
wire dataout_reg_21;
wire dataout_reg_31;
wire dataout_reg_41;
wire dataout_reg_51;
wire dataout_reg_61;
wire dataout_reg_71;
wire dataout_reg_81;
wire ram_clr_run;
wire raw_reset;
wire raw_reset1;
wire ss_mem_ready1;
wire stateLEG_RESET;
wire reset;
wire index_6;
wire index_1;
wire index_3;
wire index_2;
wire stateAP_WRITE;
wire state_addr_3;
wire state_addr;
wire LessThan1;
wire state_addr_4;
wire comb;
wire state_addr_0;
wire Mux56;
wire state_addr_6;
wire state_addr_2;
wire state_addr_7;
wire ss_mem_active;
wire LessThan11;
wire state_addr_1;
wire state_wdata_0;
wire Add1;
wire state_wdata_1;
wire maddr_0;
wire mo_wr;
wire state_wdata_2;
wire maddr_1;
wire state_wdata_3;
wire maddr_2;
wire state_wdata_4;
wire maddr_3;
wire state_wdata_5;
wire maddr_4;
wire state_wdata_6;
wire mo_addr_0;
wire state_wdata_7;
wire mo_addr_1;
wire state_wdata_8;
wire mo_addr_2;
wire state_wdata_9;
wire mo_addr_3;
wire mo_addr_4;
wire index_7;
wire index_5;
wire index_4;
wire devpor;
wire devclrn;
wire devoe;
wire gnd;
wire vcc;
wire unknown;
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
wire \init_ch[1]~DUPLICATE_q ;
wire \init_ch[2]~4_combout ;
wire \init_ch[3]~0_combout ;
wire \init_ch[3]~DUPLICATE_q ;
wire \init_ch[4]~2_combout ;
wire \init_ch[4]~DUPLICATE_q ;
wire \data_array~16_combout ;
wire \Equal0~0_combout ;
wire \data_array~17_combout ;
wire \data_array~18_combout ;
wire \data_array~19_combout ;
wire \data_array~20_combout ;
wire \ss_mem_active~0_combout ;
wire \LessThan1~0_combout ;
wire \ss_mem_index~0_combout ;
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
assign gnd = 1'b0;
assign vcc = 1'b1;
assign unknown = 1'bx;
assign dataout_reg_0 = \data_array_rtl_0|auto_generated|lutrama0_PORTBDATAOUT_bus [0];
assign dataout_reg_1 = \data_array_rtl_0|auto_generated|lutrama1_PORTBDATAOUT_bus [0];
assign dataout_reg_2 = \data_array_rtl_0|auto_generated|lutrama2_PORTBDATAOUT_bus [0];
assign dataout_reg_3 = \data_array_rtl_0|auto_generated|lutrama3_PORTBDATAOUT_bus [0];
assign dataout_reg_4 = \data_array_rtl_0|auto_generated|lutrama4_PORTBDATAOUT_bus [0];
assign dataout_reg_5 = \data_array_rtl_0|auto_generated|lutrama5_PORTBDATAOUT_bus [0];
assign dataout_reg_6 = \data_array_rtl_0|auto_generated|lutrama6_PORTBDATAOUT_bus [0];
assign dataout_reg_7 = \data_array_rtl_0|auto_generated|lutrama7_PORTBDATAOUT_bus [0];
assign dataout_reg_8 = \data_array_rtl_0|auto_generated|lutrama8_PORTBDATAOUT_bus [0];
assign dataout_reg_9 = \data_array_rtl_0|auto_generated|lutrama9_PORTBDATAOUT_bus [0];
assign dataout_reg_91 = \data_array__dual_rtl_0|auto_generated|lutrama9_PORTBDATAOUT_bus [0];
assign dataout_reg_01 = \data_array__dual_rtl_0|auto_generated|lutrama0_PORTBDATAOUT_bus [0];
assign dataout_reg_11 = \data_array__dual_rtl_0|auto_generated|lutrama1_PORTBDATAOUT_bus [0];
assign dataout_reg_21 = \data_array__dual_rtl_0|auto_generated|lutrama2_PORTBDATAOUT_bus [0];
assign dataout_reg_31 = \data_array__dual_rtl_0|auto_generated|lutrama3_PORTBDATAOUT_bus [0];
assign dataout_reg_41 = \data_array__dual_rtl_0|auto_generated|lutrama4_PORTBDATAOUT_bus [0];
assign dataout_reg_51 = \data_array__dual_rtl_0|auto_generated|lutrama5_PORTBDATAOUT_bus [0];
assign dataout_reg_61 = \data_array__dual_rtl_0|auto_generated|lutrama6_PORTBDATAOUT_bus [0];
assign dataout_reg_71 = \data_array__dual_rtl_0|auto_generated|lutrama7_PORTBDATAOUT_bus [0];
assign dataout_reg_81 = \data_array__dual_rtl_0|auto_generated|lutrama8_PORTBDATAOUT_bus [0];
assign reset=~out_en;assign devclrn=1'b1;assign devpor=1'b1;assign devoe=1'b1;
assign {\data_array.raddr_a[4]~4_combout ,\data_array.raddr_a[3]~3_combout ,\data_array.raddr_a[2]~2_combout ,\data_array.raddr_a[1]~1_combout ,\data_array.raddr_a[0]~0_combout } = ra0;
assign {maddr_4,maddr_3,maddr_2,maddr_1,maddr_0} = ra1;
assign {\data_array~28_combout ,\data_array~26_combout ,\data_array~24_combout ,\data_array~22_combout ,\data_array~21_combout } = wa;
assign \data_array~18_combout = we;
assign {\data_array~19_combout } = data[0];
assign {\data_array~29_combout } = data[1];
assign {\data_array~30_combout } = data[2];
assign {\data_array~31_combout } = data[3];
assign {\data_array~32_combout } = data[4];
assign {\data_array~33_combout } = data[5];
assign {\data_array~34_combout } = data[6];
assign {\data_array~35_combout } = data[7];
assign {\data_array~36_combout } = data[8];
assign {\data_array~37_combout } = data[9];
assign q0[0] = \data_array_rtl_0|auto_generated|lutrama0_PORTBDATAOUT_bus [0];
assign q0[1] = \data_array_rtl_0|auto_generated|lutrama1_PORTBDATAOUT_bus [0];
assign q0[2] = \data_array_rtl_0|auto_generated|lutrama2_PORTBDATAOUT_bus [0];
assign q0[3] = \data_array_rtl_0|auto_generated|lutrama3_PORTBDATAOUT_bus [0];
assign q0[4] = \data_array_rtl_0|auto_generated|lutrama4_PORTBDATAOUT_bus [0];
assign q0[5] = \data_array_rtl_0|auto_generated|lutrama5_PORTBDATAOUT_bus [0];
assign q0[6] = \data_array_rtl_0|auto_generated|lutrama6_PORTBDATAOUT_bus [0];
assign q0[7] = \data_array_rtl_0|auto_generated|lutrama7_PORTBDATAOUT_bus [0];
assign q0[8] = \data_array_rtl_0|auto_generated|lutrama8_PORTBDATAOUT_bus [0];
assign q0[9] = \data_array_rtl_0|auto_generated|lutrama9_PORTBDATAOUT_bus [0];
assign q1[9] = \data_array__dual_rtl_0|auto_generated|lutrama9_PORTBDATAOUT_bus [0];
assign q1[0] = \data_array__dual_rtl_0|auto_generated|lutrama0_PORTBDATAOUT_bus [0];
assign q1[1] = \data_array__dual_rtl_0|auto_generated|lutrama1_PORTBDATAOUT_bus [0];
assign q1[2] = \data_array__dual_rtl_0|auto_generated|lutrama2_PORTBDATAOUT_bus [0];
assign q1[3] = \data_array__dual_rtl_0|auto_generated|lutrama3_PORTBDATAOUT_bus [0];
assign q1[4] = \data_array__dual_rtl_0|auto_generated|lutrama4_PORTBDATAOUT_bus [0];
assign q1[5] = \data_array__dual_rtl_0|auto_generated|lutrama5_PORTBDATAOUT_bus [0];
assign q1[6] = \data_array__dual_rtl_0|auto_generated|lutrama6_PORTBDATAOUT_bus [0];
assign q1[7] = \data_array__dual_rtl_0|auto_generated|lutrama7_PORTBDATAOUT_bus [0];
assign q1[8] = \data_array__dual_rtl_0|auto_generated|lutrama8_PORTBDATAOUT_bus [0];
cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama0 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array_rtl_0|auto_generated|lutrama0 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y12_N30

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama1 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array_rtl_0|auto_generated|lutrama1 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y12_N24

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama2 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array_rtl_0|auto_generated|lutrama2 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y12_N54

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama3 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array_rtl_0|auto_generated|lutrama3 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y12_N36

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama4 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array_rtl_0|auto_generated|lutrama4 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y12_N6

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama5 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array_rtl_0|auto_generated|lutrama5 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y12_N12

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama6 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array_rtl_0|auto_generated|lutrama6 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y12_N42

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama7 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array_rtl_0|auto_generated|lutrama7 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y12_N0

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama8 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array_rtl_0|auto_generated|lutrama8 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y12_N18

cyclonev_mlab_cell \data_array_rtl_0|auto_generated|lutrama9 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array_rtl_0|auto_generated|lutrama9 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y14_N36

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama9 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array__dual_rtl_0|auto_generated|lutrama9 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y14_N42

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama0 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array__dual_rtl_0|auto_generated|lutrama0 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y14_N0

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama1 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array__dual_rtl_0|auto_generated|lutrama1 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y14_N18

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama2 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array__dual_rtl_0|auto_generated|lutrama2 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y14_N24

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama3 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array__dual_rtl_0|auto_generated|lutrama3 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y14_N30

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama4 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array__dual_rtl_0|auto_generated|lutrama4 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y14_N48

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama5 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array__dual_rtl_0|auto_generated|lutrama5 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y14_N6

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama6 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array__dual_rtl_0|auto_generated|lutrama6 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y14_N12

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama7 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array__dual_rtl_0|auto_generated|lutrama7 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: MLABCELL_X72_Y14_N54

cyclonev_mlab_cell \data_array__dual_rtl_0|auto_generated|lutrama8 (
	.clk0(clk),
	.clk1(clk),
	.ena0(\data_array~18_combout ),
	.ena1(!reset),
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
defparam \data_array__dual_rtl_0|auto_generated|lutrama8 .port_b_data_out_clock = "clock1";
// synopsys translate_on

// Location: FF_X73_Y12_N52

endmodule
