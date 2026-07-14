function M = sim_mission(C, dt_ecl, quiet)
%SIM_MISSION  15-year GEO life simulation: every eclipse cycle, every season.
%
%   M = sim_mission(C, dt_ecl, quiet)
%
%   Two time scales are used, which is what makes a 15-year, 1-Hz-fidelity
%   battery life study tractable:
%
%     * ECLIPSE DAYS (~91/yr, ~1365 over 15 yr) are integrated with the full
%       ECM + bus manager at dt_ecl (default 60 s).  These days contain all of
%       the cycling damage and all of the deep DOD excursions.
%
%     * SOLSTICE (non-eclipse) DAYS are the ~74% of the mission where the
%       battery just floats.  They are advanced with a single 86400 s aging
%       step at the reduced-voltage storage SOC (standard GEO practice: the
%       battery is taper-charged down to ~3.90 V/cell between eclipse seasons
%       to suppress calendar fade).  No cycling damage accrues.
%
%   Outputs (per day, length N):
%     M.day, M.doy, M.year, M.beta, M.T_ecl, M.is_ecl
%     M.fade_cal, M.fade_cyc, M.fade, M.cap_Ah, M.R0_mult
%     M.DOD, M.V_min, M.I_dis_max, M.D_miner, M.n_cycles, M.Ah_thru
%   Per-year worst-case rollup:
%     M.yr.*  (worst-case eclipse day of each year)

if nargin < 2 || isempty(dt_ecl), dt_ecl = 60;  end
if nargin < 3, quiet = false; end

G = geo_lib();  B = battery_lib();
st = B.init(C);

N = round(C.mission.life_yr * 365.25);
z = zeros(1,N);
M = struct('day',1:N,'doy',z,'year',z,'beta',z,'T_ecl',z,'is_ecl',z, ...
           'fade_cal',z,'fade_cyc',z,'fade',z,'cap_Ah',z,'R0_mult',z, ...
           'DOD',z,'V_min',z,'I_dis_max',z,'D_miner',z,'n_cycles',z, ...
           'Ah_thru',z,'E_margin',z);

% Storage SOC corresponding to the reduced-voltage float setpoint
soc_store = interp1(C.bat.ocv_v, C.bat.ocv_soc, C.bat.V_store, 'pchip');

nY = C.mission.life_yr;
yr = struct('year',1:nY,'DOD',zeros(1,nY),'V_min',zeros(1,nY), ...
            'I_dis_max',zeros(1,nY),'fade',zeros(1,nY),'cap_Ah',zeros(1,nY), ...
            'R0_mult',zeros(1,nY),'E_margin',zeros(1,nY),'P_sa_peak',zeros(1,nY), ...
            'T_ecl',zeros(1,nY),'D_miner',zeros(1,nY));

if ~quiet
    fprintf('Running %d-year mission (%d days, dt = %g s on eclipse days)...\n', ...
            C.mission.life_yr, N, dt_ecl);
end

for d = 1:N
    doy    = mod(C.mission.epoch_doy + d - 2, 365.25) + 1;
    age_yr = (d-1)/365.25;
    [T_ecl, beta] = G.eclipse_duration(doy, C);

    if T_ecl > 0
        % ---- eclipse day: full electrical simulation -------------------
        [R, st] = sim_orbit(C, doy, st, dt_ecl, age_yr, false);
        st.n_cycles = st.n_cycles + 1;
        st.D_miner  = st.D_miner + B.miner_damage(C, R.DOD);
        M.DOD(d)       = R.DOD;
        M.V_min(d)     = R.V_min;
        M.I_dis_max(d) = R.I_dis_max;
        M.E_margin(d)  = R.margin;
        M.is_ecl(d)    = 1;
    else
        % ---- solstice day: reduced-voltage float, calendar aging only ---
        st.soc = min(st.soc, soc_store);      % taper down to storage SOC
        st = B.step(C, B, st, 0, 86400, C.bat.T_C);
        M.V_min(d) = st.V_cell;
    end

    M.doy(d)      = doy;
    M.year(d)     = age_yr;
    M.beta(d)     = beta;
    M.T_ecl(d)    = T_ecl;
    M.fade_cal(d) = st.fade_cal;
    M.fade_cyc(d) = st.fade_cyc;
    M.fade(d)     = st.fade_cal + st.fade_cyc;
    M.cap_Ah(d)   = B.capacity(C, st) * C.bat.Np;     % pack capacity [Ah]
    M.R0_mult(d)  = st.R0_mult;
    M.D_miner(d)  = st.D_miner;
    M.n_cycles(d) = st.n_cycles;
    M.Ah_thru(d)  = st.Ah_thru;
end

% ------------------------------------------------- per-year worst-case rollup
for y = 1:nY
    idx = (M.year >= y-1) & (M.year < y) & (M.is_ecl == 1);
    if ~any(idx), continue; end
    [~,iw] = max(M.DOD(idx));                 % worst-case (deepest) eclipse
    ii = find(idx);  iw = ii(iw);
    yr.DOD(y)       = M.DOD(iw);
    yr.V_min(y)     = M.V_min(iw);
    yr.I_dis_max(y) = M.I_dis_max(iw);
    yr.fade(y)      = M.fade(iw);
    yr.cap_Ah(y)    = M.cap_Ah(iw);
    yr.R0_mult(y)   = M.R0_mult(iw);
    yr.E_margin(y)  = M.E_margin(iw);
    yr.T_ecl(y)     = M.T_ecl(iw);
    yr.D_miner(y)   = M.D_miner(iw);
end
M.yr    = yr;
M.state = st;                 % final (EOL) battery state
M.EFC   = st.Ah_thru / C.bat.Q_cell;     % equivalent full cycles (per cell)

if ~quiet
    fprintf('  Eclipse cycles simulated : %d\n', st.n_cycles);
    fprintf('  Cell throughput          : %.0f Ah  (%.0f equivalent full cycles)\n', ...
            st.Ah_thru, M.EFC);
    fprintf('  EOL capacity fade        : %.1f%%  (calendar %.1f%% + cycling %.1f%%)\n', ...
            100*M.fade(end), 100*M.fade_cal(end), 100*M.fade_cyc(end));
    fprintf('  EOL pack capacity        : %.1f Ah  (BOL %.1f Ah)\n', ...
            M.cap_Ah(end), C.bat.Q_cell*C.bat.Np);
    fprintf('  EOL R0 growth            : x%.2f\n', M.R0_mult(end));
    fprintf('  Miner damage (DOD model) : %.2f  (1.0 = EOL)\n', st.D_miner);
    fprintf('  Worst-case EOL DOD       : %.1f%%  (limit %.0f%%)\n', ...
            100*max(M.DOD(M.year>C.mission.life_yr-1)), 100*C.bat.DOD_max);
end
end
