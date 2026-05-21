% ************************************************************************
% This function calculates 2D Ray-traced delays. Results are writing a text file
% which has extension ".art" at the "OUTPUT" folder.
%
% Reference :
% Hofmeister, A. (2016). Determination of path delays in the atmosphere for 
% geodetic VLBI by means of ray-tracing. Dissertation, Technische Universität Wien.
%
% INPUT     :
% matfile   : converted netCDF file. This file obtain using "readnetcdf.m"
%             function. This file path is "INPUT/MAT/"
% statfile  : station mat file. This file path is "INPUT/STAT/"
% azimuth   : azimuth angles of 2D ray-tracing in [degree]
% elevation : elevation angles of 2D ray-tracing in [degree]
%
% OUTPUT    :
% This function create a text file with extention ".art". The art file is
% result of 2D ray-tracing delays.
%
% Coded by Kamil Teke and Ozgur Ozel [25 Dec 2025]
% ************************************************************************

function raytracer(matfile,statfile,azimuth,elevation)
format longg
addpath('UNDULATIONS');

% Loading ECMWF and station data
load(['INPUT/MAT/',matfile]);
load(['INPUT/STAT/',statfile]);

% grid resolution
diff_lat = abs(latitude.val(1) - latitude.val(2));
diff_lon = abs(longitude.val(1) - longitude.val(2));

% Loading geoid undulations of the region w.r.t. grid resolution
if diff_lat == 0.25 && diff_lon == 0.25
    N08_World = load('EGM2008_World_0_25x0_25.mat');
elseif diff_lat == 1 && diff_lon == 1
    N08_World = load('EGM2008_World_1x1.mat');
elseif diff_lat == 0.125 && diff_lon == 0.125
    N08_World = load('EGM2008_World_0_125x0_125.mat');
else
    N08_World = load('EGM2008_World_5x5.mat');
end

geodlon = double(longitude.val);
geodlat = double(latitude.val);
ilat = find(N08_World.lat_unique >=geodlat(end) & N08_World.lat_unique <=geodlat(1));
ilon = find(N08_World.lon_unique >=geodlon(1) & N08_World.lon_unique <=geodlon(end));
N08.lat_unique = N08_World.lat_unique(ilat);
N08.lon_unique = N08_World.lon_unique(ilon);
N08.geoid_grid = N08_World.geoid_grid(ilat,ilon);
geodlon(geodlon<0) = geodlon(geodlon<0) + 360; % converting longitudes to between 0 and 360 degree

disp('Data Loaded')
disp('--------------------------')

% molar masses of dry and wet air, universal gas constant 
Md = 28.9644*1e-3; % [kg/mol]
Mw = 18.01528*1e-3;% [kg/mol]
R = 8.3143; % [J/(K*mol) = (Pa*m^3)/(K*mol)]  1 Joule =  1 N*m = 1 Pa*m^3 = 1 kg*m^2/sn^2 
Rd = R/Md; % specific gas constant for dry air

k1 = 77.6890*1e-2; %[K/Pa]
k2 = 71.2952*1e-2; %[K/Pa]
k2p = k2-k1*(Mw/Md); %[K/Pa]
k3 = 375463*1e-2;  %[K^2/Pa]

% defining number of latitude, longitude, pressure levels and stations
numlat = dim(2).length; 
numlon = dim(1).length;
numlevel = dim(3).length; 
numstat = size(stat,2); 

% Epochs in hours since 1900.01.01 0:00:00 to MJD
tmjd = modjuldat(1900,1,1) + double(time.val)/24; % MJD
[y, m, d, ho, minu, s] = mjd2date(tmjd);
datestr = [y m d ho minu s];
clear y m d ho minu s

