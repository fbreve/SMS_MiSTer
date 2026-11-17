const fs=require('fs'),p=require('path'),cp=require('child_process'),root=p.resolve(__dirname,'../..'),map=require('./state_map.json'),base=require('./baseline.json').head;
const old=f=>cp.execFileSync('git',['show',base+':'+f],{cwd:root}).toString('latin1').replace(/\r\n/g,'\n');
const put=(f,s)=>fs.writeFileSync(p.join(root,f),s,'latin1');
let s=old('rtl/system.vhd');
s=s.replace("ss_freeze     : in  STD_LOGIC := '0'",`fm_state_addr : in std_logic_vector(7 downto 0) := (others=>'0');
        fm_state_read, fm_state_write : in std_logic := '0';
        fm_state_wdata : in std_logic_vector(31 downto 0) := (others=>'0');
        fm_state_rdata : out std_logic_vector(31 downto 0);
        fm_initialized : out std_logic;
        fm_legacy_reset, fm_initialization_run : in std_logic := '0';
        ss_freeze     : in  STD_LOGIC := '0'`);
s=s.replace(/signal fm_a\s*:/i,'signal fm_a :'); // preserve original declarations below
s=s.replace(/(signal\s+fm_d\s*:[^;]+;)/i,'$1\n    signal fm_local_rdata, fm_wrapper_rdata : std_logic_vector(31 downto 0);');
s=s.replace('ic_n\t\t=> RESET_n,',"ic_n\t\t=> RESET_n and not fm_legacy_reset,");
s=s.replace('mixout   => FM_out',`mixout   => FM_out,
        ss_hold => ss_freeze and not fm_initialization_run,
        ss_addr => fm_state_addr, ss_read => fm_state_read,
        ss_write => fm_state_write, ss_wdata => fm_state_wdata,
        ss_rdata => fm_local_rdata, ss_initialized => fm_initialized`);
s=s.replace(/if RESET_n='0' then\s*fm_d/i,"if RESET_n='0' or fm_legacy_reset='1' then\n\t\t\t\tfm_d");
s=s.replace("elsif ss_freeze = '0' and fm_WR_n='0' then",`elsif ss_freeze='1' and fm_state_write='1' and fm_state_addr=x"4c" then
                fm_a <= fm_state_wdata(0); fm_d <= fm_state_wdata(8 downto 1);
            elsif ss_freeze = '0' and fm_WR_n='0' then`);
s=s.replace('-- AMR - Clamped volume boosting',`fm_state_rdata <= fm_local_rdata or fm_wrapper_rdata;
    process(clk_sys)
    begin
        if rising_edge(clk_sys) then
            fm_wrapper_rdata <= (others=>'0');
            if ss_freeze='1' and fm_state_read='1' and fm_state_addr=x"4c" then
                fm_wrapper_rdata <= (31 downto 9=>'0') & fm_d & fm_a;
            end if;
        end if;
    end process;

-- AMR - Clamped volume boosting`);put('rtl/system.vhd',s);
s=old('SMS.sv');
s=s.replace('wire ss_freeze;',`wire ss_freeze;
wire [7:0] ss_fm_addr;
wire [31:0] ss_fm_rdata,ss_fm_wdata;
wire ss_fm_read,ss_fm_write,ss_fm_initialized,ss_fm_legacy_reset,ss_fm_initialization_run;`);
const ports=`.fm_state_addr(ss_fm_addr), .fm_state_read(ss_fm_read), .fm_state_write(ss_fm_write),
    .fm_state_wdata(ss_fm_wdata), .fm_state_rdata(ss_fm_rdata), .fm_initialized(ss_fm_initialized),
    .fm_legacy_reset(ss_fm_legacy_reset), .fm_initialization_run(ss_fm_initialization_run),`;
