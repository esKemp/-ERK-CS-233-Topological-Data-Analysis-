% ------------------------
% CS233 HW1
% Problem 1  Starter Code
% ------------------------

%% Introduction
clear all; close all; clc;
addpath('data_p1');
rng(0); 

% Load the face data set
extensions = {'centerlight', 'glasses', 'happy', 'leftlight', ...
    'noglasses', 'normal', 'rightlight', 'sad', 'sleepy', 'surprised', 'wink' };
load('YaleFaces');

% Cleaned up version -- currently commented out
% Faces(14) = [];
% Faces(13) = [];
% Faces(8) = [];
% extensions = {'centerlight', 'happy', ...
%     'noglasses', 'normal', 'sad', 'sleepy', 'surprised', 'wink' };

imH = 159; imW = 159;

% -----------------------------------------
%% TODO: (a) visualize mean faces from train set
% use imagesc for plotting

mean_face = zeros(imH,imW);
happy_mean_face = mean_face;
sad_mean_face = mean_face;

numImages = length(Faces)*length(extensions);
numFaces = length(Faces);

% Extract the faces into training and test faces
trainidx = 1;
testidx = 1;
for i = 1:length(Faces),
    for j = 1:length(extensions);
        X = double(Faces(i).(extensions{j}));
        if( rand > 0.3 )
            train(trainidx).data = X;
            train(trainidx).label = i;
            trainidx = trainidx + 1;
            % TODO: add code here to compute mean face
            % filter extensitions for happy and sad faces
            %
            
            mean_face = mean_face + X * (1/numImages);
         
            if extensions{j} == "happy"
                happy_mean_face = happy_mean_face + X * (1/numFaces);
            elseif extensions{j} == "sad"
                sad_mean_face = sad_mean_face + X * (1/numFaces);
            end;
            
        else
            test(testidx).data = X;
            test(testidx).label = i;
            testidx = testidx + 1;
        end;
    end;
end;

imagesc(happy_mean_face)
imagesc(sad_mean_face)
imagesc(mean_face)

% happy_mean_face = ...
% sad_mean_face = ...
% mean_face = ...


% Zero-center and put all train set images into a big matrix
idx = 1;
for i = 1:length(train),
    X = double(train(i).data);
    W = X - mean_face;
    M(:, idx) = W(:);
    idx = idx + 1;
end;


% -----------------------------------------

%% TODO: (b) do PCA (by MATLAB function svd) on face
% images and plot the energy (sum of top-k variances/total sum) curve
%

[U,S,V] = svd(M');

W = (1/numImages)*S*transpose(S);

shapeW = size(W);

numVariances = shapeW(1);

Energy = zeros([1 numVariances]);

Energy(1) = W(1,1);

for i = 2:numVariances
    Energy(i) = Energy(i - 1) + W(i,i);
end

Energy = Energy * (1/Energy(numVariances));

plot(Energy);

% -----------------------------------------
%% TODO: (c) show top 25 eigen faces
% Hint: you can create a large matrix (image) and set each
% eigen face image to a portion of it.
big_image = zeros(imH*5,imW*5);
eigen_idx = 1;
for i = 1:5
    for j = 1:5
        % TODO: fill in eigen face below
        index = (i - 1)*5 + j;
        big_image((i-1)*imH+1:i*imH, (j-1)*imW+1:j*imW) = reshape(V(:,index), [imH imW]);
    end
end
figure(2), imagesc(big_image), colormap('gray'); axis off;


% -----------------------------------------
%% TODO: (d) face reconstrunction
% reconstruct the first face train(1).data with different
% number of principal components
%

% Plot the orignal face
centered_face1 = train(1).data - mean_face;
orig_face1 = centered_face1 + mean_face;
figure, imagesc(orig_face1); 
colormap(gray); axis off; truesize; 

% Plot reconstructed faces, 
figure;
idx = 1;
for k = [1,10,20,30,40,50]
    
    % TODO: finish the reconstruction of using k eigen faces
    kV = V(:,1:k);
    Projector = kV*kV';
    reconstruction = Projector*M;
    recon = reshape(reconstruction(:,1), [imH imW]);
        
    subplot(2,3,idx), imagesc(recon);
    colormap(gray);
    axis off;
    
    idx = idx + 1;
end;


% -----------------------------------------
%% TODO: (e) face recognition
% For each test example, find best match in training data
%

% Put all of the testing faces into one big matrix
idx = 1;
for i = 1:length(test),
    X = double(test(i).data);
    Wh = X - mean_face; % zero-center it
    T(:, idx) = Wh(:);
    idx = idx + 1;
end;

k = 25;
kV = V(:,1:k);
Projector = kV*kV';
reconstruction = Projector*M;
for i = 1:length(train)
    % TODO: fill in projections of train set images
    % use top 25 eigen vectors
    trainweights(:,i) = reconstruction(:,i);
end;

figure;
figure_idx = 1;
row = 7;
col = ceil(length(test)/row);
accuracy_sum = 0;

reconstruction = Projector*T;
for i = 1:length(test)

    % TODO: fill in projections of i-th test set image
    % use top 25 eigen vectors
    testweights = reconstruction(:,i);
    
    % TODO: nearest neighbor serach: 
    % find closest train image to this test image
    minDistance = norm(trainweights(:,1) - testweights);
    minIndex = 1;
    
    for k = 2:length(train)
        dist = norm(trainweights(:,k) - testweights);
        if dist < minDistance
            minIndex = k;
            minDistance = dist;
        end
    end
        
    nearest_train_image = reshape(trainweights(:,minIndex),  [imH imW]);
    nearest_train_idx = minIndex;
    
    % This is to determien a relationship between extensions and the
    % accuracy of the labels 
    nearest_train_extension = 'toto';
    for j = 1:length(extensions)
        if double(Faces(train(nearest_train_idx).label).(extensions{j})) == double(train(minIndex).data)
            nearest_train_extension = extensions{j};
        end
    end
        
    % See if recognition is correct
    correct = (test(i).label == train(nearest_train_idx).label);
    accuracy_sum = accuracy_sum + correct;
    
    subplot(row,col,figure_idx), imagesc([test(i).data, nearest_train_image]);
    axis off; colormap(gray); drawnow;
    if correct
        title('\color{green}CORRECT');
        disp("CORRECT - " + nearest_train_extension);
    else
        title('\color{red}WRONG - ');
        disp("WRONG - " + nearest_train_extension);
    end
    figure_idx = figure_idx + 1;
    
end;

accuracy = accuracy_sum / length(test);
fprintf('Face recognition accuracy: %f\n', accuracy);

% -----------------------------------------
%% TODO: (f) recognition for non-face image
%

%Now load three images and project them to both the eigenfaces,
% and to the orthogonal complement
k = 50;
kV = V(:,1:k);
Projector = kV*kV';
test_imgs = {'face1.jpg', 'face2.jpg', 'nonface1.jpg'};
for j=1:length(test_imgs),
    im = double(imread(test_imgs{j}));
    
    % TODO: use top-k eigen faces to reconstruct the image
    recon_im = reshape(Projector*reshape(im, [imH*imW 1]), [imH, imW]);
    
    figure, imagesc([im recon_im]);
    colormap(gray); axis off;
    
    % TODO: show the original and reconstructed image's
    % relative norm difference
    norm_diff = norm(recon_im - im);
        
end;


