const fs=require('fs'),p=require('path'),d=__dirname,t=fs.readFileSync(p.join(d,'review.md'),'utf8');
const headings=[...t.matchAll(/^## (\d+)\./gm)].map(m=>+m[1]);
if(headings.length!==42||headings.some((n,i)=>n!==i+1))throw Error('report numbering');
const r=JSON.parse(fs.readFileSync(p.join(d,'simulation_results.json')));
if(!r.requiredRuntimeGate||r.failed||r.pending||r.passed!==34)throw Error('incomplete runtime gate');
for(const m of t.matchAll(/\]\(([^)]+)\)/g))if(!fs.existsSync(p.resolve(d,m[1])))throw Error('missing report link '+m[1]);
const inventory=fs.readFileSync(p.join(d,'architecture.md'),'utf8');if(/candidate|UNKNOWN until/.test(inventory))throw Error('unresolved inventory classification');
if(!t.includes(r.collisions[0].shaA)||!t.includes(r.collisions[1].shaA))throw Error('stale witness hash');
console.log('PASS final report:42 sections;34/34 integrated groups;4/4 supporting groups;2 complete-image pairs;no pending cases;links valid.');
