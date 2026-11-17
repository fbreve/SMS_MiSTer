// Test-only sufficiency ceiling: preserve every sprite storage element and
// the coupled delayed collision bits in a side record, outside v13. This is
// deliberately not a proposed production representation or a format test.
const fs=require('fs'),p=require('path');const dir=__dirname,root=p.resolve(dir,'../..'),old=p.join(dir,'reproduction'),d=p.join(dir,'prototype');
fs.mkdirSync(d,{recursive:true});const read=f=>fs.readFileSync(p.join(root,f),'utf8').replace(/\r\n/g,'\n'),write=(f,s)=>fs.writeFileSync(p.join(d,f),s);
function replace(s,a,b){if(!s.includes(a))throw Error('missing anchor '+a.slice(0,80));return s.replace(a,b);}
for(const f of ['rom.hex','rom.json','header.svh','T80_sim.vhd','T80s_sim.vhd','savestates_sim.sv','reference.dat'])fs.copyFileSync(p.join(old,f),p.join(d,f));
let s=read('rtl/vdp_sprite_shifter.vhd');
s=replace(s,"ss_regs_set: in std_logic := '0'",`g06_out: out std_logic_vector(32 downto 0);
 g06_in: in std_logic_vector(32 downto 0) := (others=>'0');
 g06_valid: in std_logic := '0';
 ss_regs_set: in std_logic := '0'`);
s=replace(s,'begin\n\n\tprocess',`begin
 g06_out <= '1' & shift3 & shift2 & shift1 & shift0 when wideclock else '0' & shift3 & shift2 & shift1 & shift0;
\n\tprocess`);
s=replace(s,"if ss_regs_set = '1' then",`if ss_regs_set = '1' then
            if g06_valid='1' then
              shift0<=g06_in(7 downto 0);shift1<=g06_in(15 downto 8);
              shift2<=g06_in(23 downto 16);shift3<=g06_in(31 downto 24);
              wideclock<=g06_in(32)='1';
            else`);
s=replace(s,"wideclock <= false;\n\t\t\telsif", "wideclock <= false;\n            end if;\n\t\t\telsif");
write('shifter_proto.vhd',s);
s=read('rtl/vdp_sprites.vhd');
s=replace(s,"ss_regs_set\t\t: in  STD_LOGIC := '0'",`g06_out: out std_logic_vector(74*(MAX_SPPL+1)+43 downto 0);
 g06_in: in std_logic_vector(74*(MAX_SPPL+1)+43 downto 0) := (others=>'0');
 g06_valid: in std_logic := '0';
 ss_regs_set\t\t: in STD_LOGIC := '0'`);
