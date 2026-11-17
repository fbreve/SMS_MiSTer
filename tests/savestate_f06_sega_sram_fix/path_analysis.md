PASS. The paired seed1 build has no failing timing-summary category or routing failure. No confirmation build was needed.

- v17 worst setup: +0.105 ns, `shadowmask:HDMI_shadowmask|dout[20]` → `osd:hdmi_osd|nrdout1[20]` ([path report](baseline_paths_setup.rpt)).
- v18 worst setup: +0.366 ns, `ascal:ascal|o_vacpt[5]` → `ascal:ascal|o_vpixq_pre[2].r[3]` ([path report](early_paths_setup.rpt)).
- v17 worst hold: +0.206 ns, `ascal:ascal|o_poly_phase_b.t1[8]` → `ascal:ascal|o_poly_phase_b2.t1[8]` ([path report](baseline_paths_hold.rpt)).
- v18 worst hold: +0.234 ns, `emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\shifters:31:shifter|shift0[6]` → `emu:emu|system:system|vdp:vdp2_inst|vdp_main:vdp_main_inst|vdp_sprites:vdp_spr_inst|vpd_sprite_shifter:\shifters:31:shifter|shift0[7]` ([path report](early_paths_hold.rpt)).
- v17 emulation-clock worst setup: +0.635 ns, `emu:emu|sdram:ram|sd_dat[8]` → `emu:emu|system:system|T80s:z80_inst|T80:u0|IR[4]` ([path report](baseline_emu_setup.rpt)).
- v18 emulation-clock worst setup: +0.983 ns, `emu:emu|ce_cpu` → `emu:emu|sdram:ram|q[0]` ([path report](early_emu_setup.rpt)).

The new global worst setup path remains in the unchanged HDMI/scaler framework. The emulation-clock minimum improves by +0.348 ns. These endpoint changes and positive margins provide no evidence of structural critical-path growth from F06. The source-only input manifest proves that the framework, CPU, VDP and audio RTL were unchanged. Realized slack changes include global placement/routing effects; a single paired build does not measure an intrinsic timing benefit from the extra flag. Existing partially unconstrained setup/hold coverage remains unchanged. Detailed reports use the Slow 1100 mV 100 C model; the complete multi-corner STA summary is retained in the build outputs.
