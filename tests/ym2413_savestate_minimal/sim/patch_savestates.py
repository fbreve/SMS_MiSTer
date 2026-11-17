import os

path = r'rtl/savestates.sv'
with open(path, 'rb') as f:
    text = f.read()

# 1. Ports
target_ports = b'// ---- DDRAM interface ----\r\n    output reg [28:0] DDRAM_ADDR,'
repl_ports = (
    b'// ---- FM (YM2413 / OPLL) interface ----\r\n'
    b'    output reg [7:0]  fm_state_addr,\r\n'
    b'    output reg        fm_state_read,\r\n'
    b'    output reg        fm_state_write,\r\n'
    b'    output reg [31:0] fm_state_wdata,\r\n'
    b'    input      [31:0] fm_state_rdata,\r\n'
    b'    input             fm_initialized,\r\n'
    b'    output reg        fm_legacy_reset,\r\n\r\n'
    b'    // ---- DDRAM interface ----\r\n'
    b'    output reg [28:0] DDRAM_ADDR,'
)

# 2. Localparams & registers
target_decl = b'localparam ST_SAVE_AUDIO_INVALID = 7\'d66'
repl_decl = (
    b'// FM (YM2413 / OPLL) Savestate Extension (Approach C: 16 x 64-bit words = 32 x 32-bit registers)\r\n'
    b'localparam [31:0] FM_MAGIC = 32\'h4F504C4C; // "OPLL"\r\n'
    b'localparam [63:0] FM_DESC  = {16\'d16, 8\'d1, 8\'d1, FM_MAGIC};\r\n'
    b'localparam ST_FM_SAVE_LO   = 7\'d73, ST_FM_SAVE_HI   = 7\'d74,\r\n'
    b'           ST_FM_SAVE_WRITE= 7\'d75, ST_FM_SAVE_DESC = 7\'d76,\r\n'
    b'           ST_FM_LOAD_DESC = 7\'d77, ST_FM_LOAD_LO   = 7\'d78,\r\n'
    b'           ST_FM_LOAD_HI   = 7\'d79, ST_FM_LOAD_NEXT = 7\'d80;\r\n'
    b'reg [4:0] fm_word;\r\n'
    b'reg       has_fm;\r\n'
    b'reg [31:0] fm_temp_lo;\r\n\r\n'
    b'function fm_word_valid;\r\n'
    b'    input [4:0]  addr;\r\n'
    b'    input [31:0] data;\r\n'
    b'    begin\r\n'
    b'        case (addr)\r\n'
    b'            5\'d0, 5\'d1, 5\'d2, 5\'d3, 5\'d4, 5\'d5, 5\'d6, 5\'d7, 5\'d8: // Channels 0..8\r\n'
    b'                fm_word_valid = (data & ~32\'h00FF3FFF) == 0;\r\n'
    b'            5\'d9, 5\'d11: // User voice Low words\r\n'
    b'                fm_word_valid = 1;\r\n'
    b'            5\'d10, 5\'d12: // User voice High words\r\n'
    b'                fm_word_valid = (data & ~32\'h0000000F) == 0;\r\n'
    b'            5\'d13, 5\'d14, 5\'d15, 5\'d16, 5\'d17, 5\'d18, 5\'d19, 5\'d20,\r\n'
    b'            5\'d21, 5\'d22, 5\'d23, 5\'d24, 5\'d25, 5\'d26, 5\'d27, 5\'d28,\r\n'
    b'            5\'d29, 5\'d30: // Envelopes 0..17\r\n'
    b'                fm_word_valid = (data & ~32\'h01FFFFFF) == 0;\r\n'
    b'            5\'d31: // Control & Latches\r\n'
    b'                fm_word_valid = (data & ~32\'h00FFFFFF) == 0;\r\n'
    b'            default: fm_word_valid = 0;\r\n'
    b'        endcase\r\n'
    b'    end\r\n'
    b'endfunction\r\n\r\n'
    b'localparam ST_SAVE_AUDIO_INVALID = 7\'d66'
)

# 3. Reset assignments
target_reset = b'state           <= ST_IDLE;\r\n        ss_freeze       <= 0;'
repl_reset = (
    b'state           <= ST_IDLE;\r\n'
    b'        ss_freeze       <= 0;\r\n'
    b'        fm_state_addr   <= 8\'d0;\r\n'
    b'        fm_state_read   <= 0;\r\n'
    b'        fm_state_write  <= 0;\r\n'
    b'        fm_state_wdata  <= 32\'d0;\r\n'
    b'        fm_legacy_reset <= 0;\r\n'
    b'        fm_word         <= 5\'d0;\r\n'
    b'        has_fm          <= 0;\r\n'
    b'        fm_temp_lo      <= 32\'d0;'
)

