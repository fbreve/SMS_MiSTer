const fs=require('fs'),p=require('path'),d=__dirname;
const rows=[];
const add=(group,module,signal,width,count,offset,consumer,reason)=>rows.push({group,module,signal,width,count,totalBits:width*count,offset,snapshot:'Existing post-T record; parallel 4800-bit register bank per VDP',restore:'Existing ss_regs_set plus sprite_valid/default selection',currentMux:'Capture/hold/zero/rotate/insert scratch FF; distributed receiver selectors',freeze:'Accepted T completes; ss_freeze suppresses all guest VDP/pixel/sprite enables and raw overflow bookkeeping',version:'has_restart true for v14..v17; older formats normalize absent sprite history',firstConsumer:consumer,reason,candidate:'Local constant-slice 32-bit read/write, same original field offsets, no state removal'});
add('G06 SPRITE STATE','rtl/vdp_sprites.vhd','enable',1,64,0,'registered sprite color/collision reduction','Each slot independently contributes to pixels and collisions.');
add('G06 SPRITE STATE','rtl/vdp_sprites.vhd','spr_x',8,64,1,'shifter reload comparator','Retained X position survives mode changes and inactive slots.');
for(let i=0;i<4;i++)add('G06 SPRITE STATE','rtl/vdp_sprites.vhd','spr_d'+i,8,64,9+8*i,'shifter load / legacy plane/color interpretation','Cached pattern bytes are historical, not refetched during transport.');
for(let i=0;i<4;i++)add('G06 SPRITE STATE','rtl/vdp_sprite_shifter.vhd','shift'+i,8,64,41+8*i,'next enabled pixel and later shifted pixels','Exact already-loaded pixel history.');
add('G06 SPRITE STATE','rtl/vdp_sprite_shifter.vhd','wideclock',1,64,73,'wide sprite half-rate advancement','Historical width phase.');
for(const [name,width,offset,consumer,reason]of[
 ['data_address',14,4736,'next evaluator VRAM address','Prior partial address formation can survive mode changes.'],['m2_flags',8,4750,'legacy X offset/color load','Historical cached flags.'],['color_reg',4,4758,'registered pixel composition','First post-release pixel uses registered color.'],['collide_reg',1,4762,'collision delay source','Registered collision event source.'],['overflow_reg',1,4763,'VDP overflow/status bookkeeping','Registered overflow event source.']
])add('G06 SPRITE STATE','rtl/vdp_sprites.vhd',name,width,1,offset,consumer,reason);
add('G06 SPRITE STATE','rtl/vdp.vhd','xspr_collide_shift',14,1,4764,'collision flag and IRQ timing','Full pending collision-delay history, shared G04 dependency.');
const map=Array.from({length:150},(_,word)=>({word,lowBit:32*word,highBit:Math.min(32*word+31,4777),mask:word===149?'000003ff':'ffffffff',externalDDRWord:Math.floor(word/2),externalHalf:word%2?'high32':'low32'}));
const g10=[
 ['rtl/savestates.sv','phase_snap',2,'saved class 0/10/20/25, word02f bits1:0','First native CPU/VDP/pixel/sprite event order'],
 ['rtl/savestates.sv','capture_tick_snap',1,'word02f bit3','One versus two private historical CPU replay ticks'],
 ['SMS.sv','clkd and ce_cpu/ce_vdp/ce_pix/ce_sp',9,'existing live divider5 plus four enables; install from captured class','Falling-edge canonical commit and first logical T+1'],
 ['rtl/T80/T80s.vhd','private NMI/context replay controls',null,'ReplayT2, RestoreHold, wrapper replay state; no independent new payload','Historical CPU reconstruction before VDP release'],
 ['rtl/savestates.sv','ST_CPU_PREPARE/ST_PHASE_COMMIT',null,'states105/106 plus phase handshake; no new historical payload','Replay completion, phase acknowledgment, beam/release ordering']
].map(([module,signal,bits,representation,firstConsumer])=>({group:'G10 DETERMINISTIC RESTART STATE',module,signal,bits,representation,firstConsumer,candidate:'UNCHANGED',reason:'Preserve the committed deterministic restart contract.'}));
const shared=[
 {signal:'ss_freeze',bits:1,role:'Post-T guest hold; raw overflow freeze; remain asserted through complete sequential apply.'},
 {signal:'ss_regs_set / vdp2_regs_set',bits:2,role:'Architectural register install and evaluator WAITING/count0/index0 normalization; serialized fields already installed privately.'},
 {signal:'has_restart / sprite_valid',bits:1,role:'Version-presence and deterministic legacy zero selection; remains in controller, removed from full-width receiver choice when sequential generic true.'},
 {signal:'sprite_second / sprite_word',bits:8,role:'Existing two-bank/75-word transport indexing; same external addresses.'},
 {signal:'System E ownership',bits:1,role:'Word02f bit2; absent second payload zero and inactive second VDP not modified.'},
 {signal:'video_state_in/set',bits:23,role:'Existing post-T beam install, acknowledged phase/release; unchanged.'},
 {signal:'private CPU memory-address ownership',bits:null,role:'Existing 14/15-bit address muxes and no guest writes during replay; unchanged.'},
 {signal:'evaluator state/count/index',bits:16,role:'Not serialized by the existing accepted-boundary proof; all three live declarations remain and normalize at original strobe.'}
];
fs.writeFileSync(p.join(d,'inventory.json'),JSON.stringify({perVDPBits:4778,VDPs:2,historicalBits:9556,paddedTransportBits:9600,paddingBits:44,rows,map,g10,shared,attribution:{measured:{neededDelta:8051,placedDelta:5458,synthesisFFDelta:9603,fittedFFDelta:11171,controllerSynthesisFFDelta:9601,logicALUTDelta:5818,routingALUTDelta:5399,packingGapDelta:-2593},inferred:'9600 snapshot FF explain almost all mapped FF growth; broad scratch transfer/restore selection and high-fanout controls are principal structural targets.',unknown:'No additive isolated ALM decomposition for version decode, fanout, routing, live restore and global remapping. Packing improved in aggregate; degradation is not the dominant measured cause.'}},null,2)+'\n');
console.log({groups:rows.length,perVDPBits:rows.reduce((n,r)=>n+r.totalBits,0),portRows:map.length,G10Groups:g10.length,sharedGroups:shared.length});
