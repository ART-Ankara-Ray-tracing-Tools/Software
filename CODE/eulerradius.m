% ************************************************************************
% This function calculates radius of the Earth w.r.t. Euler's formula.
%
% Reference :
% Torge, W., and Müller, J. (2012). Geodesy (4th ed.). Walter de Gruyter.
% 433 pp. ISBN: 978-3-11-020718-7.
%
% INPUT  :
% lat    : geodetic latitude of the ray point in [degree]
% az     : azimuth of the ray direction in [degree]
%
% OUTPUT :
% Ra     : radius of the earth w.r.t. euler's formula in [meters]
% R      : distance from the ellipsoid centre to the surface point at a
%          geodetic latitude in [meters]

% Coded by Kamil Teke and Ozgur Ozel [20 Dec 2025]
% ************************************************************************

function [Ra,R] = eulerradius(lat,az)

% WGS84 parameters
a = 6378137.0;            % semimajor axis [m]
b = 6356752.31424522;     % semimajor axis [m]

% first eccentricity
e2 = (a^2-b^2)/a^2;

% Meridian radius of curvature
M = a*(1-e2)/(1-e2*sind(lat)^2)^(3/2);

% Radius of curvature in the prime vertical
N = a/sqrt(1-e2*sind(lat)^2);

% Radius of the Earth
Ra = M*N/(N*cosd(az)^2+M*sind(az)^2);

% Distance from the ellipsoid centre to the surface point at a geodetic latitude 
R = N*sqrt(cosd(lat)^2+(1-e2)^2*sind(lat)^2);
end

