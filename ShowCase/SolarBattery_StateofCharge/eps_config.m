function C = eps_config()
%EPS_CONFIG  Single source of truth for the GEO spacecraft power model.
%
%   All sizing, environment, solar-array, battery, power-electronics and
%   load parameters live here.  Nothing else in the model hard-codes a number.
%
%   Reference design: ~5.5 kW GEO comms/USSF-class bus, 15-year design life,
%   100 V regulated bus, S3R (Sequential Switching Shunt Regulator) primary
%   power, BCR/BDR battery interface, 24s2p Li-ion (NMC/LCO) battery.
%
%   Author: EPS model, 2026.

% ------------------------------------------------------------------ mission
C.mission.life_yr        = 15;          % design life [yr]
C.mission.epoch_doy      = 80;          % start day-of-year (vernal equinox)
C.mission.worstcase_doy  = 80;          % day used for the worst-case orbit sim

% -------------------------------------------------------------- environment
C.env.S_ref     = 1353;        % AM0 reference irradiance for cell data [W/m^2]
C.env.S_1AU     = 1361;        % solar constant at 1 AU [W/m^2]
C.env.ecc_earth = 0.0167;      % Earth orbit eccentricity (flux +/-3.4%/yr)
C.env.T_orb     = 86164.09;    % GEO (sidereal) period [s]
C.env.R_E       = 6378.137;    % Earth equatorial radius [km]
C.env.r_geo     = 42164.17;    % GEO radius [km]
C.env.obliquity = 23.44;       % ecliptic obliquity [deg]
C.env.t_penumbra= 130;         % penumbra transit time each side [s]

% -------------------------------------------------------------- solar array
% Cell: Azur Space 3G30C-class triple-junction GaInP/GaAs/Ge, 30.18 cm^2,
% BOL values quoted at AM0 = 1353 W/m^2, 28 degC.
C.sa.cell.A_cm2   = 30.18;
C.sa.cell.T_ref   = 28;        % [degC]
C.sa.cell.Isc     = 0.5202;    % [A]
C.sa.cell.Voc     = 2.700;     % [V]
C.sa.cell.Imp     = 0.5024;    % [A]
C.sa.cell.Vmp     = 2.411;     % [V]
C.sa.cell.dIsc_dT = +0.36e-3;  % [A/K]
C.sa.cell.dImp_dT = +0.28e-3;  % [A/K]
C.sa.cell.dVoc_dT = -6.2e-3;   % [V/K]
C.sa.cell.dVmp_dT = -6.7e-3;   % [V/K]
C.sa.cell.nVt     = 0.090;     % irradiance-voltage coefficient, n*Vt [V]

C.sa.Ns          = 50;         % cells in series per string  -> Vmp ~ 120 V @28C
C.sa.Np          = 176;        % strings (88 per wing, 2 wings)
C.sa.f_pack      = 0.97;       % assembly/wiring/mismatch/diode losses
C.sa.f_harness   = 0.98;       % SA harness + slip-ring loss to the bus
C.sa.point_err   = 1.5;        % SADA pointing error [deg]
C.sa.regulation  = 'DET';      % 'DET' (S3R at bus voltage) or 'MPPT'

% Array thermal (first-order lumped node)
C.sa.T_sun       = 62;         % steady-state sunlit temperature [degC]
C.sa.T_eclipse   = -100;       % steady-state eclipse temperature [degC]
C.sa.tau_cool    = 400;        % cool-down time constant [s]
C.sa.tau_heat    = 700;        % warm-up time constant [s]

% Degradation (replace with EQFLUX/SPENVIS remaining-factor curves when available)
C.sa.deg_year1   = 0.025;      % 1st-year loss: radiation + UV + contamination
C.sa.deg_annual  = 0.010;      % subsequent annual radiation loss
C.sa.deg_V_eol   = 0.020;      % EOL voltage (Vmp/Voc) loss fraction
C.sa.string_fail = 0.02;       % cumulative string failures by EOL

% ------------------------------------------------------------------ battery
% Cell: 60 Ah / 3.65 V nominal space Li-ion (Saft VES-class).
C.bat.Ns        = 24;          % series cells   -> 87.6 V nom, 98.4 V @4.10 V/cell
C.bat.Np        = 2;           % parallel strings -> 120 Ah, 10.5 kWh BOL
C.bat.Q_cell    = 60;          % nameplate cell capacity [Ah]
C.bat.V_cell_max= 4.10;        % charge (CV) setpoint [V]
C.bat.V_cell_min= 3.00;        % discharge cut-off [V]
C.bat.V_store   = 3.90;        % reduced-voltage storage setpoint, solstice [V]
C.bat.soc0      = 0.95;        % initial SOC (= SOC at the 4.10 V/cell CV limit)
C.bat.T_C       = 20;          % battery baseplate temperature [degC]
C.bat.C_rate_chg= 0.10;        % CC charge rate [C]  -> 6 A/cell, 12 A pack
C.bat.Kp_chg    = 150;         % charge-controller gain [A per V per cell]
C.bat.I_taper   = 0.01;        % end-of-charge taper threshold [C]
C.bat.DOD_max   = 0.75;        % max allowable DOD at EOL (design constraint)

