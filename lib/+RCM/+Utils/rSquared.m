function [ r2 ] = rSquared(y, yPredicted)
    %RSQUARED Summary of this function goes here
    %   Detailed explanation goes here


    % Calculate the R2 value  - a measure of the model fit
    sse = sum((y - yPredicted).^2);
    sst = sum((y - mean(y)).^2);
    r2 = 1 - sse/sst;
end

