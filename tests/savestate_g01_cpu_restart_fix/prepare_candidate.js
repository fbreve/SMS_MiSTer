const fs=require('fs'),path=require('path'),cp=require('child_process');const d=__dirname,r=path.resolve(d,'../..'),out=path.join(d,'proposed');fs.mkdirSync(out,{recursive:true});
const read=n=>cp.execFileSync('git',['show','faf7036e4450027f79cc639a731053dca29840ca:'+n],{cwd:r,maxBuffer:1024*1024}).toString().replace(/\r\n/g,'\n');
function change(s,a,b){if(!s.includes(a))throw Error('Missing source anchor: '+a.slice(0,100));return s.replace(a,b);}
function put(n,s){const p=path.join(out,n);fs.mkdirSync(path.dirname(p),{recursive:true});fs.writeFileSync(p,s);}
const ports=`        -- Pre-fetch semantic context: ordinary, CB, ED, DD, FD, EI.
        RestartContext : out std_logic_vector(2 downto 0);
        RestartDIR     : in std_logic_vector(2 downto 0) := "000";
        RestartValid   : in std_logic := '0';
`;
let cpu=read('rtl/T80/T80.vhd');cpu=change(cpu,'\t\tDIRSet     : in',ports+'\t\tDIRSet     : in');
cpu=change(cpu,'\tREG <=',`    -- Only consumed at the accepted ISet=00, MC1/T2 boundary. T1 has
    -- drained general writeback; T2 still consumes the preceding IR's
    -- prefix selection and EI action before installing the fetched opcode.
    RestartContext <= "001" when IR=x"CB" else
                      "010" when IR=x"ED" else
                      "011" when IR=x"DD" else
                      "100" when IR=x"FD" else
                      "101" when IR=x"FB" else "000";
\tREG <=`);
cpu=change(cpu,'\t\t\t\tIR <= "00000000";\n\t\t\t\tMCycles',`                -- Seed the predecessor class for historical T2. Legacy files
                -- have no such history and retain ordinary normalization.
                IR <= x"00";
                if RestartValid='1' then
                    case RestartDIR is
                        when "001" => IR <= x"CB";
                        when "010" => IR <= x"ED";
                        when "011" => IR <= x"DD";
                        when "100" => IR <= x"FD";
                        when "101" => IR <= x"FB";
                        when others => null;
                    end case;
                end if;
\t\t\t\tMCycles`);put('rtl/T80/T80.vhd',cpu);
let w=read('rtl/T80/T80s.vhd');w=change(w,'\t\tDIRSet     : in',ports+'\t\tDIRSet     : in');w=change(w,'DIRSet => DIRSet,',`RestartContext => RestartContext, RestartDIR => RestartDIR,
            RestartValid => RestartValid,
\t\t\tDIRSet => DIRSet,`);put('rtl/T80/T80s.vhd',w);
let sys=read('rtl/system.vhd');sys=change(sys,'        z80_nmi_out : out',`        z80_restart_out : out STD_LOGIC_VECTOR(2 downto 0);
        z80_restart_dir : in STD_LOGIC_VECTOR(2 downto 0) := "000";
        z80_restart_valid : in STD_LOGIC := '0';
        z80_nmi_out : out`);sys=change(sys,'\t\tNMIState => z80_nmi_out,',`        RestartContext => z80_restart_out, RestartDIR => z80_restart_dir,
        RestartValid => z80_restart_valid,
\t\tNMIState => z80_nmi_out,`);put('rtl/system.vhd',sys);
let top=read('SMS.sv');top=change(top,'wire [2:0] ss_z80_nmi,',`wire [2:0] ss_z80_restart, ss_z80_restart_dir;
wire ss_z80_restart_valid;
wire [2:0] ss_z80_nmi,`);top=change(top,'    .z80_nmi_out(ss_z80_nmi)',`    .z80_restart_out(ss_z80_restart), .z80_restart_dir(ss_z80_restart_dir),
    .z80_restart_valid(ss_z80_restart_valid),
    .z80_nmi_out(ss_z80_nmi)`);top=change(top,'    .z80_nmi(ss_z80_nmi)',`    .z80_restart(ss_z80_restart), .z80_restart_dir(ss_z80_restart_dir),
    .z80_restart_valid(ss_z80_restart_valid),
    .z80_nmi(ss_z80_nmi)`);top=top.replace('"00" = clean instruction boundary (no prefix)','"00" = eligible fetch; pending decoder context is saved separately');put('SMS.sv',top);
