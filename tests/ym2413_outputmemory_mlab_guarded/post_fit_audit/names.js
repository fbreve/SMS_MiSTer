const {nl,find}=require('./eval.js');
for(const re of process.argv.slice(3))console.log(re,find(new RegExp(re)).slice(0,40));
const ff=nl.cells['\\fm_word[0]']||Object.values(nl.cells).find(c=>/fm_word\[0\]/.test(c.name)&&c.type==='dffeas');console.log(ff&&ff.name,ff&&JSON.stringify(ff.ports));
