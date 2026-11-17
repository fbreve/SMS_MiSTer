const fs=require('fs'),path=require('path'),crypto=require('crypto'),cp=require('child_process');
const d=__dirname,root=path.resolve(d,'../..');
const read=n=>{const b=fs.readFileSync(path.join(d,n));return b.toString(b[0]===255?'utf16le':'utf8').replace(/^\ufeff/,'');};
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const fields=JSON.parse(read('context_fields.json'));
const unpack=(hex,defs)=>Object.fromEntries(defs.map(f=>[f.name,Number((BigInt('0x'+hex)>>BigInt(f.low))&((1n<<BigInt(f.width))-1n))]));
const arch=[['A',0,8],['F',8,8],['R',40,8],['SP',48,16],['PC',64,16],['BC',80,16],['DE',96,16],['HL',112,16],['IFF1',210,1],['IFF2',211,1],['WZ',212,16],['HALT',229,1]].map(([name,low,width])=>({name,low,width}));
const results=[];
for(const n of fs.readdirSync(d).filter(n=>/^extended_.*\.log$/.test(n))){
 const s=read(n);if(!s.includes('PASS G01 CHARACTERIZED'))throw Error('Incomplete '+n);
 const c=[...s.matchAll(/CANONICAL iter(\d+) arch_equal1 ctxR([a-f\d]+) ctxD([a-f\d]+)/g)].map(m=>({iteration:+m[1],reference:unpack(m[2],fields),restored:unpack(m[3],fields)}));
 const a=[...s.matchAll(/FIRST_CPU iter(\d+) k(\d+) R([a-f\d]+) D([a-f\d]+)/g)].map(m=>({iteration:+m[1],logicalHostOffset:+m[2],reference:unpack(m[3],arch),restored:unpack(m[4],arch)}));
 const bus=[...s.matchAll(/FIRST_BUS iter(\d+) k(\d+) R([a-f\d]+) D([a-f\d]+)/g)].map(m=>({iteration:+m[1],logicalHostOffset:+m[2],referenceAddress:Number(BigInt('0x'+m[3])>>21n),restoredAddress:Number(BigInt('0x'+m[4])>>21n)}));
 if(c.length!==3||a.length!==3||bus.length!==3)throw Error('Missing three-load evidence '+n);
 results.push({log:n,sha256:sha(fs.readFileSync(path.join(d,n))),accepted:s.match(/ACCEPT program[^\r\n]+/)[0],saveOnly:s.match(/SAVE_ONLY PASS comparisons\d+/)[0],canonical:c,firstArchitectural:a,firstBus:bus,final:[...s.matchAll(/FINAL[^\r\n]+/g)].map(m=>m[0])});
}
const names=cp.execFileSync('git',['ls-files','-z'],{cwd:root}).toString().split('\0').filter(Boolean);
const changed=[];for(const n of names){const p=path.join(root,n);if(!fs.existsSync(p)||!fs.statSync(p).isFile())continue;const committed=cp.execFileSync('git',['show','HEAD:'+n],{cwd:root,maxBuffer:20*1024*1024});if(sha(committed.toString().replace(/\r\n/g,"\n"))!==sha(fs.readFileSync(p,"utf8").replace(/\r\n/g,"\n")))changed.push(n);}
const exact=['fixed_tb.sv','machine.sv','mapping.sv','T80_observed.vhd','T80s_observed.vhd','mapper_ctrl_observed.vhd','savestates_sim.sv','io_instance.sv','run.do','run.ps1'].map(n=>({file:n,identicalToG09:sha(fs.readFileSync(path.join(d,n)))===sha(fs.readFileSync(path.join(d,'../savestate_g09_last_read',n)))}));
if(changed.length||exact.some(v=>!v.identicalToG09))throw Error('Source integrity check failed '+changed);
fs.writeFileSync(path.join(d,'results.json'),JSON.stringify({head:cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root}).toString().trim(),trackedFilesCompared:names.length,trackedChanges:changed,exactOriginalFixtures:exact,runs:results},null,2));
console.log(JSON.stringify({extendedRuns:results.length,trackedFilesCompared:names.length,trackedChanges:changed,exactOriginalFixtures:true}));



