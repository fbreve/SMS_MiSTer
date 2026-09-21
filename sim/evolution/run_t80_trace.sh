#!/bin/sh
set -eu
GHDL="${GHDL:-ghdl}"
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)"
cd "$ROOT"
for f in rtl/T80/T80_ALU.vhd rtl/T80/T80_MCode.vhd rtl/T80/T80_Reg.vhd rtl/T80/T80.vhd rtl/T80/T80s.vhd; do
  "$GHDL" -a --std=08 "$f"
done
"$GHDL" -a --std=08 rtl/evolution_mapper.vhd
"$GHDL" -a --std=08 sim/evolution/evolution_t80_bios_trace_tb.vhd
"$GHDL" -e --std=08 evolution_t80_bios_trace_tb
"$GHDL" -r --std=08 evolution_t80_bios_trace_tb \
  -gBIOS_FILE="$1" -gFLASH_FILE="$2" -gMAX_CYCLES="${3:-2000000}" \
  --assert-level=error
