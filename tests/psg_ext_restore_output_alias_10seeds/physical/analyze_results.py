import os, sys, math, json
from parse_run import parse_run

def mean(vals):
    return sum(vals) / len(vals) if vals else 0.0

def median(vals):
    if not vals:
        return 0.0
    s = sorted(vals)
    n = len(s)
    if n % 2 == 1:
        return s[n // 2]
    return (s[n // 2 - 1] + s[n // 2]) / 2.0

def stddev(vals):
    if len(vals) < 2:
        return 0.0
    m = mean(vals)
    variance = sum((x - m) ** 2 for x in vals) / (len(vals) - 1)
    return math.sqrt(variance)

def main():
    runs_dir = os.path.join(os.path.dirname(__file__), 'runs')
    seeds = range(1, 11)

    print(f"{'Seed':<5} | {'Placed Baseline':<15} | {'Placed Candidate':<16} | {'Delta ALMs':<10} | {'Delta ALUT':<10} | {'Delta FF':<10} | {'Delta Route':<11} | {'Setup Cand (ns)':<15} | {'TNS Cand'}")
    print("=" * 115)

    delta_placed = []
    delta_needed = []
    delta_aluts = []
    delta_ffs = []
    delta_route = []
    cand_setup_slacks = []
    cand_tns_list = []
    details = []

    for s in seeds:
        b_dir = os.path.join(runs_dir, f"baseline_s{s}")
        c_dir = os.path.join(runs_dir, f"candidate_s{s}")

        b_res = parse_run(b_dir)
        c_res = parse_run(c_dir)

        if b_res['placed_alms'] is None or c_res['placed_alms'] is None:
            print(f"Seed {s:2d} | INCOMPLETE (waiting for builds)")
            continue

        d_placed = c_res['placed_alms'] - b_res['placed_alms']
        d_needed = c_res['needed_alms'] - b_res['needed_alms']
        d_alut = c_res['logic_aluts'] - b_res['logic_aluts']
        d_ff = c_res['ffs'] - b_res['ffs']
        d_route = c_res['routing_aluts'] - b_res['routing_aluts']

        delta_placed.append(d_placed)
        delta_needed.append(d_needed)
        delta_aluts.append(d_alut)
        delta_ffs.append(d_ff)
        delta_route.append(d_route)
        cand_setup_slacks.append(c_res['setup_slack'])
        cand_tns_list.append(c_res['tns'])

        details.append({
            'seed': s,
            'baseline': b_res,
            'candidate': c_res,
            'delta_placed': d_placed,
            'delta_needed': d_needed,
            'delta_alut': d_alut,
            'delta_ff': d_ff,
            'delta_route': d_route
        })

        print(f"{s:<5} | {b_res['placed_alms']:<15.1f} | {c_res['placed_alms']:<16.1f} | {d_placed:<+10.1f} | {d_alut:<+10d} | {d_ff:<+10d} | {d_route:<+11d} | {c_res['setup_slack']:<+15.3f} | {c_res['tns']:.3f}")

    print("=" * 115)

    n = len(delta_placed)
    if n == 0:
        print("No completed seeds to analyze.")
        return

    mean_dp = mean(delta_placed)
    median_dp = median(delta_placed)
    std_dp = stddev(delta_placed)

    # 95% Confidence Interval (t-distribution approximation)
    # For n=10, df=9, t_crit=2.262
    t_crit = 2.262 if n == 10 else (2.0 if n > 1 else 0.0)
    margin_error = t_crit * (std_dp / math.sqrt(n)) if n > 1 else 0.0
    ci_lower = mean_dp - margin_error
    ci_upper = mean_dp + margin_error

    print(f"\nSTATISTICAL SUMMARY ACROSS {n} SEEDS:")
    print(f"Placed ALMs Delta Mean:          {mean_dp:+.2f}")
    print(f"Placed ALMs Delta Median:        {median_dp:+.2f}")
    print(f"Placed ALMs Delta StdDev:        {std_dp:.2f}")
    print(f"95% Confidence Interval:         [{ci_lower:+.2f}, {ci_upper:+.2f}] ALMs")
    print(f"Logic ALUTs Delta Mean:          {mean(delta_aluts):+.2f}")
    print(f"Registers (FF) Delta Mean:       {mean(delta_ffs):+.2f}")
    print(f"Routing ALUTs Delta Mean:        {mean(delta_route):+.2f}")
    print(f"Worst Candidate Setup Slack:     {min(cand_setup_slacks):+.3f} ns")
    print(f"Total Negative Slack (TNS):      {sum(cand_tns_list):.3f} ns")

    summary_data = {
        'n_seeds': n,
        'mean_delta_placed': mean_dp,
        'median_delta_placed': median_dp,
        'std_delta_placed': std_dp,
        'ci_95': [ci_lower, ci_upper],
        'mean_delta_aluts': float(mean(delta_aluts)),
        'mean_delta_ffs': float(mean(delta_ffs)),
        'mean_delta_route': float(mean(delta_route)),
        'min_setup_slack': min(cand_setup_slacks),
        'total_tns': sum(cand_tns_list),
        'seeds': details
    }
    with open(os.path.join(os.path.dirname(__file__), 'summary_results.json'), 'w') as f:
        json.dump(summary_data, f, indent=2)

if __name__ == '__main__':
    main()
