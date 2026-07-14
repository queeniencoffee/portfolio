function S = solar_lib()
%SOLAR_LIB  Triple-junction GaAs solar array model for a GEO spacecraft.
%
%   S = solar_lib() returns function handles:
%     S.cell_point(C,flux,T_C,age_yr)      -> Isc,Voc,Imp,Vmp (degraded cell)
%     S.iv_curve(C,flux,T_C,age_yr,Vbus)   -> [V,I,P] array-level IV/PV curve
%     S.array_power(C,Vbus,flux,T_C,age_yr)-> [P_bus, I_array, P_mp]
%     S.array_temp(T_prev,illum,dt,C)      -> array temperature integration
%     S.degradation(age_yr,C)              -> [fI, fV] current/voltage factors
%
%   Electrical model: empirical exponential ("Green") IV fit, which reproduces
%   the knee of a multi-junction cell to within a few percent and is far
%   cheaper than solving the implicit single-diode equation every time step.
%
%       I(V) = Isc * [ 1 - C1*( exp(V/(C2*Voc)) - 1 ) ]
%       C2   = (Vmp/Voc - 1) / ln(1 - Imp/Isc)
%       C1   = (1 - Imp/Isc) * exp( -Vmp/(C2*Voc) )
%
%   Regulation:
%     'DET'  - Direct Energy Transfer / S3R.  The array is clamped to the bus
%              voltage, so the operating point is I(V_bus/Ns), NOT the MPP.
%              A cold array (post-eclipse) sits far left of the knee and
%              delivers ~Isc; a hot EOL array can fall below the knee.
%     'MPPT' - array delivers Pmp (minus conversion losses).

S.cell_point   = @cell_point;
S.iv_curve     = @iv_curve;
S.array_power  = @array_power;
S.array_temp   = @array_temp;
S.degradation  = @degradation;
end

% -------------------------------------------------------------------------
function [fI, fV] = degradation(age_yr, C)
%DEGRADATION  Cumulative BOL->EOL derating factors on current and voltage.
% Sources lumped here: 1 MeV-equivalent electron/proton fluence, UV darkening
% of the coverglass, contamination, thermal cycling, micrometeoroid, and
% random string failures.  Replace with SPENVIS/EQFLUX remaining-power factors.
y  = max(age_yr, 0);
f1 = (1 - C.sa.deg_year1)^min(y,1);
f2 = (1 - C.sa.deg_annual)^max(y-1,0);
f_str = 1 - C.sa.string_fail * min(y,C.mission.life_yr)/C.mission.life_yr;
fI = f1 * f2 * f_str;
fV = 1 - C.sa.deg_V_eol * min(y,C.mission.life_yr)/C.mission.life_yr;
end

function [Isc,Voc,Imp,Vmp] = cell_point(C, flux, T_C, age_yr)
%CELL_POINT  Degraded, temperature- and irradiance-corrected cell parameters.
c  = C.sa.cell;
kI = max(flux,0) / C.env.S_ref;                 % irradiance ratio
[fI, fV] = degradation(age_yr, C);

if kI <= 1e-6
    Isc=0; Voc=0; Imp=0; Vmp=0; return;
end
dT  = T_C - c.T_ref;
Isc = (c.Isc + c.dIsc_dT*dT) * kI * fI;
Imp = (c.Imp + c.dImp_dT*dT) * kI * fI;
Voc = (c.Voc + c.dVoc_dT*dT + c.nVt*log(kI)) * fV;
Vmp = (c.Vmp + c.dVmp_dT*dT + c.nVt*log(kI)) * fV;

Isc = max(Isc,0);  Imp = max(min(Imp,0.999*Isc),0);
Voc = max(Voc,0);  Vmp = max(min(Vmp,0.999*Voc),0);
end

function I = cell_current(V, Isc, Voc, Imp, Vmp)
%CELL_CURRENT  Empirical exponential IV model, vectorised over V.
if Isc <= 0 || Voc <= 0
    I = zeros(size(V)); return;
end
C2 = (Vmp/Voc - 1) / log(1 - Imp/Isc);
C1 = (1 - Imp/Isc) * exp(-Vmp/(C2*Voc));
I  = Isc .* (1 - C1 .* (exp(V./(C2*Voc)) - 1));
I  = min(max(I, 0), Isc);
end

function [V, I, P] = iv_curve(C, flux, T_C, age_yr, npts)
%IV_CURVE  Array-level IV and PV curves (for plotting / margin checks).
if nargin < 5, npts = 400; end
[Isc,Voc,Imp,Vmp] = cell_point(C, flux, T_C, age_yr);
v_cell = linspace(0, max(Voc,1e-3), npts);
i_cell = cell_current(v_cell, Isc, Voc, Imp, Vmp);
V = v_cell * C.sa.Ns;
I = i_cell * C.sa.Np * C.sa.f_pack;
P = V .* I * C.sa.f_harness;
end

function [P_bus, I_arr, P_mp] = array_power(C, V_bus, flux, T_C, age_yr)
%ARRAY_POWER  Power delivered to the regulated bus.
[Isc,Voc,Imp,Vmp] = cell_point(C, flux, T_C, age_yr);
f_cos_pack = C.sa.f_pack * C.sa.f_harness;

% Maximum power point (reference / MPPT case)
P_mp = C.sa.Ns * C.sa.Np * Vmp * Imp * f_cos_pack;

switch upper(C.sa.regulation)
    case 'MPPT'
        P_bus = P_mp;
        I_arr = P_bus / max(V_bus,1e-6);
    otherwise    % 'DET' / S3R : array clamped to bus voltage
        v_cell = V_bus / C.sa.Ns;
        if v_cell >= Voc || Isc <= 0
            I_arr = 0;                       % array cannot support the bus
        else
            I_arr = cell_current(v_cell, Isc, Voc, Imp, Vmp) * C.sa.Np * f_cos_pack;
        end
        P_bus = V_bus * I_arr;
end
P_bus = max(P_bus, 0);
end

function T = array_temp(T_prev, illum, dt, C)
%ARRAY_TEMP  First-order lumped thermal node for the wing.
if illum > 0.5
    T_eq = C.sa.T_sun;   tau = C.sa.tau_heat;
else
    T_eq = C.sa.T_eclipse; tau = C.sa.tau_cool;
end
T = T_eq + (T_prev - T_eq) * exp(-dt/tau);
end
