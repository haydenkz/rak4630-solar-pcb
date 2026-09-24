#!/usr/bin/env bash
# Deterministic check + fabrication-output script for meshcore-solar (JLCPCB).
# usage: scripts/export.sh [review|fab]   (run from anywhere; outputs go to build/)
#   review (default): run ERC/DRC and write review-only outputs to build/llm-review/
#   fab:              refuse unless ERC/DRC are clean or OVERRIDE=1 is set; writes build/fab/
set -uo pipefail
cd "$(dirname "$0")/.."
KICAD_CLI="${KICAD_CLI:-kicad-cli}"   # override with KICAD_CLI=/path/to/kicad-cli
P=meshcore-solar
MODE="${1:-review}"
OUT=build/llm-review; [ "$MODE" = fab ] && OUT=build/fab
mkdir -p "$OUT/gerbers"
CONVERT="${CONVERT:-$(dirname "$0")/convert_position.py}"
k() { "$KICAD_CLI" "$@" 2> >(grep -v Fontconfig >&2); }

k version
k sch erc --output "$OUT/$P-erc.rpt" --format report --units mm \
    --severity-warning --severity-error --exit-code-violations $P.kicad_sch; ERC=$?
k pcb drc --output "$OUT/$P-drc.rpt" --format report --units mm \
    --severity-warning --severity-error --refill-zones --schematic-parity \
    --exit-code-violations $P.kicad_pcb; DRC=$?
echo "ERC exit=$ERC DRC exit=$DRC"
if [ "$MODE" = fab ] && { [ $ERC -ne 0 ] || [ $DRC -ne 0 ]; } && [ "${OVERRIDE:-0}" != 1 ]; then
    echo "FAILURE: ERC/DRC violations present. Re-run with OVERRIDE=1 to export anyway."; exit 1
fi

LAYERS=F.Cu,B.Cu,F.Paste,B.Paste,F.SilkS,B.SilkS,F.Mask,B.Mask,Edge.Cuts
k pcb export gerbers --output "$OUT/gerbers" --layers "$LAYERS" \
    --crossout-DNP-footprints-on-fab-layers --sketch-DNP-footprints-on-fab-layers \
    --subtract-soldermask --precision 5 $P.kicad_pcb
k pcb export drill --output "$OUT/gerbers/" --format excellon --drill-origin absolute \
    --excellon-units mm --excellon-zeros-format decimal --excellon-separate-th \
    --generate-map --map-format gerberx2 --gerber-precision 5 $P.kicad_pcb
k pcb export pos --output "$OUT/positions_raw.csv" --format csv --units mm \
    --side both --exclude-dnp $P.kicad_pcb
python3 "$CONVERT" "$OUT/positions_raw.csv" "$OUT/positions_JLCPCB.csv"
# JLCPCB columns (project has no JLCPCB BOM preset; fields are spelled out here)
k sch export bom --output "$OUT/bom_JLCPCB.csv" \
    --fields 'Value,Reference,Footprint,LCSC,${QUANTITY},${DNP}' \
    --labels 'Comment,Designator,Footprint,LCSC,Qty,DNP' \
    --group-by 'Value,Footprint,LCSC' --sort-field Reference --exclude-dnp $P.kicad_sch
k sch export bom --output "$OUT/components.csv" \
    --fields 'Reference,Value,Footprint,LCSC,Part,Manufacturer,${EXCLUDE_FROM_BOM},${DNP}' \
    --sort-field Reference $P.kicad_sch
k sch export pdf --output "$OUT/schematic.pdf" $P.kicad_sch
k pcb render --output "$OUT/top.png" --width 1280 --height 1600 --quality basic --side top $P.kicad_pcb
k pcb render --output "$OUT/bottom.png" --width 1280 --height 1600 --quality basic --side bottom $P.kicad_pcb
if [ "$MODE" = fab ]; then (cd "$OUT/gerbers" && zip -q ../${P}_gerbers.zip *); fi
echo "done -> $OUT"