# 4. Clear one-cycle strobes
target_strobes = b'// default: clear one-cycle strobes\r\n        z80_set      <= 0;'
repl_strobes = (
    b'// default: clear one-cycle strobes\r\n'
    b'        fm_state_read  <= 0;\r\n'
    b'        fm_state_write <= 0;\r\n'
    b'        fm_legacy_reset <= 0;\r\n'
    b'        z80_set      <= 0;'
)

# 5. ST_IDLE
target_idle = b'ST_IDLE: begin\r\n            ss_freeze   <= 0;\r\n            is_old_format <= 0;\r\n            has_audio_ext <= 0;'
repl_idle = (
    b'ST_IDLE: begin\r\n'
    b'            ss_freeze   <= 0;\r\n'
    b'            is_old_format <= 0;\r\n'
    b'            has_audio_ext <= 0;\r\n'
    b'            has_fm        <= 0;'
)

# 6. Combinational always @* for FM
target_comb_ee = b'ST_SAVE_EEPROM: if (! DDRAM_BUSY) ddram_cmd_write ( base_addr + 29\'h01b , evolution_snap [ 31 : 16 ] == 16\'hE132 ? evolution_snap [ 95 : 32 ] : eeprom_snap , 8\'hFF ) ;\r\n        '
repl_comb_ee = (
    b'ST_SAVE_EEPROM: if (! DDRAM_BUSY) ddram_cmd_write ( base_addr + 29\'h01b , evolution_snap [ 31 : 16 ] == 16\'hE132 ? evolution_snap [ 95 : 32 ] : eeprom_snap , 8\'hFF ) ;\r\n'
    b'        ST_FM_SAVE_WRITE: if (! DDRAM_BUSY) ddram_cmd_write ( base_addr + 29\'h2998 + {24\'d0, fm_word} , { fm_state_rdata , fm_temp_lo } , 8\'hFF ) ;\r\n'
    b'        ST_FM_SAVE_DESC: if (! DDRAM_BUSY) ddram_cmd_write ( base_addr + 29\'h2997 , FM_DESC , 8\'hFF ) ;\r\n        '
)

# 7. Combinational always @* for LOAD FM
target_comb_load = (
    b'ST_LOAD_VIDEO: if (!(DDRAM_DOUT_READY && dout_expected)) if (! dout_expected && ! DDRAM_BUSY) ddram_cmd_read ( base_addr + 29\'h01b ) ;\r\n        '
    b'ST_LOAD_EEPROM: begin\r\n            if (!(DDRAM_DOUT_READY && dout_expected)) begin\r\n                if (! dout_expected && ! DDRAM_BUSY) begin\r\n                    if (systeme) begin\r\n                        ddram_cmd_read ( base_addr + 29\'h10 ) ;\r\n                    end else begin\r\n                        ddram_cmd_read ( base_addr + 29\'h101 ) ;\r\n                    end\r\n                end\r\n            end\r\n        end\r\n        '
)
repl_comb_load = (
    b'ST_LOAD_VIDEO: if (!(DDRAM_DOUT_READY && dout_expected)) if (! dout_expected && ! DDRAM_BUSY) ddram_cmd_read ( base_addr + 29\'h01b ) ;\r\n        '
    b'ST_LOAD_EEPROM: if (!(DDRAM_DOUT_READY && dout_expected)) if (! dout_expected && ! DDRAM_BUSY) ddram_cmd_read ( base_addr + 29\'h2997 ) ;\r\n        '
    b'ST_FM_LOAD_DESC: begin\r\n            if (!(DDRAM_DOUT_READY && dout_expected)) begin\r\n                if (! dout_expected && ! DDRAM_BUSY) begin\r\n                    if (dout_latch == FM_DESC) begin\r\n                        ddram_cmd_read ( base_addr + 29\'h2998 ) ;\r\n                    end else if (systeme) begin\r\n                        ddram_cmd_read ( base_addr + 29\'h10 ) ;\r\n                    end else begin\r\n                        ddram_cmd_read ( base_addr + 29\'h101 ) ;\r\n                    end\r\n                end\r\n            end\r\n        end\r\n        '
    b'ST_FM_LOAD_NEXT: begin\r\n            if (! DDRAM_BUSY) begin\r\n                if (fm_word == 5\'d15) begin\r\n                    if (systeme) begin\r\n                        ddram_cmd_read ( base_addr + 29\'h10 ) ;\r\n                    end else begin\r\n                        ddram_cmd_read ( base_addr + 29\'h101 ) ;\r\n                    end\r\n                end else begin\r\n                    ddram_cmd_read ( base_addr + 29\'h2999 + {24\'d0, fm_word} ) ;\r\n                end\r\n            end\r\n        end\r\n        '
)

