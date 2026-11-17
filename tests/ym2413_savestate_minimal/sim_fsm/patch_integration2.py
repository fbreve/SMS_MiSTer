with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv', 'rb') as f:
    tb = f.read()

target = b"""        // Deixar oscilar por 10.000 clocks para que o envelope entre na fase de sustain
        repeat(10000) tick;"""

replacement = b"""        // Deixar oscilar por 10.000 clocks para que o envelope entre na fase de sustain
        repeat(10000) tick;
        $display("   [DEBUG PRE-SAVE] mixout=%04x, Ch0 regs_array=%06h, Env0 egdata_set=%07h",
                 opll_mixout, dut_opll.ct.u_register_memory.regs_array[0], dut_opll.eg.u_envelope_memory.egdata_set[0]);"""

if target in tb:
    tb = tb.replace(target, replacement, 1)
    with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv', 'wb') as f:
        f.write(tb)
    print('SUCCESS')
else:
    print('NOT FOUND')

