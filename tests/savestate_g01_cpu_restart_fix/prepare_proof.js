const fs=require('fs'),path=require('path');const d=__dirname,r=path.resolve(d,'../..'),old=path.join(r,'tests/savestate_g01_cpu_restart');
const get=(base,n)=>fs.readFileSync(path.join(base,n),'utf8'),put=(n,s)=>fs.writeFileSync(path.join(d,n),s);
for(const n of ['mapping.sv','mapper_ctrl_observed.vhd','io_instance.sv'])put(n,get(old,n));
let cpu=get(old,'T80_context.vhd').replace(/\r\n/g,'\n');
cpu=cpu.replace('DIRSet     : in',`Restart : out std_logic_vector(2 downto 0); RestartDIR : in std_logic_vector(2 downto 0) := "000";
 DIRSet     : in`);
cpu=cpu.replace('    debug_nmi <=',` Restart <= "001" when IR=x"CB" else "010" when IR=x"ED" else "011" when IR=x"DD" else "100" when IR=x"FD" else "101" when IR=x"FB" else "000";
    debug_nmi <=`);
cpu=cpu.replace('IR <= "00000000";\n\t\t\t\tMCycles',`case RestartDIR is
 when "001" => IR <= x"CB"; when "010" => IR <= x"ED";
 when "011" => IR <= x"DD"; when "100" => IR <= x"FD";
 when "101" => IR <= x"FB"; when others => IR <= x"00";
 end case;
\t\t\t\tMCycles`);
if(!cpu.includes('case RestartDIR'))throw Error('Prototype restore insertion failed');put('T80_proof.vhd',cpu);
let wrap=get(old,'T80s_context.vhd').replace('DIRSet     : in',`Restart : out std_logic_vector(2 downto 0); RestartDIR : in std_logic_vector(2 downto 0) := "000";
 DIRSet     : in`).replace('DIRSet => DIRSet,','Restart => Restart, RestartDIR => RestartDIR, DIRSet => DIRSet,');put('T80s_proof.vhd',wrap);
let m=get(old,'extended_machine.sv').replace('output[63:0]ctx_view,','input[2:0]restart_dir,output[2:0]restart_out,output[63:0]ctx_view,').replace('.DIRSet(cpu_set)', '.Restart(restart_out),.RestartDIR(restart_dir),.DIRSet(cpu_set)');
const progs={10:[0x06,0x81,0xcb,0x00],11:[0x3e,0x35,0xed,0x44],12:[0xdd,0x21,0,0xc2,0xdd,0x24],13:[0xfd,0x21,0x10,0xc2,0xfd,0x2c],14:[0xdd,0x21,0,0xc2,0xdd,0xcb,0,0x06],15:[0xfd,0x21,0,0xc2,0xfd,0xcb,0,0xc6],16:[0xfb,0,0,0xf3],17:[0x06,3,0x0e,5,0x78,0x81,0x32,0x20,0xc1,0x3a,0x20,0xc1,0xc5,0xd1,0xcd,0x80,1,0xaf,0x20,0,0x28,0,0xdb,0x7c,0xd3,0x7c],26:[0xdd,0xfd,0xdd,0xfd,0,0x3c],27:[0xfb,0x76,0xf3]};
for(let i=0;i<8;i++)progs[18+i]=[0x3e,1,0x32,0,0xc2,0x3c,0x32,1,0xc2,0x3c,0x32,2,0xc2,0x21,...(i%2?[2,0xc2]:[0,0xc2]),0x11,...(i%2?[2,0xc3]:[0,0xc3]),0x01,...(i>=4?[0x7c,3]:[3,0]),0x3e,0x7f,0xed,[0xb0,0xb8,0xb1,0xb9,0xb2,0xba,0xb3,0xbb][i]];
let rom='';for(const [p,body]of Object.entries(progs)){const bytes=[...body,0xed,0x43,0x20,0xc1,0xed,0x53,0x22,0xc1,0xed,0x63,0x24,0xc1,0x32,0x10,0xc1,0xc3,0,1];rom+=`if(PROGRAM==${p})case(a)\n`+bytes.map((b,i)=>`${0x120+i}:rom=8'h${b.toString(16)};`).join('\n')+"\n384:rom=8'hc9;\ndefault:begin end endcase\n";}
m=m.replace('end endfunction',rom+'end endfunction');put('proof_machine.sv',m);
let tb=get(old,'fixed_tb.sv').replace('CAPTURES=0;','CAPTURES=0,SIGNATURE=0;').replace('localparam LENGTH=12000;','localparam LENGTH=12000;\nwire[2:0]restart_out;reg[2:0]restart_saved=0;wire[63:0]du,ru;');
tb=tb.replaceAll('.PROGRAM(PROGRAM),.SYS(SYS))','.PROGRAM(PROGRAM),.SYS(SYS),.SIGNATURE(SIGNATURE))').replace(' core(.qmode',' core(.restart_dir(restart_saved),.restart_out(restart_out),.ctx_view(du),.qmode').replace(' reference(.qmode',' reference(.restart_dir(3\'d0),.restart_out(),.ctx_view(ru),.qmode');
tb=tb.replace('accepted=1;accepted_cycle=cycle;',`restart_saved=restart_out;
 $display("CONTEXT pre%h saved%h",du,restart_out);
 accepted=1;accepted_cycle=cycle;`);
put('proof_tb.sv',tb);
put('savestates_sim.sv',get(old,'savestates_sim.sv'));
put('proof.do',get(old,'run.do').replaceAll('vlib work','vlib proof_work').replaceAll('-work work','-work proof_work').replace('work.fixed_tb','proof_work.fixed_tb').replace('T80_observed.vhd T80s_observed.vhd','T80_proof.vhd T80s_proof.vhd').replace('machine.sv fixed_tb.sv','proof_machine.sv proof_tb.sv').replace('-gCAPTURES=$env(G09_CAPTURES)','-gCAPTURES=$env(G09_CAPTURES) -gSIGNATURE=$env(G01_SIGNATURE)'));
put('proof.ps1',get(old,'run.ps1').replace('[switch]$Compile)','[int]$Signature=0,[switch]$Compile)').replace('Get-Content run.do','Get-Content proof.do').replace('$run=@()','$env:G01_SIGNATURE="$Signature"\n $run=@()').replace('"p${Program}_o','"proof_p${Program}_o'));
put('programs.json',JSON.stringify(progs,null,2));console.log('Prepared test-only six-class pre-T2 context prototype; production unchanged.');


