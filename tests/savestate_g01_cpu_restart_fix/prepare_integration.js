const fs=require('fs'),path=require('path');const d=__dirname,r=path.resolve(d,'../..'),old=path.join(r,'tests/savestate_g01_cpu_restart');
const get=n=>fs.readFileSync(path.join(d,n),'utf8').replace(/\r\n/g,'\n'),put=(n,s)=>fs.writeFileSync(path.join(d,n),s);
const src=n=>get('proposed/'+n);
const dbg='debug_ctx : out std_logic_vector(63 downto 0); debug_nmi : out std_logic_vector(12 downto 0); debug_old : out std_logic;\n';
const fields=JSON.parse(fs.readFileSync(path.join(old,'context_fields.json'),'utf8'));
let cpu=src('rtl/T80/T80.vhd').replace(/: work\.(T80_MCode|T80_ALU|T80_Reg)/g,': entity work.$1');
// ModelSim checks unconstrained vector operand lengths at runtime. Give the
// inherited block-IO low-three-bit mask its nine-bit zero-extended width.
cpu=cpu.replace('(ioq and x"7")','(ioq and "000000111")');
cpu=cpu.replace('DIRSet     : in',dbg+'DIRSet     : in').replace('\tREG <=',` debug_ctx <= ${fields.map(f=>['ID16','MCycle','TState'].includes(f.name)?`std_logic_vector(${f.name})`:f.name).join(' & ')};
 debug_nmi <= NMI_s & NMICycle & IntCycle & std_logic_vector(MCycle) & std_logic_vector(TState) & Prefix & IntE_FF1 & IntE_FF2;
 debug_old <= OldNMI_n;
\tREG <=`);put('T80_integrated.vhd',cpu);
let wrap=src('rtl/T80/T80s.vhd').replace(': work.T80',': entity work.T80').replace('DIRSet     : in',dbg+'DIRSet     : in').replace('DIRSet => DIRSet,','debug_ctx => debug_ctx, debug_nmi => debug_nmi, debug_old => debug_old, DIRSet => DIRSet,');put('T80s_integrated.vhd',wrap);
let ss=src('rtl/savestates.sv');for(const n of ['mapper_snap','evolution_snap','dout_latch']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';[^\\n]*\\n','m'),m=ss.match(re);if(!m)throw Error(n);ss=ss.replace(re,'').replace('// NVRAM size calculation helpers',m[0]+'// NVRAM size calculation helpers');}put('savestates_integrated.sv',ss);
let m=get('proof_machine.sv').replace('input[2:0]restart_dir,','input int_n,input restart_valid,input[2:0]restart_dir,').replace('.INT_n(1\'b1)','.INT_n(int_n)').replace('.Restart(restart_out),','.RestartContext(restart_out),.RestartValid(restart_valid),');
// Relocate inherited startup for interrupt fixtures so vector0038 is free.
const original=fs.readFileSync(path.join(old,'machine.sv'),'utf8');let startup='';
for(const match of original.matchAll(/^(\d+):rom=([^;]+);/gm)){const a=+match[1];if(a>=32&&a<=99)startup+=`${0x2000+a-32}:rom=${match[2]};\n`;}
const bodies={28:[0xed,0x56,0x3e,0x5a,0xfb,0x32,0x40,0xc1,0x32,0x41,0xc1,0xf3],29:[0xf3,0x76,0x3e,0x69,0x32,0x43,0xc1],30:[0xed,0x56,0xfb,0x76,0x3e,0x6a,0x32,0x43,0xc1],31:[0xf3,0x76,0x3e,0x6b,0x32,0x43,0xc1]};
let extras=`if(PROGRAM>=28)case(a)\n2:rom=8'hc3;3:rom=0;4:rom=8'h20;\n${startup}56:rom=8'hc3;57:rom=0;58:rom=6;\n`;
const handler=[0xf5,0x3a,0x42,0xc1,0x3c,0x32,0x42,0xc1,0xf1,0xed,0x4d];extras+=handler.map((b,i)=>`${0x600+i}:rom=8'h${b.toString(16)};`).join('\n')+'\ndefault:begin end endcase\n';
for(const[p,body]of Object.entries(bodies)){const bytes=[...body,0xc3,0,1];extras+=`if(PROGRAM==${p})case(a)\n`+bytes.map((b,i)=>`${0x120+i}:rom=8'h${b.toString(16)};`).join('\n')+'\ndefault:begin end endcase\n';}
m=m.replace('end endfunction',extras+'end endfunction');put('integrated_machine.sv',m);
m=m.replace("addr[7:0]==8'h7d ? {6'd0,qmode}:io_data","addr[7:0]==8'h7d ? {6'd0,qmode}:addr[7:0]==8'h7c ? (8'ha5^addr[15:8]):io_data");
// CPU-class matrices use a transparent immutable ROM/RAM fixture. Retain the
// full production mapper/decode for the original PROGRAM0..9 regressions.
const mappingLine=m.split('\n').find(s=>s.includes(' mapping maps('));
if(!mappingLine)throw Error('mapper fixture anchor');
m=m.replace(mappingLine,` generate if(PROGRAM<10)begin: real_mapper
${mappingLine}
 end else begin: cpu_fixture
 assign map_out=0;assign hist_out=0;assign physical={6'd0,addr};
 reg[15:0]last=0;assign last_read=last;
 always @(posedge clk)if(mrst&&cpu_ce&&!ss_freeze&&wr&&!mreq)last<=addr;
 end endgenerate`);put('integrated_machine.sv',m);
