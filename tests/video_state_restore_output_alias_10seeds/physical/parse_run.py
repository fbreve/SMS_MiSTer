import os, sys, re, glob, json

def parse_run(run_dir):
    fit_rpt = os.path.join(run_dir, 'output_files', 'SMS.fit.rpt')
    sta_rpt = os.path.join(run_dir, 'output_files', 'SMS.sta.rpt')
    
    res = {
        'placed_alms': None,
        'needed_alms': None,
        'ffs': None,
        'logic_aluts': None,
        'routing_aluts': None,
        'm10k': None,
        'setup_slack': None,
        'hold_slack': None,
        'tns': 0.0,
        'clock_slacks': {}
    }
    
    if os.path.exists(fit_rpt):
        with open(fit_rpt, 'r', errors='ignore') as f:
            text = f.read()
            
        m = re.search(r'Logic utilization \(in ALMs\)\s*;\s*([0-9,.]+)\s*/', text)
        if m:
            res['placed_alms'] = float(m.group(1).replace(',', ''))
            
        m = re.search(r';\s*ALMs needed \[=A-B\+C\]\s*;\s*([0-9,.]+)\s*;', text)
        if m:
            res['needed_alms'] = float(m.group(1).replace(',', ''))
            
        m = re.search(r'Dedicated logic registers\s*;\s*([0-9,]+)', text)
        if m:
            res['ffs'] = int(m.group(1).replace(',', ''))
            
        m = re.search(r'Combinational ALUT usage for logic\s*;\s*([0-9,]+)', text)
        if m:
            res['logic_aluts'] = int(m.group(1).replace(',', ''))
            
        m = re.search(r'Combinational ALUT usage for route-throughs\s*;\s*([0-9,]+)', text)
        if m:
            res['routing_aluts'] = int(m.group(1).replace(',', ''))
            
        m = re.search(r'Total RAM Blocks\s*;\s*([0-9,]+)\s*/', text)
        if m:
            res['m10k'] = int(m.group(1).replace(',', ''))
            
    if os.path.exists(sta_rpt):
        with open(sta_rpt, 'r', errors='ignore') as f:
            sta_text = f.read()
            
        m = re.search(r'Worst-case setup slack is\s+([-\d.]+)', sta_text)
        if m:
            res['setup_slack'] = float(m.group(1))
            
        m = re.search(r'Worst-case hold slack is\s+([-\d.]+)', sta_text)
        if m:
            res['hold_slack'] = float(m.group(1))
            
        # Parse clock-by-clock setup slacks
        m_tbl = re.search(r'Worst-case setup slack is.*?Clock\s*\n\s*Info \(332119\):\s*=========.*?\n(.*?)(?:Info \(332146\)|Info \(332102\)|$)', sta_text, re.DOTALL)
        if m_tbl:
            lines = m_tbl.group(1).strip().split('\n')
            for line in lines:
                parts = line.split()
                if len(parts) >= 4 and parts[0] == 'Info' and parts[1] == '(332119):':
                    try:
                        slack = float(parts[2])
                        tns = float(parts[3])
                        clk = parts[4]
                        res['clock_slacks'][clk] = {'slack': slack, 'tns': tns}
                        if tns < 0:
                            res['tns'] += tns
                    except ValueError:
                        pass
                        
    return res

if __name__ == '__main__':
    if len(sys.argv) > 1:
        print(json.dumps(parse_run(sys.argv[1]), indent=2))

