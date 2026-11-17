// Isolated candidate only. Production files are never written by this script.
const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname;
function change(s,a,b){assert(s.includes(a),'missing edit '+a.slice(0,90));return s.replaceAll(a,b);}
function emit(file,s){const f=p.join(d,'candidate',file);fs.mkdirSync(p.dirname(f),{recursive:true});fs.writeFileSync(f,s);}
let s=fs.readFileSync(p.join(d,'baseline/rtl/savestates.sv'),'utf8');
s=change(s,'    input audio_phase_out,','    input audio_phase_out,\n    input [15:0] audio_last_out,\n    output [15:0] audio_last_in,\n    output audio_last_valid,');
s=change(s,'reg audio_phase_snap, has_audio_ext;','reg audio_phase_snap, has_audio_ext;\nreg [15:0] audio_last_snap;\nreg has_audio_last;\nassign audio_last_in = audio_last_snap;\nassign audio_last_valid = has_audio_last;\nwire audio_desc_valid = !is_old_format && dout_latch[31:0] == AUDIO_MAGIC &&\n    (dout_latch[39:32] == 8\'d1 || dout_latch[39:32] == 8\'d2) &&\n    dout_latch[40] == systeme && dout_latch[48:46] == audio_words && dout_latch[63:49] == 0;\nwire audio_payload_invalid = audio_word[0] &&\n    ((audio_word == 1 && has_audio_last) ? dout_latch[63:48] != 0 : dout_latch[63:32] != 0);');
const ruleStart=s.indexOf('wire audio_desc_valid'),ruleEnd=s.indexOf('reg [2:0] audio_word;',ruleStart),rules=s.slice(ruleStart,ruleEnd);
s=s.slice(0,ruleStart)+s.slice(ruleEnd);s=change(s,'reg         is_old_format;','reg         is_old_format;\n'+rules);
s=change(s,'audio_div_snap, systeme, 8\'d1, AUDIO_MAGIC','audio_div_snap, systeme, 8\'d2, AUDIO_MAGIC');
s=change(s,"localparam [23:0] SRAM_MAGIC = 24'h484312;","localparam [23:0] SRAM_MAGIC = 24'h484312;\n// v19: exact last mixed channel at accepted T, audio extension version2.\nlocalparam [23:0] AUDIO_LAST_MAGIC = 24'h484313;");
s=change(s,'video_word = {SRAM_MAGIC,','video_word = {AUDIO_LAST_MAGIC,');
s=change(s,'dout_latch[63:40] == FM_MAGIC || dout_latch[63:40] == SRAM_MAGIC;','dout_latch[63:40] == FM_MAGIC || dout_latch[63:40] == SRAM_MAGIC || dout_latch[63:40] == AUDIO_LAST_MAGIC;');
s=change(s,'has_audio_ext <= 0;','has_audio_ext <= 0; has_audio_last <= 0; audio_last_snap <= 0;');
s=change(s,"audio_phase_snap<=do_save ? audio_phase_out : 1'b0;", "audio_phase_snap<=do_save ? audio_phase_out : 1'b0;\n            audio_last_snap <= do_save ? audio_last_out : 16'd0;\n            has_audio_last <= do_save;");
s=change(s,"{ 32'd0 , psg_ext_snap [ 95 : 64 ] }","{ 16'd0 , audio_last_snap , psg_ext_snap [ 95 : 64 ] }");
s=change(s,"{32'd0,psg_ext_snap[95:64]}","{16'd0,audio_last_snap,psg_ext_snap[95:64]}");
s=change(s,"! is_old_format && dout_latch [ 31 : 0 ] == AUDIO_MAGIC && dout_latch [ 39 : 32 ] == 8'd1 && dout_latch [ 40 ] == systeme && dout_latch [ 48 : 46 ] == audio_words && dout_latch [ 63 : 49 ] == 0",'audio_desc_valid');
s=change(s,"audio_word [ 0 ] && ( dout_latch [ 63 : 32 ] != 0 )",'audio_payload_invalid');
s=change(s,"!is_old_format && dout_latch[31:0] == AUDIO_MAGIC &&\n                    dout_latch[39:32] == 8'd1 && dout_latch[40] == systeme &&\n                    dout_latch[48:46] == audio_words && dout_latch[63:49] == 0",'audio_desc_valid');
s=change(s,'audio_div_snap <= dout_latch[44:41];','has_audio_last <= dout_latch[39:32] == 8\'d2;\n                    audio_div_snap <= dout_latch[44:41];');
s=change(s,'audio_word[0] && (dout_latch[63:32] != 0)','audio_payload_invalid');
s=change(s,'1: psg_ext_snap[95:64] <= dout_latch[31:0];','1: begin psg_ext_snap[95:64] <= dout_latch[31:0];\n                                 if (has_audio_last) audio_last_snap <= dout_latch[47:32]; end');
s=change(s,"has_full_sram <= dout_latch[63:40] == SRAM_MAGIC;","has_full_sram <= dout_latch[63:40] == SRAM_MAGIC || dout_latch[63:40] == AUDIO_LAST_MAGIC;");
s=change(s,'if (invalid_nmi_header || (live_evolution',"if ((has_audio_last != (dout_latch[63:40] == AUDIO_LAST_MAGIC)) || invalid_nmi_header || (live_evolution");
s=change(s,'// [63:49] reserved zero. Payload high words have [63:32] zero.','// [63:49] reserved zero. Audio v2 stores the last mixed channel in\n// word022[47:32]; word022[63:48] and word024[63:32] remain zero.');
emit('rtl/savestates.sv',s);
s=fs.readFileSync(p.join(d,'baseline/rtl/AudioMix.vhd'),'utf8');
s=change(s,"ss_phase_set : in std_logic := '0'","ss_phase_set : in std_logic := '0';\n    ss_last_sample : in signed(15 downto 0) := (others=>'0');\n    ss_last_valid : in std_logic := '0'");
s=change(s,'audio_l<=clipped(15 downto 0);',"audio_l<=clipped(15 downto 0);\n            if ss_phase_set='1' and ss_last_valid='1' then audio_r<=ss_last_sample; end if;");
s=change(s,'audio_r<=clipped(15 downto 0);',"audio_r<=clipped(15 downto 0);\n            if ss_phase_set='1' and ss_last_valid='1' then audio_l<=ss_last_sample; end if;");
emit('rtl/AudioMix.vhd',s);
s=fs.readFileSync(p.join(d,'baseline/rtl/system.vhd'),'utf8');
s=change(s,"audio_pending_tick : in STD_LOGIC := '0';","audio_pending_tick : in STD_LOGIC := '0';\n        audio_last_in : in STD_LOGIC_VECTOR(15 downto 0) := (others=>'0');\n        audio_last_valid : in STD_LOGIC := '0';");
s=change(s,'ss_phase_out => audio_phase_out, ss_phase_in => audio_phase_in, ss_phase_set => audio_phase_set,','ss_phase_out => audio_phase_out, ss_phase_in => audio_phase_in, ss_phase_set => audio_phase_set,\n    ss_last_sample => signed(audio_last_in), ss_last_valid => audio_last_valid,');
emit('rtl/system.vhd',s);
s=fs.readFileSync(p.join(d,'baseline/SMS.sv'),'utf8');
s=change(s,'wire ss_audio_quiescent,ss_audio_phase_out,ss_audio_phase_in,ss_audio_phase_set,ss_audio_ext_set;','wire ss_audio_quiescent,ss_audio_phase_out,ss_audio_phase_in,ss_audio_phase_set,ss_audio_ext_set;\nwire [15:0] ss_audio_last_in;\nwire ss_audio_last_valid;');
// Both system and savestates have this existing phase connection.
s=change(s,'.audio_phase_out(ss_audio_phase_out),','.audio_phase_out(ss_audio_phase_out),\n    .audio_last_in(ss_audio_last_in), .audio_last_valid(ss_audio_last_valid),');
// Only the savestates instance has the direct capture input.
assert(/savestates\s+savestates_inst\s*\(/.test(s));s=s.replace(/savestates\s+savestates_inst\s*\(/,'savestates savestates_inst(\n    .audio_last_out(ss_audio_phase_out ? audio_l : audio_r),');
emit('SMS.sv',s);
console.log('Prepared isolated v19 candidate: one16-bit last-channel record, unchanged raw OPLL/PSG and release phase.');
