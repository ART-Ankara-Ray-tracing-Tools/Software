% ************************************************************************
% This function calculates the spherical coordinates (latitude and
% longitude) of the points along the ray path.
%
% Reference :
% Hofmeister, A. (2016). Determination of path delays in the atmosphere for 
% geodetic VLBI by means of ray-tracing. Dissertation, Technische Universität Wien. 
%
% INPUT
%   lat   : latitude of the starting point of the ray in [degree]
%   lon   : longitude of the the starting point of the ray in [degree]
%   az    : azimuth angle of the observation in [degree]
%   delta : geocentric angle that is referred to the starting point of
%             the ray in [degree]
% 
% OUTPUT
%   lati  : latitude of the target point to be determined in [degree]
%   loni  : latitude of the target point to be determined in [degree]
%
% Coded by Kamil Teke and Ozgur Ozel [20 Dec 2025]
% ************************************************************************

function [lati,loni] = latlon_calc(lat,lon,az,delta)
% calculate next ray point using spherical triangle solution
lati = asind(sind(lat)*cosd(delta)+cosd(lat)*sind(delta)*cosd(az));
loni = lon + atan2d(sind(az),1/tand(delta)*cosd(lat)-sind(lat)*cosd(az));

% adoption of latitude and longitude
if loni > 360
    loni = loni - 360;
elseif loni < 0
    loni = loni + 360;
end

if lati > 90
    lati = 180 - lati;
    if loni >= 180
        loni = loni - 180;
    elseif loni < 180
        loni = loni + 180;
    end
elseif lati < -90
    lati = -180 - lati;
    if loni >= 180
        loni = loni - 180;
    elseif loni < 180
        loni = loni + 180;
    end
end

if loni == 360
    loni = 0;
end

if  (lati < -90) || (lati > 90) || (loni < 0) || (loni > 360)
    warning('Program stopped!!');
    return
end