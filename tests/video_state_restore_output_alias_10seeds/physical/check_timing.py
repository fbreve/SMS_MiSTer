import json

with open("tests/video_state_restore_output_alias_10seeds/physical/summary_results.json") as f:
    d = json.load(f)

for s in d["seeds"]:
    print(f"=== Seed {s['seed']} ===")
    for clk, val in s["candidate"]["clock_slacks"].items():
        base_slack = s["baseline"]["clock_slacks"].get(clk, {}).get("slack", None)
        short_clk = clk.replace("pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk", "HDMI_CLK")
        short_clk = short_clk.replace("emu|pll|pll_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk", "CORE_CLK")
        print(f"  {short_clk}: Cand={val['slack']:+.3f} ns | Base={base_slack:+.3f} ns (TNS={val['tns']:.3f})")

