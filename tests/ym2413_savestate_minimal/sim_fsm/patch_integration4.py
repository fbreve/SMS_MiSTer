with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv', 'rb') as f:
    tb = f.read()

target = b"""        // Canal 0: User Voice (inst 0), F-number = 8'h91, Block = 1, Key-On = 1
        write_opll(8'h10, 8'h91); // F-number low
        write_opll(8'h30, 8'h00); // Voice 0 (User), volume 0
        write_opll(8'h20, 8'h19); // Key-On, Block 1, F-number high 1"""

replacement = b"""        $display("   [DEBUG PROBE INIT] opllptr=%02x, opllwr=%0b", dut_opll.opllptr, dut_opll.opllwr);
        write_opll(8'h10, 8'h91);
        $display("   [DEBUG PROBE 10] opllptr=%02x, opllwr=%0b, regs_array[0]=%06h",
                 dut_opll.opllptr, dut_opll.opllwr, dut_opll.ct.u_register_memory.regs_array[0]);
        write_opll(8'h30, 8'h00);
        $display("   [DEBUG PROBE 30] opllptr=%02x, opllwr=%0b, regs_array[0]=%06h",
                 dut_opll.opllptr, dut_opll.opllwr, dut_opll.ct.u_register_memory.regs_array[0]);
        write_opll(8'h20, 8'h19);
        $display("   [DEBUG PROBE 20] opllptr=%02x, opllwr=%0b, regs_array[0]=%06h",
                 dut_opll.opllptr, dut_opll.opllwr, dut_opll.ct.u_register_memory.regs_array[0]);"""

if target in tb:
    tb = tb.replace(target, replacement, 1)
    with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv', 'wb') as f:
        f.write(tb)
    print('SUCCESS')
else:
    print('NOT FOUND')

