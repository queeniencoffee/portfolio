function G = geo_lib()
%GEO_LIB  GEO orbit environment: sun geometry, eclipse timing, solar flux.
%
%   G = geo_lib() returns a struct of function handles:
%     G.sun_declination(doy)          -> solar declination [deg]
%     G.beta_angle(doy)               -> sun angle out of orbit plane [deg]
%     G.eclipse_duration(doy,C)       -> [T_ecl_s, beta_deg]
%     G.illumination(t,T_ecl,C)       -> 0..1 illumination factor (with penumbra)
%     G.solar_flux(doy,C)             -> irradiance at spacecraft [W/m^2]
%     G.cos_incidence(doy,C)          -> SADA cosine loss factor
%
%   Assumptions
%     * Orbit is circular, equatorial (i ~ 0 deg), so the beta angle equals the
%       solar declination.  For an inclined/inclined-drifting GEO, replace
%       beta_angle() with the proper sun-vector / orbit-normal dot product.
%     * Cylindrical shadow (umbra) with a linear penumbra ramp.
%     * Eclipse is centred at local midnight, i.e. orbit time T_orb/2 with
%       orbit time measured from local solar noon.

G.sun_declination = @sun_declination;
G.beta_angle      = @beta_angle;
G.eclipse_duration= @eclipse_duration;
G.illumination    = @illumination;
G.solar_flux      = @solar_flux;
G.cos_incidence   = @cos_incidence;
G.beta_cutoff     = @beta_cutoff;
end

% -------------------------------------------------------------------------
function dec = sun_declination(doy)
% Low-precision solar declination [deg]; adequate for eclipse bookkeeping.
lambda = 2*pi*(doy - 80.5)/365.25;              % ecliptic longitude from equinox
dec    = asind( sind(23.44) .* sin(lambda) );
end

function b = beta_angle(doy)
b = sun_declination(doy);        % equatorial orbit => beta = declination
end

function bmax = beta_cutoff(C)
% |beta| below which an eclipse occurs at all.
bmax = acosd( sqrt(C.env.r_geo^2 - C.env.R_E^2) / C.env.r_geo );   % = 8.700 deg
end

function [T_ecl, beta] = eclipse_duration(doy, C)
% Umbral eclipse duration for a circular orbit, cylindrical shadow.
beta = beta_angle(doy);
x = sqrt(C.env.r_geo^2 - C.env.R_E^2) / (C.env.r_geo * cosd(beta));
if x >= 1
    T_ecl = 0;                                   % no eclipse this day
else
    T_ecl = C.env.T_orb * acosd(x) / 180;        % [s]  max = 4165 s = 69.4 min
end
end

function f = illumination(t, T_ecl, C)
% Illumination factor 0..1 as a function of orbit time t [s] from solar noon.
% Umbra of length T_ecl centred at T_orb/2, with linear penumbra ramps.
if T_ecl <= 0
    f = ones(size(t)); return;
end
tp  = C.env.t_penumbra;
dt  = abs(mod(t - C.env.T_orb/2 + C.env.T_orb/2, C.env.T_orb) - C.env.T_orb/2);
h   = T_ecl/2;
f   = ones(size(t));
f(dt <= h)              = 0;                                   % umbra
ramp = dt > h & dt < h + tp;
f(ramp) = (dt(ramp) - h)/tp;                                   % penumbra
end

function S = solar_flux(doy, C)
% Irradiance at the spacecraft, corrected for Earth-Sun distance.
nu = 2*pi*(doy - 3)/365.25;                       % from perihelion (~Jan 3)
r_au = 1 - C.env.ecc_earth*cos(nu);               % ~1 +/- 1.67%
S = C.env.S_1AU / r_au^2;                         % ~1361 * (1 +/- 3.4%)
end

function f = cos_incidence(doy, C)
% Single-axis (SADA) sun tracking about the N-S axis: the residual cosine
% loss is the sun's out-of-plane (declination) angle, plus pointing error.
f = cosd(beta_angle(doy)) * cosd(C.sa.point_err);
end
