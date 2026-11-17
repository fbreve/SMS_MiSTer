// Preserve each unchanged baseline line's original mixed LF/CRLF spelling.
// New lines use LF to avoid treating a new CR as trailing whitespace in a
// mixed-ending Git blob. HDL tokens are unchanged.
function preserveEndings(original,edited){
 const a=original.replace(/\r\n/g,'\n').split('\n'),b=edited.replace(/\r\n/g,'\n').split('\n');
 const endings=[...original.matchAll(/\r\n|\n/g)].map(m=>m[0]);
 const n=a.length,m=b.length,dp=new Uint16Array((n+1)*(m+1));
 for(let i=n-1;i>=0;i--)for(let j=m-1;j>=0;j--)dp[i*(m+1)+j]=a[i]===b[j]?1+dp[(i+1)*(m+1)+j+1]:Math.max(dp[(i+1)*(m+1)+j],dp[i*(m+1)+j+1]);
 const map=new Map();let i=0,j=0;while(i<n&&j<m){if(a[i]===b[j]){map.set(j,i);i++;j++;}else if(dp[(i+1)*(m+1)+j]>=dp[i*(m+1)+j+1])i++;else j++;}
 let out='';for(let k=0;k<m;k++){const e=map.has(k)?endings[map.get(k)]:'\n';out+=b[k]+(k<m-1?(e||'\n'):'');}return out;
}
module.exports=preserveEndings;
if(require.main===module){const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),d=__dirname,root=p.resolve(d,'../..'),proof=JSON.parse(fs.readFileSync(p.join(d,'sufficiency_pre_edit.json'),'utf8')),record={};
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
for(const f of Object.keys(proof.sources)){const old=cp.execFileSync('git',['show','HEAD:'+f],{cwd:root,maxBuffer:8*1024*1024}).toString('utf8'),now=fs.readFileSync(p.join(root,f),'utf8'),out=preserveEndings(old,now);if(out.replace(/\r\n/g,'\n')!==now.replace(/\r\n/g,'\n'))throw Error('token/text change '+f);fs.writeFileSync(p.join(root,f),out);fs.writeFileSync(p.join(d,'proposed',f),out);record[f]={rawSha:sha(out),normalizedSha:sha(out.replace(/\r\n/g,'\n')),proofNormalizedSha:proof.sources[f]};if(record[f].normalizedSha!==proof.sources[f])throw Error('not the proof-gated text '+f);}
fs.writeFileSync(p.join(d,'production_sources.json'),JSON.stringify(record,null,2));console.log('Preserved baseline line endings; all six normalized source hashes equal the proof-gated files');}
