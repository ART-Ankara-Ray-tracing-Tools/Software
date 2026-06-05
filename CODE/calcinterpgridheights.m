% ************************************************************************
% This function calculates height vector for interpolation w.r.t. Rocken
% et.al (2001). Since the lowest topographic height in the world is -1000 meters,
% height increments have started from this level. 
%
% Reference:
% Rocken,C., Sokolovskiy, S., Johnson, J. M., and Hunt, D. (2001). Improved mapping of tropospheric delays.
% J. Atmos. Ocean. Technol., vol. 18, no. 7, pp. 1205–1213.
%
% OUTPUT  :
% hinterp : height vector for interpolation
%
% Coded by Kamil Teke and Ozgur Ozel [20 Dec 2025]
% ************************************************************************

function hinterp = calcinterpgridheights

hint10 = -1000:10:2000;
hint20 = 2020:20:6000;
hint50 = 6050:50:16000;
hint100 = 16100:100:36000;
hint500 = 36500:500:84000;
% height vector for interpolation
hinterp = [hint10 hint20 hint50 hint100 hint500];

