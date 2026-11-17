import os
from parse_run import parse_run

runs_dir = "tests/psg_ext_restore_output_alias_10seeds/physical/runs"
for s in range(1, 11):
    c_res = parse_run(os.path.join(runs_dir, f"candidate_s{s}"))
    b_res = parse_run(os.path.join(runs_dir, f"baseline_s{s}"))
    print(f"Seed {s:2d}: Cand Setup = {c_res['setup_slack']:+.3f} ns | Base Setup = {b_res['setup_slack']:+.3f} ns | Cand Hold = {c_res['hold_slack']:+.3f} ns (TNS={c_res['tns']:.3f})")

