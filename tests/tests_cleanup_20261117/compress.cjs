const fs=require('fs'),path=require('path'),zlib=require('zlib'),{pipeline}=require('stream/promises'),s=require('../artifact-store.cjs');
const removed=new Set(require('./deletions.json').map(f=>f.path)),inventory=require('./inventory_before.json'),compact=process.argv.includes('compact-small');
const candidates=inventory.filter(f=>!removed.has(f.path)&&!f.symlink&&f.status!=='tracked'&&!f.path.startsWith('tests/worktree_cleanup_20261117/')&&!f.path.startsWith('tests/tests_cleanup_20261117/')&&!/\/tools\//.test(f.path)&&(
 (/\/(db|incremental_db)\//.test(f.path)&&f.bytes>=1024)||
 (f.bytes>=(compact?64*1024:1024*1024)&&/\.(log|rpt|dat|bin|csv|hex|vo|txt|trace|ppm|mem|tsv|sof|tar)$/i.test(f.path))||
 (compact&&f.bytes>=8*1024*1024&&f.extension==='.json')));
fs.writeFileSync(path.join(__dirname,'compression_plan.json'),JSON.stringify(candidates,null,2));
(async()=>{fs.mkdirSync(s.store,{recursive:true});const done=new Set(s.records().map(r=>r.path)),cached=new Map(s.records().map(r=>[r.sha256,r]));let count=0,saved=0;for(const f of candidates){if(done.has(f.path))continue;const full=s.safe(f.path);if(!fs.existsSync(full))throw Error('Missing candidate '+f.path);if(fs.statSync(full).size!==f.bytes)throw Error('Changed file '+f.path);const sha256=s.hash(full),archive=path.join(s.store,sha256+'.gz');let archiveSha256;
if(cached.has(sha256)){archiveSha256=cached.get(sha256).archiveSha256;if(s.hash(archive)!==archiveSha256)throw Error('Changed existing archive');}
else{const tmp=archive+'.partial';
// Interrupted runs can leave only a derived partial; the original has just
// been checked and hashed, so discarding this partial cannot lose evidence.
if(fs.existsSync(tmp))fs.unlinkSync(tmp);
if(fs.existsSync(archive)){if(await s.verifyGzip(archive,sha256)!==f.bytes)throw Error('Orphan archive mismatch');archiveSha256=s.hash(archive);}
else if(f.bytes<4*1024*1024){const data=fs.readFileSync(full),packed=zlib.gzipSync(data,{level:6});if(packed.length>=f.bytes-128)continue;const restored=zlib.gunzipSync(packed);if(!restored.equals(data))throw Error('Small-file roundtrip mismatch');fs.writeFileSync(tmp,packed,{flag:'wx'});archiveSha256=s.hash(tmp);fs.renameSync(tmp,archive);}
else{await pipeline(fs.createReadStream(full),zlib.createGzip({level:6}),fs.createWriteStream(tmp,{flags:'wx'}));if(fs.statSync(tmp).size>=f.bytes-128){fs.unlinkSync(tmp);continue;}if(await s.verifyGzip(tmp,sha256)!==f.bytes)throw Error('Roundtrip size mismatch');archiveSha256=s.hash(tmp);fs.renameSync(tmp,archive);}
cached.set(sha256,{archiveSha256});}
const record={path:f.path,bytes:f.bytes,sha256,archive:path.relative(s.root,archive).replaceAll('\\','/'),archiveBytes:fs.statSync(archive).size,archiveSha256,category:/\/(db|incremental_db)\//.test(f.path)?'exact-fitted-database':f.extension==='.tar'?'source-archive':'scientific-raw-or-report',verified:true};
// Persist the recovery mapping before deleting its original.
fs.appendFileSync(path.join(__dirname,'compression.jsonl'),JSON.stringify(record)+'\n');fs.unlinkSync(full);count++;saved+=f.bytes-record.archiveBytes;if(count%200===0)console.log('Archived',count,'files; logical per-file saving',saved);}
console.log('Archived this pass:',count,'files');})();
