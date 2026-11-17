const fs=require('fs'),p=require('path');
// Widths from the audited architectural inventory, not the RTL read serializer.
const masks=[...Array(9).fill(0x3fffff),0xffffffff,15,0xfc08ffff,15,...Array(18).fill(0x3ffff),...Array(18).fill(0x1ffffff),...Array(27).fill(0x3ff),0x1ff,0x1ffff,0x7f,0,0xffffffff,0xffff,0xffffffff,0x7ffffff,0x7fffffff,0xfffffff,0x7fffffff,0x7fffffff,0xfffff,0x1ffffff,0x3ffff,0x3fffff,0x1fff,0xffffffff,0x7ffff,0xfffff,0x7fffffff,0x3ffff,0xffffff,0x7fffff,0x7fffffff,0xfffff,0x3fff,0];
if(masks.length!==104)throw Error(masks.length);
let seed=0x2413f019;function rand(){seed^=seed<<13;seed^=seed>>>17;seed^=seed<<5;return seed>>>0;}
let all=[];
for(let pass=0;pass<8;pass++){
 let w=masks.map(m=>(rand()&m)>>>0);
 w[78]=rand()%72;
 w[81]=(w[81]&15)|((rand()%9)<<4)|((rand()%38)<<8)|((rand()%2)<<14)|((rand()%2)<<15);
 w[86]=((w[86]&~31)|(rand()%18))>>>0;
 w[97]=((w[97]&~15)|(rand()%9))>>>0;
 w[100]=((w[100]&~0x7fc)|((rand()%9)<<2)|((rand()%18)<<6))>>>0;
 w[101]=((w[101]&~62)|((rand()%18)<<1))>>>0;
 all.push(...w.map(v=>v.toString(16).padStart(8,'0')));
}
fs.writeFileSync(p.join(__dirname,'patterns.hex'),all.join('\n')+'\n');
