% ************************************************************************
% This function determines the four surrounding grid points around a specific
% point of interest (POI). This function was created using the "determine_grid_points.f90" 
% script of the RADIATE program. 
%
% Reference:
% Hofmeister, A., and Böhm, J. (2017). Application of ray-traced tropospheric 
% slant delays to geodetic VLBI analysis. Journal of Geodesy, 91(8), 945–964. 
% https://doi.org/10.1007/s00190-017-1000-7.
%
% INPUT        :
% POI_lat      : station latitude in [degree]
% POI_lon      : station longitude in [degree]
% diff_lat     : grid interval for latitude in [degree]
% diff_lon     : grid interval for longitude in [degree]
% geodlat      : latitudes of grid in [degree]
% geodlon      : longitudes of grid in [degree]
%
% OUTPUT
% ind_lat1lon1 : index [row,column] of point lat1lon1 in the grid
% ind_lat1lon2 : index [row,column] of point lat1lon2 in the grid
% ind_lat2lon2 : index [row,column] of point lat2lon2 in the grid
% ind_lat2lon1 : index [row,column] of point lat2lon1 in the grid
% lat1lon1_out : (optional) [lat,lon] of point lat1lon1 in the grid in [degree]
% lat1lon2_out : (optional) [lat,lon] of point lat1lon2 in the grid in [degree]
% lat2lon2_out : (optional) [lat,lon] of point lat2lon2 in the grid in [degree]
% lat2lon1_out : (optional) [lat,lon] of point lat2lon1 in the grid in [degree]
%
% Created by Armin Hofmeister
% modified by Kamil Teke and Ozgur Ozel [20 Dec 2025]
% ************************************************************************

function [ind_lat1lon1, ind_lat1lon2, ind_lat2lon2, ind_lat2lon1, ...
          lat1lon1_out, lat1lon2_out, lat2lon2_out, lat2lon1_out] = ...
          determine_grid_points(POI_lat, POI_lon, diff_lat, diff_lon, geodlat, geodlon)

% grid sizes
nlat = size(geodlat,1);
nlon = size(geodlon,1);

lat_first = geodlat(1);
lon_first = geodlon(1);
lon_last  = geodlon(nlon);

global_lat_check  = ((nlat-1) * diff_lat == 180);   % 90° to -90°
global_lon_check  = (nlon    * diff_lon == 360);    % 0° to 360°

start_lat_check   = (geodlat(1) == 90);   % Usually 90°
start_lon_check   = (geodlon(1) == 0);   % Usually 0°

start_and_global_check = (global_lat_check && ...
                          global_lon_check && ...
                          start_lat_check  && ...
                          start_lon_check);

% previous grid nodes
lat1 = floor(POI_lat/diff_lat) * diff_lat;
lon1 = floor(POI_lon/diff_lon) * diff_lon;

% indices
ind_lat1 = round((lat_first - lat1)/diff_lat) + 1;
ind_lon1 = round((lon1 - lon_first)/diff_lon) + 1;

%----------------------------------------------------------------------
% In case the first longitude is greater or equal to the last longitude then
% the 0° meridian is in between the grid.
%----------------------------------------------------------------------
if lon_first > lon_last

    if lon1 <= lon_last 
        ind_lon1 = ind_lon1 + (360/diff_lon); % 0° longitude transition

    elseif (~start_and_global_check) && ((lon_first - lon1) > (lon1 - lon_last))
        ind_lon1 = nlon - 1;   % right boundary
    end
end

%--------------------------------------------------------------------------
% Global Grid Check
%--------------------------------------------------------------------------
if start_and_global_check
    
    %---------------- LAT1-LON1 ----------------
    ind_lat1lon1 = [ind_lat1, ind_lon1];
    lat1lon1     = [geodlat(ind_lat1), geodlon(ind_lon1)];

    %---------------- LAT1-LON2 ----------------
    if ind_lon1 == nlon
        ind_lon2_for_lat1 = 1;
    else
        ind_lon2_for_lat1 = ind_lon1 + 1;
    end

    ind_lat1lon2 = [ind_lat1, ind_lon2_for_lat1];
    lat1lon2     = [geodlat(ind_lat1), geodlon(ind_lon2_for_lat1)];

    %---------------- POLE CROSSING ----------------
    if ind_lat1 == 1

        ind_lat2 = 2;     % 90° → 89°

        % lon1 adjust 180°
        if lat1lon1(2) >= 180
            ind_lon1_for_lat2 = ind_lon1 - 180/diff_lon;
        else
            ind_lon1_for_lat2 = ind_lon1 + 180/diff_lon;
        end

        % lon2 adjust 180°
        if lat1lon2(2) >= 180
            ind_lon2_for_lat2 = ind_lon2_for_lat1 - 180/diff_lon;
        else
            ind_lon2_for_lat2 = ind_lon2_for_lat1 + 180/diff_lon;
        end

    else
        % no pole crossing
        ind_lat2 = ind_lat1 - 1;
        ind_lon1_for_lat2 = ind_lon1;
        ind_lon2_for_lat2 = ind_lon2_for_lat1;
    end

    %---------------- LAT2-LON1 ----------------
    ind_lat2lon1 = [ind_lat2, ind_lon1_for_lat2];
    lat2lon1     = [geodlat(ind_lat2), geodlon(ind_lon1_for_lat2)];

    %---------------- LAT2-LON2 ----------------
    ind_lat2lon2 = [ind_lat2, ind_lon2_for_lat2];
    lat2lon2     = [geodlat(ind_lat2), geodlon(ind_lon2_for_lat2)];

else
%--------------------------------------------------------------------------
% Not Global Grid → Boundary Check
%--------------------------------------------------------------------------

    if ind_lat1 < 2, ind_lat1 = 2; end
    if ind_lat1 > nlat, ind_lat1 = nlat; end

    if ind_lon1 < 1, ind_lon1 = 1; end
    if ind_lon1 > nlon-1, ind_lon1 = nlon-1; end

    ind_lat2 = ind_lat1 - 1;
    ind_lon2 = ind_lon1 + 1;
    
    lat1lon1 = [geodlat(ind_lat1), geodlon(ind_lon1)];
    lat1lon2 = [geodlat(ind_lat1), geodlon(ind_lon2)];
    lat2lon1 = [geodlat(ind_lat2), geodlon(ind_lon1)];
    lat2lon2 = [geodlat(ind_lat2), geodlon(ind_lon2)];
    
    ind_lat1lon1 = [ind_lat1, ind_lon1];
    ind_lat1lon2 = [ind_lat1, ind_lon2];
    ind_lat2lon1 = [ind_lat2, ind_lon1];
    ind_lat2lon2 = [ind_lat2, ind_lon2];
end

%--------------------------------------------------------------------------
% OPTIONAL OUTPUTS
%--------------------------------------------------------------------------
if nargout >= 5, lat1lon1_out = lat1lon1; end
if nargout >= 6, lat1lon2_out = lat1lon2; end
if nargout >= 7, lat2lon2_out = lat2lon2; end
if nargout >= 8, lat2lon1_out = lat2lon1; end

end
