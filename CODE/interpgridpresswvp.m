% ************************************************************************
% This function interpolates pressure and water vapor pressure values exponentially
% along the vertical profile.
%
% Reference :
% Hofmeister, A. (2016). Determination of path delays in the atmosphere for 
% geodetic VLBI by means of ray-tracing. Dissertation, Technische Universität Wien.
%
% INPUT    :
% hinterp  : height increments of vertical profile
% geom_h   : ellipsoidal height of vertical increment profile
% press    : pressure level of ECMWF data
% wvp      : water vapor pressure calculated from specific humidity and pressure
%
% OUTPUT   :
% pressint : interpolated pressure
% wvpint   : interpolated water vapor pressure
%
% Coded by Kamil Teke and Ozgur Ozel [20 Dec 2025]
% ************************************************************************

function [pressint,wvpint] = interpgridpresswvp(hinterp,geom_h,press,wvp)
% interpolate pressure, wvp

indnan = find(isnan(hinterp));
hint = hinterp(~isnan(hinterp));
if find(geom_h(1) == hint) == 1
    geom_h(1)  = geom_h(1) -  0.0001;
end
% coefficients c for interpolation of pressure and wvp
geom_h0 = geom_h(1:end-1);
geom_h1 = geom_h(2:end);
press0 = press(1:end-1);
press1 = press(2:end);
wvp0 = wvp(1:end-1);
wvp1 = wvp(2:end);
cintp = (geom_h1-geom_h0)./log(press1./press0);
cinte = (geom_h1-geom_h0)./log(wvp1./wvp0);

% make vectors with c for each interpolation height
cintpall = []; cinteall = []; press0all = []; wvp0all = []; geom_h0all = []; numind_ = [];

for i = 1 : length(cintp)
    ind = hint((hint>geom_h0(i))&(hint<=geom_h1(i)));
    numind = length(ind);
    cintpall = [cintpall;ones(numind,1)*cintp(i)];
    cinteall = [cinteall;ones(numind,1)*cinte(i)];
    press0all = [press0all;ones(numind,1)*press0(i)];
    wvp0all = [wvp0all;ones(numind,1)*wvp(i)];
    geom_h0all = [geom_h0all;ones(numind,1)*geom_h0(i)];
end

% interpolate pressure, wvp
pressint = press0all.*exp(1./cintpall.*(hint-geom_h0all));
wvpint  = wvp0all .*exp(1./cinteall.*(hint-geom_h0all));

pressint = [nan(length(indnan),1);pressint];
wvpint = [nan(length(indnan),1);wvpint];
