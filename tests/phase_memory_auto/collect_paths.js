const fs=require('fs'),p=require('path'),d=__dirname;
const read=f=>{const b=fs.readFileSync(p.join(d,f));return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');};
const r={global:{},registerQueries:{},keeperQueryFailure:{file:'candidate_paths.log',reason:'Access violation in sta_find_duplicates_of_deleted_net_name / add_keeper_to_vector_if_wildcard_matches after successful global setup and hold reports'}};
for(const v of ['baseline','candidate']){
 r.global[v]={};for(const t of ['setup','hold']){
  const file=v+'_register_paths_'+t+'.rpt',row=read(file).split(/\r?\n/).find(s=>/^; -?\d+\.\d+ ;/.test(s));
  r.global[v][t]=row.split(';').slice(1,-1).map(x=>x.trim());
 }
 r.registerQueries[v]={};
 for(const t of ['fm_from','fm_to','phase_from','phase_to'])r.registerQueries[v][t]=Number(read(v+'_register_paths_'+t+'.rpt').match(/Worst case slack is ([-\d.]+)/)[1]);
 r.registerQueries[v].counts=read(v+'_register_paths.log').split(/\r?\n/).filter(s=>/^(FM|PhaseMemory) registers:/.test(s));
}
fs.writeFileSync(p.join(d,'path_results.json'),JSON.stringify(r,null,2)+'\n');
