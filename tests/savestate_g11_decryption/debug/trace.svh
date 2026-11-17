always@(posedge clk)if(reset_n&&cpu_ce&&!crd&&!cmreq&&cpu.TState==2)begin
 $display("STARTUP cycle%0d A%h op%b byte%h encoded%h intended%h mask%b CPU%h IR%h ISET%b ALT%b",cycle,ca,!cm1,decoded,sd,chip.program_bytes[ca],chip.opmask[ca],z80_reg,cpu.u0.IR,cpu.u0.ISet,cpu.u0.Alternate);
end
initial begin #500000;$display("PASS DEBUG TRACE ONLY");$finish;end
always@(posedge clk)if(cpu_ce&&cycle>=9900&&cycle<=10690)$display("CORE cycle%0d MC%0d TS%0d IR%h ex%b pref%b ce%b Mode%0d ISET%b XY%b Alt%b",cycle,cpu.MCycle,cpu.TState,cpu.u0.IR,cpu.u0.ExchangeRS,cpu.u0.Prefix,cpu.u0.ClkEn,cpu.u0.Mode,cpu.u0.ISet,cpu.u0.XY_State,cpu.u0.Alternate);