let connected=0;s=s.replace(/(\.ss_freeze\s*\(ss_freeze\),)/g,m=>++connected<=2?ports+'\n'+m:m);put('SMS.sv',s);
put('files.qip',old('files.qip')+'\nset_global_assignment -name SYSTEMVERILOG_FILE rtl/opll_snapshot.sv\n');
// Compile-time padding/range validation stays narrow and local to each word.
let valid=`function fm_word_valid;\ninput [7:0] address;input [31:0] data;begin\ncase(address)\n`;
for(let i=0;i<map.words;i++){
 const constraints=[`(data & ~32'h${map.masks[i]})==0`];
 for(const r of map.rows.filter(r=>r.stored)){
  const n=r.signal.split(' ')[0],limit=r.module==='opll/s0'?72:['regs_addr','fb_addr','faddr'].includes(n)?9:n==='slot_voice_addr'?38:['rslot','mo_addr','maddr'].includes(n)?18:0;
  if(limit){const x=r.slices.find(x=>x.word===i);if(x)constraints.push(`data[${x.wordLo+x.width-1}:${x.wordLo}] < ${limit}`);}
 }
 valid+=`8'd${i}:fm_word_valid=${constraints.join(' && ')};\n`;
}valid+='default:fm_word_valid=0;endcase\nend endfunction\n';
const defaults=Array(map.words).fill(0n);
for(const r of map.rows.filter(r=>r.stored&&r.count===1)){
 let v=r.module==='opll/s0'?71n:r.module==='eg'&&r.signal==='amphase (variable)'?32768n:r.module==='eg'&&r.signal==='ntable (variable)'?(1n<<18n)-1n:r.module==='tm'&&r.signal==='mute'?1n:0n;
 for(const x of r.slices)defaults[x.word]|=((v>>BigInt(x.sourceLo))&((1n<<BigInt(x.width))-1n))<<BigInt(x.wordLo);
}
let snapshot=fs.readFileSync(p.join(root,'rtl/opll_snapshot.sv'),'utf8');snapshot=snapshot.replace(/\/\/ F01_LEGACY_WORDS[\s\S]*?(?=\s*default: legacy_word)/,'// F01_LEGACY_WORDS\n'+defaults.map((v,i)=>v?`            8'd${i}: legacy_word=32'h${v.toString(16)};\n`:'').join(''));put('rtl/opll_snapshot.sv',snapshot);
s=old('rtl/savestates.sv');
s=s.replace('module savestates (',`module savestates (
    output [7:0] fm_state_addr,
    output fm_state_read, fm_state_write,
    output [31:0] fm_state_wdata,
    input [31:0] fm_state_rdata,
    input fm_initialized,
    output fm_legacy_reset, fm_initialization_run,`);
