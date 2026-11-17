with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv', 'rb') as f:
    tb = f.read()

target = b"""        $display("[CHECK] Verificando se nota sustentada continuou e mixout estavel...");
        begin : check_mixout"""

replacement = b"""        $display("   [DEBUG POST-LOAD] Ch0 regs_array=%06h, Env0 egdata_set=%07h",
                 dut_opll.ct.u_register_memory.regs_array[0], dut_opll.eg.u_envelope_memory.egdata_set[0]);
        $display("[CHECK] Verificando se nota sustentada continuou e mixout estavel...");
        begin : check_mixout"""

if target in tb:
    tb = tb.replace(target, replacement, 1)
    with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv', 'wb') as f:
        f.write(tb)
    print('SUCCESS')
else:
    print('NOT FOUND')

