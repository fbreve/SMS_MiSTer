const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../../..'),old=p.join(d,'../continuation_v2'),ref='66f16d5c656fd8906d62570da4d258875bcee684';
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,encoding:'utf8',maxBuffer:8e6});
const get=f=>git('show',ref+':'+f).replace(/\r\n/g,'\n'),put=(f,s)=>fs.writeFileSync(p.join(d,f),s),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const manifest={master:ref,checkout:git('rev-parse','HEAD').trim(),trackedStatus:git('status','--porcelain','--untracked-files=no').trim(),protected:{},sources:{},candidate:'Only six-class predecessor capture/serialize/restore; no NMI/phase/background changes.'};
for(const f of ['../REPORT.md','../continuation_v2/CONTINUATION_REPORT.md','../continuation_v2/final_results.json'])manifest.protected[f]=sha(fs.readFileSync(p.resolve(d,f)));
for(const f of ['T80_Reg.vhd','T80_MCode.vhd','T80_ALU.vhd','T80_context.vhd','T80s_context.vhd']){let s=fs.readFileSync(p.join(old,f),'utf8');if(f==='T80_Reg.vhd')s=s.replace(/(signal Regs[HL] : Register_Image\(0 to 7\));/g,"$1 := (others=>(others=>'0'));");put(f,s);}
for(const f of ['video.vhd','vdp_cram.vhd','vdp_background.vhd','vdp_sprite_shifter.vhd','vdp_sprites.vhd','vdp_main.vhd','mapper_ctrl.vhd','io.vhd','memory_decode.vhd','memory_bus.vhd']){let s=get('rtl/'+f);manifest.sources['rtl/'+f]=sha(s);if(f==='mapper_ctrl.vhd')s=s.replace(/case A\(1 downto 0\) is([\s\S]*?)end case;/g,(all,body)=>body.includes('when others')?all:'case A(1 downto 0) is'+body+'when others => null;\nend case;');put(f,s);}
let vdp=get('rtl/vdp.vhd');
vdp=vdp.replace('ss_regs_out    : out',`TestWE : out std_logic; TestWA : out std_logic_vector(14 downto 0); TestWD : out std_logic_vector(7 downto 0);
 ss_regs_out    : out`).replace('mask_column <= mask_column0;',`TestWE<=vram_portA_wren;TestWA<=vram_portA_address;TestWD<=vram_portA_data;
 mask_column <= mask_column0;`);put('vdp.vhd',vdp);
let s=get('rtl/savestates.sv');manifest.sources['rtl/savestates.sv']=sha(s);
s=s.replace('module savestates (',`module savestates #(parameter CANDIDATE=0) (
 input [2:0] restart_out, output [2:0] restart_dir, output restart_valid,`);
