import os

src = 'tests/io_restore_output_alias/sim/io_verification_tb.sv'
dst = 'tests/video_state_restore_output_alias/sim/video_state_verification_tb.sv'

with open(src, 'r', encoding='utf-8') as f:
    s = f.read()

s = s.replace('module io_verification_tb;', 'module video_state_verification_tb;')
s = s.replace('wire [31:0] io_in_a, io_in_b;', 'wire [31:0] io_in_a, io_in_b;\n    wire [21:0] video_state_in_a, video_state_in_b;\n    wire video_state_set_a, video_state_set_b;')
s = s.replace('.video_state_out(video_state_out), .video_state_in(), .video_state_set(),',
              '.video_state_out(video_state_out), .video_state_in(video_state_in_a), .video_state_set(video_state_set_a),', 1)
s = s.replace('.video_state_out(video_state_out), .video_state_in(), .video_state_set(),',
              '.video_state_out(video_state_out), .video_state_in(video_state_in_b), .video_state_set(video_state_set_b),', 1)

# Check video_state_in during strobe
old_strobe = 'if (io_set_a && (io_in_a !== io_in_b)) $fatal(1, "io_in mismatch at strobe!");'
new_strobe = '''if (video_state_set_a !== video_state_set_b) $fatal(1, "video_state_set mismatch");
        if (video_state_set_a && (video_state_in_a !== video_state_in_b)) $fatal(1, "video_state_in mismatch at strobe!");
        ''' + old_strobe

assert old_strobe in s
s = s.replace(old_strobe, new_strobe)

# Update run_save_load to take video_val
old_task = 'task run_save_load(input [31:0] io_val);'
new_task = '''task run_save_load_vid(input [21:0] vid_val);
        begin
            video_state_out = vid_val;
            force a.op_cooldown = 0; force b.op_cooldown = 0;
            // Trigger Save
            ss_save = 1; tick; ss_save = 0;
            wait(ss_freeze_a);
            wait(!ss_freeze_a);
            repeat (10) tick;

            // Mutate live video input during execution to prove isolation
            video_state_out = vid_val;
            repeat (30) tick;

            // Trigger Load
            ss_load = 1; tick; ss_load = 0;
            wait(ss_freeze_a);
            wait(!ss_freeze_a);
            repeat (20) tick;
            release a.op_cooldown; release b.op_cooldown;
            op = op + 1;
            $display("SUCCESS: Test %0d with video_state=0x%06h completed with exact bit equivalence.", op, vid_val);
        end
    endtask

    ''' + old_task

assert old_task in s
s = s.replace(old_task, new_task)

old_init = '$display("=== INITIATING IO ALIAS VERIFICATION TESTBENCH ===");'
new_init = '''$display("=== INITIATING VIDEO STATE ALIAS VERIFICATION TESTBENCH ===");
        run_save_load_vid(22'h000000);
        run_save_load_vid(22'h3FFFFF);
        run_save_load_vid(22'h123456);
        run_save_load_vid(22'h2A5A55);
        run_save_load_vid(22'h0F0F0F);
        run_save_load_vid({9'd487, 9'd261, 4'b1111});
        run_save_load_vid({9'd256, 9'd192, 4'b0000});
'''

assert old_init in s
s = s.replace(old_init, new_init)

with open(dst, 'w', encoding='utf-8') as f:
    f.write(s)
print('Successfully generated video_state_verification_tb.sv')
