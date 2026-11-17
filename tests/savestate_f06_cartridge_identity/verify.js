const fs=require('fs'),cp=require('child_process'),crypto=require('crypto'),assert=require('assert'),d=__dirname;
const hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const git=(...args)=>cp.execFileSync('git',args,{encoding:'utf8'}).trim();
const base=JSON.parse(fs.readFileSync(d+'/baseline.json'));
for(const [p,h]of Object.entries(base.files))assert.equal(hash(p),h,p);
for(const [p,h]of Object.entries(base.prerequisites))assert.equal(hash(p),h,p);
assert.equal(git('rev-parse','HEAD'),base.head);
assert.equal(git('branch','--show-current'),'investigate/savestate-f06-cartridge-identity');
assert.equal(git('diff','--stat'),'');assert.equal(git('diff','--cached','--stat'),'');
const provenance=JSON.parse(fs.readFileSync(d+'/host_provenance.json'));
for(const f of provenance.files){let b=fs.readFileSync(d+'/host/'+f.path);assert.equal(crypto.createHash('sha1').update('blob '+b.length+'\0').update(b).digest('hex'),f.blob,f.path);}
const fixture=fs.readFileSync(d+'/fio_decoder.sv','utf8'),src=fs.readFileSync('sys/hps_io.sv','utf8').replace(/\r\n/g,'\n');
const body=src.slice(src.indexOf('localparam FIO_FILE_TX'),src.indexOf('endmodule'));
assert(fixture.includes(body),'FIO decoder differs from production');
const log=fs.readFileSync(d+'/interface.log','utf8');
assert(log.includes('PASS INTERFACE COMPLETE'));assert(log.includes('Errors: 0'));assert(!/\*\* (Fatal|Error):/.test(log));
assert.equal([...log.matchAll(/PASS WIRE download/g)].length,3);
const contracts=JSON.parse(fs.readFileSync(d+'/contracts.json'));assert.equal(contracts.checks.length,8);
const report=fs.readFileSync(d+'/review.md','utf8');for(let n=1;n<=38;n++)assert(report.includes('## '+n+'. '));
assert(report.includes('Decision E. SMALL FRAMEWORK EXTENSION IS REQUIRED'));
const artifacts={};for(const f of fs.readdirSync(d))if(/\.(js|json|sv|do|md|log)$/.test(f)&&!['evidence.json','interface_console.log'].includes(f))artifacts[f]=hash(d+'/'+f);
fs.writeFileSync(d+'/evidence.json',JSON.stringify({head:base.head,branch:git('branch','--show-current'),trackedFiles:Object.keys(base.files).length,trackedFilesUnchanged:true,host:provenance,hostSnapshotsVerified:provenance.files.length,decoderSourceVerbatim:true,wireTransfers:3,sourceBoundModelChecks:contracts.checks.length,decision:'E. SMALL FRAMEWORK EXTENSION IS REQUIRED',conditionalPhase12Answer:'Full32 KiB plus mapping suffices if correct same-ROM state is guaranteed; no additional FPGA owner metadata needed under that assumption',diffStat:git('diff','--stat'),stagedDiff:git('diff','--cached','--stat'),status:git('status','--short'),artifacts},null,2));
console.log('PASS: '+Object.keys(base.files).length+' tracked files unchanged; 8 pinned host blobs, unchanged decoder, 3 wire transfers, 8 source-bound checks, 38 report sections; nothing staged');

