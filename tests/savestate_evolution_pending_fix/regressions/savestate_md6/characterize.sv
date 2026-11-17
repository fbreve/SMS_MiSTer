module characterize;
parameter T=64;
reg clk=0,reset=1,th=1; always #5 clk=~clk;
wire [5:0] pins;
sega_controller #(.TIMEOUT_CYCLES(T)) dut(.clk(clk),.reset(reset),.controller_type(2'd2),.sms_pins(6'b111111),.th(th),.md_a(1'b0),.md_start(1'b0),.md_x(1'b1),.md_y(1'b1),.md_z(1'b1),.md_mode(1'b1),.pins(pins));
task tick; begin @(negedge clk); end endtask
integer phase;
initial begin
 for(phase=0;phase<=4;phase=phase+1)begin
 reset=1;repeat(3)tick;reset=0;repeat(2)tick;
 repeat(phase)begin th=0;repeat(2)tick;th=1;tick;end
 $display("BEFORE T=%0d phase=%0d timer=%0d rises=%0d TH=%b pins=%b",T,phase,dut.timer,dut.rises,th,pins);
 while(dut.timer<T-2)tick;
 $display("PRE timeout timer=%0d rises=%0d pins=%b",dut.timer,dut.rises,pins);
 tick;$display("AT terminal timer=%0d rises=%0d pins=%b",dut.timer,dut.rises,pins);
 tick;$display("POST timeout timer=%0d rises=%0d pins=%b",dut.timer,dut.rises,pins);
 if(dut.rises!==0)$fatal(1,"timeout not reached");
 end
 $display("PASS characterization T=%0d",T);$finish;
end
endmodule
