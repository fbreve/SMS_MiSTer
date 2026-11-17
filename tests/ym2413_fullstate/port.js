// Reproducible selective port; run only in the isolated approved worktree.
const fs=require('fs'),cp=require('child_process'),p=require('path');
const root=p.resolve(__dirname,'../..'),ref='7fcd5e12847eedf9e97a44dc937c3dbac3205f7c';
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,encoding:'latin1'});
if(git('branch','--show-current').trim()!=='experiment/ym2413-v19-fullstate')throw Error('wrong branch');
const get=f=>git('show',ref+':'+f),read=f=>git('show','HEAD:'+f),write=(f,s)=>fs.writeFileSync(p.join(root,f),s,'latin1');
function replace(s,a,b){if(!s.includes(a))throw Error('missing anchor '+a);return s.replace(a,b);}
// These files contain only the FM implementation in this reference delta.
for(const n of ['vm2413','opll','slotcounter','controller','registermemory','voicememory','phasememory','envelopememory','feedbackmemory','outputmemory','envelopegenerator','phasegenerator','operator','outputgenerator','temporalmixer','attacktable','sinetable','lineartable','voicerom']){
 let s=get('rtl/VM2413/'+n+'.vhd');
 if(n==='phasememory')s=replace(s,'  attribute ramstyle of phase_array : signal is "logic";\n','');
 write('rtl/VM2413/'+n+'.vhd',s);
}
write('rtl/opll_snapshot.sv',get('rtl/opll_snapshot.sv'));
write('files.qip',read('files.qip')+'\nset_global_assignment -name SYSTEMVERILOG_FILE rtl/opll_snapshot.sv\n');
let s=read('rtl/system.vhd').replace(/\r\n/g,'\n'),r=get('rtl/system.vhd');
const ports=r.slice(r.indexOf('\t\tfm_state_addr :'),r.indexOf("        ss_freeze     :"));
s=replace(s,"\t\tss_freeze     :",ports+"\t\tss_freeze     :");
s=replace(s,'\tsignal fm_WR_n:',"    signal fm_local_rdata, fm_wrapper_rdata : std_logic_vector(31 downto 0);\n\tsignal fm_WR_n:");
const start=s.indexOf('\tfm: work.opll'),end=s.indexOf('FM_gated <=',start);
// Replace just FM instance, wrapper and registered private response.
const rs=r.indexOf('\tfm: work.opll'),re=r.indexOf('FM_gated <=',rs);
if(start<0||end<0||rs<0||re<0)throw Error('FM wrapper anchors');
s=s.slice(0,start)+r.slice(rs,re)+s.slice(end);write('rtl/system.vhd',s);
s=read('SMS.sv').replace(/\r\n/g,'\n');
s=replace(s,'wire ss_freeze;','wire ss_freeze;\nwire [7:0] ss_fm_addr;\nwire [31:0] ss_fm_rdata, ss_fm_wdata;\nwire ss_fm_read, ss_fm_write, ss_fm_initialized, ss_fm_legacy_reset, ss_fm_initialization_run;');
const connections=`.fm_state_addr(ss_fm_addr), .fm_state_read(ss_fm_read), .fm_state_write(ss_fm_write),
    .fm_state_wdata(ss_fm_wdata), .fm_state_rdata(ss_fm_rdata), .fm_initialized(ss_fm_initialized),
    .fm_legacy_reset(ss_fm_legacy_reset), .fm_initialization_run(ss_fm_initialization_run),
    `;
