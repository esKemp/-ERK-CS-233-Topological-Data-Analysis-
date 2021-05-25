function D = pairwise_dissimilarity(feat1, feat2)
% Compute pairwise dissimilarity matrix between two shapes.
% Input:
%   - feat1, feat2: VxH shape feature. Each row corresponds 
%                   to the HoG feature of an image view.
% Output:
%   - D : VxV dissimilarity matrix

% ------ Your code here ------- %

shape = size(feat1);
numViews = shape(1);

D = zeros([numViews numViews]);

% First compute dists for the first view of feat1
for j = 1:numViews
    D(1, j) = norm(feat1(1,:) - feat2(j,:));
end
    
% Then, use D(theta1, theta2) = C(theta), theta = theta2 - theta1 (mod
% 2 pi) to fill out the rest of D

for i = 2:numViews
    for j = 1:numViews
        JPrime = mod(j - i, numViews) + 1;
        D(i, j) = D(1, JPrime);
    end
end
    
% ----------------------------- %
end
