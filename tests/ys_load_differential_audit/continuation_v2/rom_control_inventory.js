// Derived statistics only; never emit ROM bytes or an instruction listing.
const fs=require('fs'),p=require('path');const d=__dirname,roms=JSON.parse(fs.readFileSync(p.join(d,'local_rom_identity.json'))).roms;
const results=roms.map(r=>{const b=fs.readFileSync(r.path),direct={};let stores=0;
 for(let i=0;i+4<b.length;i++){
  if(b[i]===0x32&&b[i+1]===0xfc&&b[i+2]===0xff)stores++;
  if(b[i]===0x3e&&b[i+2]===0x32&&b[i+3]===0xfc&&b[i+4]===0xff)direct[b[i+1]]=(direct[b[i+1]]||0)+1;
 }
 return{name:r.name,SHA256:r.SHA256,immediateControlValuePatternCounts:direct,storeControlPatternCount:stores,limitation:'Static byte-pattern candidates only; data can match. Not proof of reachable instructions or runtime bank use.'};});
fs.writeFileSync(p.join(d,'rom_control_inventory.json'),JSON.stringify({results},null,2)+'\n');console.log(results);
