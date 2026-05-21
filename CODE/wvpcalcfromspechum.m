% ************************************************************************
% This function calculates water vapor pressure (wvp) from specific humidity.
%
% INPUT   :
% spechum : specific humidity in [kg/kg]
% press   : total pressure in [Pa]
%
% OUTPUT  :
% wvp     : water vapor pressure in [Pa]
%
% Coded by Kamil Teke and Ozgur Ozel [20 Dec 2025]
% ************************************************************************

function wvp = wvpcalcfromspechum(press,spechum)
            
% molar masses of dry and wet air, universal gas constant 
Md = 28.9644*1e-3; % [kg/mol]
Mw = 18.01528*1e-3;% [kg/mol]
eps = Mw/Md;

wvp = (spechum.*press)./(eps + (1-eps)*spechum); % [Pa] (kg*m^-1*s^-2)











