with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv') as f:
    text = f.read()

target = "    // Instantiate OPLL\n"
diag = """    always @(posedge clk) begin
        if (dut_opll.opllwr) begin
            $display("   [MONITOR opllwr=1] time=%0t opllptr=%02x oplldat=%02x slot=%0d stage=%0d regs_wr=%0b",
                     $time, dut_opll.opllptr, dut_opll.oplldat, dut_opll.slot, dut_opll.stage, dut_opll.ct.regs_wr);
        end
        if (dut_opll.ct.regs_wr) begin
            $display("   [MONITOR regs_wr=1] time=%0t regs_addr=%0d regs_wdata=%06h",
                     $time, dut_opll.ct.regs_addr, dut_opll.ct.regs_wdata);
        end
    end
"""
assert target in text
text = text.replace(target, target + diag, 1)

with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv', 'w') as f:
    f.write(text)
print("Added monitor successfully.")

