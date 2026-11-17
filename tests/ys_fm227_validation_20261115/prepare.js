const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert');
const root=p.resolve(__dirname,'../..'),d=__dirname,old=p.join(root,'tests/ys_load_differential_audit/continuation_v4/candidate_v2');
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,maxBuffer:100*1024*1024}),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const base='8cd53ccc954c24970372ea6d8a3fb2336a14c46f',head=git('rev-parse','HEAD').toString().trim();assert.equal(head,'69edeb48455820d3119ab54d052bf3de906c91fa');
const protectedFiles={};for(const f of git('ls-files','-z').toString().split('\0').filter(Boolean))if(fs.existsSync(p.join(root,f))&&fs.statSync(p.join(root,f)).isFile())protectedFiles[f]=sha(fs.readFileSync(p.join(root,f)));
for(const f of ['tests/pr227_matched_20261114/REPORT.md','tests/pr227_matched_20261114/PR227_SUMMARY.md','tests/ys_load_differential_audit/continuation_v4/CONTINUATION_REPORT.md',...fs.readdirSync(root).filter(f=>f.endsWith('.rbf'))])protectedFiles[f]=sha(fs.readFileSync(p.join(root,f)));
fs.writeFileSync(p.join(d,'preservation_before.json'),JSON.stringify({head,base,branch:git('branch','--show-current').toString().trim(),protectedFiles},null,2),{flag:'wx'});
function write(f,s){fs.writeFileSync(p.join(d,f),s,{flag:'wx'});}
const inputs={};for(const f of fs.readdirSync(old).filter(f=>/\.(vhd|svh)$/.test(f)||['ys_environment_load_tb.sv','seed_slot.hex','seed_sram.hex','seed_saved.mem','seed_boot150.mem','seed_boot150.ppm','seed_cold_reference.log','seed_manifest.json','analyze_map_runs.js','analyze_first_map_column.js','ppm_to_png.js'].includes(f))){const b=fs.readFileSync(p.join(old,f));write(f,b);inputs[f]=sha(b);}
const seedMetaDir=p.join(d,'seed_metadata');fs.mkdirSync(seedMetaDir);fs.copyFileSync(p.join(old,'../rom_owner_results.json'),p.join(d,'rom_owner_results.json'));
let prior=fs.readFileSync(p.join(old,'savestates_probe.sv'),'utf8');const header=prior.slice(prior.indexOf('module savestates'),prior.indexOf('\n);')+3);
const ports=[...header.replace(/\/\/[^\n]*/g,'').matchAll(/\b(?:input|output)(?:\s+(?:reg|wire))?(?:\s*\[[^\]]+\])?\s+(\w+)/g)].map(m=>m[1]);
const dummy=['full_sram_allowed','restart_out','restart_dir','restart_valid'];
const aliases={state:7,do_save:1,op_cooldown:28,is_old_format:1,cpu_idx:2,dout_latch:64};
let wrapper=header+'\nassign restart_dir=0;assign restart_valid=0;wire [2:0] restart_snap=0;wire metadata_invalid=0;\n';
for(const [n,w]of Object.entries(aliases))wrapper+=`wire [${w-1}:0] ${n};\n`;
wrapper+=`wire[7:0] fm_addr;wire fm_rd,fm_wr,fm_reset,fm_init;wire[31:0] fm_wdata;reg[31:0] fm_q=0;reg[31:0] fm_words[0:99];
initial for(integer i=0;i<100;i++)fm_words[i]=0;
always @(posedge clk)begin if(fm_rd)fm_q<=fm_words[fm_addr];if(fm_wr)fm_words[fm_addr]<=fm_wdata;if(fm_reset)for(integer i=0;i<100;i++)fm_words[i]<=0;end
generate if((CANDIDATE&2)==0)begin:B\n`;
const fm='.fm_state_addr(fm_addr),.fm_state_read(fm_rd),.fm_state_write(fm_wr),.fm_state_wdata(fm_wdata),.fm_state_rdata(fm_q),.fm_initialized(1\'b1),.fm_legacy_reset(fm_reset),.fm_initialization_run(fm_init)';
for(const [label,module]of [['B','baseline_controller'],['F','candidate_controller']]){
 if(label==='F')wrapper+='end else begin:F\n';
 wrapper+=module+' dut('+ports.filter(n=>!dummy.includes(n)).map(n=>`.${n}(${n})`).join(',')+','+fm+(label==='F'?",.sc3000_mode(!full_sram_allowed),.eeprom_present(1'b0)":'')+');\n';
 for(const n of Object.keys(aliases))wrapper+=`assign ${n}=dut.${n};\n`;
}
wrapper+='end endgenerate\nendmodule\n';write('controller_adapter.sv',wrapper);
function adapt(s,module){s=s.replace('module savestates (','module '+module+' (');for(const n of ['mapper_snap','evolution_snap','dout_latch']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';\\r?\\n','m'),m=s.match(re);assert(m,n);s=s.replace(re,'').replace('// Helpers',m[0]+'// Helpers');}return s;}
write('baseline_controller.sv',adapt(git('show',base+':rtl/savestates.sv').toString(),'baseline_controller'));
write('candidate_controller.sv',adapt(fs.readFileSync(p.join(root,'rtl/savestates.sv'),'utf8'),'candidate_controller'));
write('opll_snapshot.sv',fs.readFileSync(p.join(root,'rtl/opll_snapshot.sv')));
let tb=fs.readFileSync(p.join(d,'ys_environment_load_tb.sv'),'utf8').replace('metadata=%h",vd,wd,sd,dma_sram_bytes,save_sram_words,load_sram_words,ddr[5]','metadata=%h",vd,wd,sd,dma_sram_bytes,save_sram_words,load_sram_words,ddr[\'h1a]');
fs.writeFileSync(p.join(d,'ys_environment_load_tb.sv'),tb);
write('compile.do',`onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib work\nvcom -2008 -quiet T80_Reg.vhd T80_MCode.vhd T80_ALU.vhd T80_context.vhd T80s_context.vhd dpram.vhd video.vhd vdp_cram.vhd vdp_background.vhd vdp_sprite_shifter.vhd vdp_sprites.vhd vdp_main.vhd vdp_probe.vhd mapper_ctrl.vhd io.vhd\nvlog -sv -quiet opll_snapshot.sv baseline_controller.sv candidate_controller.sv controller_adapter.sv ys_environment_load_tb.sv\nquit -code 0\n`);
write('environment_case.do',fs.readFileSync(p.join(old,'environment_case.do')));
write('source_identity.json',JSON.stringify({base,head,productionSHA256:sha(fs.readFileSync(p.join(root,'rtl/savestates.sv'))),inputs,adapters:['module renaming and forward-declaration relocation only','wrapper selects exact baseline or candidate and supplies zero-initialized synchronous 100-word FM interface model; real opll_snapshot retained','CPU predecessor interface tied inactive; no restart mechanism added','reused actual CPU/VDP/mapper/controller Ys fixture']},null,2));
console.log('Prepared isolated exact-production controller pair and playable fixture.');
