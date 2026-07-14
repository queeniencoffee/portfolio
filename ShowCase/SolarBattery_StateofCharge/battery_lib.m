function B = battery_lib()
%BATTERY_LIB  Li-ion battery: OCV, 2nd-order ECM, charge control, aging.
%
%   B = battery_lib() returns function handles:
%     B.init(C)                         -> battery state struct
%     B.ocv(C,soc)                      -> open-circuit voltage per cell [V]
%     B.params(C,soc,T_C,fade)          -> [R0,R1,C1,R2,C2] per cell
%     B.capacity(C,st)                  -> present cell capacity [Ah]
%     B.step(C,B,st,I_pack,dt,T_C)      -> electrical + aging update
%     B.charge_current(C,B,st,T_C,mode) -> commanded pack charge current [A]
%     B.miner_damage(C,DOD)             -> incremental Miner damage per cycle
%
%   SIGN CONVENTION:  I_pack > 0 = DISCHARGE, I_pack < 0 = CHARGE.
%
%   Electrical model (per cell):
%       V = OCV(SOC) - I*R0 - V1 - V2
%       dV1/dt = I/C1 - V1/(R1*C1)          (backward-Euler, unconditionally stable)
%       dV2/dt = I/C2 - V2/(R2*C2)
%       dSOC/dt = -I / (3600 * Q_now)
%
%   Aging model (state-shifted so it is path-independent and monotonic):
%       Q_cal = k_cal*exp(-Ea_cal/(Rg*T))*exp(a_soc*SOC) * t_eff^p_cal
%       Q_cyc = k_cyc*exp(-Ea_cyc/(Rg*T))*exp(b_c*Crate) * Ah_eff^p_cyc
%   At each step the "effective" time / throughput is back-solved from the
%   accumulated damage under the CURRENT stress factor, incremented, and the
%   damage recomputed.  This is the standard approach for a semi-empirical
%   fade law under time-varying stress (equivalent to the Simscape Battery
%   lookup-table aging blocks, but continuous rather than table-driven).
%
%   Resistance growth is coupled to total fade:
%       R0 = R0_BOL * (1 + kR * fade/fade_EOL)

B.init            = @init;
B.ocv             = @ocv;
B.params          = @params;
B.capacity        = @capacity;
B.step            = @step;
B.charge_current  = @charge_current;
B.miner_damage    = @miner_damage;
B.pack_voltage    = @pack_voltage;
end

% -------------------------------------------------------------------------
function st = init(C)
st.soc      = C.bat.soc0;
st.V1       = 0;          % RC1 overpotential, per cell [V]
st.V2       = 0;          % RC2 overpotential, per cell [V]
st.V_cell   = ocv(C, C.bat.soc0);
st.V_pack   = st.V_cell * C.bat.Ns;
st.I_cell   = 0;
st.fade_cal = 0;          % calendar capacity fade [fraction]
st.fade_cyc = 0;          % cycling  capacity fade [fraction]
st.t_eff    = 0;          % effective calendar time [days]
st.Ah_eff   = 0;          % effective cell throughput [Ah]
st.Ah_thru  = 0;          % true cell throughput (discharge only) [Ah]
st.R0_mult  = 1;          % resistance growth multiplier
st.D_miner  = 0;          % Miner's-rule damage (0..1)
st.n_cycles = 0;          % eclipse (discharge) cycles counted
end

function v = ocv(C, soc)
soc = min(max(soc,0),1);
v = interp1(C.bat.ocv_soc, C.bat.ocv_v, soc, 'pchip');
end

function Q = capacity(C, st)
Q = C.bat.Q_cell * (1 - st.fade_cal - st.fade_cyc);   % present cell capacity [Ah]
end

function Vp = pack_voltage(C, st)
Vp = st.V_cell * C.bat.Ns;
end

function [R0,R1,Cap1,R2,Cap2] = params(C, soc, T_C, st)
% Mild SOC dependence (resistance rises at the SOC extremes), Arrhenius in T,
% and a growth term proportional to accumulated capacity fade.
k_soc = 1 + 0.35*exp(-soc/0.10) + 0.15*exp(-(1-soc)/0.08);
T_K   = T_C + 273.15;
k_T   = exp( C.bat.Ea_R_over_Rg * (1/T_K - 1/293.15) );
k_age = st.R0_mult;

