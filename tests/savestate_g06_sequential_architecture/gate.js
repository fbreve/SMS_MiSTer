const fs=require('fs'),p=require('path'),assert=require('assert'),crypto=require('crypto'),cp=require('child_process'),d=__dirname,root=p.resolve(d,'../..');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
function log(f,marker){const b=fs.readFileSync(p.join(d,f)),s=b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');assert(s.includes(marker),'gate pending '+f);assert(!/\*\* (?:Error|Failure|Fatal):|Errors: [1-9]/.test(s),'gate failure '+f);assert(/Errors: 0/.test(s),'unterminated '+f);return {file:f,marker,sha256:sha(b)};}
const evidence=[
 log('local.log','PASS LOCAL ALL trials16 checks320016'),
 log('local_root.log','PASS LOCAL ALL trials16 checks320016'),
 log('read_retiming/retiming.log','PASS READ RETIMING clocks480848'),
 log('memory.log','PASS MEMORY ALL trials6 words300 exact_once legacy transport_gaps0_7_97'),
 log('sprites/dut_collision/simulation.log','DONE VDP'),
 log('sprites/dut_overflow9/simulation.log','DONE VDP'),
 log('sprites/dut_accelerated64/simulation.log','DONE VDP'),
 log('phases/dut_phases/simulation.log','PASS V15 VDP'),
 log('background/dut_h0/simulation.log','PASS RICH V15 VDP'),
 log('protocol/candidate/simulation.log','PASS PROTOCOL ALL profiles16 loads48 full_images16'),
 log('protocol/golden/simulation.log','PASS PROTOCOL ALL profiles16 loads48 full_images16'),
 log('protocol/format.log','PASS V17 FORMAT rejected2016 accepted400')
];
const eq=require('./image_equivalence.json');assert(eq.passed&&eq.profiles.length===16);
const baseline=require('./baseline.json');assert.equal(cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),baseline.head);assert.equal(cp.execFileSync('git',['diff','--name-only'],{cwd:root,encoding:'utf8'}).trim(),'');assert.equal(cp.execFileSync('git',['diff','--cached','--name-only'],{cwd:root,encoding:'utf8'}).trim(),'');
for(const[f,h]of Object.entries(baseline.hashes))assert.equal(sha(fs.readFileSync(p.join(root,f))),h,'production identity '+f);
const files=[...baseline.files,'rtl/sprite_state_pkg.vhd','rtl/sprite_snapshot.sv'],candidateHashes=Object.fromEntries(files.map(f=>[f,sha(fs.readFileSync(p.join(d,'candidate_A',f)))]));
const result={passed:true,head:baseline.head,format:17,candidate:'A, local32, one response register per VDP,300x32 scratch / twoM10Ks',candidateHashes,evidence,imageEquivalence:eq,requirements:{G06:'real collision,overflow9,actual64 SAVE + threeLOADs;16-mode full4764-bit guest miter',G10:'natural13-phase/repeat native enable-order fixture, all4phasecodes/ownership/consumption in coherent controller protocol',G05:'retained42000-pixel text-to-Mode4 oracle, SAVE + threeLOADs',saveDuration:'local0/7/97-clock gaps and transaction-qualified transport profiles0/1/2; exact full images and guest-state futures',loadDuration:'same plus48typed arbitrary full-record replays against committed controller',equivalence:'320016 live-state/output comparisons;480848 read-response clocks;16 full98304-byte image identities;48LOADs per controller'},sourceComposition:'Earlier distributed-response runtime connects to selected boundary response by read_retiming/equivalence.md and exact miter. No guest state/write/control change.',supplementalCampaign:'Remaining sprite modes,dualVDP,pending64,deterministic/full-flush tests continue; they are not counted as passed here. Any contradictory failure invalidates this gate and must stop the build.'};
fs.writeFileSync(p.join(d,'functional_gate.json'),JSON.stringify(result,null,2)+'\n');console.log({passed:true,evidenceLogs:evidence.length,productionUnchanged:true,fullQuartusAuthorized:true});
