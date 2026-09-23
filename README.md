# rak4630-solar-pcb

Solar-powered MeshCore node PCB built around the **RAK4630-8-SM-I** (nRF52840 + SX1262 LoRa) module.

## Features
- RAK4630-8-SM-I LoRa / MCU module
- Dual-input Li-ion charging (USB-C and solar) via SGM41513 with power-path management
- 18650 battery holder with NTC temperature sensing
- 3.3 V LDO rail (XC6206P332)
- SWD programming / test points

## Files
| File | Description |
|------|-------------|
| `meshcore-solar.kicad_pro` | KiCad project |
| `meshcore-solar.kicad_sch` | Schematic |
| `meshcore-solar.kicad_pcb` | PCB layout |

## Requirements
- KiCad 10 (file format `generator_version 10.0`)
- Symbols and footprints are embedded in the design files; 3D models are not bundled.

## Notes
- Solar panel connects to the PH2.0 `SOLAR IN` connector (P1) → SGM41513 `VAC`.
- No MPPT; the solar input feeds the charger's input-regulation loop directly.
