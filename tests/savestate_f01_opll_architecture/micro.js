const fs=require('fs'),p=require('path'),d=__dirname;
const settings=fs.readFileSync(p.resolve(d,'../../SMS.qsf'),'utf8').split(/\r?\n/).filter(l=>l.startsWith('set_global_assignment')&&!/TOP_LEVEL_ENTITY|PRE_FLOW_SCRIPT|POST_FLOW_SCRIPT|QIP_FILE|SDC_FILE/.test(l)).join('\n');
const header=`module micro(input clk,run,load,capture,shift,input[5:0]addr,input[31:0]bus,input[2047:0]din,input[2047:0]restore,output reg[2047:0]q,output[31:0]dout);\n`;
const variants={
 base:header+`always@(posedge clk)if(run)q<=din;assign dout=q[31:0];endmodule`,
 parallel:header+`reg[2047:0]snap;always@(posedge clk)begin if(load)q<=restore;else if(run)q<=din;if(capture)snap<=q;else if(shift)snap<={bus,snap[2047:32]};end assign dout=snap[31:0];endmodule`,
 ce:header+`always@(posedge clk)if(load||run)q<=load?restore:din;assign dout=q[31:0];endmodule`,
 sequential:header+`genvar i;generate for(i=0;i<64;i=i+1)begin:wordbank always@(posedge clk)if(load&&addr==i)q[i*32+:32]<=bus;else if(run)q[i*32+:32]<=din[i*32+:32];end endgenerate assign dout=q[addr*32+:32];endmodule`,
 scan:header+`always@(posedge clk)if(shift)q<={bus,q[2047:32]};else if(run)q<=din;assign dout=q[31:0];endmodule`,
 ram:`module micro(input clk,wr,input[5:0]addr,raddr,input[31:0]bus,output reg[31:0]dout);(* ramstyle="M10K" *)reg[31:0]mem[0:63];always@(posedge clk)begin if(wr)mem[addr]<=bus;dout<=mem[raddr];end endmodule`,
 dualram:`module micro(input clk,wr,bank,input[5:0]addr,raddr,input[31:0]bus,output reg[31:0]dout);(* ramstyle="M10K" *)reg[31:0]mem[0:127];always@(posedge clk)begin if(wr)mem[{bank,addr}]<=bus;dout<=mem[{!bank,raddr}];end endmodule`,
 fullram:`module micro(input clk,wr,input[7:0]addr,raddr,input[31:0]bus,output reg[31:0]dout);(* ramstyle="M10K" *)reg[31:0]mem[0:255];always@(posedge clk)begin if(wr)mem[addr]<=bus;dout<=mem[raddr];end endmodule`
};
for(const[n,s]of Object.entries(variants)){let dir=p.join(d,'micro_'+n);fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p.join(dir,'micro.sv'),s);fs.writeFileSync(p.join(dir,'micro.qpf'),'PROJECT_REVISION = "micro"\n');fs.writeFileSync(p.join(dir,'micro.qsf'),settings+'\nset_global_assignment -name FAMILY "Cyclone V"\nset_global_assignment -name DEVICE 5CSEBA6U23I7\nset_global_assignment -name TOP_LEVEL_ENTITY micro\nset_global_assignment -name SYSTEMVERILOG_FILE micro.sv\nset_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files\nset_instance_assignment -name VIRTUAL_PIN ON -to *\n');}
