const fs=require('fs'),assert=require('assert'),p=require('path'),file=p.join(__dirname,'final_results.json'),r=JSON.parse(fs.readFileSync(file));
assert(r.sourceHashesVerified&&r.snapshotInferred);assert.equal(r.candidate.violations,0);assert.deepEqual(r.warningDetails.newTypes,[]);
for(const[k,v]of Object.entries(r.deltaFromEarly))assert.equal(v,0,'same-source repeatability '+k);
assert.equal(r.candidate.setup,0.105);assert.equal(r.candidate.hold,0.206);
r.classification='FITS BUT REQUIRES CAUTION';r.resourceDecision={repeatability:'Every measured resource, packing and timing metric is identical to the early build.',physicalHeadroom:41910-r.candidate.placed,freeM10K:553-r.candidate.M10K,rationale:'Final source-only build preserves raw QSF/SDC/IP/RTL hashes and fixed baseline date. Fit/route/assembly/STA succeed. One extra M10K inferred; no new warning type. Positive 0.105ns setup reserve is limited; single-seed repetition and pre-existing partially unconstrained SDC do not establish seed/hardware robustness.'};
fs.writeFileSync(file,JSON.stringify(r,null,2)+'\n');console.log({classification:r.classification,allMeasuredDeltasFromEarly:0,sourceHashesVerified:true});
