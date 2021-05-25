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
clear all;

% Set 'true' for comparing with mobius matching.
use_sparse_landmarks = false;

mesh_dir = '../data/meshes/';

addpath(genpath('../../problem1/code')); savepath;

if use_sparse_landmarks
    output_dir = '../outputs/sparse_pairwise_matching';
    landmark_filepath = '../data/sparse_landmark_vids.txt';
else
    output_dir = '../outputs/pairwise_matching';
    landmark_filepath = '../data/landmark_vids.txt';
end

mkdir(output_dir);


%% Load landmark points
[landmark_vids, landmark_names] = load_landmark_file(landmark_filepath);
num_landmarks = length(landmark_vids);


%% Load all meshes
template_mesh_filepath = fullfile(mesh_dir, 'template', 'mesh000.obj');
template_mesh_info = load_mesh_info(template_mesh_filepath);

test_mesh_filepaths = dir(fullfile(mesh_dir, 'test', '*.obj'));
num_test_meshes = length(test_mesh_filepaths);
test_mesh_infos = cell(num_test_meshes, 1);

for k = 1:num_test_meshes
    [~, test_name, ~] = fileparts(test_mesh_filepaths(k).name); 
    test_mesh_filepath = fullfile(mesh_dir, 'test', [test_name, '.obj']);
    test_mesh_infos{k} = load_mesh_info(test_mesh_filepath);
end


%% Find point correspondences
C_acc = zeros(num_landmarks, num_landmarks);

for k = 1:num_test_meshes
    test_mesh_info = test_mesh_infos{k};
    [~, test_name, ~] = fileparts(test_mesh_filepaths(k).name); 
    disp(test_name);
    
    
    % ---- To Do ---- $
    % Solve a MRF problem comparing geodesic distances of point pairs,
    % and compute binary correspondence matrix C.
    %
    % Let 'i' and 'j' indicate i-th (ia, ib) and j-th (ja, jb) landmark 
    % point pairs between template and test meshes.
    % 'ia' and 'ja' are points in the template mesh, and
    % 'ib' and 'jb' are points in the test mesh. Then,
    % M(i, j): exp(-|geod(ia, ja) - geod(ib, jb)|_2^2 / (2 * sigma)),
    % where 'geod' is geodesic distance normalized by the longest distance
    % on the surface.
    % Use sigma = 0.05, and use pairwise normalized geodesic distances
    % stored in 'template_geod_dists' and 'test_geod_dists' below.
    
    param_sigma = 0.05;
    template_geod_dists = compute_all_pair_normalized_geodesics(...
        template_mesh_info.mesh, landmark_vids);
    test_geod_dists = compute_all_pair_normalized_geodesics(...
        test_mesh_info.mesh, landmark_vids);
    
    % ---- Fill Here ---- $
    
    W = zeros(num_landmarks*num_landmarks);
    labels = zeros(1, num_landmarks*num_landmarks);
    nodes = zeros(1, num_landmarks*num_landmarks);

    k = 0;

    for node =  1:num_landmarks
        for label = 1:num_landmarks
           k = k + 1;
           nodes(k)  = node;
           labels(k) = label;
        end
    end


    for i = 1:length(nodes)
        for j = 1:length(labels)
            d1 = template_geod_dists(nodes(i), nodes(j));
            d2 = test_geod_dists(labels(i), labels(j));
            W(i,j) =  exp(-(d1 - d2)^2/(2*param_sigma));
        end
    end
    
    D = zeros(length(nodes),1);
        
    [sol1, score1, V1] = mrf(W, D, nodes, 50, 200);
    
    C = zeros([num_landmarks num_landmarks]);
    
    for i = 1:(num_landmarks*num_landmarks)
        C(nodes(i), labels(i)) = sol1(i);
    end
	
    % -------- $
    
    C_acc = C_acc + C;
    
    h = imagesc(C);
    axis square;
    set(gca, 'XTick', 1:num_landmarks, 'YTick', 1:num_landmarks);
    title(test_name)
    saveas(h, fullfile(output_dir, [test_name, '.png']), 'png');
    
    close all;
end

% Compute overall accuracy.
accuracy = sum(diag(C_acc)) / sum(C_acc(:));
disp(['Overall accuracy = ', num2str(accuracy)]);

% Save overall frequency matrix.
h = imagesc(C_acc);
axis square;
set(gca, 'XTick', 1:num_landmarks, 'YTick', 1:num_landmarks);
title('All frequency')
saveas(h, fullfile(output_dir, 'all_frequency.png'), 'png');
