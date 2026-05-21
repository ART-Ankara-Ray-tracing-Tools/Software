% ************************************************************************
% This function calculates refractive indice using horizontal interpolation
% with four surrounding grids. Three different methods have been determined. 
% In the first method [interptype=1], if one of the grid points has a NaN value, the first 
% non-NaN value in the same grid profile is accepted as the refractive indice 
% of the grid point, and horizontal interpolation is performed. In the second method [interptype=2], 
% if there is a NaN value among the grid points, the average of the other points 
% is taken and assigned to the NaN value, and horizontal interpolation is performed. 
% If all 4 points have a NaN value, the first method is used. In the third method [interptype=3], 
% the value of the closest grid point is directly accepted, and no interpolation is performed.
%
% Reference :
% Hofmeister, A. (2016). Determination of path delays in the atmosphere for 
% geodetic VLBI by means of ray-tracing. Dissertation, Technische Universität Wien.
%
% INPUT   :
% lati    : latitude of the ray point in [degree]
% loni    : longitude of the ray point in [degree]
% geodlat : latitudes of grid in [degree]
% geodlon : longitudes of grid in [degree]
% ilevel  : height level number
% n       : refractive indice w.r.t. ray point coordinate and ilevel+1
%
% OUTPUT  :
% ni2     : interpolated refractive indice
%
% Coded by Kamil Teke and Ozgur Ozel [20 Dec 2025]
% ************************************************************************

function ni2 = horizontal_interp(lati,loni,geodlat,geodlon,ilevel,n)
% determines the four surrounding grid points
diff_lat = abs(geodlat(1) - geodlat(2));
diff_lon = abs(geodlon(1) - geodlon(2));
[ind_lat1lon1, ind_lat1lon2, ind_lat2lon2, ind_lat2lon1] = ...
          determine_grid_points(lati, loni, diff_lat, diff_lon, geodlat, geodlon);
indlat1 = ind_lat1lon1(1);
indlat2 = ind_lat2lon1(1);
indlon1 = ind_lat1lon1(2);
indlon2 = ind_lat1lon2(2);
% indlat1 = min(find(geodlat <= lati));
% indlat2 = max(find(geodlat > lati));
% indlon1 = max(find(geodlon <= loni));
% indlon2 = min(find(geodlon > loni));
lat1 = geodlat(indlat1);
lat2 = geodlat(indlat2);
lon1 = geodlon(indlon1);
lon2 = geodlon(indlon2);
% determine refractive indices of the four grid points
n11 = n(indlon1,indlat1,ilevel+1);
n21 = n(indlon2,indlat1,ilevel+1);
n12 = n(indlon1,indlat2,ilevel+1);
n22 = n(indlon2,indlat2,ilevel+1);
% selecting interpolation type
interptype = 2;
cond = 0;
switch interptype
    case 1
        if isnan(n11)
            indh11 = max(find(isnan(n(indlon1,indlat1,:))))+1;
            n11 = n(indlon1,indlat1,indh11);
        end
        if isnan(n21)
            indh21 = max(find(isnan(n(indlon2,indlat1,:))))+1;
            n21 = n(indlon2,indlat1,indh21);
        end
        if isnan(n12)
            indh12 = max(find(isnan(n(indlon1,indlat2,:))))+1;
            n12 = n(indlon1,indlat2,indh12);
        end
        if isnan(n22)
            indh22 = max(find(isnan(n(indlon2,indlat2,:))))+1;
            n22 = n(indlon2,indlat2,indh22);
        end
    case 2
        nanvec = [n11 n21 n12 n22];
        vec = nanvec(~isnan(nanvec));
        if isnan(n11)
            n11 = mean(vec);
        end
        if isnan(n21)
            n21 = mean(vec);
        end
        if isnan(n12)
            n12 = mean(vec);
        end
        if isnan(n22)
            n22 = mean(vec);
        end
        if isnan(n11) && isnan(n21) && isnan(n12) && isnan(n22)
            cond = 1;
            [~,indlat] = min(abs(geodlat-lati));
            [~,indlon] = min(abs(geodlon-loni));
            ni2 = n(indlon,indlat,ilevel+1);
            if isnan(ni2)
                indhni2 = max(find(isnan(n(indlon,indlat,:))))+1;
                ni2 = n(indlon,indlat,indhni2);
            end
        end
    case 3
        [~,indlat] = min(abs(geodlat-lati));
        [~,indlon] = min(abs(geodlon-loni));
        ni2 = n(indlon,indlat,ilevel+1);
        if isnan(ni2)
            indhni2 = max(find(isnan(n(indlon,indlat,:))))+1;
            ni2 = n(indlon,indlat,indhni2);
        end
    otherwise

end

if interptype == 1 || (interptype == 2 && cond == 0)
    % Horizontal interpolation for the next ray tracing point
    chi = (lati - lat1)/(lat2 - lat1);
    xi = (loni - lon1)/(lon2 - lon1);
    ni2 = (1-chi)*(1-xi)*n11 + (1-chi)*xi*n21 + chi*xi*n22 + chi*(1-xi)*n12;

    % yukardaki line 63-65 ile aynı çözümü yapar
    % lat = [lat1 lat2];
    % lon = [lon1 lon2];
    % [latm, lonm] = meshgrid(lat,lon);
    % n = [n11 n12; n21 n22];
    % ni2 = interp2(latm,lonm,n,lati,loni);
end
