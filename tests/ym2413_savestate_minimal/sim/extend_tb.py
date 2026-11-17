import re

p = 'tests/ym2413_savestate_minimal/sim/tb_ym2413_diff.sv'
with open(p, 'r') as f:
    c = f.read()

target = '''        $display("[METRICA FRAME 2] Amostras divergentes: %0d / 5000 | Diferença máxima: %0d", diff_count_frame2, max_abs_diff_frame2);'''

addition = '''        $display("[METRICA FRAME 2] Amostras divergentes: %0d / 5000 | Diferença máxima: %0d", diff_count_frame2, max_abs_diff_frame2);

        // Frame 3 (Avança mais 100.000 clocks)
        repeat (100000) tick;
        diff_count_frame2 = 0; max_abs_diff_frame2 = 0;
        for (sample_idx = 0; sample_idx < 5000; sample_idx = sample_idx + 1) begin
            tick;
            if (mixout_dut !== mixout_ref) begin
                integer d;
                d = mixout_dut - mixout_ref;
                if (d < 0) d = -d;
                diff_count_frame2 = diff_count_frame2 + 1;
                if (d > max_abs_diff_frame2) max_abs_diff_frame2 = d;
            end
        end
        $display("[METRICA FRAME 3 / ~3ms] Amostras divergentes: %0d / 5000 | Diferença máxima: %0d", diff_count_frame2, max_abs_diff_frame2);

        // Frame 4 (Avança mais 200.000 clocks)
        repeat (200000) tick;
        diff_count_frame2 = 0; max_abs_diff_frame2 = 0;
        for (sample_idx = 0; sample_idx < 5000; sample_idx = sample_idx + 1) begin
            tick;
            if (mixout_dut !== mixout_ref) begin
                integer d;
                d = mixout_dut - mixout_ref;
                if (d < 0) d = -d;
                diff_count_frame2 = diff_count_frame2 + 1;
                if (d > max_abs_diff_frame2) max_abs_diff_frame2 = d;
            end
        end
        $display("[METRICA FRAME 4 / ~7ms] Amostras divergentes: %0d / 5000 | Diferença máxima: %0d", diff_count_frame2, max_abs_diff_frame2);'''

c = c.replace(target, addition)
with open(p, 'w') as f:
    f.write(c)
print('Updated tb_ym2413_diff.sv')

