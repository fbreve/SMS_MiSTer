const fs=require('fs');
function parse(f){
 const atoms=[];let cur=null;
 for(const line of fs.readFileSync(f,'utf8').split(/\r?\n/)){
  const p=line.split('\t');
  if(p[0]==='ATOM'){cur={id:p[1],type:p[2],loc:p[3],name:p[4],ins:[],outs:[],params:[]};atoms.push(cur);}
  else if(p[0]==='IN'&&cur)cur.ins.push({port:p[1],type:p[2],name:p[4]||''});
  else if(p[0]==='OUT'&&cur)cur.outs.push({port:p[1],type:p[2],fan:p[3]});
  else if(p[0]==='PARAM'&&cur)cur.params.push(p.slice(1).join('|'));
 }
 return atoms;
}
const norm=s=>s.replace(/\s+/g,' ');
function replicaInfo(atoms){
 const out={};
 for(const a of atoms.filter(x=>x.type==='LUTRAM')){
  const rep=/data_array__dual_rtl_0/.test(a.name)?'dual':'single';
  (out[rep]=out[rep]||[]).push(a);
 }
 return out;
}
function sig(atoms){
 const r=replicaInfo(atoms),o={};
 for(const [rep,list] of Object.entries(r)){
  o[rep]={n:list.length,inputs:{}};
  for(const a of list)for(const i of a.ins){const k=i.type;(o[rep].inputs[k]=o[rep].inputs[k]||new Set()).add(i.name.replace(/\|lutrama\d+/,'|lutramaN').replace(/data_array~\d+/g,'data_array~N').replace(/~DUPLICATE/g,''));}
  for(const k of Object.keys(o[rep].inputs))o[rep].inputs[k]=[...o[rep].inputs[k]].sort();
 }
 return o;
}
module.exports={parse,sig,replicaInfo};
if(require.main===module){
 const [f]=process.argv.slice(2);const a=parse(f);const s=sig(a);
 for(const [rep,v] of Object.entries(s)){console.log(rep,v.n);for(const [k,names] of Object.entries(v.inputs))console.log('  ',k,names.length,names.slice(0,3).join(' ; ').slice(0,260));}
}