% Equivalent-circuit (2nd-order Thevenin), per cell, @20 degC, mid-SOC
C.bat.R0        = 1.10e-3;     % ohmic resistance [ohm]
C.bat.R1        = 0.60e-3;     % [ohm]
C.bat.tau1      = 30;          % [s]
C.bat.R2        = 0.90e-3;     % [ohm]
C.bat.tau2      = 600;         % [s]
C.bat.Ea_R_over_Rg = 2000;     % Arrhenius coefficient for resistance [K]
C.bat.kR_fade   = 0.60;        % R0 growth per 20% capacity fade (i.e. +60% @EOL)

% OCV table (per cell) -- REPLACE with pseudo-OCV / relaxation-fit vendor data
C.bat.ocv_soc = [0 0.05 0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 0.95 1.00];
C.bat.ocv_v   = [3.00 3.35 3.50 3.60 3.66 3.70 3.75 3.82 3.90 3.99 4.06 4.10 4.15];

% ---- Aging model (semi-empirical, Arrhenius + power law) -----------------
% Calendar:  Qcal = k_cal*exp(-Ea_cal/(Rg*T))*exp(a_soc*SOC) * t_days^p_cal
% Cycling :  Qcyc = k_cyc*exp(-Ea_cyc/(Rg*T))*exp(b_c*Crate) * Ah_thr^p_cyc
% Constants below are CALIBRATED PLACEHOLDERS that reproduce ~20% fade at
% 15 yr GEO.  Fit them to cell-level test data (see README).
C.age.Rg      = 8.314;
C.age.k_cal   = 2.06;    C.age.Ea_cal = 24500;  C.age.a_soc = 1.00;  C.age.p_cal = 0.75;
C.age.k_cyc   = 0.56;    C.age.Ea_cyc = 20000;  C.age.b_c   = 0.50;  C.age.p_cyc = 0.55;
C.age.fade_eol= 0.20;    % capacity fade that defines EOL (80% retention)

% Independent cross-check model: DOD-based Wohler curve + Miner's rule
% N_fail(DOD) = N0 * DOD^(-m)
C.age.N0 = 1000;   C.age.m = 2.0;

% -------------------------------------------------- power electronics / bus
C.bus.V         = 100;         % regulated bus voltage [V]
C.bus.eta_bcr   = 0.96;        % battery charge regulator efficiency
C.bus.eta_bdr   = 0.95;        % battery discharge regulator efficiency
C.bus.eta_dist  = 0.97;        % PCDU distribution + harness efficiency
C.bus.P_shunt_max = 12000;     % S3R shunt capability [W]

% ---------------------------------------------------------- load definition
% Component breakdown per operational mode [W].
% Columns: payload | TT&C | ADCS | thermal | propulsion | bus/housekeeping
C.load.names = {'NOMINAL','PEAK_TX','ECLIPSE','STATIONKEEP','MOMENTUM_DUMP','SAFE'};
C.load.table = [ ...
%   payload  ttc   adcs  thermal  prop   bus
     3800,   150,  250,   550,      0,   720;   % NOMINAL
     4900,   150,  250,   550,      0,   720;   % PEAK_TX (high-power transmit)
     2400,   150,  250,  1100,      0,   650;   % ECLIPSE (heaters on, payload derated)
     3000,   150,  600,   550,   1500,   720;   % STATIONKEEP (EP thruster + PPU)
     3800,   150,  550,   550,      0,   720;   % MOMENTUM_DUMP
      200,   150,  250,   500,      0,   150];  % SAFE
C.load.comp_names = {'Payload','TT&C','ADCS','Thermal','Propulsion','Bus'};

% Nominal 24 h mode timeline (orbit time measured from local solar NOON).
% Eclipse (centred at T_orb/2) overrides the entry with 'ECLIPSE'.
C.load.timeline = { ...
    0.0,   6.0,  'NOMINAL';        ...
    6.0,   6.75, 'STATIONKEEP';    ...   % 45 min EP N-S burn
    6.75,  8.0,  'NOMINAL';        ...
    8.0,   9.5,  'PEAK_TX';        ...   % 90 min high-power transmit
    9.5,  11.5,  'NOMINAL';        ...
   11.5,  12.5,  'NOMINAL';        ...   % eclipse falls inside this window
   12.5,  18.0,  'NOMINAL';        ...
   18.0,  18.25, 'MOMENTUM_DUMP';  ...
   18.25, 23.94, 'NOMINAL'};

end
