function [R, st] = sim_orbit(C, doy, st, dt, age_yr, verbose)
%SIM_ORBIT  Simulate one GEO orbit (one sidereal day) of the power system.
%
%   [R, st] = sim_orbit(C, doy, st, dt, age_yr, verbose)
%
%   INPUTS
%     C       - config struct from eps_config()
%     doy     - day of year (sets beta angle, eclipse duration, solar flux)
%     st      - battery state struct (from battery_lib().init) - carried in/out
%     dt      - time step [s]  (1 s for the detailed run, 30-60 s for mission)
%     age_yr  - array age [yr] (drives solar-array degradation)
%     verbose - print an energy-balance summary (default false)
%
%   OUTPUT R contains time histories and per-orbit energy/DOD metrics.
%
%   BUS ARCHITECTURE
%     Regulated 100 V bus.  Solar array is clamped to the bus (S3R / DET);
%     excess power is shunted.  Battery is charged through the BCR and
%     discharged through the BDR.  Priority: (1) loads, (2) battery recharge,
%     (3) shunt.  If the array cannot carry the loads, the BDR makes up the
%     deficit from the battery.
%
%   SIGN CONVENTION: I_bat > 0 = discharge, < 0 = charge.

if nargin < 6, verbose = false; end

G = geo_lib();  S = solar_lib();  B = battery_lib();

[T_ecl, beta] = G.eclipse_duration(doy, C);
flux0  = G.solar_flux(doy, C);
f_cos  = G.cos_incidence(doy, C);
if T_ecl > 0, season = 'eclipse'; else, season = 'solstice'; end

t  = 0:dt:C.env.T_orb;
n  = numel(t);
z  = zeros(1,n);

R = struct('t',t,'illum',z,'T_sa',z,'P_sa_avail',z,'P_sa',z,'P_mp',z, ...
           'P_shunt',z,'P_load',z,'P_bus_load',z,'P_bat',z,'I_bat',z, ...
           'V_pack',z,'V_cell',z,'soc',z,'mode',z,'I_arr',z, ...
           'fade',z,'R0_mult',z);

T_sa   = C.sa.T_sun;          % start at local noon, array hot and sunlit
T_bat  = C.bat.T_C;
n_uv   = 0;                   % undervoltage / load-shed events

for k = 1:n
    % ---------------- environment -------------------------------------
    illum = G.illumination(t(k), T_ecl, C);
    T_sa  = S.array_temp(T_sa, illum, dt, C);
    flux  = flux0 * illum * f_cos;

    % ---------------- solar array (DET at bus voltage) ----------------
    [P_sa_avail, I_arr, P_mp] = S.array_power(C, C.bus.V, flux, T_sa, age_yr);
    P_sa_avail = min(P_sa_avail, C.bus.P_shunt_max);   % S3R capability cap

    % ---------------- loads -------------------------------------------
    [P_load, m_idx] = load_power(C, t(k), illum);
    P_bus_load = P_load / C.bus.eta_dist;              % power drawn at the bus

    % ---------------- battery charge demand ---------------------------
    V_pack   = max(st.V_pack, 1);
    I_chg    = B.charge_current(C, B, st, T_bat, season);   % [A] pack, >=0
    P_chg_bus= I_chg * V_pack / C.bus.eta_bcr;              % bus power for charging

    % ---------------- bus power management (S3R / BCR / BDR) ----------
    demand = P_bus_load + P_chg_bus;
    if P_sa_avail >= demand
        % Array carries everything; shunt the surplus.
        P_sa    = demand;
        P_shunt = P_sa_avail - demand;
        I_bat   = -I_chg;                                    % charging
    elseif P_sa_avail >= P_bus_load
        % Array carries the loads but can only partially recharge.
        P_sa    = P_sa_avail;
        P_shunt = 0;
        P_chg_bus = P_sa_avail - P_bus_load;
        I_bat   = -(P_chg_bus * C.bus.eta_bcr) / V_pack;     % reduced charge
    else
        % Deficit: battery discharges through the BDR.
        P_sa    = P_sa_avail;
        P_shunt = 0;
        P_chg_bus = 0;
        P_def   = P_bus_load - P_sa_avail;                   % bus-side deficit
        I_bat   = (P_def / C.bus.eta_bdr) / V_pack;          % discharging
    end

    % Undervoltage protection / load shed flag
    if st.V_cell <= C.bat.V_cell_min && I_bat > 0
        I_bat = 0; n_uv = n_uv + 1;
    end

    % ---------------- battery integration -----------------------------
    st = B.step(C, B, st, I_bat, dt, T_bat);

    % ---------------- logging -----------------------------------------
    R.illum(k)=illum;  R.T_sa(k)=T_sa;   R.P_sa_avail(k)=P_sa_avail;
    R.P_sa(k)=P_sa;    R.P_mp(k)=P_mp;   R.P_shunt(k)=P_shunt;
    R.P_load(k)=P_load;R.P_bus_load(k)=P_bus_load;
    R.I_bat(k)=I_bat;  R.P_bat(k)=I_bat*st.V_pack;
    R.V_pack(k)=st.V_pack; R.V_cell(k)=st.V_cell; R.soc(k)=st.soc;
    R.mode(k)=m_idx;   R.I_arr(k)=I_arr;
    R.fade(k)=st.fade_cal+st.fade_cyc;  R.R0_mult(k)=st.R0_mult;