s=replace(s,'begin\n\tshifters:',`begin
 g06_out(74*(MAX_SPPL+1)+2 downto 74*(MAX_SPPL+1))<=state;
 g06_out(74*(MAX_SPPL+1)+9 downto 74*(MAX_SPPL+1)+3)<=conv_std_logic_vector(count,7);
 g06_out(74*(MAX_SPPL+1)+15 downto 74*(MAX_SPPL+1)+10)<=index;
 g06_out(74*(MAX_SPPL+1)+29 downto 74*(MAX_SPPL+1)+16)<=data_address;
 g06_out(74*(MAX_SPPL+1)+37 downto 74*(MAX_SPPL+1)+30)<=m2_flags;
 g06_out(74*(MAX_SPPL+1)+41 downto 74*(MAX_SPPL+1)+38)<=color;
 g06_out(74*(MAX_SPPL+1)+42)<=collide;
 g06_out(74*(MAX_SPPL+1)+43)<=overflow;
\tshifters:`);
s=replace(s,'\t\tshifter: entity work.vpd_sprite_shifter',`        g06_out(74*i)<='1' when enable(i) else '0';
        g06_out(74*i+8 downto 74*i+1)<=spr_x(i);
        g06_out(74*i+40 downto 74*i+9)<=spr_d3(i)&spr_d2(i)&spr_d1(i)&spr_d0(i);
\t\tshifter: entity work.vpd_sprite_shifter`);
s=replace(s,'\t\t\tss_regs_set => ss_regs_set',`            g06_out=>g06_out(74*i+73 downto 74*i+41),
            g06_in=>g06_in(74*i+73 downto 74*i+41),g06_valid=>g06_valid,
\t\t\tss_regs_set => ss_regs_set`);
s=replace(s,"if ss_regs_set = '1' then",`if ss_regs_set = '1' then
              if g06_valid='1' then
                state<=g06_in(74*(MAX_SPPL+1)+2 downto 74*(MAX_SPPL+1));
                count<=conv_integer(g06_in(74*(MAX_SPPL+1)+9 downto 74*(MAX_SPPL+1)+3));
                index<=g06_in(74*(MAX_SPPL+1)+15 downto 74*(MAX_SPPL+1)+10);
                data_address<=g06_in(74*(MAX_SPPL+1)+29 downto 74*(MAX_SPPL+1)+16);
                m2_flags<=g06_in(74*(MAX_SPPL+1)+37 downto 74*(MAX_SPPL+1)+30);
                overflow<=g06_in(74*(MAX_SPPL+1)+43);
                for i in 0 to MAX_SPPL loop
                  enable(i)<=g06_in(74*i)='1';spr_x(i)<=g06_in(74*i+8 downto 74*i+1);
                  spr_d0(i)<=g06_in(74*i+16 downto 74*i+9);spr_d1(i)<=g06_in(74*i+24 downto 74*i+17);
                  spr_d2(i)<=g06_in(74*i+32 downto 74*i+25);spr_d3(i)<=g06_in(74*i+40 downto 74*i+33);
                end loop;
              else`);
s=replace(s,"\t\t\telsif ce_spload='1' then", "              end if;\n\t\t\telsif ce_spload='1' then");
s=replace(s,"if ce_pix='1' then  -- ce_vdp??",`if ss_regs_set='1' and g06_valid='1' then
              color<=g06_in(74*(MAX_SPPL+1)+41 downto 74*(MAX_SPPL+1)+38);
              collide<=g06_in(74*(MAX_SPPL+1)+42);
            elsif ce_pix='1' then  -- ce_vdp??`);
write('sprites_proto.vhd',s);
s=read('rtl/vdp_main.vhd');
s=replace(s,"ss_regs_set:\t\tin  STD_LOGIC := '0'",`g06_out: out std_logic_vector(74*(MAX_SPPL+1)+43 downto 0);
 g06_in: in std_logic_vector(74*(MAX_SPPL+1)+43 downto 0) := (others=>'0');
 g06_valid: in std_logic := '0';
 ss_regs_set:\t\tin STD_LOGIC := '0'`);
s=replace(s,'\t\tss_regs_set\t\t=> ss_regs_set);',`        g06_out=>g06_out,g06_in=>g06_in,g06_valid=>g06_valid,
\t\tss_regs_set\t\t=> ss_regs_set);`);
write('main_proto.vhd',s);
s=fs.readFileSync(p.join(old,'vdp_sim.vhd'),'utf8').replace(/\r\n/g,'\n');
s=replace(s,'probe : out std_logic_vector(31 downto 0);',`probe : out std_logic_vector(31 downto 0);
 g06_out: out std_logic_vector(74*(MAX_SPPL+1)+57 downto 0);
 g06_in: in std_logic_vector(74*(MAX_SPPL+1)+57 downto 0) := (others=>'0');
 g06_valid: in std_logic := '0';g06_freeze:in std_logic := '0';`);
s=replace(s,'begin\n probe <=',`begin
 g06_out(74*(MAX_SPPL+1)+57 downto 74*(MAX_SPPL+1)+44)<=xspr_collide_shift;
 probe <=`);
