const fs=require('fs'),path=require('path');
const d=__dirname,old=path.resolve(d,'../savestate_g09_last_read');
const read=(base,n)=>fs.readFileSync(path.join(base,n),'utf8');const put=(n,s)=>fs.writeFileSync(path.join(d,n),s);
const fields=[['IR',8],['ISet',2],['XY_State',2],['Prefix',2],['SetEI',1],['SetDI',1],['IncDec_16',4],['RegAddrA',3],['RegWEH',1],['RegWEL',1],['ID16',16],['MCycle',3],['TState',3],['MCycles',3],['No_BTR',1],['Halt_FF',1],['Save_ALU_r',1],['Read_To_Reg_r',5],['BTR_r',1],['XY_Ind',1],['Auto_Wait_t1',1],['Auto_Wait_t2',1],['IntE_FF1',1],['IntE_FF2',1]];
let bit=64;const inventory=fields.map(([name,width])=>{bit-=width;return{name,width,low:bit,high:bit+width-1};});if(bit!==0)throw Error('context width');put('context_fields.json',JSON.stringify(inventory,null,2));
let cpu=read(old,'T80_observed.vhd');cpu=cpu.replace('debug_nmi : out','debug_ctx : out std_logic_vector(63 downto 0);\n debug_nmi : out');cpu=cpu.replace('    debug_nmi <=',' debug_ctx <= '+fields.map(([n])=>['ID16','MCycle','TState'].includes(n)?`std_logic_vector(${n})`:n).join(' & ')+';\n    debug_nmi <=');put('T80_context.vhd',cpu);
put('T80s_context.vhd',read(old,'T80s_observed.vhd').replace('debug_nmi : out','debug_ctx : out std_logic_vector(63 downto 0);\n debug_nmi : out').replace('debug_nmi => debug_nmi,','debug_ctx => debug_ctx, debug_nmi => debug_nmi,'));
let m=read(old,'machine.sv').replace('PROGRAM=0,SYS=0','PROGRAM=0,SYS=0,SIGNATURE=0').replace('output[229:0]cpu_reg,','output[63:0]ctx_view,output[229:0]cpu_reg,').replace('.debug_nmi(nstate)', '.debug_ctx(ctx_view),.debug_nmi(nstate)');
let bytes=[0x3a,0x2f,0xc1,0xb7,0xc2,0,0,0xed,0x43,0x20,0xc1,0xed,0x53,0x22,0xc1,0xed,0x63,0x24,0xc1,0x3e,1,0x32,0x2f,0xc1];
const done=0x12b+bytes.length;bytes[5]=done&255;bytes[6]=done>>8;bytes.push(0x3a,0x23,0x81,0x32,0x10,0xc1,0xc3,0,1);
const code=bytes.map((v,i)=>`${0x12b+i}:rom=8'h${v.toString(16)};`).join('\n');
m=m.replace('end endfunction',`if(SIGNATURE!=0&&PROGRAM==4)case(a)\n${code}\ndefault:begin end endcase\nend endfunction`);put('extended_machine.sv',m);put('signature_rom.json',JSON.stringify({start:0x12b,done,bytes},null,2));
let tb=read(old,'fixed_tb.sv');tb=tb.replace('CAPTURES=0;','CAPTURES=0,SIGNATURE=0;').replace('localparam LENGTH=12000;','localparam LENGTH=12000;\nwire[63:0]du,ru;reg[63:0]golden_ctx[0:LENGTH];integer first_cpu=-1,first_bus=-1;');
tb=tb.replaceAll('.PROGRAM(PROGRAM),.SYS(SYS))','.PROGRAM(PROGRAM),.SYS(SYS),.SIGNATURE(SIGNATURE))');tb=tb.replace(' core(.qmode',' core(.ctx_view(du),.qmode').replace(' reference(.qmode',' reference(.ctx_view(ru),.qmode');
tb=tb.replace('$display("ACCEPT program', '$display("CTX_PRE D%h R%h arch%h nstate%h",du,ru,z80_reg,dn);\n  $display("ACCEPT program');
tb=tb.replace('golden[0]=robs;', 'golden[0]=robs;golden_ctx[0]=ru;$display("CTX_POST R%h",ru);');
tb=tb.replace('golden[ref_index]=robs;','golden[ref_index]=robs;golden_ctx[ref_index]=ru;');
const from=tb.indexOf('task compare(input integer k);'),to=tb.indexOf('initial begin',from);
const compare=`task compare(input integer k);begin
 if(iteration==0&&dobs!==golden[k])$fatal(1,"SAVE ONLY mismatch");
 if(iteration>0)begin
  if(k==0)begin
   first_cpu=-1;first_bus=-1;
   $display("CANONICAL iter%0d arch_equal%b ctxR%h ctxD%h PC%h SP%h",iteration,dobs===golden[0],golden_ctx[0],du,z80_reg[79:64],z80_reg[63:48]);
   if(dobs!==golden[0])$fatal(1,"Canonical architectural instant differs");
  end
  if(k<4*PERIOD&&k%PERIOD==0)$display("STEP iter%0d k%0d ctxR%h ctxD%h archR%h archD%h",iteration,k,golden_ctx[k],du,golden[k][552:323],z80_reg);
  if(z80_reg!==golden[k][552:323]&&first_cpu<0)begin first_cpu=k;$display("FIRST_CPU iter%0d k%0d R%h D%h ctxR%h ctxD%h",iteration,k,golden[k][552:323],z80_reg,golden_ctx[k],du);end
  if(dobs[308:272]!==golden[k][308:272]&&first_bus<0)begin first_bus=k;$display("FIRST_BUS iter%0d k%0d R%h D%h",iteration,k,golden[k][308:272],dobs[308:272]);end
 end
 compare_count=compare_count+1;
end endtask
`;
tb=tb.slice(0,from)+compare+tb.slice(to);
tb=tb.replace('for(integer a=0;a<8192;a=a+1)if(core.ram[a]!==golden_ram[a])$fatal(1,"WRAM signature mismatch");',`begin
 integer differences;differences=0;
 for(integer a=0;a<8192;a=a+1)if(core.ram[a]!==golden_ram[a])begin differences=differences+1;if(differences<20)$display("RAM_DIFF iter%0d addr%h R%h D%h",iteration,a,golden_ram[a],core.ram[a]);end
 $display("FINAL iter%0d differences%0d signatureR%h D%h BCR%h D%h",iteration,differences,golden_ram['h110],core.ram['h110],golden_ram['h120],core.ram['h120]);
 if(first_cpu<0||first_bus<0)$fatal(1,"Expected CPU/bus divergence absent");
 if(SIGNATURE!=0&&core.ram['h120]===golden_ram['h120])$fatal(1,"Expected guest BC signature divergence absent");
end`);
tb=tb.replace('REPLAY PASS','REPLAY_OBSERVED').replace('PASS G09 program','PASS G01 CHARACTERIZED program');put('extended_tb.sv',tb);
let run=read(old,'run.do').replaceAll('vlib work','vlib extended_work').replaceAll('-work work','-work extended_work').replace('T80_observed.vhd T80s_observed.vhd','T80_context.vhd T80s_context.vhd').replace('machine.sv fixed_tb.sv','extended_machine.sv extended_tb.sv').replace('work.fixed_tb','extended_work.fixed_tb').replace('-gCAPTURES=$env(G09_CAPTURES)','-gCAPTURES=0 -gSIGNATURE=$env(G01_SIGNATURE)');put('extended.do',run);
let runner=read(old,'run.ps1').replace('[switch]$Compile)','[int]$Signature=0,[switch]$Compile)').replace('"p${Program}_o${Offset}_t${Period}_s${Sys}_c${Captures}"','"extended_p${Program}_o${Offset}_t${Period}_s${Sys}_sig${Signature}"').replace('$run=@()','$env:G01_SIGNATURE="$Signature"\n $run=@()').replace('Get-Content run.do','Get-Content extended.do').replace("'PASS G09'","'PASS G01 CHARACTERIZED'");put('extended.ps1',runner);
console.log('Prepared observation-only CPU context and non-aborting diagnostic continuation; production logic unchanged.');
