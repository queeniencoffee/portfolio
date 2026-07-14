%% RUN_GEO_EPS_MODEL
%  GEO spacecraft electrical power system (EPS) model.
%
%  Produces:
%    (0) Power budget by operational mode, and BOL/EOL array capability
%    (1) Worst-case-eclipse orbit: array power, loads, shunt, battery I/V/SOC
%    (2) Charge/discharge cycle detail: V vs cycle time, I vs cycle time
%    (3) SOC and DOD across a full eclipse season
%    (4) Battery aging: capacity fade, resistance growth, DOD growth, Miner damage
%    (5) Energy-balance margin vs mission year
%    (6) Solar array IV / PV curves, BOL vs EOL, hot vs cold, against the bus
%
%  Run time: ~30-90 s (the 15-year run integrates ~1365 eclipse cycles).
%
%  Usage:  >> run_geo_eps_model
%
clear; clc; close all;

C = eps_config();
G = geo_lib();  S = solar_lib();  B = battery_lib();

%% ---------------------------------------------------------------- 0. BUDGET
fprintf('===============================================================\n');
fprintf(' GEO SPACECRAFT POWER MODEL  --  %d-year life, %.0f V regulated bus\n', ...
        C.mission.life_yr, C.bus.V);
fprintf('===============================================================\n\n');

fprintf('SOLAR ARRAY\n');
area = C.sa.Ns*C.sa.Np*C.sa.cell.A_cm2/1e4;
[Pb_bol,~,Pmp_bol] = S.array_power(C, C.bus.V, C.env.S_ref, C.sa.cell.T_ref, 0);
fprintf('  %d cells (%d series x %d strings), %.1f m^2, %.1f%% cell eff.\n', ...
        C.sa.Ns*C.sa.Np, C.sa.Ns, C.sa.Np, area, ...
        100*C.sa.cell.Imp*C.sa.cell.Vmp/(C.env.S_ref*C.sa.cell.A_cm2/1e4));
fprintf('  BOL Pmp @ %d W/m2, %d degC : %6.0f W\n', C.env.S_ref, C.sa.cell.T_ref, Pmp_bol);

flux_wc = G.solar_flux(C.mission.worstcase_doy,C) * G.cos_incidence(C.mission.worstcase_doy,C);
[Pb0,~,~]  = S.array_power(C, C.bus.V, flux_wc, C.sa.T_sun, 0);
[Pb15,~,~] = S.array_power(C, C.bus.V, flux_wc, C.sa.T_sun, C.mission.life_yr);
fprintf('  BOL hot (%d degC), sun-pointed, to bus : %6.0f W\n', C.sa.T_sun, Pb0);
fprintf('  EOL hot (%d degC), %d yr, to bus       : %6.0f W\n\n', C.sa.T_sun, C.mission.life_yr, Pb15);

fprintf('LOAD BUDGET BY MODE [W]\n');
fprintf('  %-14s', 'Mode'); fprintf('%10s', C.load.comp_names{:}); fprintf('%10s\n','TOTAL');
for i = 1:numel(C.load.names)
    fprintf('  %-14s', C.load.names{i});
    fprintf('%10.0f', C.load.table(i,:));
    fprintf('%10.0f\n', sum(C.load.table(i,:)));
end
fprintf('\nBATTERY\n');
fprintf('  %ds%dp, %.0f Ah/cell -> %.0f Ah, %.1f V nom, %.2f kWh BOL\n', ...
        C.bat.Ns, C.bat.Np, C.bat.Q_cell, C.bat.Q_cell*C.bat.Np, ...
        C.bat.Ns*B.ocv(C,0.5), C.bat.Ns*C.bat.Np*C.bat.Q_cell*B.ocv(C,0.5)/1000);
fprintf('  Charge: CC %.2f C to %.2f V/cell, CV taper; storage float %.2f V/cell\n\n', ...
        C.bat.C_rate_chg, C.bat.V_cell_max, C.bat.V_store);

%% ------------------------------------------- 1. WORST-CASE ORBIT (BOL)
st_bol = B.init(C);
[Rb, ~] = sim_orbit(C, C.mission.worstcase_doy, st_bol, 1, 0, true);

%% ------------------------------------------- 2. FULL MISSION (AGING)
M = sim_mission(C, 60, false);

%% ------------------------------------------- 3. WORST-CASE ORBIT (EOL)
st_eol = M.state;                    % keep fade + resistance growth
st_eol.soc = C.bat.soc0;             % start the EOL orbit fully charged (CV limit)
st_eol.V1 = 0; st_eol.V2 = 0;
st_eol.V_cell = B.ocv(C,st_eol.soc); st_eol.V_pack = st_eol.V_cell*C.bat.Ns;
[Re, ~] = sim_orbit(C, C.mission.worstcase_doy, st_eol, 1, C.mission.life_yr, true);

