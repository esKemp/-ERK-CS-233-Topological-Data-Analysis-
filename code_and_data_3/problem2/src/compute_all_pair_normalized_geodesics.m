%%
% CS233 Homework 3
% Stanford University
% Author: Minhyuk Sung (mhsung@cs.stanford.edu)
% Last Updated: Mar. 2016.
%
% This file is subject to the terms and conditions defined in
% file 'LICENSE.txt', which is part of this source code package.
%

%%
function pair_geods = compute_all_pair_normalized_geodesics(mesh, vids)

    num_vids = length(vids);
    pair_geods = zeros(num_vids, num_vids);

    % Compute the longest distance on the mesh.
    % Find the farthest point 'p' from any point.
    dists = comp_geodesics_to_all(...
        mesh.vertices(:,1), mesh.vertices(:,2), mesh.vertices(:,3),...
        mesh.triangles', 1);
    [~, p_idx] = max(dists);
    
    % Find the farthest point from point 'p'.
    dists = comp_geodesics_to_all(...
        mesh.vertices(:,1), mesh.vertices(:,2), mesh.vertices(:,3),...
        mesh.triangles', p_idx);
    max_dist = max(dists);
    
    for i = 1:num_vids
        dists = comp_geodesics_to_all(...
            mesh.vertices(:,1), mesh.vertices(:,2), mesh.vertices(:,3),...
            mesh.triangles', vids(i));
        pair_geods(i, :) = (dists(vids) ./ max_dist);
    end
    
    % Symmetrize.
    pair_geods = 0.5 * (pair_geods + pair_geods');
    
    % Ensure that the maximum normalized distance is zero.
    pair_geods(pair_geods > 1) = 1;
end