end

% ---------------------------------------------------------------- metrics
R.doy       = doy;
R.beta      = beta;
R.T_ecl     = T_ecl;
R.age_yr    = age_yr;
R.season    = season;
R.n_uv      = n_uv;

ecl = R.illum < 0.5;
if any(ecl)
    soc_pre  = R.soc(find(ecl,1,'first'));
    soc_min  = min(R.soc(ecl));
    R.DOD    = soc_pre - soc_min;
    R.V_min  = min(R.V_cell(ecl));
    R.I_dis_max = max(R.I_bat(ecl));
    R.Ah_out = sum(max(R.I_bat,0))*dt/3600 / C.bat.Np;    % per cell [Ah]
else
    R.DOD = 0; R.V_min = min(R.V_cell); R.I_dis_max = 0; R.Ah_out = 0;
end

R.E_gen    = trapz(t, R.P_sa)/3.6e6;        % [kWh] delivered to the bus
R.E_avail  = trapz(t, R.P_sa_avail)/3.6e6;  % [kWh] array capability
R.E_load   = trapz(t, R.P_bus_load)/3.6e6;  % [kWh] drawn by loads at the bus
R.E_shunt  = trapz(t, R.P_shunt)/3.6e6;     % [kWh] dumped in the shunts
R.E_dis    = trapz(t, max(R.P_bat,0))/3.6e6;
R.E_chg    = trapz(t, max(-R.P_bat,0))/3.6e6;
R.margin   = (R.E_avail - R.E_load)/R.E_load;   % orbit energy margin

% Energy-balance residual (should be ~0).  P_sa already excludes the shunted
% power, so:  E_gen + eta_bdr*E_dis  =  E_load + E_chg/eta_bcr.
% A non-zero residual means a bookkeeping error in the bus manager.
R.resid = (R.E_gen + C.bus.eta_bdr*R.E_dis) - (R.E_load + R.E_chg/C.bus.eta_bcr);

if verbose
    fprintf('\n--- Orbit summary: DOY %d, beta = %+.2f deg, age = %.1f yr ---\n', ...
            doy, beta, age_yr);
    fprintf('  Eclipse duration    : %6.1f min\n', T_ecl/60);
    fprintf('  Array capability    : %6.0f W (peak, delivered to bus)\n', max(R.P_sa_avail));
    fprintf('  Peak load           : %6.0f W  |  mean load: %5.0f W\n', max(R.P_load), mean(R.P_load));
    fprintf('  Energy generated    : %6.2f kWh  (capability %.2f kWh)\n', R.E_gen, R.E_avail);
    fprintf('  Energy to loads     : %6.2f kWh  | shunted: %.2f kWh\n', R.E_load, R.E_shunt);
    fprintf('  Battery: %.2f Ah out/cell, DOD = %.1f%%, Vmin = %.3f V/cell\n', ...
            R.Ah_out, 100*R.DOD, R.V_min);
    fprintf('  Peak discharge      : %6.1f A (pack) = %.2f C\n', ...
            R.I_dis_max, R.I_dis_max/C.bat.Np/C.bat.Q_cell);
    fprintf('  Orbit energy margin : %+5.1f %%\n', 100*R.margin);
    fprintf('  Energy-balance resid: %+.2e kWh\n', R.resid);
    if n_uv > 0
        fprintf('  ** WARNING: %d undervoltage steps -> load shed required **\n', n_uv);
    end
end
end

% =========================================================================
function [P, idx] = load_power(C, t, illum)
%LOAD_POWER  Total spacecraft load [W] and mode index at orbit time t.
if illum < 0.5
    idx = find(strcmp(C.load.names,'ECLIPSE'));
else
    hr  = t/3600;
    idx = find(strcmp(C.load.names,'NOMINAL'));   % default
    for i = 1:size(C.load.timeline,1)
        if hr >= C.load.timeline{i,1} && hr < C.load.timeline{i,2}
            idx = find(strcmp(C.load.names, C.load.timeline{i,3}));
            break
        end
    end
end
P = sum(C.load.table(idx,:));
end
