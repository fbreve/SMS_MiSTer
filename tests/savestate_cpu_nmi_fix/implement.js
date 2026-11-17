// Apply the reviewed F16 contract only after baseline reproduction succeeds.
const fs=require('fs'),path=require('path'),cp=require('child_process'),assert=require('assert'),d=__dirname,r=path.resolve(d,'../..');
const text=p=>{const b=fs.readFileSync(p);return b[0]===255?b.toString('utf16le'):b.toString('utf8')};
assert.equal((text(path.join(d,'pre.out')).match(/PASS /g)||[]).length,6);
for(const n of ['pending','causal','capture_pulse','held']){let s=text(path.join(d,'baseline',n+'.log'));assert(s.includes('SAVE_SUFFIX count=1'));assert.equal((s.match(/LOAD_SUFFIX iter\d+ count=0/g)||[]).length,3,n);}
const image=n=>text(path.join(d,'baseline',n)).split(/\r?\n/).filter(x=>x&&!x.startsWith('//'));
assert.deepEqual(image('snapshot_s0_p0_e9999999_w5_r1_second9999999.hex'),image('snapshot_s0_p0_e-15_w5_r1_second9999999.hex'));
const finishSV=process.argv.includes('--finish-sv');
if(!finishSV)assert.equal(cp.execFileSync('git',['diff','--name-only'],{cwd:r}).toString(),'');
function edit(p,f){if(finishSV&&p!=='rtl/savestates.sv')return;const file=path.join(r,p),a=fs.readFileSync(file,'utf8'),b=f(a);assert(a!==b,p);fs.writeFileSync(file,b);}
const ports=`\t\t-- Normalized capture: pending, selected entry, sampled Old.
        NMIState   : out std_logic_vector(2 downto 0);
        NMIDIR     : in std_logic_vector(2 downto 0) := "001";
        NMISet     : in std_logic := '0';
        NMILegacy  : in std_logic := '0';
        NMIHold    : in std_logic := '0';
`;
edit('rtl/T80/T80.vhd',s=>{
 s=s.replace('\t\tDIRSet     : in',ports+'\t\tDIRSet     : in');
 s=s.replace('signal NMI_s                : std_logic;','signal NMI_s                : std_logic;\n    signal OldNMI_n             : std_logic; -- Retains the original no-reset history semantics.');
 s=s.replace('\tREG <=',"    NMIState <= (NMI_s or (OldNMI_n and not NMI_n)) & NMICycle & NMI_n;\n\tREG <=");
 s=s.replace('\t\tvariable OldNMI_n : std_logic;','');
 s=s.replace("\t\t\t\tif NMI_n = '0' and OldNMI_n = '1' then\r\n\t\t\t\t\tNMI_s <= '1';\r\n\t\t\t\tend if;\r\n\t\t\t\tOldNMI_n := NMI_n;",`                -- DIRSet above always wins. Apply T-time history only afterwards,
                -- with CEN stopped by the wrapper's restart protocol.
                if NMISet = '1' then
                    NMI_s <= NMIDIR(2); NMICycle <= NMIDIR(1); OldNMI_n <= NMIDIR(0);
                    if NMILegacy = '1' then
                        NMI_s <= '0'; NMICycle <= '0'; OldNMI_n <= NMI_n;
                    end if;
                elsif NMIHold = '0' then
                    if NMI_n = '0' and OldNMI_n = '1' then NMI_s <= '1'; end if;
                    OldNMI_n <= NMI_n;
                end if;`);
 assert(s.includes('elsif NMIHold'));return s;
});
edit('rtl/T80/T80s.vhd',s=>{
 s=s.replace('\t\tDIRSet     : in',`        NMIState   : out std_logic_vector(2 downto 0);
        NMIDIR     : in std_logic_vector(2 downto 0) := "001";
        NMIValid   : in std_logic := '0';
        NMIEnable  : in std_logic := '0';
        NMIHold    : in std_logic := '0';
        NMIReplay  : out std_logic;
\t\tDIRSet     : in`);
 s=s.replace('architecture rtl of T80s is',`architecture rtl of T80s is
    -- 00 live; 01 install history with CPU stopped; 10 T1; 11 historical T2.
    signal nmi_restart : std_logic_vector(1 downto 0) := "00";
    signal nmi_apply, nmi_hold_i, cen_i : std_logic;
`);
 s=s.replace('\tu0 : work.T80',`    nmi_apply <= '1' when nmi_restart="01" and DIRSet='0' and NMIHold='0' else '0';
    nmi_hold_i <= '1' when NMIHold='1' or nmi_restart/="00" else '0';
    cen_i <= CEN when nmi_restart/="01" else '0';
    NMIReplay <= '1' when nmi_restart/="00" else '0';
    process (RESET_n, CLK)
    begin
        if RESET_n='0' then nmi_restart <= "00";
        elsif rising_edge(CLK) then
            if DIRSet='1' and NMIEnable='1' then nmi_restart <= "01";
            elsif nmi_apply='1' then nmi_restart <= "10";
            elsif CEN='1' and nmi_restart="10" then nmi_restart <= "11";
            elsif CEN='1' and nmi_restart="11" then nmi_restart <= "00";
            end if;
        end if;
    end process;

\tu0 : work.T80`);
 s=s.replace('CEN => CEN,','CEN => cen_i,');
 s=s.replace('DIRSet => DIRSet,',`NMIState => NMIState, NMIDIR => NMIDIR, NMISet => nmi_apply,
            NMILegacy => not NMIValid, NMIHold => nmi_hold_i,
            DIRSet => DIRSet,`);
 s=s.replace("elsif CEN = '1' then","elsif cen_i = '1' then");return s;
});
edit('rtl/system.vhd',s=>{
 s=s.replace('\t\tz80_set      : in',`        z80_nmi_out : out STD_LOGIC_VECTOR(2 downto 0);
        z80_nmi_dir : in STD_LOGIC_VECTOR(2 downto 0) := "001";
        z80_nmi_valid : in STD_LOGIC := '0';
        z80_nmi_hold : in STD_LOGIC := '0';
\t\tz80_set      : in`);
 s=s.replace('signal z80_iset_int:',"signal nmi_replay_hold : std_logic;\n\tsignal z80_iset_int:");
 s=s.replace('DIRSet => z80_set,',`NMIState => z80_nmi_out, NMIDIR => z80_nmi_dir, NMIValid => z80_nmi_valid,
        NMIEnable => '1', NMIHold => z80_nmi_hold, NMIReplay => nmi_replay_hold,
        DIRSet => z80_set,`);
 // Only IO's hold changes; memory ownership remains controlled by ss_freeze.
 const io=s.indexOf('io_inst: entity work.io'),end=s.indexOf(');',io);s=s.slice(0,io)+s.slice(io,end).replace('ss_freeze     => ss_freeze','ss_freeze     => ss_freeze or nmi_replay_hold')+s.slice(end);
 assert(s.includes('NMIEnable'));assert(s.includes('ss_freeze or nmi_replay_hold'));return s;
});
edit('SMS.sv',s=>{
 s=s.replace('wire [229:0] ss_z80_reg, ss_z80_dir;','wire [229:0] ss_z80_reg, ss_z80_dir;\nwire [2:0] ss_z80_nmi, ss_z80_nmi_dir;\nwire ss_z80_nmi_valid, ss_z80_nmi_hold;');
 s=s.replace('.z80_reg_out (ss_z80_reg),',`.z80_reg_out (ss_z80_reg),
    .z80_nmi_out(ss_z80_nmi), .z80_nmi_dir(ss_z80_nmi_dir),
    .z80_nmi_valid(ss_z80_nmi_valid), .z80_nmi_hold(ss_z80_nmi_hold),`);
 s=s.replace('.z80_reg         (ss_z80_reg),',`.z80_reg         (ss_z80_reg),
    .z80_nmi(ss_z80_nmi), .z80_nmi_dir(ss_z80_nmi_dir),
    .z80_nmi_valid(ss_z80_nmi_valid), .z80_nmi_hold(ss_z80_nmi_hold),`);return s;
});
edit('rtl/savestates.sv',s=>{
 s=s.replace('input     [229:0] z80_reg,',`input       [2:0] z80_nmi,         // normalized post-sample history at accepted MC1/T2
    output      [2:0] z80_nmi_dir,
    output            z80_nmi_valid,
    output reg        z80_nmi_hold,
    input     [229:0] z80_reg,`);
 s=s.replace('reg [229:0] z80_snap;',`reg [229:0] z80_snap;
reg [2:0] nmi_snap;
reg has_nmi_history, nmi_padding_ok;
localparam [23:0] NMI_HISTORY_MAGIC = 24'h48430c;
// v12 inherits every v11 extension location and meaning.
wire [23:0] load_ext_magic = dout_latch[63:40] == NMI_HISTORY_MAGIC ? EVOLUTION_PENDING_MAGIC : dout_latch[63:40];
wire invalid_nmi_header = dout_latch[63:40] == NMI_HISTORY_MAGIC &&
                          (dout_latch[39:38] != 2'd3 || !nmi_padding_ok);
assign z80_nmi_dir = nmi_snap;
assign z80_nmi_valid = has_nmi_history;`);
 // Substitute only version comparisons, preserving the literal raw tag used to validate v12.
 s=s.replace(/dout_latch\[63:40\] (==|!=) (EVOLUTION_\w+|MAPPER_HISTORY_MAGIC|GUN_EXT_MAGIC|PADDLE_EXT_MAGIC|TAP_EXT_MAGIC|SC_EXT_MAGIC|EEPROM_EXT_MAGIC|MD_EXT_MAGIC|HCOUNTER_MAGIC|IO_EXT_MAGIC)/g,'load_ext_magic $1 $2');
 s=s.replace('{EVOLUTION_PENDING_MAGIC, 2\'d3,',"{NMI_HISTORY_MAGIC, 2'd3,");
 s=s.replaceAll("{ 26'd0 , z80_snap [ 229 : 192 ] }","{ 23'd0, nmi_snap, z80_snap [ 229 : 192 ] }");
 s=s.replaceAll("{26'd0, z80_snap[229:192]}","{23'd0, nmi_snap, z80_snap[229:192]}");
 s=s.replace('z80_snap    <= z80_reg;',`z80_snap    <= z80_reg;
                nmi_snap <= z80_nmi;
                if (!do_save) z80_nmi_hold <= 1;`);
 s=s.replace('ss_freeze       <= 0;',`ss_freeze       <= 0;
        z80_nmi_hold <= 0; nmi_snap <= 3'b001; has_nmi_history <= 0; nmi_padding_ok <= 1;`);
 s=s.replace('// Old 64KB files bypass ST_LOAD_VIDEO entirely.',`has_nmi_history <= 0; nmi_snap <= 3'b001; nmi_padding_ok <= 1;
                // Old 64KB files bypass ST_LOAD_VIDEO entirely.`);
 s=s.replace(/3'd3: begin\r?\n                        if \(is_old_format\)/,`3'd3: begin
                        nmi_snap <= dout_latch[40:38];
                        nmi_padding_ok <= dout_latch[63:41] == 0;
                        if (is_old_format)`);
 s=s.replace('if (!((live_evolution || evolution_state)', 'if (!invalid_nmi_header && !((live_evolution || evolution_state)');
 s=s.replace('if ((live_evolution || evolution_state) &&', 'if (invalid_nmi_header || (live_evolution || evolution_state) &&');
 s=s.replace('has_evolution_history <= (load_ext_magic',`has_nmi_history <= dout_latch[63:40] == NMI_HISTORY_MAGIC;
                has_evolution_history <= (load_ext_magic`);
 s=s.replace('ss_freeze    <= 0;', 'ss_freeze    <= 0;\n                    z80_nmi_hold <= 0;');
 s=s.replace('ss_freeze <= 0;', 'ss_freeze <= 0;\n            z80_nmi_hold <= 0;');
 assert(s.includes('nmi_padding_ok <= dout_latch'));return s;
});
console.log('Applied F16 normalized capture, post-DIRSet restart, v12 fields/validation and top-level wiring.');