%% ------------------------------------------- VERIFICATION CHECKS
fprintf('\n--- VERIFICATION -------------------------------------------\n');
fprintf('  Max GEO eclipse (beta=0)   : %.1f min   [expect 69.4]\n', ...
        G.eclipse_duration(80,C)/60);
fprintf('  Beta cutoff for eclipse    : %.2f deg   [expect 8.70]\n', G.beta_cutoff(C));
fprintf('  Eclipse days per year      : %d       [expect ~91]\n', ...
        sum(arrayfun(@(d) G.eclipse_duration(d,C)>0, 1:365)));
fprintf('  Energy-balance residual BOL: %+.2e kWh [expect ~0]\n', Rb.resid);
fprintf('  Energy-balance residual EOL: %+.2e kWh [expect ~0]\n', Re.resid);
fprintf('  EOL DOD vs limit           : %.1f%% vs %.0f%%  --> %s\n', ...
        100*Re.DOD, 100*C.bat.DOD_max, ternary(Re.DOD<=C.bat.DOD_max,'PASS','FAIL'));
fprintf('  EOL min cell voltage       : %.3f V vs %.2f V --> %s\n', ...
        Re.V_min, C.bat.V_cell_min, ternary(Re.V_min>C.bat.V_cell_min,'PASS','FAIL'));
fprintf('  EOL energy margin          : %+.1f%%   --> %s\n', ...
        100*Re.margin, ternary(Re.margin>0,'PASS','FAIL'));
fprintf('------------------------------------------------------------\n');

%% ================================================================ FIGURES
lw = 1.4;

% ---------------- Figure 1: worst-case orbit, BOL vs EOL ----------------
figure('Name','Worst-case eclipse orbit','Color','w','Position',[60 60 1000 900]);
th_b = Rb.t/3600;  th_e = Re.t/3600;
ecl_b = Rb.illum < 0.5;

ax(1) = subplot(5,1,1);
plot(th_b, Rb.P_sa_avail/1000,'-','LineWidth',lw); hold on
plot(th_e, Re.P_sa_avail/1000,'--','LineWidth',lw);
plot(th_b, Rb.P_bus_load/1000,'-','LineWidth',lw,'Color',[0.85 0.33 0.10]);
plot(th_b, Rb.P_shunt/1000,':','LineWidth',lw,'Color',[0.5 0.5 0.5]);
shade_eclipse(th_b, ecl_b);
ylabel('Power [kW]'); legend('SA capability BOL','SA capability EOL','Bus load','Shunt', ...
       'Location','southwest','FontSize',8); grid on
title(sprintf('GEO worst-case eclipse orbit (DOY %d, \\beta = %.1f deg, eclipse %.1f min)', ...
      Rb.doy, Rb.beta, Rb.T_ecl/60));

ax(2) = subplot(5,1,2);
plot(th_b, Rb.I_bat,'-','LineWidth',lw); hold on
plot(th_e, Re.I_bat,'--','LineWidth',lw);
yline(0,'k-'); shade_eclipse(th_b, ecl_b);
ylabel('I_{batt} [A]'); legend('BOL','EOL','Location','northwest','FontSize',8); grid on
text(0.5,0.85,'+ discharge / - charge','Units','normalized','FontSize',8);

ax(3) = subplot(5,1,3);
plot(th_b, Rb.V_cell,'-','LineWidth',lw); hold on
plot(th_e, Re.V_cell,'--','LineWidth',lw);
yline(C.bat.V_cell_max,'k:'); yline(C.bat.V_cell_min,'r:');
shade_eclipse(th_b, ecl_b);
ylabel('V_{cell} [V]'); legend('BOL','EOL','Location','southwest','FontSize',8); grid on

ax(4) = subplot(5,1,4);
plot(th_b, 100*Rb.soc,'-','LineWidth',lw); hold on
plot(th_e, 100*Re.soc,'--','LineWidth',lw);
shade_eclipse(th_b, ecl_b);
ylabel('SOC [%]'); ylim([0 105]); legend('BOL','EOL','Location','southwest','FontSize',8); grid on

ax(5) = subplot(5,1,5);
yyaxis left;  plot(th_b, Rb.T_sa,'-','LineWidth',lw); ylabel('T_{array} [\circC]');
yyaxis right; stairs(th_b, Rb.mode,'LineWidth',lw); ylabel('Mode');
set(gca,'YTick',1:numel(C.load.names),'YTickLabel',C.load.names,'FontSize',7);
xlabel('Orbit time from local noon [h]'); grid on
linkaxes(ax,'x'); xlim([0 C.env.T_orb/3600]);

