// Draft sources only. Applying this directory to production requires the
// protocol gate documented in contract.md to pass first.
const fs=require('fs'),p=require('path');
const cp=require('child_process');
const here=__dirname, root=p.resolve(here,'../..'), out=p.join(here,'candidate');
fs.mkdirSync(p.join(out,'rtl'),{recursive:true});
const read=f=>fs.readFileSync(p.join(here,'protocol',f),'utf8').replace(/\r\n/g,'\n');
const baseline=f=>cp.execFileSync('git',['show','8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a:'+f],{cwd:root,encoding:'utf8'}).replace(/\r\n/g,'\n');
// Two baseline VDP files contain mixed stored line endings. Preserve endings
// of unchanged lines so the functional patch does not rewrite those files.
function put(f,s){
 if(f==='vdp.vhd'||f==='vdp_main.vhd'){
  const a=cp.execFileSync('git',['show','8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a:rtl/'+f],{cwd:root,encoding:'utf8'}).split('\n'),b=s.split('\n');
  const clean=x=>x.endsWith('\r')?x.slice(0,-1):x,w=b.length+1,dp=new Uint16Array((a.length+1)*w);
  for(let i=a.length-1;i>=0;i--)for(let j=b.length-1;j>=0;j--)dp[i*w+j]=clean(a[i])===b[j]?1+dp[(i+1)*w+j+1]:Math.max(dp[(i+1)*w+j],dp[i*w+j+1]);
  const lines=[];let i=0,j=0;
  while(j<b.length){if(i<a.length&&clean(a[i])===b[j]){lines.push(a[i++]);j++;}else if(i<a.length&&dp[(i+1)*w+j]>=dp[i*w+j+1])i++;else lines.push(b[j++]);}
  s=lines.join('\n');
 }
 fs.writeFileSync(p.join(out,'rtl',f),s);
}
for(const [src,dst] of [['shifter_proto.vhd','vdp_sprite_shifter.vhd'],['sprites_proto.vhd','vdp_sprites.vhd'],['main_proto.vhd','vdp_main.vhd'],['vdp_proto.vhd','vdp.vhd']]){
 let s=read(src);
 if(dst==='vdp.vhd')s=s.replace(/^.*probe : out.*\n/m,'').replace(/^.*probe <=.*\n/m,'');
 if(dst==='vdp_sprites.vhd'){
  s=s.replace(/^.*g06_out\(74\*\(MAX_SPPL\+1\)\+2 downto 74\*\(MAX_SPPL\+1\)\)<=state;\n/m,'')
     .replace(/^.*g06_out.*<=conv_std_logic_vector\(count,7\);\n/m,'')
     .replace(/^.*g06_out.*<=index;\n/m,'');
  s=s.replace(/^.*state<=g06_in.*;\n/m,'                state <= WAITING;\n')
     .replace(/^.*count<=conv_integer\(g06_in.*;\n/m,'                count <= 0;\n')
     .replace(/^.*index<=g06_in.*;\n/m,"                index <= (others=>'0');\n");
  s=s.replace("\t\t\t\toverflow <= '0';", "\t\t\t\toverflow <= '0';\n                data_address <= (others=>'0');\n                m2_flags <= (others=>'0');");
  s=s.replace("if ss_regs_set='1' and g06_valid='1' then", "if ss_regs_set='1' then\n             if g06_valid='1' then")
     .replace("collide<=g06_in(74*(MAX_SPPL+1)+42);", "collide<=g06_in(74*(MAX_SPPL+1)+42);\n             else color<=(others=>'0');collide<='0';end if;");
 }
 // Remove only the sixteen control bits following the slot records.
 s=s.replace(/74\*\(MAX_SPPL\+1\)\+(\d+)/g,(_,n)=>'74*(MAX_SPPL+1)+'+(Number(n)-16));
 // Names describe the production interface, not the investigation number.
 s=s.replaceAll('g06_out','ss_sprite_out').replaceAll('g06_in','ss_sprite_in')
    .replaceAll('g06_valid','ss_sprite_valid').replaceAll('g06_freeze','ss_freeze');
 s=s.replace("elsif ce_pix='1' then  -- ce_vdp?? ", "elsif ce_pix='1' then");
 if(dst==='vdp_sprites.vhd'){
  s=s.replace('architecture Behavioral of vdp_sprites is', 'architecture Behavioral of vdp_sprites is\n\tsignal color_reg : std_logic_vector(3 downto 0);\n\tsignal collide_reg, overflow_reg : std_logic;');
  s=s.replace('\nbegin\n', '\nbegin\n color <= color_reg;\n collide <= collide_reg;\n overflow <= overflow_reg;\n');
  s=s.replace(/\b(color|collide|overflow)(\s*<=)/g,'$1_reg$2');
  // Keep the three external aliases, rename snapshot reads to internal regs.
  s=s.replace(' color_reg <= color_reg;', ' color <= color_reg;').replace(' collide_reg <= collide_reg;', ' collide <= collide_reg;').replace(' overflow_reg <= overflow_reg;', ' overflow <= overflow_reg;');
  s=s.replace(/<=color;/g,'<=color_reg;').replace(/<=collide;/g,'<=collide_reg;').replace(/<=overflow;/g,'<=overflow_reg;');
 }
 put(dst,s);
}
console.log('Draft sprite sources generated under candidate; production untouched.');
let c=baseline('rtl/savestates.sv');
function change(a,b){if(!c.includes(a))throw Error('Missing controller anchor: '+a.slice(0,100));c=c.replace(a,b);}
change('//   Word 0x006-0x007:', `//   v14 tag=48430e, subtype3, retaining the v13 CPU word layout.
//   Word 0x02e: sprite descriptor (width4778, version14, owner G6R1).
//   Word 0x02f: [1:0] capture phase0/10/20/25, [2] System E,
//               [3] CPU consumed capture enable, [63:4] zero.
//   Words 0x2901-0x2996: two padded4778-bit sprite records (75 words each).
//   Word 0x006-0x007:`);
change('    output reg        ss_freeze,',`    output reg        ss_freeze,
    // Private CPU historical-T1/T2 reconstruction. All guest domains stay held.
    output reg        ss_cpu_prepare,
    input             z80_replay,
    input             z80_tick_active,
    output            z80_replay_t2,
    input       [1:0] clock_phase,
    output      [1:0] clock_phase_in,
    output reg        clock_phase_set,
    input             clock_phase_ready,
    input [4777:0] sprite_out, sprite2_out,
    output [4777:0] sprite_in, sprite2_in,
    output sprite_valid,`);
change('reg [6:0]  state;',`// v14: 02e descriptor, 02f phase/owner, 2901..2996 two sprite records.
localparam [23:0] RESTART_MAGIC = 24'h48430e;
localparam [63:0] SPRITE_DESC = {16'd4778,8'd14,8'd0,32'h47365231};
localparam ST_SAVE_SPRITE_DESC=7'd99, ST_SAVE_PHASE=7'd100, ST_SAVE_SPRITE=7'd101,
           ST_LOAD_SPRITE_DESC=7'd102, ST_LOAD_PHASE=7'd103, ST_LOAD_SPRITE=7'd104,
           ST_CPU_PREPARE=7'd105, ST_PHASE_COMMIT=7'd106;
reg [4799:0] sprite_snap, sprite2_snap;
reg [6:0] sprite_word;
reg sprite_second, has_restart;
reg [1:0] phase_snap;
reg capture_tick_snap;
assign sprite_in=sprite_snap[4777:0];
assign sprite2_in=sprite2_snap[4777:0];
assign sprite_valid=has_restart;
assign clock_phase_in=phase_snap;
assign z80_replay_t2=has_restart?capture_tick_snap:1'b1;
wire [28:0] sprite_address=29'h2901+(sprite_second?29'd75:29'd0)+{22'd0,sprite_word};
wire [63:0] sprite_write_word=sprite_second?sprite2_snap[64*sprite_word+:64]:sprite_snap[64*sprite_word+:64];
reg [6:0]  state;`);
change('wire [63:0] video_word = {CPU_RESTART_MAGIC,', 'wire [63:0] video_word = {RESTART_MAGIC,');
change('wire modern_nmi_tag = ',"wire modern_restart_tag = dout_latch[63:40] == CPU_RESTART_MAGIC || dout_latch[63:40] == RESTART_MAGIC;\nwire modern_nmi_tag = ");
change('dout_latch[63:40] == NMI_HISTORY_MAGIC || dout_latch[63:40] == CPU_RESTART_MAGIC;', 'dout_latch[63:40] == NMI_HISTORY_MAGIC || modern_restart_tag;');
change('(dout_latch[63:40] == CPU_RESTART_MAGIC ? !restart_padding_ok : !nmi_padding_ok)', '(modern_restart_tag ? !restart_padding_ok : !nmi_padding_ok)');
change('has_restart_context <= dout_latch[63:40] == CPU_RESTART_MAGIC;', 'has_restart_context <= modern_restart_tag;\n                has_restart <= dout_latch[63:40] == RESTART_MAGIC;');
// Initialization is also repeated for each LOAD before format recognition.
c=c.replaceAll('has_restart_context <= 0; restart_snap <= 0; restart_padding_ok <= 1;', 'has_restart_context <= 0; restart_snap <= 0; restart_padding_ok <= 1;\n        has_restart <= 0; phase_snap <= 0; sprite_snap <= 0; sprite2_snap <= 0;');
change('// Old 64KB files bypass ST_LOAD_VIDEO entirely.', '// Old 64KB files have no beam history: use a deterministic origin.\n                video_snap <= 0;\n                // Old 64KB files bypass ST_LOAD_VIDEO entirely.');
change('        ss_freeze       <= 0;', '        ss_freeze       <= 0;\n        capture_tick_snap<=1;\n        ss_cpu_prepare <= 0; clock_phase_set <= 0; sprite_word <= 0; sprite_second <= 0;');
change('                z80_snap    <= z80_reg;', '                ss_freeze <= 1; // accepted host T finishes; T+1 is held\n                if (do_save) begin phase_snap <= clock_phase;capture_tick_snap<=z80_tick_active;end\n                z80_snap    <= z80_reg;');
change('            vdp_snap    <= vdp_regs;', "            sprite_snap <= {22'd0,sprite_out};\n            sprite2_snap <= systeme ? {22'd0,sprite2_out} : 4800'd0;\n            vdp_snap    <= vdp_regs;");
const arm=c.indexOf('        ST_ARM_FREEZE: begin');
const commentStart=c.indexOf('            // Freeze is asserted one clk_sys cycle after',arm);
const commentEnd=c.indexOf('            sprite_snap <=',commentStart);
if(commentStart<0||commentEnd<0)throw Error('ARM comment anchors');
c=c.slice(0,commentStart)+`            // Guest hold was asserted at accepted T. Collect post-T device
            // state here, before any subsequent guest enable is admitted.
`+c.slice(commentEnd);
change("ddram_write(base_addr + 29'h02d, EVOLUTION_HISTORY_DESC, 8'hFF);\n                state <= ST_SAVE_EE_DESC;", "ddram_write(base_addr + 29'h02d, EVOLUTION_HISTORY_DESC, 8'hFF);\n                state <= ST_SAVE_SPRITE_DESC;");
// Redirect the v14 path before the first early peripheral restore writes.
change("if (!invalid_nmi_header && !((live_evolution || evolution_state) && (!evolution_state || !evolution_history_valid || dout_latch != EVOLUTION_HISTORY_DESC))) ddram_cmd_read(base_addr + 29'h01f);", "if (!invalid_nmi_header && !((live_evolution || evolution_state) && (!evolution_state || !evolution_history_valid || dout_latch != EVOLUTION_HISTORY_DESC))) ddram_cmd_read(base_addr + (has_restart ? 29'h02e : 29'h01f));");
const ev1=c.indexOf('        ST_LOAD_EVOLUTION1: begin');
let tail=c.slice(ev1);tail=tail.replace("ddram_read(base_addr + 29'h01f); state <= ST_LOAD_EE_DESC;", "ddram_read(base_addr + (has_restart ? 29'h02e : 29'h01f)); state <= has_restart ? ST_LOAD_SPRITE_DESC : ST_LOAD_EE_DESC;");c=c.slice(0,ev1)+tail;
const preview=`
        ST_SAVE_SPRITE_DESC: if (!DDRAM_BUSY) ddram_cmd_write(base_addr+29'h02e,SPRITE_DESC,8'hff);
        ST_SAVE_PHASE: if (!DDRAM_BUSY) ddram_cmd_write(base_addr+29'h02f,{60'd0,capture_tick_snap,systeme,phase_snap},8'hff);
        ST_SAVE_SPRITE: if (!DDRAM_BUSY) ddram_cmd_write(base_addr+sprite_address,sprite_write_word,8'hff);
        ST_LOAD_SPRITE_DESC: if (!dout_expected && !DDRAM_BUSY && dout_latch==SPRITE_DESC) ddram_cmd_read(base_addr+29'h02f);
        ST_LOAD_PHASE: if (!dout_expected && !DDRAM_BUSY && dout_latch[63:4]==0 && dout_latch[2]==systeme) ddram_cmd_read(base_addr+29'h2901);
        ST_LOAD_SPRITE: if (!dout_expected && !DDRAM_BUSY &&
            !(sprite_word==74 && dout_latch[63:42]!=0) && !(sprite_second && !systeme && dout_latch!=0))
            ddram_cmd_read(base_addr+((sprite_second && sprite_word==74)?29'h01f:sprite_address+29'd1));
`;
change('        ST_SAVE_EVOLUTION1: if',preview+'        ST_SAVE_EVOLUTION1: if');
const states=`
        ST_SAVE_SPRITE_DESC: if (!DDRAM_BUSY) begin
            ddram_write(base_addr+29'h02e,SPRITE_DESC,8'hff);state<=ST_SAVE_PHASE;
        end
        ST_SAVE_PHASE: if (!DDRAM_BUSY) begin
            ddram_write(base_addr+29'h02f,{60'd0,capture_tick_snap,systeme,phase_snap},8'hff);
            sprite_word<=0;sprite_second<=0;state<=ST_SAVE_SPRITE;
        end
        ST_SAVE_SPRITE: if (!DDRAM_BUSY) begin
            ddram_write(base_addr+sprite_address,sprite_write_word,8'hff);
            if (sprite_word==74) begin
                sprite_word<=0;sprite_second<=1;
                if (sprite_second) state<=ST_SAVE_EE_DESC;
            end else sprite_word<=sprite_word+7'd1;
        end
        ST_LOAD_SPRITE_DESC, ST_LOAD_PHASE, ST_LOAD_SPRITE: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected<=0;dout_latch<=DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                case(state)
                ST_LOAD_SPRITE_DESC: if (dout_latch!=SPRITE_DESC) state<=ST_ERROR;
                    else begin ddram_read(base_addr+29'h02f);state<=ST_LOAD_PHASE;end
                ST_LOAD_PHASE: if (dout_latch[63:4]!=0 || dout_latch[2]!=systeme) state<=ST_ERROR;
                    else begin
                        phase_snap<=dout_latch[1:0];capture_tick_snap<=dout_latch[3];sprite_word<=0;sprite_second<=0;
                        ddram_read(base_addr+29'h2901);state<=ST_LOAD_SPRITE;
                    end
                ST_LOAD_SPRITE: if ((sprite_word==74 && dout_latch[63:42]!=0) ||
                                   (sprite_second && !systeme && dout_latch!=0)) state<=ST_ERROR;
                    else begin
                        if (sprite_second) sprite2_snap[64*sprite_word+:64]<=dout_latch;
                        else sprite_snap[64*sprite_word+:64]<=dout_latch;
                        if (sprite_second && sprite_word==74) begin
                            ddram_read(base_addr+29'h01f);state<=ST_LOAD_EE_DESC;
                        end else begin
                            ddram_read(base_addr+sprite_address+29'd1);
                            if (sprite_word==74) begin sprite_word<=0;sprite_second<=1;end
                            else sprite_word<=sprite_word+7'd1;
                        end
                    end
                endcase
            end
        end
`;
change('        ST_SAVE_EVOLUTION1: begin',states+'        ST_SAVE_EVOLUTION1: begin');
// Keep the existing peripheral settling interval. Replace arbitrary beam/quiet
// release with private CPU preparation and an acknowledged phase/beam commit.
const first=c.indexOf('        ST_UNFREEZE: begin'),last=c.indexOf('        ST_UNFREEZE_SETTLE: begin',first);
c=c.slice(0,first)+`        ST_UNFREEZE: begin
            if (unfreeze_cnt<8'd255) unfreeze_cnt<=unfreeze_cnt+8'd1;
            else begin
                z80_nmi_hold<=0;
                ss_cpu_prepare<=!do_save;
                state<=ST_CPU_PREPARE;
            end
        end
        ST_CPU_PREPARE: begin
            // Replay-complete is semantic: no ordinary instruction may execute.
            if (do_save || !z80_replay) begin
                ss_cpu_prepare<=0;
                clock_phase_set<=1;
                video_state_in<=video_snap;video_state_set<=1;
                state<=ST_PHASE_COMMIT;
            end
        end
        ST_PHASE_COMMIT: begin
            // The falling-edge divider acknowledges phase installation with
            // all enables zero. This edge installs the post-T beam and releases.
            video_state_in<=video_snap;video_state_set<=1;
            if (clock_phase_ready) begin
                clock_phase_set<=0;video_state_set<=0;ss_freeze<=0;unfreeze_cnt<=0;
                if (!do_save && has_audio_ext) begin
                    audio_phase_in<=audio_phase_snap;audio_phase_set<=1;
                end
                state<=ST_UNFREEZE_SETTLE;
            end
        end

`+c.slice(last);
change('            // Handle load error - unfreeze and return to idle', '            ss_cpu_prepare <= 0; clock_phase_set <= 0;\n            // Handle load error - unfreeze and return to idle');
c=c.replace('sprite_second?sprite2_snap[64*sprite_word+:64]:sprite_snap[64*sprite_word+:64]', 'sprite_second?sprite2_snap[63:0]:sprite_snap[63:0]');
c=c.replace("ddram_write(base_addr+sprite_address,sprite_write_word,8'hff);", "ddram_write(base_addr+sprite_address,sprite_write_word,8'hff);\n            if (sprite_second) sprite2_snap <= {sprite2_snap[63:0],sprite2_snap[4799:64]};\n            else sprite_snap <= {sprite_snap[63:0],sprite_snap[4799:64]};");
c=c.replace('sprite2_snap[64*sprite_word+:64]<=dout_latch;', 'sprite2_snap <= {dout_latch,sprite2_snap[4799:64]};').replace('sprite_snap[64*sprite_word+:64]<=dout_latch;', 'sprite_snap <= {dout_latch,sprite_snap[4799:64]};');
c=c.replace(/^\s*reg\s+\[21:0\]\s+align_timeout;[^\n]*\n/gm,'').replace(/^\s*align_timeout\s*<=.*;\n/gm,'');
put('savestates.sv',c);
// ModelSim 10.5 requires declarations before the existing net initializers;
// production Quartus accepts their original order. This adapter changes no logic.
let simc=c.replace('reg  [63:0] mapper_snap;','').replace('reg [159:0] evolution_snap;','');
simc=simc.replace('wire evolution_state =', 'reg [63:0] mapper_snap;reg [159:0] evolution_snap;\nwire evolution_state =');
fs.writeFileSync(p.join(out,'savestates_sim.sv'),simc);
let w=baseline('rtl/T80/T80s.vhd');
w=w.replace("NMIHold    : in std_logic := '0';", "NMIHold    : in std_logic := '0';\n        RestoreHold: in std_logic := '0';")
   .replace("NMIHold='1' or nmi_restart/=\"00\"", "NMIHold='1' or RestoreHold='1' or nmi_restart/=\"00\"");
w=w.replace("RestoreHold: in std_logic := '0';", "RestoreHold: in std_logic := '0';\n        ReplayT2: in std_logic := '1';")
 .replace('elsif CEN=\'1\' and nmi_restart="10" then nmi_restart <= "11";', 'elsif CEN=\'1\' and nmi_restart="10" then\n                if ReplayT2=\'1\' then nmi_restart <= "11";else nmi_restart <= "00";end if;');
fs.mkdirSync(p.join(out,'rtl/T80'),{recursive:true});put('T80/T80s.vhd',w);
let sys=baseline('rtl/system.vhd');
sys=sys.replace("\t\tss_freeze     : in  STD_LOGIC := '0'",`        ss_cpu_prepare : in std_logic := '0';
        ss_prepare_ce : in std_logic := '0';
        z80_replay_out : out std_logic;
        z80_tick_out : out std_logic;
        z80_replay_t2 : in std_logic := '1';
        ss_sprite_out, ss_sprite2_out : out std_logic_vector(74*(MAX_SPPL+1)+41 downto 0);
        ss_sprite_in, ss_sprite2_in : in std_logic_vector(74*(MAX_SPPL+1)+41 downto 0) := (others=>'0');
        ss_sprite_valid : in std_logic := '0';
\t\tss_freeze     : in  STD_LOGIC := '0'`);
sys=sys.replace("NMIEnable => '1', NMIHold => z80_nmi_hold, NMIReplay => nmi_replay_hold,", "NMIEnable => '1', NMIHold => z80_nmi_hold, RestoreHold => ss_freeze, NMIReplay => nmi_replay_hold,");
sys=sys.replace('RestoreHold => ss_freeze,','RestoreHold => ss_freeze, ReplayT2=>z80_replay_t2,');
sys=sys.replace("\tce_z80 <= '0' when se_pause='1' else", "    z80_replay_out <= nmi_replay_hold;\n\tce_z80 <= ss_prepare_ce and nmi_replay_hold when ss_cpu_prepare='1' else\n              '0' when se_pause='1' else");
sys=sys.replace('\t\tss_regs_out => vdp_regs_out,', '\t\tss_sprite_out=>ss_sprite_out,ss_sprite_in=>ss_sprite_in,ss_sprite_valid=>ss_sprite_valid,ss_freeze=>ss_freeze,\n\t\tss_regs_out => vdp_regs_out,')
       .replace('\t\tss_regs_out => vdp2_regs_out_i,', '\t\tss_sprite_out=>ss_sprite2_out,ss_sprite_in=>ss_sprite2_in,ss_sprite_valid=>ss_sprite_valid,ss_freeze=>ss_freeze,\n\t\tss_regs_out => vdp2_regs_out_i,');
put('system.vhd',sys);
sys=sys.replace('z80_replay_out <= nmi_replay_hold;', 'z80_replay_out <= nmi_replay_hold;\n    z80_tick_out <= ce_z80;');put('system.vhd',sys);
let top=baseline('SMS.sv');
top=top.replace('wire ss_freeze;', `wire ss_freeze;
wire ss_cpu_prepare, ss_z80_replay,ss_z80_tick,ss_replay_t2;
wire ss_phase_set;reg ss_phase_ready=0;
wire [1:0] ss_phase_in;
wire [1:0] ss_phase_out;
wire [4777:0] ss_sprite_out,ss_sprite2_out,ss_sprite_in,ss_sprite2_in;
wire ss_sprite_valid;`);
top=top.replace('reg  [4:0] clkd;', "reg  [4:0] clkd;\nassign ss_phase_out=clkd==25?2'd3:clkd==20?2'd2:clkd==10?2'd1:2'd0;");
top=top.replace('\t.ss_freeze(ss_freeze),', `\t.ss_freeze(ss_freeze),
    .ss_cpu_prepare(ss_cpu_prepare),.ss_prepare_ce(ce_cpu),.z80_replay_out(ss_z80_replay),
    .z80_tick_out(ss_z80_tick),.z80_replay_t2(ss_replay_t2),
    .ss_sprite_out(ss_sprite_out),.ss_sprite2_out(ss_sprite2_out),
    .ss_sprite_in(ss_sprite_in),.ss_sprite2_in(ss_sprite2_in),.ss_sprite_valid(ss_sprite_valid),`);
// Controller instantiation uses aligned whitespace rather than the system form.
const ci=top.indexOf('savestates savestates_inst (');
if(ci<0)throw Error('No top controller');
top=top.slice(0,ci)+top.slice(ci).replace('.clk', `.ss_cpu_prepare(ss_cpu_prepare),.z80_replay(ss_z80_replay),
    .z80_tick_active(ss_z80_tick),.z80_replay_t2(ss_replay_t2),
    .clock_phase(ss_phase_out),.clock_phase_in(ss_phase_in),.clock_phase_set(ss_phase_set),.clock_phase_ready(ss_phase_ready),
    .sprite_out(ss_sprite_out),.sprite2_out(ss_sprite2_out),.sprite_in(ss_sprite_in),.sprite2_in(ss_sprite2_in),.sprite_valid(ss_sprite_valid),
    .clk`);
top=top.replace('.address   (ss_freeze ?', '.address   ((ss_freeze && !ss_cpu_prepare) ?')
       .replace('.address_a   (ss_freeze ?', '.address_a   ((ss_freeze && !ss_cpu_prepare) ?');
top=top.replace('always @(negedge clk_sys) begin\n\tce_sp <=', `always @(negedge clk_sys) begin
    ss_phase_ready<=ss_phase_set;
    if (ss_phase_set) begin
        case(ss_phase_in)
        2'd0:clkd<=0;2'd1:clkd<=10;2'd2:clkd<=20;2'd3:clkd<=25;
        endcase
        ce_cpu<=0;ce_vdp<=0;ce_pix<=0;ce_sp<=0;
    end else begin
\tce_sp <=`);
const dend=top.indexOf('\nwire HS, VS;');
top=top.slice(0,dend).replace(/end\s*$/, 'end\nend\n')+top.slice(dend);
fs.writeFileSync(p.join(out,'SMS.sv'),top);
