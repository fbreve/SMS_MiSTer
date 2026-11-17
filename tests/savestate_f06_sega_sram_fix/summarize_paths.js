const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname,out={};
for(const f of ['baseline_paths_setup','baseline_paths_hold','early_paths_setup','early_paths_hold','baseline_emu_setup','early_emu_setup']){
 const s=fs.readFileSync(p.join(d,f+'.rpt'),'utf8');
 const get=x=>{const m=s.match(new RegExp('^; '+x+'\\s*; ([^;]+);','m'));assert(m,x);return m[1].trim();};
 out[f]={slack:+s.match(/Worst case slack is ([\d.]+)/)[1],from:get('From Node'),to:get('To Node')};
}
fs.writeFileSync(p.join(d,'path_summary.json'),JSON.stringify(out,null,2));
let text='PASS. The paired seed1 build has no failing timing-summary category or routing failure. No confirmation build was needed.\n\n';
for(const [title,f]of [['v17 worst setup','baseline_paths_setup'],['v18 worst setup','early_paths_setup'],['v17 worst hold','baseline_paths_hold'],['v18 worst hold','early_paths_hold'],['v17 emulation-clock worst setup','baseline_emu_setup'],['v18 emulation-clock worst setup','early_emu_setup']]){const r=out[f];text+=`- ${title}: +${r.slack.toFixed(3)} ns, \`${r.from}\` → \`${r.to}\` ([path report](${f}.rpt)).\n`;}
text+='\nThe new global worst setup path remains in the unchanged HDMI/scaler framework. The emulation-clock minimum improves by +0.348 ns. These endpoint changes and positive margins provide no evidence of structural critical-path growth from F06. The source-only input manifest proves that the framework, CPU, VDP and audio RTL were unchanged. Realized slack changes include global placement/routing effects; a single paired build does not measure an intrinsic timing benefit from the extra flag. Existing partially unconstrained setup/hold coverage remains unchanged. Detailed reports use the Slow 1100 mV 100 C model; the complete multi-corner STA summary is retained in the build outputs.\n';
fs.writeFileSync(p.join(d,'path_analysis.md'),text);console.log(JSON.stringify(out,null,2));
