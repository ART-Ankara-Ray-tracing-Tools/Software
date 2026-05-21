% ************************************************************************
% This function calculates the Gaussian radius of the Earth.
%
% Reference :
% Torge, W., and Müller, J. (2012). Geodesy (4th ed.). Walter de Gruyter.
% 433 pp. ISBN: 978-3-11-020718-7.
%
% INPUT  :
% lat    : geodetic latitude of the ray point in [degree]
%
% OUTPUT :
% Rg     : the Gaussian radius of the Earth in [meters]
% R      : distance from the ellipsoid centre to the surface point at a
%          geodetic latitude in [meters]
%
% Coded by Kamil Teke and Ozgur Ozel [20 Dec 2025]
% ************************************************************************
function [Rg,R] = gaussradius(lat)   

% WGS84 parameters
a = 6378137.0;            % Semimajor axis of WGS84 [m]
b = 6356752.31424522;     % Semiminor axis of WGS84 [m]

% first eccentricity
e2 = (a^2-b^2)/a^2;

% Meridian radius of curvature
M = a*(1-e2)/sqrt(1-e2*sind(lat)^2)^3;

% Radius of curvature in the prime vertical
N = a/sqrt(1-e2*sind(lat)^2);

% Gaussian radius of curvature
Rg = sqrt(M*N);

% Distance from the ellipsoid centre to the surface point at a geodetic latitude 
R = N*sqrt(cosd(lat)^2+(1-e2)^2*sind(lat)^2);