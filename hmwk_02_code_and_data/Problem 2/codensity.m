function [Xgood, Xbad] = codensity(X, D, k, m)
% Given a point cloud X and a pairwise distance matrix D, 
% returns the m points with lowest codensity (wrt k)
% in Xgood, and the other points in Xbad.

% Input:
%   X - point cloud dim x N
%   D - distance matrix N x N
%   k - kth nearest neighbor to use in codensity computation
%   m - number of points to return
% Output:
%   Xgood - points with the lowest codensity_k, size dim x m 
%   Xbad - all other points, size dim x (N-m)
%   
Ds = sort(D);
CODk = Ds(k+1,:);
[~, kRank] = sort(CODk);
clear Ds CODk
[~,n] = size(X);
mBest = ismember((1:n), kRank(1:m));
Xgood = X(:,mBest); 
Xbad = X(:,~mBest);
end