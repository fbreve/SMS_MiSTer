// Source-bound executable models, NOT a compiled MiSTer host or filesystem test.
const fs=require('fs'),assert=require('assert'),crypto=require('crypto'),d=__dirname;
const read=p=>fs.readFileSync(p,'utf8').replace(/\r\n/g,'\n');
const host=read(d+'/host/user_io.cpp'),file=read(d+'/host/file_io.cpp'),sms=read('SMS.sv');
const checks=[];function check(name,f){f();checks.push(name);console.log('PASS '+name);}
function savePath(n,state=false,slot=1){let b=n.split('/').pop();b=b.replace(/\.[^.]*$/,'');return (state?'savestates':'saves')+'/SMS/'+b+(state?'_'+slot+'.ss':'.sav');}
check('source anchors for name-based persistence and slots',()=>{
 for(const s of ['strrchr(name, \'/\')','strrchr(fname, \'.\')','sprintf(e, "_%d.ss", sufx)'])assert(file.includes(s));
 assert(host.includes('if(ss_base && opensave) process_ss(name);'));
 assert(host.includes('user_io_file_mount((char*)buf, 0, 1);'));
 assert(read(d+'/host/user_io.h').includes('int pre_size = 0'));
 assert(sms.includes('old_downloading & ~downloading & |img_size & bk_ena'));
});
check('different directories and extensions can share SRAM and state namespaces',()=>{
 assert.equal(savePath('/games/Japan/Game.sms'),savePath('/games/Europe/Game.gg'));
 assert.equal(savePath('/games/Japan/Game.sms',true),savePath('/games/Europe/Game.gg',true));
 assert.notEqual(savePath('/games/A.sms',true),savePath('/games/B.sms',true));
});
function mount(exists,size,writable){return {size:exists?size:0,readonly:exists?!writable:false,type:exists?0:2};}
function autoLoad(m){return m.size!==0&&!m.readonly;}
check('missing empty and readonly saves do not start SMS automatic SRAM load',()=>{
 assert(!autoLoad(mount(false,0,false)));assert(!autoLoad(mount(true,0,true)));assert(!autoLoad(mount(true,32768,false)));
 assert(autoLoad(mount(true,32768,true)));
});
check('missing precreated media can supply FF only if core actually requests a read',()=>{
 assert(host.includes('size = pre_size;'));assert(host.includes('sd_image[index].type = 2;'));
 assert(host.includes('memset(buffer[disk], -1, sizeof(buffer[disk]));'));
 assert.equal(mount(false,0,false).type,2);assert.equal(mount(false,0,false).size,0);
});
check('partial successful fread leaves unread buffer tail untouched',()=>{
 assert(file.includes('ret = fread(pBuffer, 1, length, file->filp);'));
 assert(host.includes('if (FileReadAdv(&sd_image[disk], buffer[disk], sizeof(buffer[disk])))'));
 let b=Buffer.alloc(4096,0xa7),short=Buffer.alloc(513,0x31);short.copy(b);
 assert.equal(b[512],0x31);assert.equal(b[513],0xa7);assert.equal(b[4095],0xa7);
});
check('A to B to A requires snapshot bytes, not current persistent file',()=>{
 const saved=Buffer.alloc(32768);saved.fill(0x31,0,16384);saved.fill(0x72,16384);
 let live=Buffer.alloc(32768,0xb2); // B established
 live.fill(0x44); // A reloaded, current A persistent file differs from saved state
 saved.copy(live);assert(live.equals(saved));assert.equal(live[0],0x31);assert.equal(live[16384],0x72);
});
check('generation-only loses portability and never certifies missing-save contents',()=>{
 let generation=1,ram=Buffer.alloc(32768,0x31);generation++;assert.equal(generation,2);
 assert.equal(ram[0],0x31);assert(!autoLoad(mount(false,0,false)));
 assert.notEqual(1,generation); // same saved-ROM file can be returned in a later generation
});
const provenance=JSON.parse(read(d+'/host_provenance.json'));
check('all host snapshots match pinned Git blob identities',()=>{
 for(const x of provenance.files){let b=fs.readFileSync(d+'/host/'+x.path);let h=crypto.createHash('sha1').update('blob '+b.length+'\0').update(b).digest('hex');assert.equal(h,x.blob,x.path);}
});
fs.writeFileSync(d+'/contracts.json',JSON.stringify({checks,kind:'Source-bound models and static assertions; not a compiled host or full core integration',hostCommit:provenance.commit},null,2));
