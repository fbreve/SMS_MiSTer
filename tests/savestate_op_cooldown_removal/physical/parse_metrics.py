import os, glob, re

def parse_fit_rpt(path):
    metrics = {
        'alm_used': None,
        'alut_comb': None,
        'regs': None,
        'route_alut': None,
        'worst_fmax': None
    }
    if not os.path.exists(path):
        return metrics
    with open(path, 'r', errors='ignore') as f:
        text = f.read()

    # Placed ALMs: Logic utilization (in ALMs) ; 22,590.1 / 41,910 ( 54 % )
    # Or "|emu:emu| ; ... ; [A] ALMs used in final placement"
    # Core top level:
    m = re.search(r'Logic utilization \(in ALMs\)\s*;\s*([0-9,.]+)\s*/', text)
    if m:
        metrics['alm_used'] = float(m.group(1).replace(',', ''))

    m = re.search(r'Combinational ALUT usage for logic\s*;\s*([0-9,]+)', text)
    if m:
        metrics['alut_comb'] = int(m.group(1).replace(',', ''))

    m = re.search(r'Dedicated logic registers\s*;\s*([0-9,]+)', text)
    if m:
        metrics['regs'] = int(m.group(1).replace(',', ''))

    m = re.search(r'Combinational ALUT usage for routing\s*;\s*([0-9,]+)', text)
    if m:
        metrics['route_alut'] = int(m.group(1).replace(',', ''))

    return metrics

def parse_sta_rpt(path):
    if not os.path.exists(path):
        return None
    with open(path, 'r', errors='ignore') as f:
        text = f.read()
    # Find worst fmax in Slow 1100mV 85C Model Fmax Summary
    fmaxs = re.findall(r'([0-9.]+)\s+MHz', text)
    if fmaxs:
        # minimum non-zero
        vals = [float(v) for v in fmaxs if float(v) > 10.0]
        if vals:
            return min(vals)
    return None

def main():
    base_dir = 'tests/savestate_op_cooldown_removal/physical/runs'
    seeds = [1, 2, 3]
    print(f"{'Run':<15} | {'ALMs Used':<10} | {'ALUTs Comb':<10} | {'Registers':<10} | {'Route ALUT':<10}")
    print("-" * 65)

    diffs = []
    for s in seeds:
        b_name = f"baseline_s{s}"
        c_name = f"candidate_s{s}"
        b_rpt = os.path.join(base_dir, b_name, 'output_files', 'SMS.fit.rpt')
        c_rpt = os.path.join(base_dir, c_name, 'output_files', 'SMS.fit.rpt')

        b_met = parse_fit_rpt(b_rpt)
        c_met = parse_fit_rpt(c_rpt)

        b_alm = b_met['alm_used'] if b_met['alm_used'] is not None else 0
        c_alm = c_met['alm_used'] if c_met['alm_used'] is not None else 0
        b_lut = b_met['alut_comb'] if b_met['alut_comb'] is not None else 0
        c_lut = c_met['alut_comb'] if c_met['alut_comb'] is not None else 0
        b_reg = b_met['regs'] if b_met['regs'] is not None else 0
        c_reg = c_met['regs'] if c_met['regs'] is not None else 0
        b_rt  = b_met['route_alut'] if b_met['route_alut'] is not None else 0
        c_rt  = c_met['route_alut'] if c_met['route_alut'] is not None else 0

        print(f"{b_name:<15} | {b_alm:<10.1f} | {b_lut:<10} | {b_reg:<10} | {b_rt:<10}")
        print(f"{c_name:<15} | {c_alm:<10.1f} | {c_lut:<10} | {c_reg:<10} | {c_rt:<10}")
        if b_alm > 0 and c_alm > 0:
            diff_alm = c_alm - b_alm
            diff_lut = c_lut - b_lut
            diff_reg = c_reg - b_reg
            diff_rt  = c_rt - b_rt
            diffs.append(diff_alm)
            print(f"{'Delta s' + str(s):<15} | {diff_alm:<+10.1f} | {diff_lut:<+10} | {diff_reg:<+10} | {diff_rt:<+10}")
        print("-" * 65)

    if diffs:
        avg_diff = sum(diffs) / len(diffs)
        print(f"Average ALM Delta: {avg_diff:+.2f} Placed ALMs across {len(diffs)} seeds.")

if __name__ == '__main__':
    main()

