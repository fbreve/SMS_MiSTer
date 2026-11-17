with open('tests/ym2413_savestate_minimal/sim/tb_ym2413_diff.sv', 'r', encoding='latin-1') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    new_lines.append(line)
    if '[METRICA FRAME 2]' in line:
        new_lines.append('''
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
        $display("[METRICA FRAME 4 / ~7ms] Amostras divergentes: %0d / 5000 | Diferença máxima: %0d", diff_count_frame2, max_abs_diff_frame2);
''')

with open('tests/ym2413_savestate_minimal/sim/tb_ym2413_diff.sv', 'w', encoding='latin-1') as f:
    f.writelines(new_lines)
print('Successfully extended tb_ym2413_diff.sv via script')