s=s.replace(/\.ss_freeze\s*\(ss_freeze\)/g,connections+'.ss_freeze(ss_freeze)');write('SMS.sv',s);
s=read('rtl/savestates.sv').replace(/\r\n/g,'\n');r=get('rtl/savestates.sv');
s=replace(s,'module savestates (',r.slice(r.indexOf('module savestates ('),r.indexOf('    input             clk,')));
let block=r.slice(r.indexOf('localparam [23:0] FM_MAGIC'),r.indexOf('localparam [63:0] BACKGROUND_DESC'));
// Master already declares the shared DDR read latch.
block=block.replace('reg [63:0]  dout_latch;','// Shared DDRAM response latch, declared before the FM transport connection.\nreg [63:0] dout_latch;');
s=replace(s,'// Shared latch for DDRAM read data (LOAD path)\nreg [63:0]  dout_latch;\n\n','');
s=replace(s,'reg [95:0] psg_ext_snap',`// FM v17: dedicated free tail of the existing 96 KiB slot.
// All master regions end at or below 0x2900 (System E passive VRAM).
// 32 KiB NVRAM ends at 0x1d00; FM ends at 0x29cb, below 0x3000.
// Upper video-word tag discovers this extension; untagged images never read it.
localparam [28:0] FM_DESC_ADDR=29'h2997, FM_DATA_ADDR=29'h2998;
${block}reg [95:0] psg_ext_snap`);
s=replace(s,'    case (state)\n',`    case (state)
        ST_FM_SAVE_WRITE: if(!DDRAM_BUSY) ddram_cmd_write(base_addr+FM_DATA_ADDR+fm_word,fm_bulk_rdata,8'hff);
        ST_FM_SAVE_DESC: if(!DDRAM_BUSY) ddram_cmd_write(base_addr+FM_DESC_ADDR,FM_DESC,8'hff);
        ST_FM_LOAD_DESC: if(!DDRAM_DOUT_READY && !dout_expected && !DDRAM_BUSY && dout_latch==FM_DESC) ddram_cmd_read(base_addr+FM_DATA_ADDR);
        ST_FM_LOAD_NEXT: if(!DDRAM_BUSY) ddram_cmd_read(base_addr+(fm_word==51?29'h01b:FM_DATA_ADDR+fm_word+29'd1));
`);
s=replace(s,"{ 42'd0 , video_snap }","{ FM_MAGIC, 18'd0, video_snap }");
s=replace(s,"ST_LOAD_VIDEO: if (!(DDRAM_DOUT_READY && dout_expected)) if (! dout_expected && ! DDRAM_BUSY) ddram_cmd_read ( base_addr + 29'h01b ) ;",`ST_LOAD_VIDEO: if (!(DDRAM_DOUT_READY && dout_expected)) if (!dout_expected && !DDRAM_BUSY)
            if(dout_latch[63:40]!=FM_MAGIC || dout_latch[39:22]==0)
                ddram_cmd_read(base_addr+(dout_latch[63:40]==FM_MAGIC?FM_DESC_ADDR:29'h01b));`);
s=replace(s,'    if (!reset_n) begin\n','    if (!reset_n) begin\n        fm_capture<=0;fm_apply<=0;fm_legacy<=0;fm_bulk_read<=0;fm_bulk_write<=0;has_fm<=0;fm_word<=0;\n');
s=replace(s,'    end else begin\n        // default:','    end else begin\n        fm_capture<=0;fm_apply<=0;fm_legacy<=0;fm_bulk_read<=0;fm_bulk_write<=0;\n        // default:');
s=replace(s,'            is_old_format <= 0;','            is_old_format <= 0; has_fm<=0;');
s=replace(s,'            if (cpu_ce && !z80_m1_n','            if (fm_initialized && cpu_ce && !z80_m1_n');
s=replace(s,'                state <= ST_SAVE_AUDIO_INVALID;','                fm_capture<=1; state<=ST_FM_CAPTURE;');
let states=r.slice(r.indexOf('        ST_FM_CAPTURE: if(fm_done)'),r.indexOf('        ST_SAVE_HDR: begin',r.indexOf('        ST_FM_CAPTURE: if(fm_done)')));
states=states.replace(/29'h2998/g,'FM_DATA_ADDR').replace(/29'h2997/g,'FM_DESC_ADDR').replace(/ST_SAVE_EE_DESC/g,'ST_SAVE_EEPROM').replace(/ST_LOAD_EE_DESC/g,'ST_LOAD_EEPROM').replace(/29'h01f/g,"29'h01b");
s=replace(s,'        ST_SAVE_HDR: begin',states+'        ST_SAVE_HDR: begin');
s=replace(s,"ddram_write(base_addr + 29'h01a, {42'd0, video_snap}, 8'hFF);\n                state <= ST_SAVE_EEPROM;",`ddram_write(base_addr + 29'h01a, {FM_MAGIC, 18'd0, video_snap}, 8'hFF);
                fm_word<=0; state<=ST_FM_SAVE_FETCH;`);
s=replace(s,"                ddram_read(base_addr + 29'h01b);\n                state            <= ST_LOAD_EEPROM;",`                has_fm <= dout_latch[63:40]==FM_MAGIC;
                if(dout_latch[63:40]==FM_MAGIC && dout_latch[39:22]!=0) state<=ST_ERROR;
                else begin
                    ddram_read(base_addr+(dout_latch[63:40]==FM_MAGIC?FM_DESC_ADDR:29'h01b));
                    state<=dout_latch[63:40]==FM_MAGIC?ST_FM_LOAD_DESC:ST_LOAD_EEPROM;
                end`);
s=replace(s,'                state <= ST_PRE_UNFREEZE;\n            end else begin\n                flush_cnt', '                state <= do_save ? ST_PRE_UNFREEZE : ST_FM_APPLY;\n            end else begin\n                flush_cnt');
s=replace(s,'// Slot size =', '//   FM v17: 0x2997 descriptor; 0x2998..0x29cb = 104 private 32-bit words.\n//   Video word 0x01a upper bits: [63:40]=0x484311, [39:22]=0.\n//\n// Slot size =');
write('rtl/savestates.sv',s);
console.log('Selective FM full-state port complete.');