let ss=read('rtl/savestates.sv');ss=change(ss,'    input       [2:0] z80_nmi,',`    input       [2:0] z80_restart,     // pre-T2 decoder class, not the new opcode
    output      [2:0] z80_restart_dir,
    output            z80_restart_valid,
    input       [2:0] z80_nmi,`);
ss=change(ss,'reg [2:0] nmi_snap;',`reg [2:0] nmi_snap;
reg [2:0] restart_snap;
reg has_restart_context, restart_padding_ok;
localparam [23:0] CPU_RESTART_MAGIC = 24'h48430d;
assign z80_restart_dir = restart_snap;
assign z80_restart_valid = has_restart_context;`);
ss=change(ss,'{NMI_HISTORY_MAGIC, 2\'d3,',"{CPU_RESTART_MAGIC, 2'd3,");
ss=change(ss,"wire [23:0] load_ext_magic = dout_latch[63:40] == NMI_HISTORY_MAGIC ? EVOLUTION_PENDING_MAGIC : dout_latch[63:40];",`wire modern_nmi_tag = dout_latch[63:40] == NMI_HISTORY_MAGIC || dout_latch[63:40] == CPU_RESTART_MAGIC;
wire [23:0] load_ext_magic = modern_nmi_tag ? EVOLUTION_PENDING_MAGIC : dout_latch[63:40];`);
ss=change(ss,"wire invalid_nmi_header = dout_latch[63:40] == NMI_HISTORY_MAGIC &&\n                          (dout_latch[39:38] != 2'd3 || !nmi_padding_ok);",`wire invalid_nmi_header = modern_nmi_tag &&
                          (dout_latch[39:38] != 2'd3 ||
                           (dout_latch[63:40] == CPU_RESTART_MAGIC ? !restart_padding_ok : !nmi_padding_ok));`);
ss=ss.replaceAll("has_nmi_history <= 0; nmi_snap <= 3'b001; nmi_padding_ok <= 1;",`has_nmi_history <= 0; nmi_snap <= 3'b001; nmi_padding_ok <= 1;
                has_restart_context <= 0; restart_snap <= 0; restart_padding_ok <= 1;`);
ss=change(ss,"        z80_nmi_hold <= 0; nmi_snap <= 3'b001; has_nmi_history <= 0; nmi_padding_ok <= 1;",`        z80_nmi_hold <= 0; nmi_snap <= 3'b001; has_nmi_history <= 0; nmi_padding_ok <= 1;
        has_restart_context <= 0; restart_snap <= 0; restart_padding_ok <= 1;`);
ss=change(ss,'                nmi_snap <= z80_nmi;','                nmi_snap <= z80_nmi;\n                restart_snap <= z80_restart;');
const word5=/\{\s*23'd0,\s*nmi_snap,\s*z80_snap\s*\[\s*229\s*:\s*192\s*\]\s*\}/g;
if((ss.match(word5)||[]).length!==2)throw Error('Expected both CPU word5 writers');
ss=ss.replace(word5,"{20'd0, restart_snap, nmi_snap, z80_snap[229:192]}");
ss=change(ss,'                        nmi_snap <= dout_latch[40:38];',`                        nmi_snap <= dout_latch[40:38];
                        restart_snap <= dout_latch[43:41];
                        restart_padding_ok <= dout_latch[63:44] == 0 && dout_latch[43:41] <= 3'd5;`);
ss=change(ss,'                has_nmi_history <= dout_latch[63:40] == NMI_HISTORY_MAGIC;',`                has_nmi_history <= modern_nmi_tag;
                has_restart_context <= dout_latch[63:40] == CPU_RESTART_MAGIC;`);
ss=ss.replace('//                   word5[63:41]=zero. v12 tag=48430c, subtype=3 at word01a.',`//                   v13 word5[43:41]=pre-T2 decoder class; [63:44]=zero.
//                   v13 tag=48430d, subtype=3 at word01a. v12 has zero [63:41].`);
ss=ss.replace('// v12 inherits every v11 extension location and meaning.','// v13 inherits v12 NMI and every v11 extension location and meaning.');
ss=ss.replace('//   - ISet=00   : no prefix active (not mid-way through CB/DD/ED/FD sequence)',`//   - ISet=00   : eligible fetch; previous IR may still carry a pending
            //                  prefix/EI class, captured separately in v13.`);put('rtl/savestates.sv',ss);
console.log('Prepared five proposed production files; worktree RTL not changed.');

