% ************************************************************************
% This function is main function for running to 2D Ray-traced delays.
%
% INPUT     :
% matfile   : This is .mat file converted from netCDF file. This file obtain 
%             using "readnetcdf.m" function. This file path is "INPUT/MAT/".
% statfile  : station mat file. This file path is "INPUT/STAT/"
% azimuth   : azimuth angles of 2D ray-tracing in [degree]
% elevation : elevation angles of 2D ray-tracing in [degree]
%
% OUTPUT    :
% This function create a text file with extention ".art". The art file is
% result of 2D ray-tracing delays.
%
% USAGE     :
%   run('AN2025.mat','stat.mat',[0:45:315],[3,3.3,4,5]) --> Single file usage
%   run('AN*','stat.mat',[0:45:315],[3,3.3,4,5])  --> Multiple mat files
%                                                     usage which are started 'AN'
%   run({'AN*','FC*'},'stat.mat',[0:45:315],[3,3.3,4,5])  --> Multiple mat files
%                                                     usage which are started 'AN'and 'FC'
%
% Coded by Kamil Teke and Ozgur Ozel [27 Dec 2025]
% ************************************************************************

function run(matfiles, statfile, azimuth, elevation)
tic
addpath('CODE','INPUT');
disp('Process has started')

matDir = 'INPUT/MAT/';
search_patterns = {};

% Input Validation (Convert to Cell Array safely)
if iscell(matfiles)
    search_patterns = matfiles; % Already a cell array {'FC*', 'AN*'}
elseif ischar(matfiles) || isstring(matfiles)
    search_patterns = {char(matfiles)}; % Convert single string or char matrix to cell array
else
    error('Invalid matfiles input. Please use a cell array, e.g., {''FC*'', ''AN*''}.');
end

% Scan All Patterns and Gather Files
files = []; % Initialize empty structure array for files
for p = 1:length(search_patterns)
    pattern = strtrim(search_patterns{p}); % Clean edge spaces
    if isempty(pattern), continue; end
    
    % Get files matching the current pattern
    matched_files = dir(fullfile(matDir, pattern));
    
    % Append found files to our main files list
    if ~isempty(matched_files)
        if isempty(files)
            files = matched_files;
        else
            files = [files; matched_files]; % Vertical concatenation of struct arrays
        end
    end
end

% Check if any file was found
if isempty(files)
    error('No matching .mat files were found in the INPUT/MAT folder.');
end

% Run Ray-Tracing Loop
for i = 1:length(files)
    matFile = files(i).name;
    fprintf('(%d/%d) Ray-tracing is starting: %s\n', ...
        i, length(files), files(i).name);
    raytracer(matFile, statfile, azimuth, elevation);
end

fprintf('All .mat files have been processed.\n');
disp('multi_run ended')
toc