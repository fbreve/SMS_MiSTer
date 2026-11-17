const fs=require('fs'),path=require('path');
const b=fs.readFileSync(path.join(__dirname,process.argv[2]));const s=b.toString(b[0]===255?'utf16le':'utf8');
const m=s.match(/DIFF iter\d+ clock(\d+) expected([a-f\d]+) actual([a-f\d]+)/);if(!m)throw Error('No failure');
console.log('Offset',m[1]);for(const hex of m.slice(2)){let x=BigInt('0x'+hex)>>323n;console.log(x.toString(16));for(const [n,l,w]of [['AF',0,16],['SP',48,16],['PC',64,16],['BC',80,16],['DE',96,16],['HL',112,16],['IX',128,16],['BCp',144,16],['DEp',160,16],['HLp',176,16],['IY',192,16],['WZ',212,16]])console.log(n,((x>>BigInt(l))&((1n<<BigInt(w))-1n)).toString(16));}
