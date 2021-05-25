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

if use_sparse_landmarks
    output_dir = '../outputs/sparse_desc_matching';
    landmark_filepath = '../data/sparse_landmark_vids.txt';
else
    output_dir = '../outputs/desc_matching_hungarian';
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

numFeatures = 200;

tempLD = zeros(num_landmarks, numFeatures);
for i = 1:num_landmarks
    landmark_Index = landmark_vids(i);
    tempLD(i, :) = template_mesh_info.descs(landmark_Index, :);
end

for k = 1:num_test_meshes
    test_mesh_info = test_mesh_infos{k};
    [~, test_name, ~] = fileparts(test_mesh_filepaths(k).name); 
    disp(test_name);
    
    
    % ---- To Do ---- $
    % Compute binary correspondence matrix C by comparing point
    % descriptors.
    %
    % Use descriptor vectors stored in '(mesh_info).descs'.
    % Each 'row' is a feature vector for each 'vertex'.
    % The vertex IDs of landmark points are stored in 'landmark_vids'.
    % You may want to use 'pdist2' function.
    %
    % For finding best correspondences, we recommend to implement
    % 'Hungarian algorithm'
    % (https://en.wikipedia.org/wiki/Hungarian_algorithm).
    % But any reasonable heuristic algorithm is also accepted.
    
    % ---- FILL HERE ---- $
            
    testLD = zeros(num_landmarks, numFeatures);
    for i = 1:num_landmarks
        landmark_Index = landmark_vids(i);
        testLD(i, :) = test_mesh_info.descs(landmark_Index, :);
    end
    distMatrix = pdist2(tempLD, testLD); % temps are rows, tests are cols
    
%     M = matchpairs(distMatrix,1000); % Very high cost to not matching a row
%     C = zeros([num_landmarks num_landmarks]);
%     for i = 1:num_landmarks
%         C(M(i,1), M(i,2)) = 1;
%     end

    C = hungarian_algorithm(distMatrix, num_landmarks);
    	
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
