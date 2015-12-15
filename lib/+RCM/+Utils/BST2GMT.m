function [timeGMT]=BST2GMT(dateTime,pressure,easting,northing)
% function [timeGMT]=BST2GMT(dateTime,pressure,easting,northing)
%
% BST2GMT checks if a time vector is in GMT or BST and corrects it to GMT if necessary. 
% This is achieved by comparing 2 pressure/WL records, one is the input pressure/WL 
% record and the other is created from the closest TotalTide WL station. 
%
% Input: 
% dateTime vector
% pressure/WL vector
% easting of pressure/WL record
% northing of pressure/WL record
%
% Output:
% time in GMT. 
%
% dependencies: findTSOverlap.m

% Gunda Wieczorek, SEPA, 27/08/2014

% extract Tidal Data from closest Port
portEN=TotalTide.closestStation(easting,northing,'EN');
a=datestr(dateTime(1), 'dd/mm/yyyy');
dateLength=fix(dateTime(end)-dateTime(1));
WL=TotalTide.getStationHeights(portEN,a,dateLength,20);
% WL=profile.totalTideContext(0,15,'plot',0,'resolution',20); % get heights of nearest port out supress plot

% shorten both datasets by finding the overlapping time period:
[indexTSP,indexTSWL]=RCM.Utils.findTSOverlap(dateTime,WL.time);

% detrend Pressure data:
detrPres=detrend(pressure(indexTSP));
% detrend WL
detrWL=detrend(WL.height(indexTSWL)');

% modify the time indexes as well:
modDateTimePres=dateTime(indexTSP);
modDateTimeWL=WL.time(indexTSWL)';
%% get the peaks and troughs
peakIndicesWL = findPeaksAndTroughIndexes(detrWL, 5);
peakIndicesPres = findPeaksAndTroughIndexes(detrPres, 5);

%% calculate the differences between the 2 time vectors:
for ii=1:length(modDateTimeWL(peakIndicesWL))
dt(ii)=abs(diff([modDateTimePres(peakIndicesPres(ii)) modDateTimeWL(peakIndicesWL(ii))]));
end
% take the mean of all time differences; if the difference is more than 50 min (0.034 days) 
% the time is in BST:
fprintf('\n') % line break in display
meanDt=mean(dt);
disp([num2str(meanDt),' is the average time difference between the 2 timeseries'])

meanDt5=mean(dt(1:5));
fprintf('\n') % line break in display
disp([num2str(meanDt5),' is the average time difference of first 5 values of the 2 timeseries'])

if meanDt>0.034
    fprintf('\n') % line break in display
    disp('time is in BST')
    % If data set is in BST, change it to GMT!
    % remove 1 hour from data if necessary:
    for ii=1:length(dateTime);
        timeGMT(ii)=addtodate(dateTime(ii),-1,'hour');
    end
else
    fprintf('\n') % line break in display
    disp('time is in GMT')
    timeGMT=dateTime;
end


%% plot detrended Total Tide WL vs. detrended Pressure
figure
plot(modDateTimeWL,detrWL,'.-')
hold on
plot(modDateTimePres,detrPres,'.-k')
% plot peaks and troughs in figure:
plot(modDateTimePres(peakIndicesPres),detrPres(peakIndicesPres),'or')
plot(modDateTimeWL(peakIndicesWL),detrWL(peakIndicesWL),'or')
% plot the new time (GMT in the former plot):
plot(timeGMT(indexTSP),detrPres,'c.-')
timeaxis(1,[],[],20)


%% check the times (print first 6 times of both data sets in command window):
fprintf('\n') % line break in display
disp('dates Pressure Record:')
disp(datestr(timeGMT(peakIndicesPres(1:5))));
disp('dates Total Tide:')
disp(datestr(modDateTimeWL(peakIndicesWL(1:5))));
end

