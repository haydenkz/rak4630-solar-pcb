# rak4630-solar-pcb

Solar-powered MeshCore node PCB built around the **RAK4630-8-SM-I** (nRF52840 + SX1262 LoRa) module.

## Features
- RAK4630-8-SM-I LoRa / MCU module
- Dual-input Li-ion charging (USB-C and solar) via SGM41513 with power-path management
- SMT 18650 battery holder (MYOUNG BH-18650-B1BA002, LCSC C2988620) with NTC temperature sensing
- 3.3 V LDO rail (XC6206P332)
- Hardware low-voltage cutoff (MCP65R41 + TPS22917): switches the node off below ~3.30 V battery and back on above ~3.73 V; no firmware involvement. USB power always overrides it (D3), so the RAK can be flashed over USB with no cell or a flat one. JP1 bypasses it for bench use without USB or a cell.
- SWD programming / test points

## Files
| File | Description |
|------|-------------|
| `meshcore-solar.kicad_pro` | KiCad project |
| `meshcore-solar.kicad_sch` | Schematic |
| `meshcore-solar.kicad_pcb` | PCB layout |
| `meshcore-solar.pretty/`, `meshcore-solar.3dshapes/` | Project-local footprint (18650 holder) and 3D models |
| `library-src/` | Generator sources for the holder footprint / 3D model |
| `scripts/export.sh` | ERC/DRC + JLCPCB outputs (`review` or `fab` mode) into `build/` |

## Requirements
- KiCad 10 (file format `generator_version 10.0`)
- Symbols and footprints are embedded in the design files. The battery holder footprint and 3D model live in the project library (`meshcore-solar.pretty`, `meshcore-solar.3dshapes`); their generator sources are in `library-src/`.

## Notes
- Solar panel connects to the PH2.0 `SOLAR IN` connector (P1) → SGM41513 `VAC`.
- No MPPT; the solar input feeds the charger's input-regulation loop directly.
