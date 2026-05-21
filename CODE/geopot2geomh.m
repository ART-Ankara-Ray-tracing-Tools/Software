% ************************************************************************
% This function converts geopotential (=dynamic) height to orthometric height.
% This function uses iteration method for calculation of orthometric heights.
%
% Reference :
% Kraus, H. (2001). Die Atmosphäre der Erde: Eine Einführung in die Meteorologie (2nd ed.). 
% Springer-Verlag Berlin Heidelberg.
%
% INPUT  :
% geopot : geopotential (=dynamic) height(s) in [meters]
% lat    : latitude in [degree]
%
% OUTPUT :
% geom_h : orthometric height in [meters]
%
% Coded by Kamil Teke and Ozgur Ozel [20 Dec 2025]
% ************************************************************************

function geom_h = geopot2geomh(geopot,lat)
% Conversion geopotential heights to geometric heights
gn = 9.80665; % m/s^2
geop_h = geopot./gn; % geopotential heights

% geom_h = 1 / (2 * 1.57e-7) - sqrt((1 / (2 * 1.57e-7))^2 - geop_h / ...
%         (1 - 0.0026373 * cosd(2 * lat) + 0.0000059 * (cosd(2 * lat))^2) / 1.57e-7);

crit = 1e-5;
diffh = 1;
geom_h = geop_h; 
while (diffh > crit)
test_h = geom_h(1);
grav = gn*(1-0.0026373*cosd(2*lat)+0.0000059*(cosd(2*lat))^2)...
     *(1-3.14*1e-7.*(geom_h/2));
geom_h = (geop_h*gn)./grav; % [m]
diffh = abs(geom_h(1)-test_h);
end