`timescale 1ns/1ps
module ram_equivalence_tb;
reg clk=0;always #5 clk=~clk;
reg [3:0] a=0,b=0;reg [7:0] data=0;reg we=0;
wire [7:0] qa,qb,va,vb;
dpram #(.widthad_a(4),.mixed_port_rdwr("OLD_DATA")) behavioral(.clock_a(clk),.clock_b(clk),.address_a(a),.address_b(b),.data_a(data),.data_b(8'd0),.wren_a(we),.wren_b(1'b0),.q_a(qa),.q_b(qb));
dpram_vendor #(.widthad_a(4),.mixed_port_rdwr("OLD_DATA")) vendor(.clock_a(clk),.clock_b(clk),.address_a(a),.address_b(b),.data_a(data),.data_b(8'd0),.wren_a(we),.wren_b(1'b0),.q_a(va),.q_b(vb));
initial begin
 for(integer n=0;n<128;n++)begin
  @(negedge clk);a=n%16;b=n%4==0?a:(n*3)%16;data=n*37;we=n%3!=0;
  @(posedge clk);#1;if({qa,qb}!=={va,vb})$fatal(1,"RAM mismatch n=%0d A=%h/%h B=%h/%h",n,qa,va,qb,vb);
 end
 $display("PASS RAM equivalence: 128 read/write cycles including OLD_DATA mixed-port collisions and NEW_DATA same-port writes");$finish;
end
endmodule
