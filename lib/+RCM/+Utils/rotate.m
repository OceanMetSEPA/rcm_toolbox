function [u_out, v_out] = rotate(u, v, degrees)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   rotate.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:04:10  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %A function to rotate a Cartensian coordinate
    % 
    % [newx,newy]=cmgrotate(east,north,theta)
    % 	east = east component, vector or matrix
    % 	north = north component, vector or matrix
    % 			or
    %
    % kjr, usgs, 03-09-07 - added complex
    % jpx @ usgsg 01-03-01
    % jpx @ usgsg 03-08-01
    % 
    
    if nargin<3 
        help(mfilename);
        return;
    end;
    
    if ~isequal(length(u),length(v))
        error('The first two input arguments must have the same size.');
    end;
	
	theta = degrees*pi/180;
    
    u_out =  u.*cos(theta) + v.*sin(theta);
    v_out = -u.*sin(theta) + v.*cos(theta);
end