R0   = C.bat.R0 * k_soc * k_T * k_age;
R1   = C.bat.R1 * k_soc * k_T * k_age;
R2   = C.bat.R2 * k_soc * k_T * k_age;
Cap1 = C.bat.tau1 / R1;
Cap2 = C.bat.tau2 / R2;
end

% ------------------------------------------------------------------ dynamics
function st = step(C, B, st, I_pack, dt, T_C)
%STEP  One integration step of the electrical + aging states.
Np = C.bat.Np;
I_cell = I_pack / Np;                                  % + = discharge
[R0,R1,Cap1,R2,Cap2] = params(C, st.soc, T_C, st);

% RC branches (backward Euler)
st.V1 = (st.V1 + dt*I_cell/Cap1) / (1 + dt/(R1*Cap1));
st.V2 = (st.V2 + dt*I_cell/Cap2) / (1 + dt/(R2*Cap2));

% Coulomb counting on the PRESENT (faded) capacity
Q_now  = max(capacity(C, st), 1e-3);
st.soc = st.soc - I_cell*dt/(3600*Q_now);
st.soc = min(max(st.soc, 0), 1);

% Terminal voltage
st.V_cell = ocv(C, st.soc) - I_cell*R0 - st.V1 - st.V2;
st.V_pack = st.V_cell * C.bat.Ns;
st.I_cell = I_cell;

% Aging
st = aging_step(C, st, dt, T_C, I_cell);
end

function st = aging_step(C, st, dt, T_C, I_cell)
A  = C.age;
T_K = T_C + 273.15;
Q_nom = C.bat.Q_cell;

% ---- calendar fade (state-shift on effective time) ----
f_cal = A.k_cal * exp(-A.Ea_cal/(A.Rg*T_K)) * exp(A.a_soc * st.soc);
if f_cal > 0
    t_eff = (max(st.fade_cal,0)/f_cal)^(1/A.p_cal);       % back-solve
    t_eff = t_eff + dt/86400;                             % advance [days]
    st.fade_cal = f_cal * t_eff^A.p_cal;
    st.t_eff = t_eff;
end

% ---- cycling fade (state-shift on effective Ah throughput) ----
c_rate = abs(I_cell)/Q_nom;
if c_rate > 1e-4
    f_cyc = A.k_cyc * exp(-A.Ea_cyc/(A.Rg*T_K)) * exp(A.b_c * c_rate);
    Ah_eff = (max(st.fade_cyc,0)/f_cyc)^(1/A.p_cyc);
    Ah_eff = Ah_eff + abs(I_cell)*dt/3600;
    st.fade_cyc = f_cyc * Ah_eff^A.p_cyc;
    st.Ah_eff   = Ah_eff;
end
if I_cell > 0
    st.Ah_thru = st.Ah_thru + I_cell*dt/3600;             % discharge throughput
end

% ---- resistance growth coupled to total fade ----
fade = st.fade_cal + st.fade_cyc;
st.R0_mult = 1 + C.bat.kR_fade * fade / C.age.fade_eol;
end

% ------------------------------------------------------- charge controller
function I_chg = charge_current(C, B, st, T_C, season)
%CHARGE_CURRENT  Commanded PACK charge current [A] (positive = charging).
%   Proportional voltage controller with CC saturation.  Large voltage error
%   -> saturates at the CC limit; as the cell approaches the setpoint the
%   current tapers automatically, reproducing a CC-CV profile without an
%   explicit mode switch.
%   season = 'eclipse' (full charge to V_cell_max) or 'solstice' (reduced-
%   voltage storage at V_store, standard GEO practice to limit calendar fade).
switch lower(season)
    case 'solstice', V_set = C.bat.V_store;
    otherwise,       V_set = C.bat.V_cell_max;
end
I_cc  = C.bat.C_rate_chg * C.bat.Q_cell * C.bat.Np;      % pack CC limit [A]
err   = V_set - st.V_cell;
I_chg = C.bat.Kp_chg * err * C.bat.Np;                   % [A] at pack level
I_chg = min(max(I_chg, 0), I_cc);
if st.soc >= 0.9999, I_chg = 0; end
end

% ------------------------------------------------------------ Miner's rule
function dD = miner_damage(C, DOD)
%MINER_DAMAGE  Incremental damage of one discharge cycle of depth DOD.
%   N_fail(DOD) = N0 * DOD^(-m)   ->   dD = DOD^m / N0
DOD = min(max(DOD,0),1);
dD  = DOD^C.age.m / C.age.N0;
end
