% ************************************************************************
% This function converts netCDF files to .mat format.
%
% INPUT        :
% input_args   : netCDF file names.
%
% OUTPUT :
% This function creates a .mat format in the ../MAT folder.
%
% USAGE:
%   readnetcdf()  --> Converts ALL .nc files in the folder.
%   readnetcdf({'FC20*', 'AN*'})  --> Scans multiple wildcard patterns safely.
%   readnetcdf({'AN2025.nc', 'FC1992.nc'})  --> Converts specific file list.
%   readnetcdf('AN2*')  --> Can also take a single pattern string.
%
% Coded by Kamil Teke and Ozgur Ozel [08 Jun 2025]
% ************************************************************************

function readnetcdf(input_args)
tic;

% 1. Dynamic Path Configuration
current_file_path = fileparts(mfilename('fullpath'));
input_folder = fullfile(current_file_path, '..');
pathread  = fullfile(input_folder, 'NETCDF');
pathwrite = fullfile(input_folder, 'MAT');

search_patterns = {};
files_to_process = {};

% 2. Input Validation (Cell Array Oriented)
if nargin < 1 || isempty(input_args)
    % Default to scan everything if no input is provided
    search_patterns = {'*.nc'};
elseif iscell(input_args)
    % Ideal scenario: Cell array of strings ({'FC2025*', 'AN*'})
    search_patterns = input_args;
elseif ischar(input_args) || isstring(input_args)
    % If a single string is passed, automatically wrap it into a cell array
    search_patterns = {char(input_args)};
else
    error('Invalid input! Please use cell array format: readnetcdf( {''pattern1'', ''pattern2''} )');
end

% 3. Scan All Patterns and Build File List
for p = 1:length(search_patterns)
    pattern = strtrim(search_patterns{p}); % Clean edge spaces
    if isempty(pattern), continue; end
    
    % Automatically append .nc extension if missing
    if ~contains(pattern, '.nc')
        pattern = [pattern, '.nc'];
    end
    
    % If it doesn't contain a wildcard (*), treat it as a direct file name
    if ~contains(pattern, '*')
        files_to_process = [files_to_process, {pattern}];
    else
        % If wildcard exists, search matching files in the folder
        matched_files = dir(fullfile(pathread, pattern));
        if ~isempty(matched_files)
            files_to_process = [files_to_process, {matched_files.name}];
        end
    end
end

% Remove duplicate file names if any, keeping the original order
files_to_process = unique(files_to_process, 'stable');

if isempty(files_to_process)
    warning('No matching .nc files found for the specified criteria.');
    return;
end

fprintf('%d matching file(s) listed. Conversion starting...\n', length(files_to_process));
fprintf('--------------------------------------------------\n');

% 4. Start Loop Over the Determined File List
for file_idx = 1:length(files_to_process)
    
    file = files_to_process{file_idx};
    fprintf('(%d/%d) Processing: %s\n', file_idx, length(files_to_process), file);
    
    % Check if the file physically exists
    nc_file_full_path = fullfile(pathread, file);
    if ~exist(nc_file_full_path, 'file')
        warning('File not found in folder, skipping: %s', file);
        continue;
    end
    
    % Define mode to read nc-file
    mode = 'NC_NOWRITE';

    % Open nc-file
    ncid = netcdf.open(nc_file_full_path, mode);

    % Get # of dimensions, variables, global attributes and index of unlimited dimension
    [ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);

    % Generate the full path for the output .mat file
    save_file_path = fullfile(pathwrite, [file(1:end-3), '.mat']);

    % Read variables
    for varid = 0 : nvars - 1
        % Get infos from .nc file for 'running' varid
        [varname, xtype, varDimIDs, varAtts] = netcdf.inqVar(ncid, varid);
        % Read out data from variable
        eval([varname,'.val = netcdf.getVar(ncid, varid);']);
        % Read attributes of the variables
        for varattid = 0 : varAtts - 1
            % Read out data from variable Attributes
            attname = netcdf.inqAttName(ncid,varid,varattid);
            if ~strcmp(attname,'_FillValue')
                eval([varname,'.',attname,' = netcdf.getAtt(ncid, varid, attname);']);
            end
        end

        if varid == 0
            eval(['save -v7.3 ''', save_file_path, ''' ', varname, ';']);
        else
            eval(['save -append ''', save_file_path, ''' ', varname, ';']);
        end
    end

    % Read dimension names and lengths
    for idim = 0 : ndims-1
       [dimname, dimlen] = netcdf.inqDim(ncid,idim);
       dim(idim+1).name = dimname;
       dim(idim+1).length = dimlen;
    end
    eval(['save -append ''', save_file_path, ''' dim;']);

    netcdf.close(ncid);
    
    % Memory cleanup to protect RAM from swelling during large batch processes
    clearvars -except files_to_process file_idx pathread pathwrite input_folder current_file_path tic;
end

fprintf('--------------------------------------------------\n');
fprintf('All processes completed successfully.\n');
toc;
end
