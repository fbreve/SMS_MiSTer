seed | variant | neededALMs | placedALMs | fittedRegisters | mappedRegisters | MLABcells | MLABbits | M10K | setupSlack | holdSlack | setupTNS | holdTNS | warnings | critical | outcome
--- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | ---
1 | v17_104w | 27438 | 32465 | 36049 | 34942 | 0 | 0 | 489 | -0.173 | 0.168 | -3.97 | 0 | 68 | 39 | timing_failure
1 | b1 | 27009 | 31932 | 35560 | 34737 | 20 | 380 | 489 | 0.438 | 0.241 | 0 | 0 | 67 | 38 | timing_pass
1 | c1 | 27274 | 32333 | 35789 | 34731 | 20 | 380 | 489 | 0.566 | 0.245 | 0 | 0 | 67 | 38 | timing_pass
2 | v17_104w | 27421 | 32490 | 36112 | 34942 | 0 | 0 | 489 | 0.367 | 0.244 | 0 | 0 | 67 | 38 | timing_pass
2 | b1 | 27061 | 31830 | 35469 | 34737 | 20 | 380 | 489 | 0.344 | 0.076 | 0 | 0 | 67 | 38 | timing_pass
2 | c1 | 27237 | 32122 | 35812 | 34731 | 20 | 380 | 489 | 0.52 | 0.225 | 0 | 0 | 67 | 38 | timing_pass
3 | v17_104w | 27445 | 32453 | 36044 | 34942 | 0 | 0 | 489 | 0.002 | 0.17 | 0 | 0 | 67 | 38 | timing_pass
3 | b1 | 26953 | 31907 | 35503 | 34737 | 20 | 380 | 489 | -0.036 | 0.245 | -0.044 | 0 | 68 | 39 | timing_failure
3 | c1 | 27258 | 32244 | 35829 | 34731 | 20 | 380 | 489 | 0.43 | 0.242 | 0 | 0 | 67 | 38 | timing_pass
average | baseline | 26417.333 | 31432.667 | 35366.667 | 34461.000 | 0.000 | 0.000 | 488.000 | 0.483 | 0.229 | 0.000 | 0.000 |  |  | 
average | v17_104w | 27434.667 | 32469.333 | 36068.333 | 34942.000 | 0.000 | 0.000 | 489.000 | 0.065 | 0.194 | -1.323 | 0.000 |  |  | 
average | b1 | 27007.667 | 31889.667 | 35510.667 | 34737.000 | 20.000 | 380.000 | 489.000 | 0.249 | 0.187 | -0.015 | 0.000 |  |  | 
average | c1 | 27256.333 | 32233.000 | 35810.000 | 34731.000 | 20.000 | 380.000 | 489.000 | 0.505 | 0.237 | 0.000 | 0.000 |  |  | 

setupTNS/holdTNS = worst clock-group TNS; DistinctGroups = sum over reported groups; units ns. Timing qualification covers constrained paths only.

Critical paths and complete warning text are preserved in study_results.json. Averages for B1/C1 require all three completed builds.
