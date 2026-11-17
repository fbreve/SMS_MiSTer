// Isolated transport candidate. No production source is written.
const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto');
const d=__dirname,out=p.join(d,process.argv[2]||'candidate');fs.mkdirSync(out,{recursive:false});
for(const f of fs.readdirSync(d).filter(f=>/\.(vhd|svh)$/.test(f)))fs.copyFileSync(p.join(d,f),p.join(out,f));
let s=fs.readFileSync(p.join(d,'savestates_probe.sv'),'utf8');
s=s.replace('reg        do_save;',''); // ModelSim requires declaration before the helper wire.
function change(a,b){assert(s.includes(a),'missing source anchor '+a.slice(0,80));s=s.replace(a,b);}
change('input [2:0] restart_out,','input full_sram_allowed, // fixture eligibility: excludes SC, EEPROM and nonordinary configurations\n input [2:0] restart_out,');
change('reg [2:0] restart_snap=0; reg restart_present=0;',`reg do_save;
localparam CPU_FEATURE=(CANDIDATE & 1)!=0, SRAM_FEATURE=(CANDIDATE & 2)!=0;
reg [2:0] restart_snap=0; reg restart_present=0;
reg full_sram_snap=0,has_full_sram=0;
// Test schema YS1: full43, context42, class41:39, reserved38. Always-written word.
wire metadata_present=dout_latch[63:38]!=0;
wire metadata_invalid=metadata_present && (
 dout_latch[63:48]!=16'h5953 || dout_latch[47:44]!=4'd1 || dout_latch[38]!=0 ||
 dout_latch[41:39]>5 || (!dout_latch[42] && dout_latch[41:39]!=0) ||
 (dout_latch[42] && !CPU_FEATURE) ||
 (dout_latch[43] && (!SRAM_FEATURE || !full_sram_allowed || systeme)));
wire transfer_full_sram=!systeme && full_sram_allowed &&
                         (do_save ? full_sram_snap : has_full_sram);
wire [25:0] committed_extension=(CPU_FEATURE||full_sram_snap)?
 {16'h5953,4'd1,full_sram_snap,CPU_FEATURE,CPU_FEATURE?restart_snap:3'd0,1'b0}:26'd0;`);
change('assign restart_valid=CANDIDATE && restart_present;','assign restart_valid=CPU_FEATURE && restart_present;');
change("wire [25:0] cpu_extension=CANDIDATE?{16'h4352,4'd1,restart_snap,3'd0}:26'd0;",`wire [25:0] cpu_extension=(CPU_FEATURE||full_sram_snap)?
 {16'h5953,4'd1,1'b0,CPU_FEATURE,CPU_FEATURE?restart_snap:3'd0,1'b0}:26'd0;`);
change("wire context_invalid=(dout_latch[63:38]!=0) && (dout_latch[63:48]!=16'h4352 || dout_latch[47:44]!=4'd1 || dout_latch[43:41]>5 || dout_latch[40:38]!=0);",'');
change('wire has_nvram     = has_nvram_8k | has_nvram_16k | has_nvram_32k;','wire has_nvram = has_nvram_8k | has_nvram_16k | has_nvram_32k | transfer_full_sram;');
change("wire [14:0] nvram_size_minus_1 = has_nvram_32k ? 15'd32767 :","wire [14:0] nvram_size_minus_1 = (transfer_full_sram || has_nvram_32k) ? 15'd32767 :");
change('reg [6:0]  state;',"localparam ST_SAVE_SRAM_COMMIT=7'd73,ST_SAVE_SRAM_DRAIN=7'd74;\nreg [6:0]  state;");
change('ST_SAVE_HDR: if (! DDRAM_BUSY)',`ST_SAVE_SRAM_COMMIT: if(!DDRAM_BUSY) ddram_cmd_write(base_addr+29'd5,{committed_extension,z80_snap[229:192]},8'hff);
        ST_SAVE_HDR: if (! DDRAM_BUSY)`);
change('restart_snap<=0;restart_present<=0;','restart_snap<=0;restart_present<=0;full_sram_snap<=0;has_full_sram<=0;');
change('restart_snap<=restart_out;','restart_snap<=restart_out;\n                full_sram_snap<=SRAM_FEATURE && full_sram_allowed && !systeme;\n                has_full_sram<=0;');
change('if(CANDIDATE && cpu_idx==3 && !is_old_format && context_invalid)',
       'if((CPU_FEATURE||SRAM_FEATURE) && cpu_idx==3 && !is_old_format && metadata_invalid)');
change('restart_present<=CANDIDATE && !is_old_format && dout_latch[63:38]!=0;',
       'restart_present<=CPU_FEATURE && !is_old_format && metadata_present && dout_latch[42];\n                        has_full_sram<=SRAM_FEATURE && !is_old_format && metadata_present && dout_latch[43];');
change("restart_snap<=(!is_old_format && dout_latch[63:38]!=0)?dout_latch[43:41]:3'd0;",
       "restart_snap<=(!is_old_format && metadata_present && dout_latch[42])?dout_latch[41:39]:3'd0;");
change('state <= ST_SAVE_DONE; // framework change detector remains last',
       'state <= full_sram_snap?ST_SAVE_SRAM_COMMIT:ST_SAVE_DONE; // framework change detector remains last');
change('        ST_SAVE_DONE: begin\n            // Write MiSTer framework control word',`        ST_SAVE_SRAM_COMMIT: begin
            if(!DDRAM_BUSY)begin
                ddram_write(base_addr+29'd5,{committed_extension,z80_snap[229:192]},8'hff);
                freeze_drain_cnt<=0;state<=ST_SAVE_SRAM_DRAIN;
            end
        end
        ST_SAVE_SRAM_DRAIN: begin
            if(DDRAM_BUSY)freeze_drain_cnt<=0;
            else if(freeze_drain_cnt==31)state<=ST_SAVE_DONE;
            else freeze_drain_cnt<=freeze_drain_cnt+6'd1;
        end
        ST_SAVE_DONE: begin
            // Write MiSTer framework control word`);
fs.writeFileSync(p.join(out,'savestates_probe.sv'),s);
let inc=fs.readFileSync(p.join(out,'controller.svh'),'utf8');
inc=inc.replace('controller(', 'controller(.full_sram_allowed(full_sram_allowed),');
assert(inc.includes('.full_sram_allowed(full_sram_allowed)'));fs.writeFileSync(p.join(out,'controller.svh'),inc);
fs.writeFileSync(p.join(out,'implementation_metadata.json'),JSON.stringify({sourceMaster:'66f16d5c656fd8906d62570da4d258875bcee684',basedOnV3ProbeSHA256:crypto.createHash('sha256').update(fs.readFileSync(p.join(d,'savestates_probe.sv'))).digest('hex'),variants:{A:0,B:2,C:1,D:3},features:'Full32K SRAM only and/or predecessor only; no NMI, phase, background or FM changes',eligibility:'Test fixture must deassert full_sram_allowed for SC, EEPROM and nonordinary configurations. Internal SystemE exclusion remains mandatory.',status:'TRANSPORT CANDIDATE ONLY; graphics scene qualification remains pending'},null,2)+'\n');
console.log('Prepared isolated YS1 candidate; not a graphical-causality result.');
