# Format history evidence

Classification is bounded to the live official/fork repository evidence captured in network_evidence.json. Master membership is separately tested from public release membership. The release/source association is STRONGLY SUPPORTED, without a reproducible-build attestation of the binary.

| Format | Commit/date | Fields and reader change | Master | Public release |
|---|---|---|---|---|
|untagged64|[077545e0](https://github.com/MiSTer-devel/SMS_MiSTer/commit/077545e09bdbcb98b777fcd5dafd01b7af3810ad), 2026-05-28T09:25:31+08:00|212-bit CPU,56-bit PSG,64KiB slot, SMS1 magic|yes|[SMS_20260603.rbf](https://github.com/MiSTer-devel/SMS_MiSTer/blob/4d364780502d1c5d212ad06962a44341c3bbfeaf/releases/SMS_20260603.rbf), blob b592ff3cf2d2a1321ef4428c768b00d7200824fa|
|untagged96|[8f3bcb2b](https://github.com/MiSTer-devel/SMS_MiSTer/commit/8f3bcb2bb7129139940cfbb18cc66f5ef139bd1f), 2026-06-13T11:28:35+08:00|230-bit CPU,96KiB slot,gameID,SystemE second device,IO/video; August release also64-bit EEPROM wrapper|yes|[SMS_20260823.rbf](https://github.com/MiSTer-devel/SMS_MiSTer/blob/3ae7eec9cc2a9e02f824771e2e5652f5992ed906/releases/SMS_20260823.rbf), blob 26632aabd2f9db6b1f593f460e0701eb2591acce|
|v1|60c6552afdbc87dd6f7f3ccfbab14ee41be7195e, 2026-10-20T10:11:07-03:00|two8-bit HCounter latches, word01a; tagHC01/subtype0; reader extends presence/tag membership and retains deterministic older fallback|no|no; not ancestor of either release, nor any of56live branch/tag refs|
|v2|02838b753751530576045c3c15cbfafa684c5f6e, 2026-10-20T11:21:31-03:00|GG temporal114bits in128-bit container at01c..01d; subtype2; reader extends presence/tag membership and retains deterministic older fallback|no|no; not ancestor of either release, nor any of56live branch/tag refs|
|v3|e090434c449d77c506b9c46548399da4ab76d119, 2026-10-20T12:17:53-03:00|MD6 two-port46bits,01e; common subtype3; reader extends presence/tag membership and retains deterministic older fallback|no|no; not ancestor of either release, nor any of56live branch/tag refs|
|v4|b0f4b710d1d182635a59c238a6a0341bf3d8ba7c, 2026-10-20T13:13:55-03:00|EEPROM128-bit temporal extension, descriptors and128-byte contents; legacy64-bit wrapper retained; reader extends presence/tag membership and retains deterministic older fallback|no|no; not ancestor of either release, nor any of56live branch/tag refs|
|v5|e4a1ac90a5beed09218cb9720af16ae39445a6e1, 2026-10-20T15:17:08-03:00|SC RAM2/16/32KiB footprint and SCR5 descriptor; reader extends presence/tag membership and retains deterministic older fallback|no|no; not ancestor of either release, nor any of56live branch/tag refs|
|v6|52fb7496aeeaf2227e332194e06ec2cdfcf43932, 2026-10-20T16:26:13-03:00|MasterTap19bits,MTAP descriptor; reader extends presence/tag membership and retains deterministic older fallback|no|no; not ancestor of either release, nor any of56live branch/tag refs|
|v7|77147af4b1c0657d99bfaa840bcb17ad0be5d658, 2026-10-20T17:21:56-03:00|paddle32bits,PAD7 descriptor; reader extends presence/tag membership and retains deterministic older fallback|no|no; not ancestor of either release, nor any of56live branch/tag refs|
|v8|dcbe06d5527f96d3fb172472aaed44c3845a1e43, 2026-10-21T11:00:37-03:00|lightgun46bits plus owner descriptor; reader extends presence/tag membership and retains deterministic older fallback|no|no; not ancestor of either release, nor any of56live branch/tag refs|
|v8 (no bump)|b61f307dcb161a6ac9a70fd544d435436807191d, 2026-10-21T13:42:04-03:00|Fix System E pause handling during savestates; behavioral ordering correction, no new format|no|no; not ancestor of either release, nor any of56live branch/tag refs|
|v9|eede89d01a6441906dbbda237865a0cbc761d830, 2026-10-21T15:35:17-03:00|mapper detection18bits,history descriptor; reader extends presence/tag membership and retains deterministic older fallback|no|no; not ancestor of either release, nor any of56live branch/tag refs|
|v10|ff9d66b79c20f90cea53d5fd78ae8f8021462a53, 2026-10-21T22:48:25-03:00|Evolution selector/history57bits; reader extends presence/tag membership and retains deterministic older fallback|no|no; not ancestor of either release, nor any of56live branch/tag refs|
|v11|d1df5902e4e671ed0cb87e770b43b15da53a3a92, 2026-10-22T07:30:02-03:00|Evolution pending6bits across existing fields; EV11 width60 descriptor; reader extends presence/tag membership and retains deterministic older fallback|no|no; not ancestor of either release, nor any of56live branch/tag refs|
|v12|faf7036e4450027f79cc639a731053dca29840ca, 2026-10-22T11:57:05-03:00|normalized CPU NMI3bits atword5[40:38]; reader extends presence/tag membership and retains deterministic older fallback|no|no; not ancestor of either release, nor any of56live branch/tag refs|
|v13|8ffd15e2a7e530c0d77b07c6eeae3e8dc0aa0c8a, 2026-10-22T20:17:38-03:00|CPU instruction-restart3bits atword5[43:41]; reader extends presence/tag membership and retains deterministic older fallback|no|no; not ancestor of either release, nor any of56live branch/tag refs|
|v14|58583189b5c650dc6658ef467e8dcb72d9f6e6c2, 2026-10-23T22:25:46-03:00|two4778-bit sprite records,2-bit phase,accepted-tick flag; deterministic restart contract; reader extends presence/tag membership and retains deterministic older fallback|no|no; not ancestor of either release, nor any of56live branch/tag refs|
|v15|f205b05dc058fc5f7f2432779b61e8f3b0e22519, 2026-10-24T15:13:41-03:00|two139-bit background records; reader extends presence/tag membership and retains deterministic older fallback|no|no; not ancestor of either release, nor any of56live branch/tag refs|
|v16|08cf1426bfd2e1f2a73fdb25aaf57715d408db11, 2026-10-24T22:41:33-03:00|historical AudioMix phase bit; coherent pending PSG tick handling uses existing restart/divider state; reader extends presence/tag membership and retains deterministic older fallback|no|no; not ancestor of either release, nor any of56live branch/tag refs|
|v16 (no bump)|cb2e8615128d61adb996ada68e6bbdcc314c20f6, 2026-10-25T16:59:36-03:00|Fix ROM request restart across savestates; behavioral ordering correction, no new format|no|no; not ancestor of either release, nor any of56live branch/tag refs|
|v17|7fcd5e12847eedf9e97a44dc937c3dbac3205f7c, 2026-10-26T13:31:53-03:00|OPLL104x32=3328stored bits (1896meaningful),FMS1 descriptor and52DDR words; reader extends presence/tag membership and retains deterministic older fallback|no|no; not ancestor of either release, nor any of56live branch/tag refs|

## Untagged history before v1

- 077545e09bdbcb98b777fcd5dafd01b7af3810ad|2026-05-28T09:25:31+08:00|Implement savestates and enhance detection for Zemina/Nemesis (#191)
- 8f3bcb2bb7129139940cfbb18cc66f5ef139bd1f|2026-06-13T11:28:35+08:00|SaveStates and Pause for System-E, enhanced SaveStates for SMS (#192)
- 11ff6379c939acc2952180538b650842b49b3891|2026-07-04T22:34:42+08:00|Fix loading of pre-#192 save states (#195)
- 9dfc10739f35b13987ba54afc2f88fb4662ee511|2026-08-15T04:57:37+08:00|Refine Codemasters mapper handling and add Game Gear EEPROM support (#199)
- 0f768a858698ab4e680fab8ba15682ad5858d8a3|2026-09-09T11:08:30-03:00|Add Master System Evolution support
- 19fedb6cfeaddf15380823c203c4d9738bde6e7a|2026-10-05T16:50:35+08:00|Refactor savestate transfers and fix controller/RAM issues (#216)
- ce5a63c6ca473a6913a31a87286b6203adc3f391|2026-10-06T16:29:07+08:00|Remove dead savestate FSM states (#217)
- 998d8aa6f17499c913c2df64d858f76b7a5d8d4a|2026-10-08T09:36:14-03:00|Fix savestate DDRAM transaction handshake
- a196cf113e0d36a9ec11c2c39a2c5142b1e0ea3f|2026-10-08T09:36:59-03:00|Preserve PSG state across savestates

The untagged96 family evolved on master after the August release, including Evolution and PSGX1. This experiment retains the existing untagged reader, the PSGX presence/validation path, and both public size layouts. It does not assert that every untagged master state was a release. The only intentionally rejected formats are the16 numbered development tags HC01..HC10.

## Git proof

Both live master refs are8443a0d19a88aff7a5900011bccf386daf146945. The latest official releases/ directory contains SMS_20260823.rbf and no newer binary. GitHub Releases API is empty, which is not evidence that the checked-in binaries were unreleased. Six live annotated fork tags peel to May/June commits; upstream has no tags namespace. All56 live refs were resolved locally and checked with git merge-base --is-ancestor for all19 commits in the development series; every result was false. No conclusion relies solely on local branch names.