% ------------- Figure 2: charge/discharge cycle detail ------------------
% Zoom on the eclipse discharge + subsequent recharge (the "battery cycle").
[i0,i1,t_entry]    = cycle_window(Rb, 300);
[i0e,i1e,t_entry_e]= cycle_window(Re, 300);
tc_b = (Rb.t(i0:i1)   - t_entry  )/3600;   % cycle time [h], 0 = eclipse entry
tc_e = (Re.t(i0e:i1e) - t_entry_e)/3600;

figure('Name','Battery charge/discharge cycle','Color','w','Position',[80 80 1000 720]);
subplot(3,1,1);
plot(tc_b, Rb.V_cell(i0:i1),'-','LineWidth',lw); hold on
plot(tc_e, Re.V_cell(i0e:i1e),'--','LineWidth',lw);
yline(C.bat.V_cell_max,'k:','CV setpoint'); yline(C.bat.V_cell_min,'r:','EOD limit');
xline(0,'k-'); xline(Rb.T_ecl/3600,'k-');
ylabel('Cell voltage [V]'); grid on
legend('BOL','EOL','Location','southeast','FontSize',8);
title('Battery cycle: eclipse discharge -> CC recharge -> CV taper -> float');
text(Rb.T_ecl/7200, C.bat.V_cell_min+0.05,'DISCHARGE','FontSize',8,'HorizontalAlignment','center');

subplot(3,1,2);
plot(tc_b, Rb.I_bat(i0:i1),'-','LineWidth',lw); hold on
plot(tc_e, Re.I_bat(i0e:i1e),'--','LineWidth',lw);
yline(0,'k-'); yline(-C.bat.C_rate_chg*C.bat.Q_cell*C.bat.Np,'k:','CC limit');
xline(0,'k-'); xline(Rb.T_ecl/3600,'k-');
ylabel('Pack current [A]'); grid on
legend('BOL','EOL','Location','southeast','FontSize',8);
text(1.5, -C.bat.C_rate_chg*C.bat.Q_cell*C.bat.Np*0.6,'CC','FontSize',8);
text(5.5, -2,'CV taper','FontSize',8);

subplot(3,1,3);
plot(tc_b, 100*Rb.soc(i0:i1),'-','LineWidth',lw); hold on
plot(tc_e, 100*Re.soc(i0e:i1e),'--','LineWidth',lw);
xline(0,'k-'); xline(Rb.T_ecl/3600,'k-');
xlabel('Cycle time from eclipse entry [h]'); ylabel('SOC [%]'); grid on
legend('BOL','EOL','Location','southeast','FontSize',8);

% ------------- Figure 3: one eclipse season -----------------------------
figure('Name','Eclipse season','Color','w','Position',[100 100 1000 620]);
sel = M.day <= 366;                              % first year
subplot(2,1,1);
yyaxis left;  plot(M.day(sel), M.T_ecl(sel)/60,'LineWidth',lw); ylabel('Eclipse duration [min]');
yyaxis right; plot(M.day(sel), M.beta(sel),'LineWidth',lw); ylabel('\beta angle [deg]');
yline(0,'k:'); grid on; xlabel('Mission day (year 1)');
title('GEO eclipse seasons: two per year, ~45 days each, 69.4 min max');

subplot(2,1,2);
idx = sel & M.is_ecl==1;
plot(M.day(idx), 100*M.DOD(idx),'o-','MarkerSize',3,'LineWidth',1); hold on
yline(100*C.bat.DOD_max,'r--','DOD limit');
ylabel('DOD per eclipse [%]'); xlabel('Mission day (year 1)'); grid on
title('Depth of discharge per eclipse (triangular season profile)');

% ------------- Figure 4: aging ------------------------------------------
figure('Name','Battery aging','Color','w','Position',[120 120 1050 780]);
subplot(2,2,1);
plot(M.year, 100*M.fade_cal,'LineWidth',lw); hold on
plot(M.year, 100*M.fade_cyc,'LineWidth',lw);
plot(M.year, 100*M.fade,'k','LineWidth',lw+0.4);
yline(100*C.age.fade_eol,'r--','EOL (80% retention)');
xlabel('Mission year'); ylabel('Capacity fade [%]'); grid on
legend('Calendar','Cycling','Total','Location','northwest','FontSize',8);
title('Capacity fade: calendar vs cycling');

subplot(2,2,2);
plot(M.Ah_thru/C.bat.Q_cell, 100*(1-M.fade),'LineWidth',lw); hold on
yline(80,'r--');
xlabel('Equivalent full cycles [-]'); ylabel('Capacity retention [%]'); grid on
title(sprintf('Retention vs throughput (%.0f EFC at EOL)', M.EFC));

