const fs=require('fs'),p=require('path'),d=__dirname,cases=[];
for(const phase of [0,10,20,25])for(const div of [13,14,15]){
 const normal=phase===25;
 const boot=normal?(div===14?16:6):phase===20?(div===14?20:6):(div===14?6:20);
 cases.push({id:`boundary_p${phase}_d${div}`,args:{N:24000,REPLAYS:1,DUAL:normal?5:4,BOOT:boot,BUS:1,SEEK:phase||30,DIVSEEK:div}});
}
fs.writeFileSync(p.join(d,'modes/boundary_cases.json'),JSON.stringify(cases,null,2)+'\n');
fs.writeFileSync(p.join(d,'modes/boundary_remaining.json'),JSON.stringify(cases.filter(c=>c.id.startsWith('boundary_p20_')||c.id.startsWith('boundary_p25_')),null,2)+'\n');
console.log('Twelve accepted-boundary neighbors, literal GG normal/turbo decode');
