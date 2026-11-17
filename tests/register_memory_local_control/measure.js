const fs=require('fs'),p=require('path'),crypto=require('crypto'),assert=require('assert');
const d=__dirname,root=p.resolve(d,'../..'),measure=require('../cpu_restore_output_alias/measure');
const read=f=>{const b=fs.readFileSync(f);return b.toString(b[0]===255&&b[1]===254?'utf16le':'utf8');};
const hash=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');

function analyzeBuild(folder){
  const m=measure(folder),fit=read(p.join(folder,'output_files/SMS.fit.rpt')),map=read(p.join(folder,'output_files/SMS.map.rpt'));
  const n=re=>{const x=fit.match(re);assert(x,String(re));return Number(x[1].replaceAll(',',''));};
  m.MLABbits=n(/Total MLAB memory bits\s*;\s*([\d,]+)/);
  m.memoryALMs=n(/ALMs used for memory[^;]*;\s*([\d,]+)/);
  m.M10K=n(/; M10K blocks\s*;\s*([\d,]+)/);
  const ramStart=fit.indexOf('; Fitter RAM Summary');
  const ramLines=fit.slice(ramStart).split(/\r?\n/),ramEnd=ramLines.findIndex((s,i)=>i>4&&s==='');
  const ramRows=ramLines.slice(0,ramEnd<0?undefined:ramEnd).filter(s=>/^;/.test(s)).map(s=>s.split(';').slice(1,-1).map(x=>x.trim()));
  m.MLABcells=ramRows.filter(r=>r.length>20&&/^\d+$/.test(r[19])).reduce((a,r)=>a+Number(r[19]),0);
  const retimed=fit.split(/\r?\n/).filter(l=>/^;/.test(l)&&/Retimed Register/.test(l));
  m.retiming={
    whole:retimed.length,
    scaler:retimed.filter(l=>l.includes('ascal:ascal|')).length,
    luminance:retimed.filter(l=>/o_poly_lum|o_[hv]_lum_pix/.test(l)).length
  };
  m.setupTNS=Math.min(...m.timing.filter(q=>q.type.startsWith('Setup')).map(q=>q.tns));
  m.holdTNS=Math.min(...m.timing.filter(q=>q.type.startsWith('Hold')).map(q=>q.tns));
  m.registerHierarchy=fit.split(/\r?\n/).filter(l=>/^;/.test(l)&&/;\s*RegisterMemory\s*;\s*work\s*;/.test(l)).map(l=>l.split(';').slice(1,-1).map(s=>s.trim()));
  m.registerRamRows=fit.split(/\r?\n/).filter(l=>/^;/.test(l)&&/regs_array.*;\s*AUTO\s*;/.test(l));
  return m;
}

const seed2={
  baseline:analyzeBuild(p.join(root,'tests/register_memory_auto_seed2/baseline')),
  auto:analyzeBuild(p.join(root,'tests/register_memory_auto_seed2/candidate')),
  localControl:analyzeBuild(p.join(d,'candidate'))
};
const seed1={
  baseline:analyzeBuild(p.join(root,'tests/register_memory_auto/baseline')),
  auto:analyzeBuild(p.join(root,'tests/register_memory_auto/candidate')),
  localControl:analyzeBuild(p.join(d,'candidate_seed1'))
};

// Verify prior test directories are untouched
const old=JSON.parse(read(p.join(root,'tests/register_memory_impl_control/preservation_before.json')));
let preservedCount=0;
for(const [f,h]of Object.entries(old.files)){
  if(f.startsWith('tests/')){
    assert.equal(hash(p.join(root,f)),h,'Modified prior test file '+f);
    preservedCount++;
  }
}

