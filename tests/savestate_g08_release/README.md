# G08.release investigation

Run `powershell -ExecutionPolicy Bypass -File tests/savestate_g08_release/run.ps1 -Prepare`
from the repository root. Requires Node and ModelSim 17.0 at the paths in the
runner. No Quartus, production edit or proposed fix is included.

This is a defect characterizer: the final audit requires the observed exact
reference differences and zero raw-PSG/clock mismatches. PASS CHARACTERIZED
means the experiment completed, not that savestate audio is correct.

The fixture derives from the retained current-v15 F12 known-register fixture.
It uses actual T80, actual video, actual two JT89s, current v15 controller with
the retained declaration-order adapter and TB_FAST flush option, and unchanged
production AudioMix. Other endpoints are known mock state. The first PSG alone
feeds the mixer (equivalent to disabling PSG2 contribution with psg_enables).
Production signed scaling is exact. FM input is literal zero.

The separate reference has its own never-rephased divider, CPU, PSG and mixer.
It executes the same prefix P, with identical reset/write timing. At accepted
T the DUT freezes but the reference continues. Its next 20,000 host-clock
outputs, PSG state/output and divider phase form an immutable offline oracle.
Replay compares k0 on the FIRST rising clock after phase/beam release to the
reference T+1. No four-clock grace period, dropped sample, time shift or
tolerance is used. Transport/reconstruction is outside logical time.

Mixers have no RTL reset. Test startup seeds their exposed phase-restore ports
to zero during reset, then releases those ports for the complete prefix P.
No CPU/PSG/mixer historical register is forced at capture/release. DDR contents
start known zero, including unwritten/preserved reserved bytes. PSG bus writes
are legal wr_n transactions from the fixture, not ROM-driven IO; the CPU
supplies the natural accepted instruction boundary. UI cooldown alone is
forced off to repeat requests. Q writes change attenuation/period between
LOADs. The production 255-clock settlement and private CPU replay remain;
TB_FAST removes only the 900,000-clock LOAD flush, which cannot repair phase
selection made from the saved descriptor.

The source adapter only reorders existing declarations and optionally exposes
the test-only flush parameter. CPU observation copies are inherited from the
v15 known-register sanity fixture; production T80 is unchanged. Production
AudioMix and JT89 are compiled directly from the repository.

`TARGET` is an exploratory storage-eligibility delay; it is zero in all final
evidence. Early target pilots were stopped when their overly constrained
conditions did not admit capture; they do not count as completed tests. Initial
DC-only pilots missed the first configuration write because last_wr had not
settled after reset. Two idle clocks and a fail-closed tone0==6 check correct
that. Those pilots and tone_dut/replay preliminary characterizers are retained
as diagnostics, excluded from final case counts. Final known-image runs are
final_reference, final_replay and final_stalls only.

Per the requested stop rule, the confirmed mixer release defect ends the
investigation after causal characterization. The noise/dual-routing/stereo/
Pause/full natural-phase matrix is deferred to the separately authorized fix
task, not silently claimed as passing.
