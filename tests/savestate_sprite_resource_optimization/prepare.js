const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname,root=p.resolve(d,'../..');
const git=(...a)=>cp.execFileSync('git',a,{cwd:root,maxBuffer:32*1024*1024}),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
assert.equal(git('rev-parse','HEAD').toString().trim(),'cb2e8615128d61adb996ada68e6bbdcc314c20f6');assert.equal(git('diff').length,0);
const baseline=git('show','HEAD:rtl/savestates.sv').toString().replace(/\r\n/g,'\n');
fs.writeFileSync(p.join(d,'baseline.sv'),baseline);
let s=baseline;
function replace(a,b,count=1){assert.equal(s.split(a).length-1,count,a);s=s.split(a).join(b);}
replace('sprite_snap <= 0; sprite2_snap <= 0;','',2);
replace("            sprite_snap <= {22'd0,sprite_out};\n            sprite2_snap <= systeme ? {22'd0,sprite2_out} : 4800'd0;",'');
replace('            if (sprite_second) sprite2_snap <= {sprite2_snap[63:0],sprite2_snap[4799:64]};\n            else sprite_snap <= {sprite_snap[63:0],sprite_snap[4799:64]};','');
replace('                        if (sprite_second) sprite2_snap <= {dout_latch,sprite2_snap[4799:64]};\n                        else sprite_snap <= {dout_latch,sprite_snap[4799:64]};','');
const controls=`// Snapshot-bank updates are decoded once, outside the transport FSM.
// These are the original accepted-edge predicates, including rejected LOADs.
wire sprite_capture = ddram_step && state == ST_ARM_FREEZE;
wire sprite_clear = ddram_step && state == ST_LOAD_HDR_RD && !DDRAM_BUSY;
wire sprite_save_shift = ddram_step && state == ST_SAVE_SPRITE && !DDRAM_BUSY;
wire sprite_load_shift = ddram_step && state == ST_LOAD_SPRITE &&
                         !(DDRAM_DOUT_READY && dout_expected) &&
                         !dout_expected && !DDRAM_BUSY &&
                         !(sprite_word == 74 && dout_latch[63:42] != 0) &&
                         !(sprite_second && !systeme && dout_latch != 0);
wire sprite_shift = sprite_save_shift || sprite_load_shift;
wire [63:0] sprite_head = sprite_load_shift ? dout_latch : sprite_write_word;
`;
const processA=`always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin sprite_snap <= 0; sprite2_snap <= 0; end
    else begin
        if (sprite_clear) begin sprite_snap <= 0; sprite2_snap <= 0; end
        else if (sprite_capture) begin
            sprite_snap <= {22'd0, sprite_out};
            sprite2_snap <= systeme ? {22'd0, sprite2_out} : 4800'd0;
        end else if (sprite_shift) begin
            if (sprite_second) sprite2_snap <= {sprite_head, sprite2_snap[4799:64]};
            else sprite_snap <= {sprite_head, sprite_snap[4799:64]};
        end
    end
end
`;
const processB=`wire sprite_shift1 = sprite_shift && !sprite_second;
wire sprite_shift2 = sprite_shift && sprite_second;
wire [4799:0] sprite_capture1 = {22'd0, sprite_out};
wire [4799:0] sprite_capture2 = {22'd0, sprite2_out};
// Mutually exclusive capture/clear/shift events permit one shared enable
// and a parallel data selection, rather than an FSM-wide priority mux.
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin sprite_snap <= 0; sprite2_snap <= 0; end
    else begin
        if (sprite_clear || sprite_capture || sprite_shift1)
            sprite_snap <= ({4800{sprite_capture}} & sprite_capture1) |
                           ({4800{sprite_shift1}} & {sprite_head, sprite_snap[4799:64]});
        if (sprite_clear || sprite_capture || sprite_shift2)
            sprite2_snap <= ({4800{sprite_capture && systeme}} & sprite_capture2) |
                            ({4800{sprite_shift2}} & {sprite_head, sprite2_snap[4799:64]});
    end
end
`;
for(const[name,proc]of [['A',processA],['B',processB]])fs.writeFileSync(p.join(d,'candidate_'+name+'.sv'),s.replace('\nendmodule','\n'+controls+proc+'\nendmodule'));
const files={};for(const f of git('ls-files').toString().trim().split(/\r?\n/)){const file=p.join(root,f);if(fs.statSync(file).isFile())files[f]=sha(fs.readFileSync(file));}
const reports=['savestate_resource_growth','savestate_g06_g10_fix','savestate_g02_g05_v14','savestate_g05_background_fix','savestate_g08_release_fix','savestate_g12_sdram_fix'];
fs.writeFileSync(p.join(d,'baseline.json'),JSON.stringify({head:git('rev-parse','HEAD').toString().trim(),files,reports:Object.fromEntries(reports.map(r=>[r,sha(fs.readFileSync(p.join(root,'tests',r,'review.md')))]))},null,2));
fs.writeFileSync(p.join(d,'g06_g10.diff'),git('diff','8ffd15e','5858318'));
const settings=fs.readFileSync(p.join(root,'SMS.qsf'),'utf8').split(/\r?\n/).filter(l=>l.startsWith('set_global_assignment')&&!/TOP_LEVEL_ENTITY|PRE_FLOW_SCRIPT|POST_FLOW_SCRIPT|QIP_FILE|SDC_FILE/.test(l)).join('\n');
for(const[name,source]of [['baseline',baseline],['A',fs.readFileSync(p.join(d,'candidate_A.sv'))],['B',fs.readFileSync(p.join(d,'candidate_B.sv'))]]){const dst=p.join(d,'micro_'+name);fs.mkdirSync(dst,{recursive:true});fs.writeFileSync(p.join(dst,'savestates.sv'),source);fs.writeFileSync(p.join(dst,'micro.qpf'),'PROJECT_REVISION = "micro"\n');fs.writeFileSync(p.join(dst,'micro.qsf'),settings+'\nset_global_assignment -name FAMILY "Cyclone V"\nset_global_assignment -name DEVICE 5CSEBA6U23I7\nset_global_assignment -name TOP_LEVEL_ENTITY savestates\nset_global_assignment -name SYSTEMVERILOG_FILE savestates.sv\nset_instance_assignment -name VIRTUAL_PIN ON -to *\n');}
fs.writeFileSync(p.join(d,'.gitignore'),'micro_*/\nquartus_*/\n**/*_work/\n**/transcript\n**/vsim.wlf\n**/modelsim.ini\n');
console.log('Prepared baseline and two isolated structural candidates; production unchanged.');
