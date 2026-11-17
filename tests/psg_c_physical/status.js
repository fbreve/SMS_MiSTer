const fs=require('fs'),p=require('path'),d=__dirname;
const read=f=>{const b=fs.readFileSync(f);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');};
const w=read(p.join(d,'workflow.log')).trim().split(/\r?\n/);console.log(w.slice(-4).join('\n'));
const m=w[w.length-1].match(/^(seed[12]\/[AC]) (map|fit|asm|sta) /);if(m){const file=p.join(d,m[1],m[2]+'.log');if(fs.existsSync(file))console.log(read(file).trim().split(/\r?\n/).slice(-6).join('\n'));}
console.log(new Date().toLocaleString('en-GB',{timeZone:'America/Sao_Paulo'}));
