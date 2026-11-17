const fs=require('fs'),p=require('path'),cp=require('child_process'),assert=require('assert');
const root=p.resolve(__dirname,'../..'),rev='8443a0d19a88aff7a5900011bccf386daf146945';
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,maxBuffer:32*1024*1024}).toString('utf8');
const blob=(r,f)=>git('show',`${r}:${f}`).replace(/\r\n/g,'\n');
const replace=(s,a,b)=>{assert(s.includes(a),a.slice(0,160));return s.replace(a,b);};
for(const candidate of ['B','C']){
 const dir=p.join(__dirname,candidate),controls=candidate==='C';
 const write=(f,s)=>fs.writeFileSync(p.join(dir,f),s);
 // These seven files had no post-implementation changes. The parent already
 // includes 998d8aa6; do not restore the merge's first parent.
 for(const f of ['SMS.sv','rtl/savestates.sv','rtl/jt89/jt89.v','rtl/jt89/jt89.vhd','rtl/jt89/jt89_tone.v','rtl/jt89/jt89_noise.v','rtl/jt89/jt89_vol.v']){
  assert.equal(blob('a196cf11',f),blob(rev,f),f);write(f,blob('a196cf11^',f).replace('package jt89 is \n','package jt89 is\n').replace('output reg signed [8:0]  snd   \n','output reg signed [8:0]  snd\n'));
 }
 let mix=blob('a196cf11^','rtl/AudioMix.vhd');
 mix=replace(mix,'\treset_n : in std_logic;\n','');write('rtl/AudioMix.vhd',mix);
 // Invert only the PSG implementation's system hunks, retaining #219/#223.
 let sys=blob(rev,'rtl/system.vhd');
 sys=sys.replace(/\n\t\tpsg_ext_out, psg2_ext_out[\s\S]*?audio_phase_in, audio_phase_set, audio_ext_set : in STD_LOGIC := '0';\n/,'\n');
 sys=replace(sys,"    signal psg_div1, psg_div2 : std_logic_vector(3 downto 0);\n    signal psg_quiet1, psg_quiet2 : std_logic;\n",'');
 sys=replace(sys,"\t\tss_in  => psg_in,\n        ss_ext_out => psg_ext_out, ss_ext_in => psg_ext_in,\n        ss_ext_set => audio_ext_set, ss_div_out => psg_div1,\n        ss_div_in => psg_div_in, ss_quiescent => psg_quiet1","\t\tss_in  => psg_in");
 sys=replace(sys,"\t\tss_in  => psg2_in,\n        ss_ext_out => psg2_ext_out, ss_ext_in => psg2_ext_in,\n        ss_ext_set => audio_ext_set and systeme, ss_div_out => psg_div2,\n        ss_div_in => psg_div_in, ss_quiescent => psg_quiet2","\t\tss_in  => psg2_in");
 sys=sys.replace(/psg_div_out <= psg_div1;[\s\S]*?-- synthesis translate_on\n\n/,'');
 sys=replace(sys,'    ss_phase_out => audio_phase_out, ss_phase_in => audio_phase_in, ss_phase_set => audio_phase_set,\n','');
 sys=replace(sys,"            elsif audio_ext_set='1' then\n                det_D <= audio_control_in(10 downto 8);\n                PSG_mux <= audio_control_in(7 downto 0);\n",controls?"            elsif psg_set='1' then\n                det_D <= audio_control_in(10 downto 8);\n                PSG_mux <= audio_control_in(7 downto 0);\n":'');
 if(controls){sys=replace(sys,'\t\tpsg_out      : out STD_LOGIC_VECTOR(55 downto 0);','\t\taudio_control_out : out STD_LOGIC_VECTOR(10 downto 0);\n\t\taudio_control_in : in STD_LOGIC_VECTOR(10 downto 0) := (others => \'0\');\n\t\tpsg_out      : out STD_LOGIC_VECTOR(55 downto 0);');sys=replace(sys,'mix : entity work.AudioMix','audio_control_out <= det_D & PSG_mux;\n\nmix : entity work.AudioMix');}
 assert(!/ss_ext_|psg_div|audio_phase|audio_quiescent/.test(sys));write('rtl/system.vhd',sys);
 let top=fs.readFileSync(p.join(dir,'SMS.sv'),'utf8');
 if(controls){top=replace(top,'wire [55:0]  ss_psg_out, ss_psg_in;','wire [10:0] ss_audio_control_out, ss_audio_control_in;\nwire [55:0]  ss_psg_out, ss_psg_in;');top=replace(top,'\t.psg_out     (ss_psg_out),','\t.audio_control_out(ss_audio_control_out),\n\t.audio_control_in(ss_audio_control_in),\n\t.psg_out     (ss_psg_out),');top=replace(top,'\t.psg_out         (ss_psg_out),','\t.audio_control_out(ss_audio_control_out),\n\t.audio_control_in(ss_audio_control_in),\n\t.psg_out         (ss_psg_out),');}write('SMS.sv',top);
 let ss=fs.readFileSync(p.join(dir,'rtl/savestates.sv'),'utf8');
 ss=replace(ss,"32'h534D5331; // \"SMS1\"",`32'h534D${controls?'43':'42'}01; // Experimental ${candidate}, version 1 (cartridge)`);
 ss=replace(ss,"32'h534D5342; // \"SMSB\"",`32'h5342${controls?'43':'42'}01; // Experimental ${candidate}, version 1 (BIOS)`);
 ss=ss.replace(/^\/\/   Word 0x00E:.*$/m,`//   Word 0x00E: PSG config [51:0], ${controls?'controls [62:52], System E [63]':'System E [52], reserved zero [63:53]'} (${candidate} v1)`);
 if(controls){ss=replace(ss,'    // ---- PSG snapshot / restore ----','    // Architectural audio controls only; restored with psg_set.\n    input [10:0] audio_control_out,\n    output reg [10:0] audio_control_in,\n    // ---- PSG snapshot / restore ----');ss=replace(ss,'reg  [55:0] psg_snap;','reg [10:0] audio_control_snap;\nreg  [55:0] psg_snap;');ss=replace(ss,'        psg_set         <= 0;', '        psg_set         <= 0;\n        audio_control_in <= 0;');ss=replace(ss,'                psg_set      <= 1;', '                psg_set      <= 1;\n                audio_control_in <= audio_control_snap;');}
 // Keep configuration capture after the pending PSG write/tick drains, rather
 // than reintroducing the pre-drain capture from the old implementation.
 ss=replace(ss,'            state <= do_save ? ST_SAVE_HDR : ST_LOAD_HDR_RD;',`            if (do_save) begin\n                psg_snap <= psg_out;\n                psg2_snap <= psg2_out;\n${controls?'                audio_control_snap <= audio_control_out;\n':''}            end\n            state <= do_save ? ST_SAVE_HDR : ST_LOAD_HDR_RD;`);
 const word=controls?"{ systeme , audio_control_snap , psg_snap [ 51 : 0 ] }":"{ 11'd0 , systeme , psg_snap [ 51 : 0 ] }";
 ss=replace(ss,"{ 8'd0 , psg_snap }",word);
 ss=replace(ss,"{8'd0, psg_snap}",word.replaceAll(' ',''));
 const valid=controls?'dout_latch[63] == systeme':"dout_latch[63:53] == 0 && dout_latch[52] == systeme";
 // A new-format image must have the exact size. The duplicated command
 // preview and sequential FSM must make the same acceptance decision.
 ss=replace(ss,"if (! dout_expected && ! DDRAM_BUSY) ddram_cmd_read ( base_addr + 29'd1 ) ;", "if (! dout_expected && ! DDRAM_BUSY) if (dout_latch[63:32] == NEW_SS_WORDS) ddram_cmd_read ( base_addr + 29'd1 ) ;");
 ss=replace(ss,'                is_old_format <= (dout_latch[63:32] == OLD_SS_WORDS);\n                ddram_read(base_addr + 29\'d1);\n                state <= ST_LOAD_HDR_WT2;',"                if (dout_latch[63:32] == NEW_SS_WORDS) begin\n                    is_old_format <= 0;\n                    ddram_read(base_addr + 29'd1);\n                    state <= ST_LOAD_HDR_WT2;\n                end else state <= ST_ERROR;");
 ss=replace(ss,"if (! dout_expected && ! DDRAM_BUSY) ddram_cmd_read ( base_addr + 29'd15 ) ;",`if (! dout_expected && ! DDRAM_BUSY) if (${valid}) ddram_cmd_read ( base_addr + 29'd15 ) ;`);
 ss=replace(ss,"                psg_snap <= dout_latch[55:0];\n                ddram_read(base_addr + 29'd15);\n                state    <= ST_LOAD_MAPPER;",`                if (${valid}) begin\n                    psg_snap <= {4'd0,dout_latch[51:0]};\n${controls?'                    audio_control_snap <= dout_latch[62:52];\n':''}                    ddram_read(base_addr + 29'd15);\n                    state <= ST_LOAD_MAPPER;\n                end else state <= ST_ERROR;`);
 // Preserve the production BIOS size-only publication correction.
 const base=blob(rev,'rtl/savestates.sv'),start=base.indexOf('            if (cur_bios_mode) begin\n                // BIOS states'),end=base.indexOf('            end else if (!DDRAM_BUSY) begin',start);
 const cmdStart=base.indexOf('        ST_SAVE_DONE: begin'),cmdEnd=base.indexOf('        ST_LOAD_HDR_RD:',cmdStart);
 assert(cmdStart>0&&cmdEnd>cmdStart);ss=replace(ss,"        ST_SAVE_DONE: if (!(cur_bios_mode)) if (! DDRAM_BUSY) ddram_cmd_write ( base_addr + 29'd0 , { NEW_SS_WORDS , ss_change_det } , 8'hFF ) ;\n",base.slice(cmdStart,cmdEnd));
 const oldStart=ss.indexOf('            if (cur_bios_mode) begin\n                // BIOS states'),oldEnd=ss.indexOf('            end else if (!DDRAM_BUSY) begin',oldStart);
 assert(start>0&&end>start&&oldStart>0&&oldEnd>oldStart);ss=ss.slice(0,oldStart)+base.slice(start,end)+ss.slice(oldEnd);
 ss=ss.replace('not classify this committed extension as an old-format load.','not classify this versioned image as an old-format load.');
 write('rtl/savestates.sv',ss);
 console.log(candidate,'implemented');
}

