const fs=require('fs'),p=require('path'),cp=require('child_process');const d=__dirname,root=p.resolve(d,'../..');
const baseline=f=>cp.execFileSync('git',['show','f205b05dc058fc5f7f2432779b61e8f3b0e22519:'+f],{cwd:root,encoding:'utf8',maxBuffer:8*1024*1024}).replace(/\r\n/g,'\n');
let s=baseline('rtl/savestates.sv');
s=require('./phase_fix')(s);
s=s.replace('audio_phase_snap<=audio_phase_out;',"audio_phase_snap<=do_save ? audio_phase_out : 1'b0;");
s=s.replace('//   v15 tag=48430f adds139-bit background records, retaining v14 restart.','//   v15 tag=48430f adds139-bit background records, retaining v14 restart.\n//   v16 tag=484310 records post-T AudioMix phase and restores it for SAVE/LOAD.');
s=s.replace("localparam [23:0] BACKGROUND_MAGIC = 24'h48430f;","localparam [23:0] BACKGROUND_MAGIC = 24'h48430f;\nlocalparam [23:0] MIXER_MAGIC = 24'h484310;");
s=s.replace('video_word = {BACKGROUND_MAGIC,','video_word = {MIXER_MAGIC,');
s=s.replaceAll('dout_latch[63:40] == BACKGROUND_MAGIC','(dout_latch[63:40] == BACKGROUND_MAGIC || dout_latch[63:40] == MIXER_MAGIC)');
s=s.replace('wire invalid_nmi_header = modern_nmi_tag &&','wire invalid_nmi_header = (dout_latch[63:40] == MIXER_MAGIC && !has_audio_ext) || modern_nmi_tag &&');
s=s.replace('                has_nmi_history <= modern_nmi_tag;','                // v15 and older recorded transport phase, not historical T+1.\n                if (dout_latch[63:40] != MIXER_MAGIC) audio_phase_snap<=0;\n                has_nmi_history <= modern_nmi_tag;');
// Clear before each operation, including genuine old64 images that skip VIDEO.
s=s.replace('            has_audio_ext <= 0;','            has_audio_ext <= 0;\n            audio_phase_snap <= 0;');
// Every supported LOAD uses deterministic normalized phase, including no extension.
s=s.replace('                if (do_save || has_audio_ext) begin\n                    audio_phase_in<=audio_phase_snap;audio_phase_set<=1;\n                end','                audio_phase_in<=audio_phase_snap;audio_phase_set<=1;');
s=s.replace('    output reg audio_phase_set,','    output reg audio_phase_set,\n    output audio_pending_tick,');
s=s.replace('assign clock_phase_in=phase_snap;',`assign clock_phase_in=phase_snap;
// T consumed a raw PSG enable only at divider phase10/25. Post-T div15
// means its falling-edge /16 event belongs to logical T+1. Transport held
// that event; replay it on the falling edge before the first resumed clock.
assign audio_pending_tick = audio_phase_set && capture_tick_snap &&
                            (phase_snap==2'd1 || phase_snap==2'd3) &&
                            audio_div_snap==4'd15;`);
fs.mkdirSync(p.join(d,'proposed'),{recursive:true});fs.writeFileSync(p.join(d,'proposed/savestates.sv'),s);
let j=baseline('rtl/jt89/jt89.v').replace('    input          ss_ext_set,','    input          ss_ext_set,\n    input          ss_pending_tick, // resume only: deferred capture-edge /16 event');
j=j.replace("    end else begin\n        cen_16 <= !ss_ext_set", "    end else if (ss_pending_tick) begin\n        cen_16 <= 1'b1;\n    end else begin\n        cen_16 <= !ss_ext_set");
fs.writeFileSync(p.join(d,'proposed/jt89.v'),j);
let v=baseline('rtl/jt89/jt89.vhd').replace("    ss_ext_set : in std_logic := '0';","    ss_ext_set : in std_logic := '0';\n    ss_pending_tick : in std_logic := '0';");fs.writeFileSync(p.join(d,'proposed/jt89.vhd'),v);
v=baseline('rtl/system.vhd').replace("audio_phase_in, audio_phase_set, audio_ext_set : in STD_LOGIC := '0';","audio_phase_in, audio_phase_set, audio_ext_set : in STD_LOGIC := '0';\n        audio_pending_tick : in STD_LOGIC := '0';");
v=v.replace('ss_ext_set => audio_ext_set, ss_div_out', 'ss_pending_tick => audio_pending_tick, ss_ext_set => audio_ext_set, ss_div_out').replace('ss_ext_set => audio_ext_set and systeme, ss_div_out','ss_pending_tick => audio_pending_tick and systeme, ss_ext_set => audio_ext_set and systeme, ss_div_out');fs.writeFileSync(p.join(d,'proposed/system.vhd'),v);
v=baseline('SMS.sv').replace('wire ss_audio_quiescent,','wire ss_audio_pending_tick;\nwire ss_audio_quiescent,').replaceAll('.audio_phase_set(ss_audio_phase_set),','.audio_phase_set(ss_audio_phase_set),\n    .audio_pending_tick(ss_audio_pending_tick),');fs.writeFileSync(p.join(d,'proposed/SMS.sv'),v);
console.log('Prepared coupled v16 proposal in test directory; production unchanged');