s=s.replace("localparam [23:0] MIXER_MAGIC = 24'h484310;",`localparam [23:0] MIXER_MAGIC = 24'h484310;
localparam [23:0] FM_MAGIC = 24'h484311;
// Explicit owner, version17, 104 private32-bit rows. Free tail of96KiB slot.
localparam [63:0] FM_DESC = {16'd104,8'd17,8'd1,32'h464d5331};
localparam ST_FM_CAPTURE=7'd111, ST_FM_SAVE_FETCH=7'd112, ST_FM_SAVE_WAIT=7'd113,
 ST_FM_SAVE_WRITE=7'd114, ST_FM_SAVE_DESC=7'd115, ST_FM_LOAD_DESC=7'd116,
 ST_FM_LOAD=7'd117, ST_FM_LOAD_STORE=7'd118, ST_FM_LOAD_NEXT=7'd119,
 ST_FM_APPLY=7'd120, ST_FM_APPLY_WAIT=7'd121;
reg fm_capture,fm_apply,fm_legacy,fm_bulk_read,fm_bulk_write,has_fm;
reg [6:0] fm_word;
wire [63:0] fm_bulk_rdata;
wire fm_done,fm_busy;
opll_snapshot fm_snapshot(.clk(clk),.reset_n(reset_n),.capture(fm_capture),.apply_state(fm_apply),.legacy(fm_legacy),
 .initialized(fm_initialized),.legacy_reset(fm_legacy_reset),.initialization_run(fm_initialization_run),
 .bulk_read(fm_bulk_read),.bulk_write(fm_bulk_write),.bulk_addr(fm_word),.bulk_wdata(dout_latch),
 .bulk_rdata(fm_bulk_rdata),.done(fm_done),.busy(fm_busy),.state_addr(fm_state_addr),
 .state_read(fm_state_read),.state_write(fm_state_write),.state_wdata(fm_state_wdata),.state_rdata(fm_state_rdata));
${valid}`);
// Forward declarations are required by Verilog ordering in Quartus and ModelSim.
const latchDecl=s.match(/reg\s+\[63:0\]\s+dout_latch\s*;/)?.[0];
if(!latchDecl)throw Error('DDRAM latch declaration');
s=s.replace(latchDecl,'');s=s.replace('reg fm_capture,',latchDecl+'\nreg fm_capture,');
s=s.replace('{MIXER_MAGIC, 2\'d3,',"{FM_MAGIC, 2'd3,");
s=s.replace(/dout_latch\[63:40\] == MIXER_MAGIC/g,"(dout_latch[63:40] == MIXER_MAGIC || dout_latch[63:40] == FM_MAGIC)");
s=s.replace(/dout_latch\[63:40\] != MIXER_MAGIC/g,"(dout_latch[63:40] != MIXER_MAGIC && dout_latch[63:40] != FM_MAGIC)");
s=s.replace('if (!storage_busy && cpu_ce &&', 'if (fm_initialized && !storage_busy && cpu_ce &&');
s=s.replace('state           <= ST_IDLE;','fm_capture<=0;fm_apply<=0;fm_legacy<=0;fm_bulk_read<=0;fm_bulk_write<=0;has_fm<=0;fm_word<=0;\n        state           <= ST_IDLE;');
s=s.replace('// default: clear one-cycle strobes','fm_capture<=0;fm_apply<=0;fm_legacy<=0;fm_bulk_read<=0;fm_bulk_write<=0;\n        // default: clear one-cycle strobes');
s=s.replace('is_old_format <= 0;\n            has_audio_ext', 'is_old_format <= 0;has_fm<=0;\n            has_audio_ext');
s=s.replace('has_nmi_history <= modern_nmi_tag;',"has_fm <= dout_latch[63:40] == FM_MAGIC;\n                has_nmi_history <= modern_nmi_tag;");
s=s.replace('state <= ST_SAVE_AUDIO_INVALID;', 'fm_capture<=1;state<=ST_FM_CAPTURE;');
s=s.replace('if (bg_second) state<=ST_SAVE_EE_DESC;', 'if (bg_second)begin fm_word<=0;state<=ST_FM_SAVE_FETCH;end');
// Redirect post-BG LOAD to the FM descriptor only for v17 (both command and FSM paths).
s=s.replace("(bg_second && bg_word==2)?29'h01f:bg_address+29'd1", "(bg_second && bg_word==2)?(has_fm?29'h2997:29'h01f):bg_address+29'd1");
s=s.replace("if (bg_second && bg_word==2) begin ddram_read(base_addr+29'h01f);state<=ST_LOAD_EE_DESC;end", "if (bg_second && bg_word==2) begin ddram_read(base_addr+(has_fm?29'h2997:29'h01f));state<=has_fm?ST_FM_LOAD_DESC:ST_LOAD_EE_DESC;end");
// Insert shared DDRAM command predicates in the existing acceptance mechanism.
s=s.replace('case (state)\n        ST_WAIT_RESTORE_BOUNDARY:',`case (state)
        ST_FM_SAVE_WRITE: if(!DDRAM_BUSY)ddram_cmd_write(base_addr+29'h2998+fm_word,fm_bulk_rdata,8'hff);
        ST_FM_SAVE_DESC: if(!DDRAM_BUSY)ddram_cmd_write(base_addr+29'h2997,FM_DESC,8'hff);
        ST_FM_LOAD_DESC: if(!dout_expected&&!DDRAM_BUSY&&dout_latch==FM_DESC)ddram_cmd_read(base_addr+29'h2998);
        ST_FM_LOAD_NEXT: if(!DDRAM_BUSY)ddram_cmd_read(base_addr+(fm_word==51?29'h01f:29'h2998+fm_word+29'd1));
        ST_WAIT_RESTORE_BOUNDARY:`);
