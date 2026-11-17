const fs=require('fs');
function load(file,mod){
 let t=fs.readFileSync(file,'latin1');if(mod){const i=t.indexOf('\nmodule '+mod+' (');const j=t.indexOf('\nendmodule',i);t=t.slice(i,j);}const cells={};const byQ={};
 const re=/(cyclonev_lcell_comb|dffeas)\s+(\\?[^\s(]+)\s*\(([\s\S]*?)\);\s*\n/g;let m;
 const masks={};const dre=/defparam (?:(\\\S+) |([A-Za-z_]\w*))\.(lut_mask|extended_lut) = (?:64'h([0-9A-Fa-f]+)|"(\w+)");/g;
 while((m=dre.exec(t))){const k=m[1]||m[2];masks[k]=masks[k]||{};masks[k][m[3]]=m[4]||m[5];}
 while((m=re.exec(t))){
  const name=m[2],body=m[3],ports={};
  for(const pm of body.matchAll(/\.(\w+)\(([^)]*)\)/g))ports[pm[1]]=pm[2].trim();
  const c={type:m[1],name,ports,mask:masks[name]};cells[name]=c;
  if(m[1]==='dffeas'){byQ[ports.q.replace(/^\\/,'\\')]=c;}
  else if(ports.combout&&ports.combout!=='')byQ[ports.combout]=c;
 }
 return {cells,byQ};
}
function sig(s){s=s.trim();let inv=false;if(s.startsWith('!')){inv=true;s=s.slice(1).trim();}return {w:s,inv};}
module.exports={load,sig};



