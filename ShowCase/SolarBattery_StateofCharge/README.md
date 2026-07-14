# GEO Spacecraft Power Model — MATLAB

Physics-based EPS model for a ~5.5 kW GEO spacecraft: solar-array generation, battery
cycling and aging, and load consumption across all operational modes, over a 15-year life.

```
>> run_geo_eps_model
```

No toolboxes required (base MATLAB only, R2018b+). Runtime ~30–90 s.

---

## 1. Files

| File | Role |
|---|---|
| `eps_config.m` | **Single source of truth.** Every number in the model lives here. |
| `geo_lib.m` | GEO geometry: β angle, umbra/penumbra timing, solar flux, SADA cosine loss |
| `solar_lib.m` | Triple-junction GaAs array: IV curve, temperature, radiation/UV degradation, DET vs MPPT |
| `battery_lib.m` | Li-ion: OCV, 2nd-order Thevenin ECM, CC-CV charge controller, calendar + cycle aging |
| `sim_orbit.m` | One sidereal day at 1 Hz with the S3R/BCR/BDR bus manager |
| `sim_mission.m` | 15 years: every eclipse cycle integrated, solstice days advanced analytically |
| `run_geo_eps_model.m` | Driver: power budget, BOL/EOL orbits, aging run, verification, 6 figures |

## 2. Reference design

| | |
|---|---|
| Orbit | GEO, circular, i≈0°, sidereal period 86164 s |
| Bus | 100 V regulated, S3R (DET) primary power, BCR/BDR battery interface |
| Array | 3G30C-class TJ GaAs, 50s × 176 strings, 8800 cells, **24.1 m²** |
| Battery | Li-ion **24s2p**, 60 Ah cells → 120 Ah, 87.6 V nom, **10.5 kWh** BOL |
| Loads | NOMINAL 5.47 kW · PEAK_TX 6.57 kW · ECLIPSE 4.55 kW · STATIONKEEP 6.52 kW · SAFE 1.25 kW |
| Life | 15 yr, ~91 eclipses/yr, **1361 cycles** simulated |

## 3. Key model equations

**Eclipse (cylindrical umbra, circular orbit):**

`T_ecl = T_orb/180 · acosd[ √(r² − R_E²) / (r·cos β) ]`

For GEO this gives a **69.4 min** maximum eclipse and an eclipse only when |β| < **8.70°** —
i.e. two ~45-day seasons per year straddling the equinoxes. Both are reproduced by the
model and printed as verification checks.

**Solar cell (empirical exponential IV fit, "Green" form):**

`I(V) = Isc·[1 − C1·(exp(V/(C2·Voc)) − 1)]`, with `C2 = (Vmp/Voc − 1)/ln(1 − Imp/Isc)`

Cheaper than the implicit single-diode equation and accurate through the knee. Under **DET/S3R
the array is clamped to the bus, so it operates at `I(V_bus/Ns)`, not at the MPP** — set
`C.sa.regulation = 'MPPT'` to compare.

**Battery (2nd-order Thevenin, per cell, backward Euler):**

`V = OCV(SOC) − I·R0 − V1 − V2`,  `dSOC/dt = −I/(3600·Q_now)`

Sign convention: **I > 0 = discharge.** R0/R1/R2 carry a mild SOC dependence, an Arrhenius
temperature term, and a growth term coupled to accumulated fade.

**Aging (semi-empirical, state-shifted):**

```
Q_cal = k_cal·exp(−Ea_cal/RT)·exp(a·SOC) · t_eff^0.75
Q_cyc = k_cyc·exp(−Ea_cyc/RT)·exp(b·C_rate) · Ah_eff^0.55
R0(t) = R0_BOL · (1 + 0.60·fade/fade_EOL)
```

At each step the *effective* time / throughput is back-solved from the accumulated damage under
the **current** stress, incremented, and the damage recomputed. This keeps the fade law monotonic
and path-independent under time-varying stress — the continuous analogue of the
`Battery Equivalent Circuit` block's `Lookup Tables (temperature and current dependent)` aging
option in Simscape Battery.

An **independent cross-check** runs in parallel: a Wöhler DOD curve `N_fail = N0·DOD^−m` with
Miner's rule accumulation.

## 4. Results the model produces

