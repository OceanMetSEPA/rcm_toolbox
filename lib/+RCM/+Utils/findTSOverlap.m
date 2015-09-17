function [indexTS1,indexTS2]=findTSOverlap(timeseries1,timeseries2)
% [indexTS1,indexTS2]=findTSOverlap(timeseries1,timeseries2)
%
% "findTSoverlap" takes 2 sets of timeseries and finds the overlapping
% time period. These overlapping indexes are then kept
%
% Input:
% timeseries1 = dateTime of the first timeseries
% timeseries2 = dateTime of the second timeseries
%
% Output:
% indexTS1, indexTS2 = returns the 2 sets of indexes for the overlapping
% time periods. These indexes can then be used further.
% 
% % Gunda Wieczorek, SEPA, 26/08/2014

% find out which timeseries starts first
TS1StartFirst=1;
TS1EndFirst=1;
if timeseries1(1)>timeseries2(1)
    TS1StartFirst = 0;
    fprintf('\n') 
    disp('timeseries2 starts first')
else
    fprintf('\n') 
   disp('timeseries1 starts first') 
end

% find out which timeseries ends first
if timeseries1(end)>timeseries2(end)
    TS1EndFirst = 0;
    fprintf('\n') % line break in display
    disp('timeseries2 ends first')
else
    fprintf('\n') % line break in display
   disp('timeseries1 ends first') 
end

%% define the starting and finishing indexes of the 2 timeseries
TS1StartIndex=[];
TS1EndIndex=[];
TS2StartIndex=[];
TS2EndIndex=[];

% determine which timeseries starts first and which is the corresponding
% index in the other timeseries
if TS1StartFirst
    TS2StartIndex=1;
    
    for ii=1:length(timeseries1)
        diffTS1Start(ii)=abs(diff([timeseries1(ii), timeseries2(1)])); % calculate time difference between both timeseries
    end
    [B1,ix1]=sort(diffTS1Start); % sort by smallest difference
    BStart1=B1(1);
    TS1StartIndex=ix1(1);
else
    TS1StartIndex=1;
    for ii=1:length(timeseries2)
        diffTS2Start(ii)=abs(diff([timeseries1(1), timeseries2(ii)])); % calculate time difference between both timeseries
    end
    [B2,ix2]=sort(diffTS2Start); % sort by smallest difference
    BStart2=B2(1);
    TS2StartIndex=ix2(1);
end

% determine which timeseries ends first and which is the corresponding
% index in the other timeseries
if TS1EndFirst
    TS1EndIndex=length(timeseries1);
    for ii=1:length(timeseries2)
        diffTS2End(ii)=abs(diff([timeseries1(end), timeseries2(ii)])); % calculate time difference between both timeseries
    end
    [BE2,ixE2]=sort(diffTS2End); % sort by smallest difference
    BEnd2=BE2(1);
    TS2EndIndex=ixE2(1);
else
    TS2EndIndex=length(timeseries2);
    for ii=1:length(timeseries1)
        diffTS1End(ii)=abs(diff([timeseries1(ii), timeseries2(end)])); % calculate time difference between both timeseries
    end 
    [BE1,ixE1]=sort(diffTS1End); % sort by smallest difference
    BEnd1=BE1(1);
    TS1EndIndex=ixE1(1);
end

% Output: Vector of Indexes for both timeseries:
indexTS1=TS1StartIndex:TS1EndIndex;
indexTS2=TS2StartIndex:TS2EndIndex;
