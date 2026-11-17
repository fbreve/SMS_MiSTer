const fs=require('fs'),p=require('path'),d=__dirname,src=p.resolve(d,'../savestate_g12_sdram_fix/final_protocol'),dst=p.join(d,'pause');
fs.mkdirSync(dst,{recursive:true});
for(const f of fs.readdirSync(p.join(d,'matrix'))){if(/\.(v|sv|vhd|hex|svh|do)$/.test(f))fs.copyFileSync(p.join(d,'matrix',f),p.join(dst,f));}
for(const f of ['crypto_functions.svh','decrypt_path.sv'])fs.copyFileSync(p.join(d,f),p.join(dst,f));
let s=fs.readFileSync(p.join(src,'audio_tb.sv'),'utf8');
s=s.replace('parameter SAVED_PAUSED=','parameter MODE=2,PROGRAM=1,SAVED_PAUSED=');
s=s.replace('repeat(BOOT)tick','repeat(BOOT+8200)tick').replace('cycle>BOOT+5000','cycle>BOOT+13200');
s=s.replaceAll('pin_model #(.TAC(TAC)','pin_model #(.MODE(MODE),.PROGRAM(PROGRAM),.TAC(TAC)');
s=s.replace('.irom_D_out(sd)','.irom_D_out(decoded)').replace('.irom_D_out(rsd)','.irom_D_out(rchip.plain_byte(ra,rphys,!rm1))').replace('.irom_D_out(rchip.byte_at(rphys))','.irom_D_out(rchip.plain_byte(ra,rphys,!rm1))');
s=s.replace('tri[15:0]dq,rdq;',`wire[7:0]decoded;wire decrypt_loaded;
decrypt_path #(.MODE(MODE)) crypt(clk,ca,!cm1,sd,decoded,decrypt_loaded);
tri[15:0]dq,rdq;`);
s=s.replace('repeat(1000)tick;','repeat(N)tick;');
s=s.replace('integer wrong_fetches=', 'initial begin #1;if(cpu.u0.Mode!=0||rcpu.u0.Mode!=0)$fatal(1,"G11 requires production Z80 CPU mode");end\ninteger wrong_fetches=');
s=s.replace('$isunknown({z80_reg,rr})||z80_reg!==rr','z80_reg!==rr');
s=s.replace('$writememh("image.hex",mem);','for(integer image_index=0;image_index<12288;image_index++)if($isunknown(mem[image_index]))$fatal(1,"unknown complete image %h",image_index);\n $writememh("image.hex",mem);');
s=s.replace('$fatal(1,"golden CPU differs before LOAD")','$fatal(1,"golden CPU differs before LOAD CPU%h/%h A%h/%h DI%h/%h M1%b/%b MC%0d/%0d TS%0d/%0d",z80_reg,rr,ca,ra,cdi,rdi,cm1,rm1,cpu.MCycle,rcpu.MCycle,cpu.TState,rcpu.TState)');
s=s.replace('else $display("PASS G12 LOAD_RUNNING tailDelay%0d",TAIL_DELAY);','else $display("PASS G11 PAUSE tailDelay%0d saved%0d current%0d suffix%0d",TAIL_DELAY,SAVED_PAUSED,CURRENT_PAUSED,N);');
const main=fs.readFileSync(p.join(d,'matrix/audio_tb.sv'),'utf8');
const monitor=main.slice(main.indexOf('integer baseline_consumptions='),main.lastIndexOf('endmodule'));
s=s.replace(/endmodule\s*$/,monitor+'\nendmodule\n');
s=s.replace('if($isunknown({z80_reg,rr,signature,ref_signature})','if($isunknown({z80_reg,rr,signature,ref_signature})');
// Golden CPU follows the same real restart controls but computes decryption
// directly from current logical address/M1/raw media, without omitted history.
fs.writeFileSync(p.join(dst,'audio_tb.sv'),s);
fs.writeFileSync(p.join(dst,'pin_model.sv'),fs.readFileSync(p.join(dst,'pin_model.sv'),'utf8').replace('if(CACHEHISTORY)begin opmask','#0;if(CACHEHISTORY)begin opmask'));
console.log('Prepared production-decrypt / pure-byte golden four-way Pause fixture.');

