function [spd,direc] = uv2spd(east,north)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   uv2spd.m  $
% $Revision:   1.3  $
% $Author:   andrew.berkeley  $
% $Date:   May 30 2014 11:12:04  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create speed direction in a cartesian coordinate.
    % 
    % [spd,dir]=cmguv2spd(east,north)
    % 
    % east = east component, vector or matrix
    % north = north component, vector or matrix
    % spd = speed
    % dir = direction (degrees) in true north
    % 
    % east and north must be the same size. if matrices, calculation is performed
    % columnwise.
    % 
    % jpx @ usgs 01-03-01
    % 
    
    if nargin<2; help(mfilename);return;end;
    if any(size(east) - size(north))
        fprintf('\nTwo input arguments must be the same size.\n');
        return;
    end;
    % east=cmgdataclean(east);
    % north=cmgdataclean(north);

    [direc,spd]=cart2pol(north,east);
    direc=direc*180/pi;
    indx=find(direc<0);
    direc(indx)=direc(indx)+360;

return;
