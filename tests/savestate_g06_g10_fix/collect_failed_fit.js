const fs=require('fs'),p=require('path'),d=__dirname,b=p.join(d,'quartus_failed_congestion');
const read=f=>{const x=fs.readFileSync(f);return x[0]===255&&x[1]===254?x.subarray(2).toString('utf16le'):x.toString();};
const fit=read(p.join(b,'output_files/SMS.fit.summary')),rpt=read(p.join(b,'output_files/SMS.fit.rpt'));
const v=n=>+fit.match(new RegExp(n+'[^:\\r\\n]*:\\s*([\\d,]+)'))[1].replaceAll(',','');
const result={status:'FAILED - ROUTING CONGESTION',ALMsNeeded:v('Logic utilization'),ALMsPlaced:+rpt.match(/\[A\] ALMs used in final placement[^;]*;\s*([\d,]+)/)[1].replaceAll(',',''),registers:v('Total registers'),M10K:v('Total RAM Blocks'),memoryBits:v('Total block memory bits'),DSP:v('Total DSP Blocks'),setup:null,hold:null,timing:'No valid final routed timing result',reason:'16684/16618 congestion;188026 route failure;170143/11802 unsuccessful fitting. Indexed snapshot transport replaced with sequential64-bit ring/shift operations; no seed/constraint/device/format change.'};
fs.writeFileSync(p.join(d,'failed_congestion_summary.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result,null,2));
