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
function [mesh, areas, descs] = compute_mesh_info(filepath)

    mesh = Mesh(filepath, '');
    
    % Associate an area with each vertex via the 'barycentric' rule.
    mesh.set_default_vertex_areas('barycentric');
    
    % Uses the cotangent scheme for the laplacian.
    lb = Laplace_Beltrami(mesh);
    
    areas = full(diag(lb.A));
    
    % Generate functions over the mesh vertices.
    feat_funcs = Mesh_Features(mesh, lb);
    
    % Parameters for the function generation.
    hks_samples    = 100;	% Feature dimensions.
    wks_samples    = 100;
    mc_samples     = 0;
    gc_samples     = 0;
    neigs          = 100;    % LB eigenvecs to be used.
    
    feat_funcs.compute_default_feautures(...
        neigs, wks_samples, hks_samples, mc_samples, gc_samples);
    
    descs = feat_funcs.F;
end