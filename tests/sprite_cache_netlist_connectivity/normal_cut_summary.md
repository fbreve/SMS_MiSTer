# Shared normal-data cut nodes

IDs are netlist-local `(atom,output-port)` identities; these nodes use output port0. Exact raw masks and input bindings are in connectivity.json. X bit0 is the already-shared VRAM read output, with inversion combined into each required terminal restore mux. Other entries are shared X/d3 data logic. Fitter pin permutations can change masks.

|Owner|Field|Bit|Map ID|Map fanout|Slots checked|Fit location|Fit fanout|Direct fitted FF sinks checked|Unresolved bridge sinks|
|---|---|---:|---:|---:|---:|---|---:|---:|---:|
|vdp_inst|x|0|57297|280|64|MLABCELL_X25_Y47_N57|285|70|0|
|vdp_inst|x|1|57424|64|64|MLABCELL_X21_Y51_N42|64|71|0|
|vdp_inst|x|2|57557|64|64|MLABCELL_X21_Y51_N45|64|67|0|
|vdp_inst|x|3|57651|64|64|MLABCELL_X21_Y51_N39|64|68|0|
|vdp_inst|x|4|57789|64|64|MLABCELL_X21_Y51_N57|64|69|0|
|vdp_inst|x|5|57870|64|64|MLABCELL_X21_Y51_N54|64|65|0|
|vdp_inst|x|6|57957|64|64|MLABCELL_X21_Y51_N24|64|68|0|
|vdp_inst|x|7|58036|64|64|MLABCELL_X21_Y51_N36|64|68|0|
|vdp_inst|d3|0|60009|64|64|MLABCELL_X25_Y42_N15|64|68|0|
|vdp_inst|d3|1|60071|64|64|LABCELL_X29_Y44_N57|64|66|0|
|vdp_inst|d3|2|60118|64|64|LABCELL_X31_Y43_N3|64|68|0|
|vdp_inst|d3|3|60160|64|64|LABCELL_X31_Y43_N45|64|66|1|
|vdp_inst|d3|4|60224|64|64|LABCELL_X31_Y43_N39|64|70|0|
|vdp_inst|d3|5|60318|64|64|LABCELL_X29_Y44_N15|64|64|0|
|vdp_inst|d3|6|60376|64|64|LABCELL_X30_Y43_N9|64|65|0|
|vdp_inst|d3|7|60472|64|64|MLABCELL_X28_Y47_N27|64|68|0|
|vdp2_inst|x|0|57287|280|64|LABCELL_X22_Y33_N3|283|67|0|
|vdp2_inst|x|1|57420|64|64|LABCELL_X22_Y18_N54|64|73|0|
|vdp2_inst|x|2|57554|64|64|LABCELL_X22_Y18_N39|64|71|0|
|vdp2_inst|x|3|57648|64|64|MLABCELL_X21_Y18_N24|64|73|0|
|vdp2_inst|x|4|57786|64|64|MLABCELL_X21_Y18_N57|64|67|0|
|vdp2_inst|x|5|57867|64|64|LABCELL_X22_Y18_N30|64|74|0|
|vdp2_inst|x|6|57954|64|64|LABCELL_X22_Y18_N18|64|69|0|
|vdp2_inst|x|7|58033|64|64|LABCELL_X22_Y18_N48|64|66|0|
|vdp2_inst|d3|0|60005|64|64|LABCELL_X33_Y24_N6|64|63|0|
|vdp2_inst|d3|1|60069|64|64|LABCELL_X36_Y22_N33|64|66|0|
|vdp2_inst|d3|2|60116|64|64|LABCELL_X37_Y24_N57|64|66|0|
|vdp2_inst|d3|3|60158|64|64|LABCELL_X36_Y25_N42|64|70|0|
|vdp2_inst|d3|4|60222|64|64|MLABCELL_X25_Y24_N27|64|70|0|
|vdp2_inst|d3|5|60316|64|64|LABCELL_X36_Y22_N54|64|70|0|
|vdp2_inst|d3|6|60374|64|64|LABCELL_X36_Y22_N57|64|66|0|
|vdp2_inst|d3|7|60470|64|64|LABCELL_X29_Y23_N48|64|67|0|
