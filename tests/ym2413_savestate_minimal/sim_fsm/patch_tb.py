with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_rigorous_validation.sv', 'r', encoding='utf-8') as f:
    tb = f.read()

target = """        // Inspecionar imediatamente se Channel 0 preservou o valor restaurado
        $display("   Inspecionando regs_array(0) imediatamente pos-unfreeze: %06h", dut_opll.ct.u_register_memory.regs_array[0]);
        if (dut_opll.ct.u_register_memory.regs_array[0] !== 24'h00041180) begin
            $fatal(1, "Channel 0 foi corrompido por stale write!");
        end"""

replacement = """        // Inspecionar imediatamente se Channel 0 preservou o valor restaurado
        $display("   Inspecionando regs_array(0) imediatamente pos-unfreeze: %06h (Esperado: %06h)",
                 dut_opll.ct.u_register_memory.regs_array[0],
                 {expected_words[0][21:14], 2'b00, expected_words[0][13:0]});
        if (dut_opll.ct.u_register_memory.regs_array[0] !== {expected_words[0][21:14], 2'b00, expected_words[0][13:0]}) begin
            $fatal(1, "Channel 0 foi corrompido por stale write!");
        end"""

if target in tb:
    tb = tb.replace(target, replacement, 1)
    with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_rigorous_validation.sv', 'w', encoding='utf-8') as f:
        f.write(tb)
    print('SUCCESS')
else:
    print('TARGET NOT FOUND')