let tb=get('proof_tb.sv').replace('reg[2:0]restart_saved=0;','wire[2:0]restart_saved;wire restart_valid;');
tb=tb.replace('SIGNATURE=0;','SIGNATURE=0,INTCASE=0;');
tb=tb.replace('reg npause=1,rpause=1;','reg nint=1,rint=1;reg npause=1,rpause=1;');
tb=tb.replace('wire[2:0]restart_out;wire[2:0]restart_saved;wire restart_valid;','');
tb=tb.replace('savestates dut(','wire[2:0]restart_out,restart_saved;wire restart_valid;\nsavestates dut(');
tb=tb.replace('savestates dut(','.BAD.');if(!tb.includes('.BAD.'))throw Error('controller');tb=tb.replace('.BAD.',`savestates dut(.z80_restart(restart_out),.z80_restart_dir(restart_saved),.z80_restart_valid(restart_valid),`);
tb=tb.replace(' core(.restart_dir',' core(.restart_valid(restart_valid),.restart_dir').replace(' reference(.restart_dir',' reference(.restart_valid(1\'b0),.restart_dir');
tb=tb.replace(' core(.restart_valid',' core(.int_n(nint),.restart_valid').replace(' reference(.restart_valid',' reference(.int_n(rint),.restart_valid');
tb=tb.replace('restart_saved=restart_out;','');
tb=tb.replace('accepted=1;accepted_cycle=cycle;',`if((^z80_reg)===1'bx)$fatal(1,"Unknown architectural capture");
 $display("ACCEPT_REG BC%h DE%h HL%h HALT%b IFF%b%b INT%b",z80_reg[95:80],z80_reg[111:96],z80_reg[127:112],z80_reg[229],z80_reg[211],z80_reg[210],nint);
 accepted=1;accepted_cycle=cycle;`);
tb=tb.replace('PROGRAM==9&&n>=200','(PROGRAM==9||PROGRAM==31)&&n>=200');
tb=tb.replace('function future_pause(input integer n);future_pause=',"function future_pause(input integer n);if(PROGRAM==31&&INTCASE==5)future_pause=!(n>=200);else future_pause=");
tb=tb.replace('always @(negedge clk)begin\n #1;\n if(accepted',`function future_int(input integer n);begin
 case(INTCASE)
 1:future_int=0;
 2:future_int=!(n>=300);
 3:future_int=!(n>=15&&n<45);
 4:future_int=!(n>=-30);
 default:future_int=1;
 endcase
end endfunction
always @(negedge clk)begin
 #1;
 if(!accepted)begin nint=future_int(cycle-ready_cycle-OFFSET-79);rint=nint;end
 if(accepted&&!ref_done)rint=future_int(cycle-accepted_cycle);
 if(follow_d)nint=future_int(d_index+1);
 if(accepted`);
tb=tb.replace('if(PROGRAM==9)begin npause=0;','if(PROGRAM==9||PROGRAM>=29)begin npause=0;');
tb=tb.replace('wire pix=(!mrst||cycle%10==0);','wire pix=(!mrst||cycle%10==0)&&!ss_freeze;');
tb=tb.replaceAll('PASS G09','PASS G01');tb=tb.replace('pre%h saved%h','pre%h class%h');
tb=tb.replace('$writememh($sformatf("image_p%0d_o%0d_t%0d_s%0d.hex",PROGRAM,OFFSET,PERIOD,SYS),mem);',`if(mem['h1a][63:40]!==24'h48430d)$fatal(1,"v13 writer tag");
 $display("IMAGE class%h nmi%h tag%h",mem[5][43:41],mem[5][40:38],mem['h1a][63:40]);
 $writememh($sformatf("image_p%0d_o%0d_t%0d_s%0d_sig%0d_i%0d.hex",PROGRAM,OFFSET,PERIOD,SYS,SIGNATURE,INTCASE),mem);`);
put('integrated_tb.sv',tb);
put('integrated.do',get('proof.do').replaceAll('proof_work','integrated_work').replace('T80_proof.vhd T80s_proof.vhd','T80_integrated.vhd T80s_integrated.vhd').replace('savestates_sim.sv','savestates_integrated.sv').replace('proof_machine.sv proof_tb.sv','integrated_machine.sv integrated_tb.sv').replace('-gSIGNATURE=$env(G01_SIGNATURE)','-gSIGNATURE=$env(G01_SIGNATURE) -gINTCASE=$env(G01_INTCASE)'));
put('integrated.ps1',get('proof.ps1').replace('[int]$Signature=0,','[int]$IntCase=0,[int]$Signature=0,').replace('Get-Content proof.do','Get-Content integrated.do').replace('"proof_p','"integrated_p').replace('_c${Captures}"','_c${Captures}_sig${Signature}_i${IntCase}"').replace('$run=@()','$env:G01_INTCASE="$IntCase"\n $run=@()').replace("'PASS G09'","'PASS G01'"));
console.log('Prepared proposed v13 end-to-end integration, full flush, no context side record.');


