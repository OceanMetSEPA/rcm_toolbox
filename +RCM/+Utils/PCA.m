function [ pcaStruct ] = PCA(u, v)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   PCA.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:04:10  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Returns the covariance matrix, eigen values and eigen vectors
    % associated with the passed in u and v components.
    %
    % Usage:
    %
    %  pca = RCM.Utils.PCA(u, v)
    %
    % Example:
    %
    %  RCM.Utils.PCA(u, v)
    %  ans = 
    %            covar: [2x2 double]
    %      eigenVector: [2x2 double]
    %       eigenValue: [2x2 double]
    %             cols: [2 1]
    %
    
    pcaStruct.covar = cov(u, v);
    [pcaStruct.eigenVector, pcaStruct.eigenValue] = eig(pcaStruct.covar); % eigenvector

    if pcaStruct.eigenValue(2,2) > pcaStruct.eigenValue(1,1)
        pcaStruct.cols = [2 1];
    else
        pcaStruct.cols = [1 2];
    end;
end

