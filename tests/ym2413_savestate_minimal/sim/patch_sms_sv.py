import os

path = r'SMS.sv'
with open(path, 'rb') as f:
    text = f.read()

# 1. Add FM state wires
target_wires = b'wire [21:0]  ss_video_state_out, ss_video_state_in;\r\nwire         ss_video_state_set;'
repl_wires = (
    b'wire [21:0]  ss_video_state_out, ss_video_state_in;\r\n'
    b'wire         ss_video_state_set;\r\n'
    b'wire [7:0]   fm_state_addr;\r\n'
    b'wire         fm_state_read, fm_state_write;\r\n'
    b'wire [31:0]  fm_state_wdata, fm_state_rdata;\r\n'
    b'wire         fm_initialized, fm_legacy_reset;'
)

# 2. In system instance, add FM ports
target_sys_end = b'\t.io_state_set (ss_io_set)\r\n);'
repl_sys_end = (
    b'\t.io_state_set (ss_io_set),\r\n'
    b'\t.fm_state_addr (fm_state_addr),\r\n'
    b'\t.fm_state_read (fm_state_read),\r\n'
    b'\t.fm_state_write(fm_state_write),\r\n'
    b'\t.fm_state_wdata(fm_state_wdata),\r\n'
    b'\t.fm_state_rdata(fm_state_rdata),\r\n'
    b'\t.fm_initialized(fm_initialized),\r\n'
    b'\t.fm_legacy_reset(fm_legacy_reset)\r\n'
    b');'
)

# 3. In savestates_inst, add FM ports
target_ss_end = b'\t.DDRAM_BUSY      (DDRAM_BUSY)\r\n);'
repl_ss_end = (
    b'\t.DDRAM_BUSY      (DDRAM_BUSY),\r\n'
    b'\t.fm_state_addr   (fm_state_addr),\r\n'
    b'\t.fm_state_read   (fm_state_read),\r\n'
    b'\t.fm_state_write  (fm_state_write),\r\n'
    b'\t.fm_state_wdata  (fm_state_wdata),\r\n'
    b'\t.fm_state_rdata  (fm_state_rdata),\r\n'
    b'\t.fm_initialized  (fm_initialized),\r\n'
    b'\t.fm_legacy_reset (fm_legacy_reset)\r\n'
    b');'
)

assert target_wires in text, "target_wires missing"
text = text.replace(target_wires, repl_wires, 1)

assert target_sys_end in text, "target_sys_end missing"
text = text.replace(target_sys_end, repl_sys_end, 1)

assert target_ss_end in text, "target_ss_end missing"
text = text.replace(target_ss_end, repl_ss_end, 1)

with open(path, 'wb') as f:
    f.write(text)

print('Updated SMS.sv successfully!')