// Move declarations only: ModelSim rejects some forward references accepted by Quartus.
for(const name of ['mapper_snap','evolution_snap','dout_latch']){const re=new RegExp('reg\\s+\\[[^\\]]+\\]\\s*'+name+';');const m=s.match(re);assert(m,name);s=s.replace(m[0],'');s=s.replace('// Helpers',m[0]+'\n// Helpers');}
s=s.replace('// Helpers',`reg [2:0] restart_snap=0; reg restart_present=0;
 assign restart_dir=restart_snap;assign restart_valid=CANDIDATE && restart_present;
 wire [25:0] cpu_extension=CANDIDATE?{16'h4352,4'd1,restart_snap,3'd0}:26'd0;
 wire context_invalid=(dout_latch[63:38]!=0) && (dout_latch[63:48]!=16'h4352 || dout_latch[47:44]!=4'd1 || dout_latch[43:41]>5 || dout_latch[40:38]!=0);
// Helpers`);
s=s.replace(/\{\s*26'd0\s*,\s*z80_snap\s*\[\s*229\s*:\s*192\s*\]\s*\}/g,'{cpu_extension,z80_snap[229:192]}');
assert.equal((s.match(/\{cpu_extension,z80_snap\[229:192\]\}/g)||[]).length,2,'both DDR writer paths');
s=s.replace('z80_snap    <= z80_reg;','z80_snap    <= z80_reg;\n                restart_snap<=restart_out;');
s=s.replace('state           <= ST_IDLE;','state           <= ST_IDLE;\n        restart_snap<=0;restart_present<=0;');
const start=s.indexOf('        ST_LOAD_CPU0: begin',s.indexOf('always @(posedge')),end=s.indexOf('        ST_LOAD_VDP0: begin',start);assert(start>0&&end>start);
let block=s.slice(start,end);block=block.replace('                case (cpu_idx)',`                if(CANDIDATE && cpu_idx==3 && !is_old_format && context_invalid) state<=ST_ERROR;
                else begin
                case (cpu_idx)`);
block=block.replace("                    3'd3: begin",`                    3'd3: begin
                        restart_present<=CANDIDATE && !is_old_format && dout_latch[63:38]!=0;
                        restart_snap<=(!is_old_format && dout_latch[63:38]!=0)?dout_latch[43:41]:3'd0;`);
block=block.replace('                    cpu_idx <= cpu_idx + 3\'d1;','                    cpu_idx <= cpu_idx + 3\'d1;\n                end');s=s.slice(0,start)+block+s.slice(end);put('savestates_probe.sv',s);
// Auto-wire otherwise inactive controller/peripheral ports, retaining every real controller state.
const hdr=s.slice(s.indexOf('input [2:0]'),s.indexOf('\n);'));
const ports=[...hdr.replace(/\/\/[^\n]*/g,'').matchAll(/\b(input|output)(?:\s+reg)?\s*(\[[^\]]+\])?\s*(\w+)/g)].map(m=>({dir:m[1],width:m[2]||'',name:m[3]}));
const inputs={clk:'clk',reset_n:'reset_n',ss_save:'save_req',ss_load:'load_req',ss_slot:"2'd0",ss_bios_mode:"1'b0",ss_game_id:"32'hf1e2d3c4",vblank:'vb',x:'x',z80_reg:'cpu_regs',z80_m1_n:'m1_n',z80_mreq_n:'mreq_n',z80_iset:'iset',cpu_ce:'ce_cpu',vdp_ce:'ce_vdp',pix_ce:'ce_pix',sp_ce:'ce_sp',vdp_regs:'vdp_regs',cram_out:'cram',vram_D:'vram_dma_d',mapper_out:'mapper_word',io_out:'io_word',video_state_out:'video_word',wram_D:'wram_q',nvram_D:'sram_q',audio_quiescent:"1'b1",restart_out:'restart_ctx'};
Object.assign(inputs,{DDRAM_BUSY:"1'b0",DDRAM_DOUT:'ddr_out',DDRAM_DOUT_READY:'ddr_ready'});
put('controller.svh',ports.map(q=>`wire ${q.width} ss_${q.name};`).join('\n')+'\n'+ports.filter(q=>q.dir==='input').map(q=>`assign ss_${q.name}=${inputs[q.name]||"'0"};`).join('\n')+'\nsavestates #(.CANDIDATE(CANDIDATE)) controller(\n'+ports.map(q=>`.${q.name}(ss_${q.name})`).join(',\n')+'\n);\n');
function vhdlInstance(file,entity,instance,map){const h=get('rtl/'+file).split(/end (?:entity|io|mapper_ctrl|memory_decode|memory_bus)/i)[0];const ports=[...h.matchAll(/\b(\w+)\s*:\s*(in|out|buffer)\s+STD_LOGIC(?:_VECTOR\s*\(([^)]+)\))?/gi)];return entity+' '+instance+'('+ports.map(m=>{let v=map[m[1]];if(v===undefined){const range=m[3]?.match(/(\d+)\s+downto\s+(\d+)/i);v=m[2].toLowerCase()==='out'?'':range?`${+range[1]-range[2]+1}'d0`:"1'b0";}return`.${m[1]}(${v})`;}).join(',\n')+');\n';}
const map={RESET_n:'reset_n',clk_sys:'clk',mapper_set:'ss_mapper_set',mapper_in:'ss_mapper_in',bootloader_n:"1'b1",rom_size_pages:"8'd32",ce_z80:'cpu_ce_live',WR_n:'wr_n',MREQ_n:'mreq_n',A:'addr',ss_freeze:'ss_ss_freeze',D_in:'cpu_do',sega_mapper_write_seen:"1'b1",bank0_out:'bank0',bank1_out:'bank1',bank2_out:'bank2',bank3_out:'bank3',nvram_e_out:'nv_e',nvram_ex_out:'nv_ex',nvram_p_out:'nv_p',nvram_cme_out:'nv_cme',lock_mapper_B_out:'map_lock',mapper_codies_out:'map_codies',mapper_codies_lock_out:'map_codies_lock',mapper_4pak_out:'map_4pak',pak4_reg2_out:'pak4reg',nem_bank0_out:'nembank'};
put('mapper.svh',vhdlInstance('mapper_ctrl.vhd','mapper_ctrl','mapper',map));
const io={clk:'clk',ce_cpu:'cpu_ce_live',WR_n:"(io_cycle && addr[7:6]==0)?wr_n:1'b1",RD_n:"(io_cycle && addr[7:6]==3)?rd_n:1'b1",A:'addr[7:0]',D_in:'cpu_do',D_out:'io_do',HL_out:'hl',RESET_n:'reset_n',io_state_out:'io_word',io_state_in:'ss_io_in',io_state_set:'ss_io_set',ss_freeze:'ss_ss_freeze',region:"1'b1",Pause:"1'b1",J1_up:'joy_n[0]',J1_down:'joy_n[1]',J1_left:'joy_n[2]',J1_right:'joy_n[3]',J1_tl:'joy_n[4]',J1_tr:'joy_n[5]',J1_th:"1'b1",gg_link_in:"7'h7f",E0:"8'hff",F2:"8'hff",F3:"8'hff",sk1100_row_data:"12'hfff"};
for(const port of ['j1_start','j1_coin','j1_a3','J2_up','J2_down','J2_left','J2_right','J2_tl','J2_tr','J2_th','j2_start','j2_coin','j2_a3'])io[port]="1'b1";
put('io.svh',vhdlInstance('io.vhd','io','io_unit',io));
put('manifest.json',JSON.stringify(manifest,null,2)+'\n');console.log('Prepared pinned-master controller, CPU, VDP, mapper and IO in isolated v3.');
