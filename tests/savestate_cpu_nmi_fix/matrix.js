const fs=require('fs'),path=require('path'),d=__dirname,r=path.resolve(d,'../..'),c=[];
const input=JSON.parse(fs.readFileSync(path.join(r,'tests/savestate_cpu_nmi_capture/cases.json'),'utf8')).filter(x=>x.cand===2);
for(const x of input)c.push({name:'replay_'+x.name.replace(/_c2$/,''),source:x.source,program:x.program,edge:x.edge,width:x.width,second:x.second,held:x.held,schedule:x.schedule,format:0,replays:3});
for(const x of JSON.parse(fs.readFileSync(path.join(r,'tests/savestate_cpu_nmi/cases_sync.json'),'utf8')).filter(x=>x.run===1))c.push({name:'timing_'+x.label,source:x.source,program:x.program,edge:x.edge,width:x.width,second:9999999,held:0,schedule:0,format:0,replays:0});
for(let version=1;version<=11;version++)for(const source of [0,1])c.push({name:`legacy${version}_source${source}`,source,program:0,edge:source?-45:0,width:1,second:9999999,held:0,schedule:0,format:version,replays:3});
for(const source of [0,1])c.push({name:`untagged_source${source}`,source,program:0,edge:0,width:1,second:9999999,held:0,schedule:0,format:99,replays:3});
for(let bit=41;bit<=63;bit++)c.push({name:'bad_padding_bit'+bit,source:0,program:0,edge:0,width:1,second:9999999,held:0,schedule:0,format:100+bit-41,replays:1});
c.push({name:'bad_subtype',source:0,program:0,edge:0,width:1,second:9999999,held:0,schedule:0,format:123,replays:1});
fs.writeFileSync(path.join(d,'cases.json'),JSON.stringify(c,null,2));console.log(c.length+' current-production integration cases');
