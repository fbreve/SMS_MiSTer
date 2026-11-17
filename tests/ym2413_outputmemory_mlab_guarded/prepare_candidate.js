const fs=require('fs'),p=require('path'),cp=require('child_process'),assert=require('assert'),d=__dirname,w=p.join(d,'worktree'),base='9873761503510e4b2c7e06600bf5515344235c2f';
const git=(...a)=>cp.execFileSync('git',['--no-optional-locks',...a],{cwd:w,encoding:'latin1'});
assert.equal(git('rev-parse','HEAD').trim(),base);assert.equal(git('branch','--show-current').trim(),'experiment/ym2413-outputmemory-mlab-guarded');assert.equal(git('status','--porcelain'),'');
const mem=p.join(w,'rtl/VM2413/outputmemory.vhd');let s=fs.readFileSync(mem,'latin1');assert(s.includes('attribute ramstyle of data_array : signal is "logic";'));fs.writeFileSync(mem,s.replace('attribute ramstyle of data_array : signal is "logic";','attribute ramstyle of data_array : signal is "MLAB";'),'latin1');
const f=p.join(w,'rtl/savestates.sv');s=fs.readFileSync(f,'latin1');const nl=s.includes('\r\n')?'\r\n':'\n';
function replace(a,b){assert(s.includes(a),a);s=s.replace(a,b);}
replace('reg [6:0] fm_word;','reg [6:0] fm_word;'+nl+'// Word 100 may retain an output write only at the restored global stage 0.'+nl+'reg fm_saved_stage_zero;');
replace('        audio_word <= 0;','        audio_word <= 0;'+nl+"        fm_saved_stage_zero <= 0;");
replace('else begin fm_word<=0;ddram_read(base_addr+FM_DATA_ADDR);state<=ST_FM_LOAD;end','else begin fm_saved_stage_zero<=0;fm_word<=0;ddram_read(base_addr+FM_DATA_ADDR);state<=ST_FM_LOAD;end');
replace("                else begin fm_bulk_write<=1;state<=ST_FM_LOAD_STORE;end",`                else if(fm_word==50 && dout_latch[1] && !fm_saved_stage_zero)state<=ST_ERROR;
                else begin
                    if(fm_word==39)fm_saved_stage_zero<=dout_latch[1:0]==2'b00;
                    fm_bulk_write<=1;state<=ST_FM_LOAD_STORE;
                end`.replace(/\n/g,nl));
fs.writeFileSync(f,s,'latin1');fs.writeFileSync(p.join(d,'production.diff'),git('diff',base,'--','rtl/','SMS.sv','files.qip','sys/'),'latin1');
console.log(git('diff','--stat'));console.log('PASS only OutputMemory MLAB and pre-apply cross-word validation');