# 8. Sequential ST_SAVE_EEPROM transition to FM
target_seq_save_ee = (
    b'ST_SAVE_EEPROM: begin\r\n'
    b'            if (!DDRAM_BUSY) begin\r\n'
    b'                ddram_write(base_addr + 29\'h01b,\r\n'
    b'                            evolution_snap[31:16] == 16\'hE132 ? evolution_snap[95:32] : eeprom_snap,\r\n'
    b'                            8\'hFF);\r\n'
    b'                if (systeme) begin'
)
repl_seq_save_ee = (
    b'ST_SAVE_EEPROM: begin\r\n'
    b'            if (!DDRAM_BUSY) begin\r\n'
    b'                ddram_write(base_addr + 29\'h01b,\r\n'
    b'                            evolution_snap[31:16] == 16\'hE132 ? evolution_snap[95:32] : eeprom_snap,\r\n'
    b'                            8\'hFF);\r\n'
    b'                fm_word <= 5\'d0;\r\n'
    b'                fm_state_addr <= 8\'d0;\r\n'
    b'                fm_state_read <= 1;\r\n'
    b'                state <= ST_FM_SAVE_LO;\r\n'
    b'            end\r\n'
    b'        end\r\n\r\n'
    b'        ST_FM_SAVE_LO: begin\r\n'
    b'            fm_temp_lo <= fm_state_rdata;\r\n'
    b'            fm_state_addr <= {fm_word[3:0], 1\'b1};\r\n'
    b'            fm_state_read <= 1;\r\n'
    b'            state <= ST_FM_SAVE_HI;\r\n'
    b'        end\r\n\r\n'
    b'        ST_FM_SAVE_HI: begin\r\n'
    b'            state <= ST_FM_SAVE_WRITE;\r\n'
    b'        end\r\n\r\n'
    b'        ST_FM_SAVE_WRITE: begin\r\n'
    b'            if (!DDRAM_BUSY) begin\r\n'
    b'                ddram_write(base_addr + 29\'h2998 + {24\'d0, fm_word},\r\n'
    b'                            {fm_state_rdata, fm_temp_lo}, 8\'hFF);\r\n'
    b'                if (fm_word == 5\'d15) begin\r\n'
    b'                    state <= ST_FM_SAVE_DESC;\r\n'
    b'                end else begin\r\n'
    b'                    fm_word <= fm_word + 5\'d1;\r\n'
    b'                    fm_state_addr <= {fm_word[3:0] + 4\'d1, 1\'b0};\r\n'
    b'                    fm_state_read <= 1;\r\n'
    b'                    state <= ST_FM_SAVE_LO;\r\n'
    b'                end\r\n'
    b'            end\r\n'
    b'        end\r\n\r\n'
    b'        ST_FM_SAVE_DESC: begin\r\n'
    b'            if (!DDRAM_BUSY) begin\r\n'
    b'                ddram_write(base_addr + 29\'h2997, FM_DESC, 8\'hFF);\r\n'
    b'                if (systeme) begin'
)

