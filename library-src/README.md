Generator sources for project-local library parts.

`battery_holder.yaml` and `battery_holder_cq_parameters.yaml` define the MYOUNG
BH-18650-B1BA002 (LCSC C2988620) footprint and 3D model for the `battery`
generator in https://gitlab.com/kicad/libraries/kicad-library-tools .
Copy them into `data/battery/` of that repo and run:

    python -m generators.generate -g battery --part "BatteryHolder_MYOUNG*" \
        --output-dir-footprints out --output-dir-models out3d

Then point the footprint's model path at `${KIPRJMOD}/meshcore-solar.3dshapes/`.
