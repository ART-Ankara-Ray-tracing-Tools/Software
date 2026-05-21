% ************************************************************************
% This function converts ICGEM gdf file to mat file.
%
% INPUT         :
% txtFilePath   : The file path and name containing the ICGEM data with the .gdf extension.
% matfilePath   : The file path and name of the undulation file to be created with the .mat extension.
%
% OUTPUT        :
% This function creates an undulation mat file.
%
% USAGE         :
%   convert_icgem_to_mat('EGM2008_World_1x1.gdf','EGM2008_World_1x1.mat')
%   convert_icgem_to_mat('UNDULATIONS/EGM2008_World_1x1.gdf','UNDULATIONS/EGM2008_World_1x1.mat')
% Coded by Kamil Teke and Ozgur Ozel [21 Dec 2025]
% ************************************************************************

function convert_icgem_to_mat(txtFilePath, matFilePath)
    format longg
    fid = fopen(txtFilePath, 'r');
    if fid == -1
        error('File is not open: %s', txtFilePath);
    end
    while true
        line = fgetl(fid);
        if contains(line, 'end_of_head')
            break;
        end
    end

    % Read data: [lon, lat, geoid]
    data = fscanf(fid, '%f %f %f', [3, Inf])';
    fclose(fid);

    lon = data(:, 1);
    lon(lon<0) = lon(lon<0) + 360;
    lat = data(:, 2);
    geoid = data(:, 3);

    lon_unique = unique(lon);
    lat_unique = flipud(unique(lat));

    [LON, LAT] = meshgrid(lon_unique, lat_unique);

    geoid_grid = nan(size(LAT));
    for i = 1:length(geoid)
        row = find(lat_unique == lat(i));
        col = find(lon_unique == lon(i));
        geoid_grid(row, col) = geoid(i);
    end

    save(matFilePath, 'LON', 'LAT', 'geoid_grid', 'lon_unique', 'lat_unique');
    fprintf('Grid data saved at "%s" file.\n', matFilePath);
end
