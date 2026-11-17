module md_gap_tb;
reg clk=0, refclk=0, runref=1, reset=1, th=1, freeze=0,ss_set=0;
always #5 begin clk=~clk; if(runref) refclk=~refclk; end
wire [5:0] pins,refpins;wire [11:0]state,refstate;reg[11:0]saved;
sega_controller #(.TIMEOUT_CYCLES(64)) dut(clk,reset,2'd2,6'b111111,th,1'b0,1'b0,1'b1,1'b1,1'b1,1'b1,pins,freeze,ss_set,1'b1,saved,state);
sega_controller #(.TIMEOUT_CYCLES(64)) reference(refclk,reset,2'd2,6'b111111,th,1'b0,1'b0,1'b1,1'b1,1'b1,1'b1,refpins,1'b0,1'b0,1'b0,12'd0,refstate);
initial begin
 repeat(4) @(negedge clk); reset=0;
 repeat(3) begin th=0; repeat(3) @(negedge clk); th=1; repeat(3) @(negedge clk); end
 if(pins!==6'b110000) $fatal(1,"setup failed");
 saved=state;runref=0;repeat(70)@(negedge clk);
 if(pins!==6'b111111 || refpins!==6'b110000)$fatal(1,"perturbation missing");
 freeze=1;ss_set=1;@(negedge clk);ss_set=0;
 if(pins!==refpins||state!==saved)$fatal(1,"F08 restore failed");
 $display("PASS md_gap_tb (original F08 scenario now restores third-rise XYZ/Mode)");$finish;
end endmodule
