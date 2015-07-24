function [ km ] = greatCircleDistance(point_a, point_b )
% Calculates the distance between two locations on the Earth's surface. 
% Locations are specified as lat/lng pairs using decimal degrees, and 
% distances are calculated using the Haversine formula whcih approximates the
% Earth as a sphere. 
%
% Usage:
% greatCircleDistance(point_a,point_b)%
%   where point_a, point_b are lat/lng pairs
%
% 
% OUTPUT:
%           Numeric value representing distance in km
%
% EXAMPLES:
%
%    [km]=greatCircleDistance(52,-1)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   greatCircleDistance.m  $
% $Revision:   1.0  $
% $Author:   ted.schlicke  $
% $Date:   Apr 08 2014 14:02:50  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
  help greatCircleDistance
  return
end

R = 6371; % Earth's radius in km

% This is the Haversine formula

point_a = point_a .* pi ./ 180;
point_b = point_b .* pi ./ 180;

delta_lat = point_b(1) - point_a(1);    % difference in latitude
delta_lon = point_b(2) - point_a(2);    % difference in longitude
a = sin(delta_lat/2)^2 + cos(point_a(1)) * cos(point_b(1)) * sin(delta_lon/2)^2;
c = 2 * atan2(sqrt(a), sqrt(1-a));

km = R * c;                             % distance in km
end

