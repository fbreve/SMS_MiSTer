# Controlled ablations

Each variant starts from exact full restoration, suppresses only the listed writes, leaves capture/readback and the 100-word file contract intact, and receives the identical snapshot. The bench independently reads every word after capture and after restore. The full instance must equal the saved image; every omitted candidate word must equal its pre-restore stale value, and every other word must equal the saved image. This is readback verification through the RTL interface, not an independent internal packing oracle.

- attack: omit 91-92.
- sine: omit 98-99.
- operator: omit 96-97.
- writeback: omit 79-79.
- output_history: omit 58-75.
- feedback: omit 49-57.

Additional negative controls omit phase RAM, envelope RAM, controller, individual envelope writeback/work, PM/writeback, PG output, PG key/noise, AM and noise groups. No combined macro-only variant is qualified or inferred from these individual tests. No transport/legacy/version code changes are required for the ablation harness.