s=replace(s,'\t\tss_regs_set\t\t    => ss_regs_set,',`        g06_out=>g06_out(74*(MAX_SPPL+1)+43 downto 0),
        g06_in=>g06_in(74*(MAX_SPPL+1)+43 downto 0),g06_valid=>g06_valid,
\t\tss_regs_set\t\t    => ss_regs_set,`);
s=replace(s,"xspr_collide_shift <= (others => '0');",`if g06_valid='1' then xspr_collide_shift<=g06_in(74*(MAX_SPPL+1)+57 downto 74*(MAX_SPPL+1)+44);
                else xspr_collide_shift <= (others => '0');end if;`);
s=replace(s,"if ce_vdp = '0' then", "if ce_vdp = '0' and g06_freeze='0' then");
write('vdp_proto.vhd',s);
s=fs.readFileSync(p.join(old,'header.svh'),'utf8').replace('REFERENCE=0;','REFERENCE=0,PROTO=1;');write('header.svh',s);
s=fs.readFileSync(p.join(old,'vdp_tb.sv'),'utf8').replace(/\r\n/g,'\n');
s=replace(s,'always #5 clk=~clk;',`wire[649:0]g06_live;reg[649:0]g06_snap;
always@(posedge clk)if(dut.state==41&&dut.do_save)g06_snap<=g06_live;
always #5 clk=~clk;`);
s=replace(s,'.probe(probe));','.probe(probe),.g06_out(g06_live),.g06_in(g06_snap),.g06_valid(PROTO!=0),.g06_freeze(frozen&&PROTO!=0));');
s=replace(s,'   if(SPRITES>2)begin\n    // Separate',`   if(PROTO)begin
    if(vdp_regs!==trace[j]||color!==pixels[j])$fatal(1,"prototype SAVE-only VDP mismatch x%0d y%0d",x,y);
    if(SPRITES>2&&(z80_reg[7:0]!==racc[j]||ram[256]!==rmem[j]))$fatal(1,"prototype SAVE-only CPU/RAM mismatch");
   end else begin
   if(SPRITES>2)begin
    // Separate`);
s=replace(s,'  savechecks++;','   end\n  savechecks++;');
s=replace(s,' if(SPRITES>2)begin\n  if(saveflags',` if(SPRITES>2&&PROTO)begin $display("PASS PROTOTYPE SAVE_ONLY observations%0d",savechecks);$finish;end
 if(SPRITES>2)begin
  if(saveflags`);
write('vdp_tb.sv',s);
write('compile.do',`onerror {quit -code 1}
onbreak {quit -code 1}
vlib vdp_work
vcom -work vdp_work -2008 -quiet ../../../rtl/video.vhd ../../../rtl/T80/T80_Reg.vhd ../../../rtl/T80/T80_MCode.vhd ../../../rtl/T80/T80_ALU.vhd T80_sim.vhd T80s_sim.vhd ../../../rtl/dpram.vhd ../../../rtl/vdp_cram.vhd ../../../rtl/vdp_background.vhd shifter_proto.vhd sprites_proto.vhd main_proto.vhd vdp_proto.vhd
vlog -work vdp_work -sv -quiet savestates_sim.sv vdp_tb.sv
quit -code 0
`);
s=fs.readFileSync(p.join(old,'run.do'),'utf8').replace('-gREPLAYS=$env(VDP_REPLAYS)','-gREPLAYS=$env(VDP_REPLAYS) -gPROTO=$env(VDP_PROTO)');write('run.do',s);
fs.mkdirSync(p.join(d,'overflow9'),{recursive:true});for(const f of ['rom.hex','reference.dat'])fs.copyFileSync(p.join(old,'overflow9',f),p.join(d,'overflow9',f));write('overflow9/run.do',s);
s=fs.readFileSync(p.join(old,'run.ps1'),'utf8').replace('[int]$Reference=0,','[int]$Reference=0,[int]$Proto=1,').replace('$env:VDP_REPLAYS=3;', '$env:VDP_REPLAYS=1;$env:VDP_PROTO=$Proto;');write('run.ps1',s);