subplot(2,2,3);
yyaxis left;  plot(M.year, M.R0_mult,'LineWidth',lw); ylabel('R_0 / R_{0,BOL}');
yyaxis right; plot(M.year, M.D_miner,'LineWidth',lw); ylabel('Miner damage D');
yline(1,'r--'); xlabel('Mission year'); grid on
title('Resistance growth and DOD-based (Miner) damage');

subplot(2,2,4);
ie = M.is_ecl==1;
scatter(M.n_cycles(ie), 100*M.DOD(ie), 6, M.year(ie), 'filled');
c = colorbar; c.Label.String = 'Mission year';
hold on; yline(100*C.bat.DOD_max,'r--','Design limit');
xlabel('Eclipse cycle number'); ylabel('DOD [%]'); grid on
title('DOD creep as the battery fades');

% ------------- Figure 5: margins ----------------------------------------
figure('Name','Power margin','Color','w','Position',[140 140 1000 420]);
subplot(1,2,1);
bar(sum(C.load.table,2)/1000); hold on
yline(Pb0/1000,'g--','SA BOL');  yline(Pb15/1000,'r--','SA EOL');
set(gca,'XTickLabel',C.load.names,'XTickLabelRotation',30,'FontSize',8);
ylabel('Power [kW]'); grid on; title('Load by mode vs array capability');

subplot(1,2,2);
plot(M.yr.year, 100*M.yr.E_margin,'o-','LineWidth',lw); hold on
yline(0,'r--','Zero margin');
xlabel('Mission year'); ylabel('Worst-case orbit energy margin [%]'); grid on
title('Energy margin on the worst eclipse of each year');

% ------------- Figure 6: array IV / PV -----------------------------------
figure('Name','Solar array IV/PV','Color','w','Position',[160 160 1000 420]);
cases = { 0, C.sa.T_sun,   'BOL hot (62 C)'; ...
          0, -90,          'BOL cold (post-eclipse)'; ...
         15, C.sa.T_sun,   'EOL hot (62 C)'; ...
         15, -90,          'EOL cold'};
subplot(1,2,1); hold on
subplot(1,2,2); hold on
for i = 1:size(cases,1)
    [V,I,P] = S.iv_curve(C, C.env.S_1AU*G.cos_incidence(C.mission.worstcase_doy,C), ...
                         cases{i,2}, cases{i,1});
    subplot(1,2,1); plot(V,I,'LineWidth',lw);
    subplot(1,2,2); plot(V,P/1000,'LineWidth',lw);
end
subplot(1,2,1); xline(C.bus.V,'k--','Bus'); xlabel('Array voltage [V]'); ylabel('Array current [A]');
grid on; legend(cases(:,3),'Location','southwest','FontSize',8); title('Array I-V');
subplot(1,2,2); xline(C.bus.V,'k--','Bus'); xlabel('Array voltage [V]'); ylabel('Array power [kW]');
grid on; title('Array P-V (S3R operates at the bus voltage, not the MPP)');

fprintf('\nDone. 6 figures generated.\n');

%% ---------------------------------------------------------------- helpers
function [i0, i1, t_entry] = cycle_window(R, lead_s)
%CYCLE_WINDOW  Index range spanning one battery cycle: a short pre-eclipse
% lead-in, the eclipse discharge, and the recharge back to full SOC.
% NOTE: "full charge" is NOT SOC = 1.  Charging terminates on the 4.10 V/cell
% CV limit, which corresponds to SOC ~ 0.95 on this OCV curve, so the window
% closes when the charge current has tapered out instead.
ecl = R.illum < 0.5;
k_in  = find(ecl,1,'first');
k_out = find(ecl,1,'last');
dt    = R.t(2) - R.t(1);
i0    = max(k_in - round(lead_s/dt), 1);
t_entry = R.t(k_in);
after   = false(size(R.soc));  after(k_out+1:end) = true;
tapered = abs(R.I_bat) < 0.5 & R.soc > 0.9;      % charge complete
i1 = find(tapered & after, 1, 'first');
if isempty(i1), i1 = numel(R.t); end
i1 = min(i1 + round(1800/dt), numel(R.t));       % keep 30 min of float tail
end

function shade_eclipse(th, ecl)
if ~any(ecl), return; end
yl = ylim; i0 = find(ecl,1,'first'); i1 = find(ecl,1,'last');
p = patch([th(i0) th(i1) th(i1) th(i0)], [yl(1) yl(1) yl(2) yl(2)], ...
          [0.85 0.85 0.9], 'EdgeColor','none');
uistack(p,'bottom'); ylim(yl);
end

function s = ternary(cond, a, b)
if cond, s = a; else, s = b; end
end
