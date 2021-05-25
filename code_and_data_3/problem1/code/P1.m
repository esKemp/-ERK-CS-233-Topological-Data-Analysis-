%
% CS233 HW 3, Problem 1 Starter Code
%
clear all; close all;

% directory of rendered views of each shape
rendering_dir = '../data/100chairs_rendering/';
% number of chairs in our dataset
num_shapes = 100;
% number of rendered views for each shape
num_views = 16; 

% This sets up the toolbox before running hog_extraction.
% You may need to update the path.
addpath(genpath('../../../toolbox/channels')); savepath;
addpath(genpath('../../../Efficient_MAP_Code')); savepath;

%%
% P1(a): extract HoG features of each input image
%        to represent each shape by V x H dim feature.

% ------ Your code here ------- %
% TODO: implement hog_extraction.m 
% TODO: compute the representation of each shape 
%       by computing the HoG feature of each view

% dimension of hog_array: [15 15 36]

H_shape = [15 15 36];

hog_features = cell(num_shapes);

for shapeNum = 1:num_shapes
    hog_feature_array = [];
    for viewNum = 0:(num_views - 1)
        leading_zeros = '';
        if shapeNum < 100
            leading_zeros = '0';
        end
        if shapeNum < 10
            leading_zeros = '00';
        end
        fileName = [rendering_dir leading_zeros num2str(shapeNum) '_' num2str(viewNum) '.png' ];
        image = im2single(imresize(imread(fileName), [120 120]));
        H = hog_extraction(image);
        H_vec = reshape(H, [1 numel(H)]);
        hog_feature_array = [hog_feature_array; H_vec];
    end
    hog_features{shapeNum} = hog_feature_array;
end

im = cell(3);

for shapeNum = 1:3
    H_vec = hog_features{shapeNum}(viewNum, :);
    H = reshape(H_vec, H_shape);
    im{shapeNum} = hogDraw(H);
end

imagesc(im{1});
imagesc(im{2});
imagesc(im{3});


% ----------------------------- %

%%
% P1(b): compute pairwise dissimilarity matrix between shapes

% ------ Your code here ------- %
% TODO: implement pairwise_dissimilarity.m 
% TODO: compute the dissimilarity matrix between each pair of shapes

D_vals = cell([num_shapes num_shapes]);

for i = 1:num_shapes
    for j = 1:num_shapes
        D_vals{i, j} = pairwise_dissimilarity(hog_features{i}, hog_features{j});
    end
end

imagesc(D_vals{1, 2});

% ----------------------------- %


%%
% P1(c): joint shape alignment by MRF

% ------ Your code here ------- %
% TODO: implement mrf.m
% TODO: build W_ij matrix that holds affinities for all pairs of shapes
% TODO: build unary vector U
% TODO: call MRF solver to jointly align shapes

sigma = 7;

W = zeros([num_shapes*num_views num_shapes*num_views]);
U = rand([num_shapes*num_views 1]);
nodes = zeros([num_shapes*num_views 1]);

for i = 1:num_shapes
    startRow = (i - 1)*num_views + 1;
    endRow = startRow + num_views - 1;
    
    nodes(startRow:endRow, 1) = i*ones(num_views, 1);
    
    for j = 1:num_shapes        
        startCol = (j - 1)*num_views + 1;
        endCol = startCol + num_views - 1;
        W(startRow:endRow, startCol:endCol) = exp(-D_vals{i, j}/sigma);
     end
end

[sol, score, V] = mrf(W, U, nodes, 30, 200); 

dir = '../data/100chairs/';
for i = 1:num_shapes
    for j = 0:(num_views-1)
        index = (i - 1)*num_views + j + 1;
        if sol(index) == 1
            leading_zeros = '';
            if i < 100
                leading_zeros = '0';
            end
            if i < 10
                leading_zeros = '00';
            end
            fileName = [rendering_dir leading_zeros num2str(i) '_' num2str(j) '.png' ];
            OBJ = read_wobj(fileName);
            fullfilename = ['../aligned/' num2str(i) '_' num2str(j) '.obj' ];
            write_wobj(OBJ,fullfilename)
        end
    end
end

% ----------------------------- %