for iep = 1 : length(tmjd)
    fileName2 = sprintf('OUTPUT/%s_%04d%02d%02d_%02d.art',matfile(1:end-4),datestr(iep,1),datestr(iep,2),datestr(iep,3),datestr(iep,4));
    art = fopen(fileName2,'w+');
    fprintf(art, ['%% Data columns:\n' ...
        '%%    1  .... scannumber\n' ...
        '%%    2  .... mjd\n' ...
        '%%    3  .... year\n' ...
        '%%    4  .... day of year\n' ...
        '%%    5  .... hour\n' ...
        '%%    6  .... min\n' ...
        '%%    7  .... sec\n' ...
        '%%    8  .... station\n' ...
        '%%    9  .... azimuth in [rad]\n' ...
        '%%    10 .... outgoing elevation angle (calculated, theoretical) in [rad]\n' ...
        '%%    11 .... source\n' ...
        '%%    12 .... temperature at station in [°C]\n' ...
        '%%    13 .... pressure at station in [hPa]\n' ...
        '%%    14 .... water vapour pressure at station in [hPa]\n' ...
        '%%    15 .... zenith total delay in [m]\n' ...
        '%%    16 .... zenith hydrostatic delay in [m]\n' ...
        '%%    17 .... zenith wet delay in [m]\n' ...
        '%%    18 .... slant total delay including geometric bending effect in [m]\n' ...
        '%%    19 .... slant hydrostatic delay including geometric bending effect in [m]\n' ...
        '%%    20 .... slant wet delay in [m]\n' ...
        '%%    21 .... elevation angle at station in [rad]\n' ...
        '%%    22 .... outgoing elevation angle from ray-tracing in [rad]\n' ...
        '%%    23 .... geometric bending effect in [m]\n' ...
        '%%    24 .... total mapping factor (includes treatment of geometric bending effect) [total_delay_along_the_path / total_zenith_delay]\n' ...
        '%%    25 .... hydrostatic mapping factor (includes treatment of geometric bending effect) [hydrostatic_delay_along_the_path / hydrostatic_zenith_delay]\n' ...
        '%%    26 .... wet mapping factor [wet_delay_along_the_path / wet_zenith_delay]\n' ...
        '%%    27 .... temperature at the station position interpolated from the numerical weather model in [°C]\n' ...
        '%%    28 .... pressure at the station position interpolated from the numerical weather model in [hPa]\n' ...
        '%%    29 .... water vapour pressure at the station position interpolated from the numerical weather model in [hPa]\n' ...
        '%%*****************************************************************************************************************\n'...
        '%%\n'...
        '%%\n'...
        '%%    1|          2|   3|  4| 5| 6|    7|       8|                   9|                  10|      11|    12|     13|    14|       15|       16|       17|       18|       19|       20|          21|          22|       23|        24|        25|        26|    27|     28|    29\n'...
        '%% scan|        mjd|year|doy| h| m|  sec| station|       azimuth [rad]|   calc. elev. [rad]|  source|T [°C]|p [hPa]|w[hPa]|  ztd [m]|  zhd [m]|  zwd [m]|  std [m]|  shd [m]|  swd [m]|e at st[rad]|e rtrd [rad]|bend. [m]|  total mf|  hydr. mf|    wet mf|T [°C]|p [hPa]|w[hPa]\n'...
        '%%\n']);
    src = 'none';
    t_meas = 'NaN';
    p_meas = 'NaN';
    wvp_meas = 'NaN';
    
    mjd = tmjd(iep);
    disp(datestr(iep,:)) % display processing MJD
    spechum = squeeze(double(q.val(:,:,:,iep)).*q.scale_factor + q.add_offset); % specific humidity [kg*kg^-1]
    geopot = squeeze(double(z.val(:,:,:,iep)).*z.scale_factor + z.add_offset); % geopotential [m^2/s^2]
    tempk = squeeze(double(t.val(:,:,:,iep)).*t.scale_factor + t.add_offset); % temperature [K]
       
    % converting the geopotential heights to orthometric heights
    geomh = nan(numlon,numlat,numlevel);
    geoid_grid = N08.geoid_grid;
    for ilon = 1 : numlon
        for ilat = 1 : numlat
            geomh(ilon,ilat,:)= geopot2geomh(squeeze(geopot(ilon,ilat,:)),latitude.val(ilat)); % [m]
            geomh(ilon,ilat,:) = geomh(ilon,ilat,:) + geoid_grid(ilat,ilon); % converting from orthometric to ellipsoidal heights of all profiles
        end
    end
    
    geomh_max = max(max(geomh(:,:,1)));
    if geomh_max < 2000
        maxhextrap = ceil(geomh_max/10)*10;
        geomhmaxtemp = [maxhextrap 2000 6000 16000  36000 50000 80000 84000];
    elseif geomh_max < 6000
        maxhextrap = ceil(geomh_max/20)*20;
        geomhmaxtemp = [maxhextrap 6000 16000  36000 50000 80000 84000];
    elseif geomh_max < 16000
        maxhextrap = ceil(geomh_max/50)*50;
        geomhmaxtemp = [maxhextrap 16000  36000 50000 80000 84000];
    elseif geomh_max < 36000
        maxhextrap = ceil(geomh_max/100)*100;
        geomhmaxtemp = [maxhextrap 36000 50000 80000 84000];
    elseif geomh_max < 50000
        maxhextrap = ceil(geomh_max/500)*500;
        geomhmaxtemp = [maxhextrap 50000 80000 84000];
    else
        maxhextrap = ceil(geomh_max/500)*500;
        geomhmaxtemp  = [maxhextrap 80000 84000];
    end    
    geomhmaxtemp = unique(flip(geomhmaxtemp),'stable');

    % add standard atmosphere model values
    appendgeomh = nan(numlon,numlat,size(geomhmaxtemp,2));
    appendtempk = nan(numlon,numlat,size(geomhmaxtemp,2));
    appendspechum = nan(numlon,numlat,size(geomhmaxtemp,2));
    appendpress = nan(numlon,numlat,size(geomhmaxtemp,2));


    % Extract pressure levels
    totpress = double(level.val)*1e2; % total pressure [Pa]
    press = nan(numlon,numlat,numlevel);
    for ilon = 1 : numlon
        for ilat = 1 : numlat
            press(ilon,ilat,:)= totpress;
        end
    end
    for ilon = 1 : numlon
        for ilat = 1 : numlat
            appendgeomh(ilon,ilat,1:size(geomhmaxtemp,2)) = geomhmaxtemp;
            [appendtempk(ilon,ilat,1:size(geomhmaxtemp,2)), appendpress(ilon,ilat,1:size(geomhmaxtemp,2)),~,~] = atmosphere(geomhmaxtemp);
            appendspechum(ilon,ilat,1:size(geomhmaxtemp,2)) = ones(size(geomhmaxtemp,2),1)'*10^-10;
        end
    end

    spechum = cat(3,appendspechum,spechum);
    geomh = cat(3,appendgeomh,geomh);
    tempk = cat(3,appendtempk,tempk);
    press = cat(3,appendpress,press);

    % re-allign from topography height to the top of troposphere
    spechum = flip(spechum,3);
    geomh = flip(geomh,3);
    tempk = flip(tempk,3);
    press = flip(press,3);

    % assigning zero values of which points do have negative relative humidities
    spechum(spechum<0) = 0;
   
    % calculating wvp from specific humidity
    wvp = wvpcalcfromspechum(press,spechum);

    % height vector for interpolation
    hinterp = calcinterpgridheights; % interpolated heights to pressure levels

    % interpolate temperature (linear) as well as pressure and WVP
    % (exponential) over the densified height increments (hinterp)
    numintheight = length(hinterp);
    geomhfromell = nan(numlon,numlat,numintheight);
    tempkfromell = nan(numlon,numlat,numintheight);
    wvpfromell = nan(numlon,numlat,numintheight);
    pressfromell = nan(numlon,numlat,numintheight);

    for ilon = 1 : numlon
        for ilat = 1 : numlat
            % create the height increments of grid profiles starting at 1000 hPa pressure level
            geomhtemp = [];
            minhinterp = ceil(squeeze(geomh(ilon,ilat,1))*0.1)*10;
            geomhtemp = [geomh(ilon,ilat,1) hinterp(find(hinterp==minhinterp):end)];
            
            % interpolate temperature over the height increments 
            tempkfromell(ilon,ilat,find(hinterp==minhinterp)-1:end) = interp1(squeeze(geomh(ilon,ilat,:)),squeeze(tempk(ilon,ilat,:)),geomhtemp,'linear');
            
            % interpolate wvp and pressure over the height increments
            opt = 2;
            if opt == 1
                pressfromell(ilon,ilat,find(hinterp==minhinterp)-1:end) = interp1(squeeze(geomh(ilon,ilat,:)),squeeze(press(ilon,ilat,:)),geomhtemp,'spline');
                wvpfromell(ilon,ilat,find(hinterp==minhinterp)-1:end)  = interp1(squeeze(geomh(ilon,ilat,:)),squeeze(wvp(ilon,ilat,:)),geomhtemp,'spline');
            elseif opt == 2
                [presstopointerp,wvptopointerp] = interpgridpresswvp(hinterp(find(hinterp==minhinterp):end)',squeeze(geomh(ilon,ilat,:)),squeeze(press(ilon,ilat,:)),squeeze(wvp(ilon,ilat,:))); % pressure and wvp in Pa at levels (interpolated)
                pressfromell(ilon,ilat,find(hinterp==minhinterp)-1:end) = [press(ilon,ilat,1); presstopointerp];
                wvpfromell(ilon,ilat,find(hinterp==minhinterp)-1:end) = [wvp(ilon,ilat,1); wvptopointerp];
            end
            geomhfromell(ilon,ilat,find(hinterp==minhinterp)-1:end) = geomhtemp;
        end
    end

    % ZHD and ZWD from raytracing
    % calculating the densities over the grid profiles
    rhod = (pressfromell-wvpfromell)*(Md/R)*1./tempkfromell;  % [kg/m^3] densities of dry air
    rhow = wvpfromell*(Mw/R)*1./tempkfromell; % [kg/m^3] densities of wet air
    rho = rhod + rhow; % [kg/m^3] densities of total air

    % calculating the refractivities over the grid profiles
    Nh = k1*(R/Md).*rho;
    Nw = k3*(wvpfromell./tempkfromell.^2) + k2p*(wvpfromell./tempkfromell);
    N = Nh + Nw;

    % ray-tracing along zenith direction
    % refractive indices from refractivities (Nh, Nw)
    ntot = N*10^-6+ones(size(N,1),size(N,2),size(N,3),1);
    nh = Nh*10^-6+ones(size(Nh,1),size(Nh,2),size(Nh,3),1);
    nw = Nw*10^-6+ones(size(Nw,1),size(Nw,2),size(Nw,3),1);

    disp('Profiles are rearranged')
    disp('--------------------------')
    
    rtzdst = nan(numstat,3);       
    rtsdst = nan(numstat,length(elevation),length(azimuth),3);
    
    disp('Station ray-tracing is started')
    disp('--------------------------')
    % starting station-wise ray-tracing loop
    for istat = 1 : numstat
        
        wvpst = nan(numintheight,1);
        tempkst = nan(numintheight,1);
        pressst = nan(numintheight,1);
        geomhst = nan(numintheight,1);
        Nhst = nan(numintheight,1);
        Nwst = nan(numintheight,1);
        stat(istat).id
        lat = stat(istat).lat; % arcdeg
        lon = stat(istat).lon; % arcdeg
        lon(lon<0) = lon(lon<0) + 360; % converting longitude of station to between 0 and 360 degree
        h = stat(istat).ellh;
        
        % determine 4 adjacent grids of the station
        [ind_lat1lon1, ind_lat1lon2, ind_lat2lon2, ind_lat2lon1] = ...
            determine_grid_points(lat, lon, ...
            diff_lat, diff_lon, ...
            geodlat, geodlon);

        if geodlon(ind_lat1lon2(2)) == 0
            [LON,LAT] = meshgrid([geodlon(ind_lat1lon1(2));360],[geodlat(ind_lat2lon1(1));geodlat(ind_lat1lon1(1))]);
        else
            [LON,LAT] = meshgrid([geodlon(ind_lat1lon1(2));geodlon(ind_lat1lon2(2))],[geodlat(ind_lat2lon1(1));geodlat(ind_lat1lon1(1))]);
        end
        
        % determine interpolated the station values w.r.t. adjacent grids
        for ilevel = 1 : numintheight
            wvpst(ilevel,1) = interp2(LON,LAT,wvpfromell(ind_lat1lon1(2):ind_lat1lon2(2),ind_lat2lon2(1):ind_lat1lon1(1),ilevel),lon,lat,'linear');
            tempkst(ilevel,1) = interp2(LON,LAT,tempkfromell(ind_lat1lon1(2):ind_lat1lon2(2),ind_lat2lon2(1):ind_lat1lon1(1),ilevel),lon,lat,'linear');
            pressst(ilevel,1) = interp2(LON,LAT,pressfromell(ind_lat1lon1(2):ind_lat1lon2(2),ind_lat2lon2(1):ind_lat1lon1(1),ilevel),lon,lat,'linear');
            geomhst(ilevel,1) = interp2(LON,LAT,geomhfromell(ind_lat1lon1(2):ind_lat1lon2(2),ind_lat2lon2(1):ind_lat1lon1(1),ilevel),lon,lat,'linear');
            Nhst(ilevel,1) = interp2(LON,LAT,Nh(ind_lat1lon1(2):ind_lat1lon2(2),ind_lat2lon2(1):ind_lat1lon1(1),ilevel),lon,lat,'linear');
            Nwst(ilevel,1) = interp2(LON,LAT,Nw(ind_lat1lon1(2):ind_lat1lon2(2),ind_lat2lon2(1):ind_lat1lon1(1),ilevel),lon,lat,'linear');
        end
        
        % determine height level below station and assign "NaN" value and 
        % extrapolate to start the height level from the station.
        initind = min(find(geomhst>=h));
        geomhst(1:initind-2,1) = nan;
        geomhst(initind-1,1) = h;
        wvpst(1:initind-2,1) = nan;
        wvpst(initind-1,1) = interp1(geomhst(initind:initind+1),wvpst(initind:initind+1),h,'linear','extrap');
        tempkst(1:initind-2,1) = nan;
        tempkst(initind-1,1) = interp1(geomhst(initind:initind+1),tempkst(initind:initind+1),h,'linear','extrap');
        pressst(1:initind-2,1) = nan;
        pressst(initind-1,1) = interp1(geomhst(initind:initind+1),pressst(initind:initind+1),h,'linear','extrap');
        Nhst(1:initind-2,1) = nan;
        Nhst(initind-1,1) = interp1(geomhst(initind:initind+1),Nhst(initind:initind+1),h,'linear','extrap');
        Nwst(1:initind-2,1) = nan;
        Nwst(initind-1,1) = interp1(geomhst(initind:initind+1),Nwst(initind:initind+1),h,'linear','extrap');
        Nst = Nhst + Nwst;

        % ray-tracing along zenith direction
        % refractive indices from refractivities (Nh, Nw)
        ntotst = Nst*10^-6+ones(length(Nst),1);
        nhst = Nhst*10^-6+ones(length(Nhst),1);
        nwst = Nwst*10^-6+ones(length(Nwst),1);
        % calculate mean refractivities at station profile
        Nhstmean = (Nhst(1:end-1) + Nhst(2:end))*1e-6/2;
        Nwstmean = (Nwst(1:end-1) + Nwst(2:end))*1e-6/2;
        dh = geomhst(2:end)-geomhst(1:end-1);

        % zenith hydrostatic and wet delays at each increment over the profiles in [m]
        zhdstint = dh.*Nhstmean;
        zwdstint = dh.*Nwstmean;

        zhdstint(isnan(zhdstint))=0;
        zwdstint(isnan(zwdstint))=0;
        zhdst = sum(zhdstint);
        zwdst = sum(zwdstint);
        ztdst = zhdst + zwdst;
        rtzdst(istat,1:3) = [zhdst zwdst ztdst];
 
        %% SHD and SWD from 2-dimensional ray-tracing
        numlevels = size(geomhfromell,3);

        % determine the starting level
        count = 0;
        for ilevel = 1 : numlevels
            if ~isnan(geomhst(ilevel)), break ,end
        end
        % loop over the elevation angles and azimuths
        for iaz = 1 : length(azimuth) 
            for ielv = 1 : length(elevation) 
                count = count + 1;
                az = azimuth(iaz);
                e_outgoing = elevation(ielv);
                % determine a priori geometric bending correction
                ap_bend = 0.02*exp(-geomhst(ilevel)/6000)/tand(e_outgoing); %  degree
                % determine initial theta elevation angle
                theta_start = e_outgoing + ap_bend;
                accuracy_elev = 5.7*10^-6;
                loop_elev = 0;

                cond = 0;
                while 1
                    theta1 = theta_start;
                    el1 = theta1;
                    [r0,~] = eulerradius(lat,az); % Calculate earth radius w.r.t. the Euler radius of curvature
                    hi1 = geomhst(ilevel); % The ellipsoidal height of the topography
                    ri1 = r0 + hi1; % distance from geocenter
                    eta1 = 0; % initial geocentric angle
                    % Initial coordinates
                    z1 = ri1; % z-axis
                    y1 = 0; % y-axis
                    
                    % Second height level values
                    hi2 = geomhst(ilevel+1); % Just one level up from the topography
                    ri2 = r0 + hi2; % distance from geocenter for second ray point
                    si = -ri1*sind(theta1) + sqrt(ri2^2-ri1^2*cosd(theta1)^2); % distance between two ray points
                    z2 = z1 + si*sind(el1); % z-axis coordinate of second ray point
                    y2 = y1 + si*cosd(el1); % y-axis coordinate of second ray point
                    eta2 = atan2d(y2,z2); % geocentric angle between two ray points
                    delta2 = eta2 - eta1; % geocentric angle difference

                    nh1 = nhst(ilevel); % hydrostatic refractive indice at station
                    nw1 = nwst(ilevel); % wet refractive indice at station
                    ni1 = ntotst(ilevel); % total refractive indice at station
                    [lati,loni] = latlon_calc(lat,lon,az,delta2); % determine spherical coordinate of the next ray point
                    nh2 = horizontal_interp(lati,loni,geodlat,geodlon,ilevel,nh); % horizontal interpolation to determine hydrostatic refractive indice of the next ray point
                    nw2 = horizontal_interp(lati,loni,geodlat,geodlon,ilevel,nw); % horizontal interpolation to determine wet refractive indice of the next ray point
                    ni2 = horizontal_interp(lati,loni,geodlat,geodlon,ilevel,ntot); % horizontal interpolation to determine total refractive indice of the next ray point
                    theta2 = acosd((ni1/ni2)*cosd(theta1+delta2)); % calculate elevation angle of next ray point
                    el2 = theta2 - eta2; % calculate elevation angle
                    s(1) = si; ri(1) = ri1; ri(2) = ri2;
                    theta(1) = theta1; theta(2) = theta2;
                    latrt(1) = lat; lonrt(1) = lon; latrt(2) = lati; lonrt(2) = loni;
                    hi(1) = hi1; hi(2) = hi2; ni(1) = ni1; ni(2) = ni2;
                    nh_(1) = nh1; nh_(2) = nh2; nw_(1) = nw1; nw_(2) = nw2;
                    ze(1) = z1; ze(2) = z2; y(1) = y1; y(2) = y2;
                    elv(1) = el1; elv(2) = el2; eta(1) = eta1; eta(2) = eta2;
                    delta(1) = 0; delta(2) = delta2;
                    DELTA(1) = 0; DELTA(2) = delta2;

                    i = 2;
                    for k = ilevel + 2 : numlevels-1
                        i = i + 1;
                        hi(i) = geomhst(k);
                        ri(i) = r0 + hi(i); % distance from geocenter
                        s(i-1) = -ri(i-1)*sind(theta(i-1)) + sqrt(ri(i)^2-ri(i-1)^2*cosd(theta(i-1))^2); % distance between two ray points
                        ze(i) = ze(i-1) + s(i-1)*sind(elv(i-1)); % z-axis coordinate of the ray point
                        y(i) = y(i-1) + s(i-1)*cosd(elv(i-1)); % y-axis coordinate of the ray point
                        eta(i) = atan2d(y(i),ze(i)); % geocentric angle between two ray points
                        DELTA(i) = eta(i) - eta(1); % geocentric angle difference w.r.t. first ray point
                        [latrt(i),lonrt(i)] = latlon_calc(lat,lon,az,DELTA(i)); % determine spherical coordinate of the next ray point
                        nh_(i) = horizontal_interp(latrt(i),lonrt(i),geodlat,geodlon,k-1,nh); % horizontal interpolation to determine hydrostatic refractive indice of the next ray point 
                        nw_(i) = horizontal_interp(latrt(i),lonrt(i),geodlat,geodlon,k-1,nw); % horizontal interpolation to determine wet refractive indice of the next ray point 
                        ni(i) = horizontal_interp(latrt(i),lonrt(i),geodlat,geodlon,k-1,ntot); % horizontal interpolation to determine total refractive indice of the next ray point 
                        delta(i) = eta(i) - eta(i-1); % geocentric angle difference
                        theta(i) = acosd((ni(i-1)/ni(i))*cosd(theta(i-1)+delta(i))); % calculate elevation angle of next ray point
                        elv(i) = theta(i) - eta(i); % calculate elevation angle
                    end
                    % iteration of calculating outgoing elevation angle
                    diff_e = e_outgoing - elv(end);
                    loop_elev = loop_elev + 1;
                    theta_start = theta_start + diff_e;
                    if cond == 1
                        break
                    end
                    if  abs(diff_e) < accuracy_elev || loop_elev >= 10
                        cond = 1;
                        continue
                    end
                end
                % mean refractive indices along ray path
                nwmean = (nw_(2:end)+nw_(1:end-1))/2;
                nhmean = (nh_(2:end)+nh_(1:end-1))/2;

                % The total effect of geometric bending on slanth path in meters
                dgeo = sum(s-cosd(elv(1:end-1)-ones(1,length(s))*elv(end)).*s);
                
                % calculate SHD
                shd = sum((nhmean-1).*s) + dgeo;
                rtsdst(istat,ielv,iaz,1) = shd;
                
                % calculate SWD
                swd = sum((nwmean-1).*s);
                rtsdst(istat,ielv,iaz,2) = swd;
                
                % calculate STD
                rtsdst(istat,ielv,iaz,3) = shd + swd;
                
                % writing parameters to output file
                [yyDoySecond] = mjd2yydoysecod(mjd);
                fprintf(art,['%6d %11.5f %d %3d %2d %2d %5.2f %-8s %20.15f '...
                    '%20.15f %-8s %6s %7s %6s %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f '...
                    '%12.7f %12.7f %9.4f %10.5f %10.5f %10.5f %6.2f %7.2f %6.2f\n'],...
                    count,mjd,datestr(iep,1),yyDoySecond(2),datestr(iep,4),datestr(iep,5),datestr(iep,6),...
                    stat(istat).id,deg2rad(azimuth(iaz)),deg2rad(elevation(ielv)),src,t_meas,p_meas,wvp_meas,...
                    rtzdst(istat,3),rtzdst(istat,1),rtzdst(istat,2),...
                    rtsdst(istat,ielv,iaz,3),rtsdst(istat,ielv,iaz,1),rtsdst(istat,ielv,iaz,2),...
                    deg2rad(el1),deg2rad(elv(end)),dgeo,rtsdst(istat,ielv,iaz,3)./rtzdst(istat,3),...
                    rtsdst(istat,ielv,iaz,1)./rtzdst(istat,1),rtsdst(istat,ielv,iaz,2)./rtzdst(istat,2),...
                    kelvin2celsius(tempkst(find(~isnan(tempkst),1,'first'))),pressst(find(~isnan(pressst),1,'first')) / 100,...
                    wvpst(find(~isnan(wvpst),1,'first')) / 100);
            end
            clear hi ri s ze y eta DELTA delta theta elv ni latrt lonrt nh_ nw_
        end
    end
    fclose(art);
    disp('Station ray-tracing is finished')
    disp('--------------------------')
end