const newStates=`
        ST_FM_CAPTURE: if(fm_done)state<=ST_SAVE_AUDIO_INVALID;
        ST_FM_SAVE_FETCH: begin fm_bulk_read<=1;state<=ST_FM_SAVE_WAIT;end
        ST_FM_SAVE_WAIT: if(fm_done)state<=ST_FM_SAVE_WRITE;
        ST_FM_SAVE_WRITE: if(!DDRAM_BUSY)begin
            ddram_write(base_addr+29'h2998+fm_word,fm_bulk_rdata,8'hff);
            if(fm_word==51)state<=ST_FM_SAVE_DESC;
            else begin fm_word<=fm_word+7'd1;state<=ST_FM_SAVE_FETCH;end
        end
        ST_FM_SAVE_DESC: if(!DDRAM_BUSY)begin ddram_write(base_addr+29'h2997,FM_DESC,8'hff);state<=ST_SAVE_EE_DESC;end
        ST_FM_LOAD_DESC,ST_FM_LOAD: begin
            if(DDRAM_DOUT_READY&&dout_expected)begin dout_expected<=0;dout_latch<=DDRAM_DOUT;end
            else if(!dout_expected&&!DDRAM_BUSY)begin
                if(state==ST_FM_LOAD_DESC)begin
                    if(dout_latch!=FM_DESC)state<=ST_ERROR;
                    else begin fm_word<=0;ddram_read(base_addr+29'h2998);state<=ST_FM_LOAD;end
                end else if(!fm_word_valid({fm_word,1'b0},dout_latch[31:0])||!fm_word_valid({fm_word,1'b1},dout_latch[63:32]))state<=ST_ERROR;
                else begin fm_bulk_write<=1;state<=ST_FM_LOAD_STORE;end
            end
        end
        ST_FM_LOAD_STORE: if(fm_done)state<=ST_FM_LOAD_NEXT;
        ST_FM_LOAD_NEXT: if(!DDRAM_BUSY)begin
            if(fm_word==51)begin ddram_read(base_addr+29'h01f);state<=ST_LOAD_EE_DESC;end
            else begin fm_word<=fm_word+7'd1;ddram_read(base_addr+29'h2998+fm_word+29'd1);state<=ST_FM_LOAD;end
        end
        ST_FM_APPLY: begin
            if(has_fm)fm_apply<=1;else fm_legacy<=1;
            state<=ST_FM_APPLY_WAIT;
        end
        ST_FM_APPLY_WAIT: if(fm_done)state<=ST_PRE_UNFREEZE;
`;
s=s.replace('        ST_SAVE_HDR: begin',newStates+'\n        ST_SAVE_HDR: begin');
s=s.replace('state <= ST_PRE_UNFREEZE;', 'state <= do_save ? ST_PRE_UNFREEZE : ST_FM_APPLY;');
// Above replacement does not affect compact ST_FM_APPLY_WAIT assignment.
put('rtl/savestates.sv',s);
fs.writeFileSync(p.join(__dirname,'format.md'),`# v17 FM extension\n\nTag 484311; container remains96KiB. Descriptor2997 is 00681101464d5331 (104 rows, v17, present1, FMS1). Payload2998..29cb contains52 little-endian64-bit words; low32 row2n, high32 row2n+1. These tail addresses follow sprites ending2996 and precede slot end2fff. No memory region or slot stride changes. FM exists and is captured even when inaudible or System E routes PSG2. Descriptor commits after all FM words; existing audio/header commit machinery remains. Whole FM record validates before applying any live OPLL field. Pre-v17 LOAD uses an explicitly lossy deterministic local reset, complete initialization, and canonical scalar/default phase setup. No missing FM history is claimed reconstructable.\n`);
console.log('Integrated v17 controller/system transport.');