const summary={
  experiment:'set_instance_assignment -name QII_AUTO_PACKED_REGISTERS OFF -to "emu:emu|system:system|opll:fm|controller:ct|RegisterMemory:u_register_memory"',
  branch:'experiment/registermemory-local-control',
  preservedPriorTestFiles:preservedCount,
  seed2:{
    baseline:{needed:seed2.baseline.needed,placed:seed2.baseline.placed,mappedRegs:seed2.baseline.synthesisRegisters,fittedRegs:seed2.baseline.registers,M10K:seed2.baseline.M10K,DSP:seed2.baseline.DSP,setup:seed2.baseline.setup,hold:seed2.baseline.hold,setupTNS:seed2.baseline.setupTNS,holdTNS:seed2.baseline.holdTNS,retiming:seed2.baseline.retiming,registerHierarchy:seed2.baseline.registerHierarchy},
    auto:{needed:seed2.auto.needed,placed:seed2.auto.placed,mappedRegs:seed2.auto.synthesisRegisters,fittedRegs:seed2.auto.registers,M10K:seed2.auto.M10K,DSP:seed2.auto.DSP,setup:seed2.auto.setup,hold:seed2.auto.hold,setupTNS:seed2.auto.setupTNS,holdTNS:seed2.auto.holdTNS,retiming:seed2.auto.retiming,registerHierarchy:seed2.auto.registerHierarchy},
    localControl:{needed:seed2.localControl.needed,placed:seed2.localControl.placed,mappedRegs:seed2.localControl.synthesisRegisters,fittedRegs:seed2.localControl.registers,M10K:seed2.localControl.M10K,DSP:seed2.localControl.DSP,setup:seed2.localControl.setup,hold:seed2.localControl.hold,setupTNS:seed2.localControl.setupTNS,holdTNS:seed2.localControl.holdTNS,retiming:seed2.localControl.retiming,registerHierarchy:seed2.localControl.registerHierarchy},
    deltaVsBaseline:{
      needed:seed2.localControl.needed-seed2.baseline.needed,
      placed:seed2.localControl.placed-seed2.baseline.placed,
      mappedRegs:seed2.localControl.synthesisRegisters-seed2.baseline.synthesisRegisters,
      fittedRegs:seed2.localControl.registers-seed2.baseline.registers,
      M10K:seed2.localControl.M10K-seed2.baseline.M10K,
      setup:+(seed2.localControl.setup-seed2.baseline.setup).toFixed(3),
      hold:+(seed2.localControl.hold-seed2.baseline.hold).toFixed(3)
    },
    deltaVsAuto:{
      needed:seed2.localControl.needed-seed2.auto.needed,
      placed:seed2.localControl.placed-seed2.auto.placed,
      mappedRegs:seed2.localControl.synthesisRegisters-seed2.auto.synthesisRegisters,
      fittedRegs:seed2.localControl.registers-seed2.auto.registers,
      M10K:seed2.localControl.M10K-seed2.auto.M10K,
      setup:+(seed2.localControl.setup-seed2.auto.setup).toFixed(3),
      hold:+(seed2.localControl.hold-seed2.auto.hold).toFixed(3)
    }
  },
  seed1:{
    baseline:{needed:seed1.baseline.needed,placed:seed1.baseline.placed,mappedRegs:seed1.baseline.synthesisRegisters,fittedRegs:seed1.baseline.registers,M10K:seed1.baseline.M10K,DSP:seed1.baseline.DSP,setup:seed1.baseline.setup,hold:seed1.baseline.hold,setupTNS:seed1.baseline.setupTNS,holdTNS:seed1.baseline.holdTNS,retiming:seed1.baseline.retiming,registerHierarchy:seed1.baseline.registerHierarchy},
    auto:{needed:seed1.auto.needed,placed:seed1.auto.placed,mappedRegs:seed1.auto.synthesisRegisters,fittedRegs:seed1.auto.registers,M10K:seed1.auto.M10K,DSP:seed1.auto.DSP,setup:seed1.auto.setup,hold:seed1.auto.hold,setupTNS:seed1.auto.setupTNS,holdTNS:seed1.auto.holdTNS,retiming:seed1.auto.retiming,registerHierarchy:seed1.auto.registerHierarchy},
    localControl:{needed:seed1.localControl.needed,placed:seed1.localControl.placed,mappedRegs:seed1.localControl.synthesisRegisters,fittedRegs:seed1.localControl.registers,M10K:seed1.localControl.M10K,DSP:seed1.localControl.DSP,setup:seed1.localControl.setup,hold:seed1.localControl.hold,setupTNS:seed1.localControl.setupTNS,holdTNS:seed1.localControl.holdTNS,retiming:seed1.localControl.retiming,registerHierarchy:seed1.localControl.registerHierarchy},
    deltaVsBaseline:{
      needed:seed1.localControl.needed-seed1.baseline.needed,
      placed:seed1.localControl.placed-seed1.baseline.placed,
      mappedRegs:seed1.localControl.synthesisRegisters-seed1.baseline.synthesisRegisters,
      fittedRegs:seed1.localControl.registers-seed1.baseline.registers,
      M10K:seed1.localControl.M10K-seed1.baseline.M10K,
      setup:+(seed1.localControl.setup-seed1.baseline.setup).toFixed(3),
      hold:+(seed1.localControl.hold-seed1.baseline.hold).toFixed(3)
    },
    deltaVsAuto:{
      needed:seed1.localControl.needed-seed1.auto.needed,
      placed:seed1.localControl.placed-seed1.auto.placed,
      mappedRegs:seed1.localControl.synthesisRegisters-seed1.auto.synthesisRegisters,
      fittedRegs:seed1.localControl.registers-seed1.auto.registers,
      M10K:seed1.localControl.M10K-seed1.auto.M10K,
      setup:+(seed1.localControl.setup-seed1.auto.setup).toFixed(3),
      hold:+(seed1.localControl.hold-seed1.auto.hold).toFixed(3)
    }
  }
};

fs.writeFileSync(p.join(d,'results.json'),JSON.stringify(summary,null,2)+'\n');
console.log(JSON.stringify(summary,null,2));