# 9. Sequential ST_LOAD_EEPROM and FM states
target_seq_load_ee = (
    b'ST_LOAD_EEPROM: begin\r\n'
    b'            if (DDRAM_DOUT_READY && dout_expected) begin\r\n'
    b'                dout_expected <= 0;\r\n'
    b'                dout_latch    <= DDRAM_DOUT;\r\n'
    b'            end else if (!dout_expected && !DDRAM_BUSY) begin\r\n'
    b'                if (evolution_snap[31:16] == 16\'hE132) begin\r\n'
    b'                    evolution_snap[95:32] <= dout_latch;\r\n'
    b'                    eeprom_snap <= 64\'d0;\r\n'
    b'                end else begin\r\n'
    b'                    evolution_snap[95:32] <= 64\'d0;\r\n'
    b'                    eeprom_snap <= dout_latch;\r\n'
    b'                end\r\n'
    b'                if (systeme) begin\r\n'
    b'                    // System E: read VDP2/CRAM2/PSG2 before restoring VRAM\r\n'
    b'                    ddram_read(base_addr + 29\'h10);\r\n'
    b'                    cram_idx <= 0;\r\n'
    b'                    state    <= ST_LOAD_VDP2REG;\r\n'
    b'                end else begin\r\n'
    b'                    // Restore memory (VRAM/WRAM) BEFORE applying registers so the VDP never\r\n'
    b'                    // renders with new register settings against old VRAM content.\r\n'
    b'                    vram_load_addr   <= 0;\r\n'
    b'                    vram_byte_cnt    <= 0;\r\n'
    b'                    vram_load_active <= 0;\r\n'
    b'                    word_cnt         <= 0;\r\n'
    b'                    ddram_read(base_addr + 29\'h101);\r\n'
    b'                    state <= ST_LOAD_VRAM;\r\n'
    b'                end\r\n'
    b'            end\r\n'
    b'        end\r\n\r\n        ST_LOAD_VDP2REG:'
)

repl_seq_load_ee = (
    b'ST_LOAD_EEPROM: begin\r\n'
    b'            if (DDRAM_DOUT_READY && dout_expected) begin\r\n'
    b'                dout_expected <= 0;\r\n'
    b'                dout_latch    <= DDRAM_DOUT;\r\n'
    b'            end else if (!dout_expected && !DDRAM_BUSY) begin\r\n'
    b'                if (evolution_snap[31:16] == 16\'hE132) begin\r\n'
    b'                    evolution_snap[95:32] <= dout_latch;\r\n'
    b'                    eeprom_snap <= 64\'d0;\r\n'
    b'                end else begin\r\n'
    b'                    evolution_snap[95:32] <= 64\'d0;\r\n'
    b'                    eeprom_snap <= dout_latch;\r\n'
    b'                end\r\n'
    b'                ddram_read(base_addr + 29\'h2997);\r\n'
    b'                state <= ST_FM_LOAD_DESC;\r\n'
    b'            end\r\n'
    b'        end\r\n\r\n'
    b'        ST_FM_LOAD_DESC: begin\r\n'
    b'            if (DDRAM_DOUT_READY && dout_expected) begin\r\n'
    b'                dout_expected <= 0;\r\n'
    b'                dout_latch    <= DDRAM_DOUT;\r\n'
    b'            end else if (!dout_expected && !DDRAM_BUSY) begin\r\n'
    b'                if (dout_latch == FM_DESC) begin\r\n'
    b'                    has_fm  <= 1;\r\n'
    b'                    fm_word <= 5\'d0;\r\n'
    b'                    ddram_read(base_addr + 29\'h2998);\r\n'
    b'                    state <= ST_FM_LOAD_LO;\r\n'
    b'                end else begin\r\n'
    b'                    has_fm <= 0;\r\n'
    b'                    if (systeme) begin\r\n'
    b'                        ddram_read(base_addr + 29\'h10);\r\n'
    b'                        cram_idx <= 0;\r\n'
    b'                        state    <= ST_LOAD_VDP2REG;\r\n'
    b'                    end else begin\r\n'
    b'                        vram_load_addr   <= 0;\r\n'
    b'                        vram_byte_cnt    <= 0;\r\n'
    b'                        vram_load_active <= 0;\r\n'
    b'                        word_cnt         <= 0;\r\n'
    b'                        ddram_read(base_addr + 29\'h101);\r\n'
    b'                        state <= ST_LOAD_VRAM;\r\n'
    b'                    end\r\n'
    b'                end\r\n'
    b'            end\r\n'
    b'        end\r\n\r\n'
    b'        ST_FM_LOAD_LO: begin\r\n'
    b'            if (DDRAM_DOUT_READY && dout_expected) begin\r\n'
    b'                dout_expected <= 0;\r\n'
    b'                dout_latch    <= DDRAM_DOUT;\r\n'
    b'            end else if (!dout_expected && !DDRAM_BUSY) begin\r\n'
    b'                if (!fm_word_valid({fm_word[3:0], 1\'b0}, dout_latch[31:0]) ||\r\n'
    b'                    !fm_word_valid({fm_word[3:0], 1\'b1}, dout_latch[63:32])) begin\r\n'
    b'                    state <= ST_ERROR;\r\n'
    b'                end else begin\r\n'
    b'                    fm_state_addr  <= {3\'d0, fm_word[3:0], 1\'b0};\r\n'
    b'                    fm_state_wdata <= dout_latch[31:0];\r\n'
    b'                    fm_state_write <= 1;\r\n'
    b'                    state <= ST_FM_LOAD_HI;\r\n'
    b'                end\r\n'
    b'            end\r\n'
    b'        end\r\n\r\n'
    b'        ST_FM_LOAD_HI: begin\r\n'
    b'            fm_state_addr  <= {3\'d0, fm_word[3:0], 1\'b1};\r\n'
    b'            fm_state_wdata <= dout_latch[63:32];\r\n'
    b'            fm_state_write <= 1;\r\n'
    b'            state <= ST_FM_LOAD_NEXT;\r\n'
    b'        end\r\n\r\n'
    b'        ST_FM_LOAD_NEXT: begin\r\n'
    b'            if (!DDRAM_BUSY) begin\r\n'
    b'                if (fm_word == 5\'d15) begin\r\n'
    b'                    if (systeme) begin\r\n'
    b'                        ddram_read(base_addr + 29\'h10);\r\n'
    b'                        cram_idx <= 0;\r\n'
    b'                        state    <= ST_LOAD_VDP2REG;\r\n'
    b'                    end else begin\r\n'
    b'                        vram_load_addr   <= 0;\r\n'
    b'                        vram_byte_cnt    <= 0;\r\n'
    b'                        vram_load_active <= 0;\r\n'
    b'                        word_cnt         <= 0;\r\n'
    b'                        ddram_read(base_addr + 29\'h101);\r\n'
    b'                        state <= ST_LOAD_VRAM;\r\n'
    b'                    end\r\n'
    b'                end else begin\r\n'
    b'                    fm_word <= fm_word + 5\'d1;\r\n'
    b'                    ddram_read(base_addr + 29\'h2999 + {24\'d0, fm_word});\r\n'
    b'                    state <= ST_FM_LOAD_LO;\r\n'
    b'                end\r\n'
    b'            end\r\n'
    b'        end\r\n\r\n        ST_LOAD_VDP2REG:'
)

