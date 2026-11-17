`timescale 1ns/1ps
// Structural probe of Quartus-generated dpram_iop1.tdf: asynchronous MLAB
// read, common write/output clock and external enabled output registers.
// This is a vendor-primitive check, not a complete mapped-netlist simulation.
module mlab_collision_tb;
reg clk=0, we=0, outen=1;
reg [3:0] wa=0,ra=0;
reg [23:0] data=0;
wire [23:0] raw;
reg [23:0] q;
genvar b;
generate for(b=0;b<24;b=b+1)begin:bitslice
 cyclonev_mlab_cell #(.address_width(4),.data_width(1),
 .first_address(0),.last_address(8),.first_bit_number(b),
 .logical_ram_depth(9),.logical_ram_width(24),
 .mixed_port_feed_through_mode("dont care")) ram(
 .clk0(clk),.clk1(1'b0),.ena0(we),.ena1(1'b1),.ena2(1'b1),
 .clr(1'b0),.devclrn(1'b1),.devpor(1'b1),.portabyteenamasks(1'b1),
 .portaaddr(wa),.portadatain(data[b]),.portbaddr(ra),.portbdataout(raw[b]));
end endgenerate
always @(posedge clk)if(outen)q<=raw;
reg [23:0] model[0:8];reg [23:0] expected;reg [8:0] valid=0;reg expected_valid=0;
integer cycles=0,checks=0,collisions=0,disabled=0,i;
task step(input integer writeaddr,readaddr,input [23:0] value,input writing,enabling);
begin
 clk=0;wa=writeaddr;ra=readaddr;data=value;we=writing;outen=enabling;
 #3;
 if(enabling)begin expected=model[readaddr];expected_valid=valid[readaddr];end
 clk=1;
 if(writing)begin model[writeaddr]=value;valid[writeaddr]=1;if(writeaddr==readaddr)collisions=collisions+1;end
 if(!enabling)disabled=disabled+1;
 #2;
 if(expected_valid&&q!==expected)$fatal(1,"OLD_DATA mismatch cycle=%0d wa=%0d ra=%0d q=%h expected=%h",cycles,wa,ra,q,expected);
 if(expected_valid)checks=checks+1;clk=0;#3;
 if(expected_valid&&q!==expected)$fatal(1,"registered output changed away from edge");
 if(expected_valid)checks=checks+1;cycles=cycles+1;
end endtask
initial begin
 for(i=0;i<9;i=i+1)model[i]=24'hxxxxxx;
 expected=24'hxxxxxx;
 for(i=0;i<9;i=i+1)step(i,i,0,1,1);
 for(i=0;i<4096;i=i+1)begin
  step(i%9,i%9,(24'h800000^i*24'h13579),1,1);
  step(i%9,(i+1)%9,~(i*24'h2468b),1,i%7!=0);
  step(i%9,i%9,0,0,1);
 end
 if(collisions<4096||disabled<500)$fatal(1,"coverage missing");
 $display("PASS VENDOR MLAB OLD_DATA cycles=%0d checks=%0d collisions=%0d disabled=%0d",cycles,checks,collisions,disabled);
 $finish;
end
initial begin #1000000;$fatal(1,"vendor probe timeout");end
endmodule