| Metric | BOL | EOL (15 yr) |
|---|---|---|
| Max eclipse duration | 69.4 min | 69.4 min |
| Array power to bus (hot, sun-pointed) | 8.91 kW | 7.37 kW |
| Worst-case DOD | **52.2 %** | **67.0 %** (limit 75 %) |
| Min cell voltage in eclipse | 3.67 V | 3.55 V (cutoff 3.00 V) |
| Peak discharge current | 56 A (0.47 C) | 58 A |
| Capacity fade | — | **20.1 %** (calendar 12.0 + cycling 8.0) |
| R0 growth | — | **×1.60** |
| Throughput | — | 568 equivalent full cycles |

Figures:

1. **Worst-case eclipse orbit** — array capability, bus load, shunt, battery I, cell V, SOC,
   array temperature and mode timeline; BOL vs EOL overlaid.
2. **Battery cycle detail** — cell voltage vs cycle time, pack current vs cycle time, SOC vs
   cycle time, spanning eclipse discharge → CC recharge → CV taper → float.
3. **Eclipse season** — β angle, eclipse duration, and the triangular DOD-per-eclipse profile.
4. **Aging** — calendar/cycling fade split, retention vs equivalent full cycles, R0 growth,
   Miner damage, and DOD creep as capacity fades.
5. **Margins** — load by mode against array capability; energy margin on the worst eclipse of
   each year.
6. **Array IV/PV** — BOL/EOL × hot/cold, with the bus voltage line showing the S3R operating
   point (a cold post-eclipse array sits far left of the knee).

## 5. Things worth knowing before you trust it

**Calibration.** `k_cal`, `k_cyc`, `N0`, `m` and the OCV table are **placeholders tuned to hit a
20 % fade / 80 % retention requirement at 15 years**. They are not vendor data. Fit them to
cell-level test data before using this for a real trade:

- The **voltage-relaxation** approach (Zhu et al., *Data-driven capacity estimation from voltage
  relaxation*) is directly usable here — features extracted from the relaxation curve after each
  eclipse discharge give you a per-cycle capacity estimate to regress `k_cal`/`k_cyc` against,
  and the same relaxation data pins down the OCV table and R0 growth.
- The **bi-variate cubic-spline** formulation (non-linear charge-based storage optimisation) is
  the natural upgrade if you want to replace the exponential/power-law fade surface with a spline
  fitted over (SOC, C-rate) — the state-shift machinery in `battery_lib.aging_step` doesn't care
  what functional form `f_cal`/`f_cyc` take.

**The two aging models disagree.** The semi-empirical law predicts 20 % fade; Miner's rule with
`N0=1000, m=2` predicts D = 0.33 (i.e. ~7 % fade equivalent). That spread of ~3× is real and is
the single largest uncertainty in the battery sizing. Resolve it with test data — don't average them.

**Known simplifications.**
- Cylindrical shadow with a linear penumbra ramp; no atmospheric refraction/penumbra photometry.
- Equatorial orbit, so β = solar declination. For an inclined or drifting GEO, replace
  `geo_lib.beta_angle` with a proper sun-vector · orbit-normal dot product.
- Single lumped battery thermal node held at 20 °C. A real GEO battery swings a few degrees
  through the eclipse; wire `C.bat.T_C` to a thermal model if fade sensitivity to T matters.
- Cell-to-cell imbalance, string failure/bypass, and BMS balancing are not modelled.
- Array degradation uses lumped annual factors; replace with SPENVIS/EQFLUX 1 MeV-equivalent
  fluence remaining-power factors for a real design.

**Verification checks** printed at every run: max eclipse 69.4 min, β cutoff 8.70°,
~91 eclipse days/yr, energy-balance residual ≈ 0 (`E_gen + η_bdr·E_dis = E_load + E_chg/η_bcr`),
EOL DOD vs limit, EOL cell voltage vs cutoff, EOL energy margin > 0.

## 6. Migrating to Simscape Battery

If you have the licence, `battery_lib` maps onto the `Battery Equivalent Circuit` block:
set **Cycling Aging Model** to `Lookup Tables (temperature and current dependent)` and supply
`CapacityChange(N,T,I)` as a 3-D array (cycles × temperature × current). Generate the table by
sweeping this model's `aging_step` — or better, straight from cell test data. Keep this model as
the fast trade-space tool and use Simscape for the detailed sign-off run.
