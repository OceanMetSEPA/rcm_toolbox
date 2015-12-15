function op=iquantile(x,q,varargin)
% 'inverse' quantile function:
% Given a vector x, what percentage of its values are <=q?
% 
% INPUT:
% x - vector of values
% q - value to test - where does this fit in x?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   iquantile.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:04:10  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<2
    help iquantile
    return
end

options=struct;
options.nan=0;
options.ignore=[];
options.round=false; % round our values?
options=checkArguments(options,varargin);

x=x(:);
if ~options.nan
    %    fprintf('Removing NaNs...\n')
    %    fprintf('Lenght was %d\n',length(x));
    x=x(~isnan(x));
    %    fprintf('Now length %d\n',length(x));
end

if ~isempty(options.ignore)
    fprintf('Removing these values:\n')
    disp(options.ignore)
    x=x(~ismember(x,options.ignore));
    %    fprintf('Now we have %d values\n',length(x));
end

Nt=length(x);
Nq=length(q);
op=NaN(Nq,1); % store our inverse quantiles in this array

for i=1:Nq % for each quantile we're after
    cx=x<q(i); % are x values smaller than this? 
    Nb=sum(cx); % this is the number of smaller values
    op(i)=Nb/Nt*100; % percentage
end
if options.round
    op=round(op);
end
