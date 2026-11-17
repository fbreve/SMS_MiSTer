const fs=require('fs'),p=require('path'),d=__dirname;let s=fs.readFileSync(p.join(d,'../prepare_vendor.js'),'utf8');
s=s.replace("src=fs.readFileSync(p.join(d,'synthesis/OutputMemory_mapped.v'),'utf8'),out=p.join(d,'vendor')", "src=fs.readFileSync(p.join(d,'OutputMemory_functional_export.v'),'utf8'),out=p.join(d,'vendor_fitted')");
s=s.replace('assert.equal(ffs.length,20)','assert.equal(ffs.length,0)');
s=s.replace("for(const x of ffs){", "for(const x of memories){assert.equal(port(x,'clk1'),'clk');assert.equal(port(x,'ena1'),'!reset');assert(x.block.includes('.port_b_data_out_clock = \"clock1\"'));const copy=x.name.includes('__dual')?1:0,bit=+x.name.match(/lutrama(\\d+)/)[1];assignments.push('assign q'+copy+'['+bit+'] = '+port(x,'portbdataout')+' [0];');}\nfor(const x of ffs){");
s=s.replace("p.join(d,'synthesis/candidate/functional_netlist/SMS.vo')","p.join(d,'candidate/fitted_netlist/SMS.vo')").replace('outputFFs:20','outputFFs:0,packedOutputRegisters:20').replace('20 actual output FFs','20 packed output FFs');
fs.writeFileSync(p.join(d,'extract_vendor_fitted.js'),s);