# 10. Unfreeze logic: legacy FM reset if !do_save && !has_fm
target_unfreeze = (
    b'if (!do_save && has_audio_ext) begin\r\n'
    b'                        audio_phase_in <= audio_phase_snap;\r\n'
    b'                        audio_phase_set <= 1;\r\n'
    b'                    end'
)
repl_unfreeze = (
    b'if (!do_save && has_audio_ext) begin\r\n'
    b'                        audio_phase_in <= audio_phase_snap;\r\n'
    b'                        audio_phase_set <= 1;\r\n'
    b'                    end\r\n'
    b'                    if (!do_save && !has_fm) begin\r\n'
    b'                        fm_legacy_reset <= 1;\r\n'
    b'                    end'
)

assert target_ports in text, "target_ports missing"
text = text.replace(target_ports, repl_ports, 1)

assert target_decl in text, "target_decl missing"
text = text.replace(target_decl, repl_decl, 1)

assert target_reset in text, "target_reset missing"
text = text.replace(target_reset, repl_reset, 1)

assert target_strobes in text, "target_strobes missing"
text = text.replace(target_strobes, repl_strobes, 1)

assert target_idle in text, "target_idle missing"
text = text.replace(target_idle, repl_idle, 1)

assert target_comb_ee in text, "target_comb_ee missing"
text = text.replace(target_comb_ee, repl_comb_ee, 1)

assert target_comb_load in text, "target_comb_load missing"
text = text.replace(target_comb_load, repl_comb_load, 1)

assert target_seq_save_ee in text, "target_seq_save_ee missing"
text = text.replace(target_seq_save_ee, repl_seq_save_ee, 1)

assert target_seq_load_ee in text, "target_seq_load_ee missing"
text = text.replace(target_seq_load_ee, repl_seq_load_ee, 1)

assert target_unfreeze in text, "target_unfreeze missing"
text = text.replace(target_unfreeze, repl_unfreeze, 1)

with open(path, 'wb') as f:
    f.write(text)

print('Updated savestates.sv successfully!')

