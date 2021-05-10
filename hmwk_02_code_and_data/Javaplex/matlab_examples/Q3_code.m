% Code for Problem 3

%% Setup
clc; clear; close all;
import edu.stanford.math.plex4.*;

javaaddpath('./lib/javaplex.jar');
import edu.stanford.math.plex4.*;
javaaddpath('./lib/plex-viewer.jar');
import edu.stanford.math.plex_viewer.*;
cd './utility';
addpath(pwd);
cd '..';

load('shapes.mat')

%% Compute Intervals

% kth shape = shapes{1, 1}{1, k}; k element of {1, 2, 3, 4, 5, 6}

shapeIntervals = cell([1 6]);

for i = 1:6
    shape = shapes{1, 1}{1, i};
    num_landmark_points = 50;
    maxmin_selector = api.Plex4.createMaxMinSelector(shape, num_landmark_points);
    maxmin_points = shape(maxmin_selector.getLandmarkPoints() + 1, :);
    max_dimension = 3;
    max_filtration_value = 200;
    num_divisions = 1000;
    stream = api.Plex4.createVietorisRipsStream(maxmin_points, max_dimension, ...
           max_filtration_value, num_divisions);
    persistence = api.Plex4.getModularSimplicialAlgorithm(max_dimension, 2);
    intervals = persistence.computeIntervals(stream);
    shapeIntervals{i} = intervals;
end

%% Compute Bottleneck Distances

shapeDists = zeros([6 6 3]);

for i = 1:5
    for j = (i+1):6
        for dim = 0:2
            dists = bottleneck_distances(shapeIntervals{1, i}, shapeIntervals{1, j}, dim);
            shapeDists(i, j, dim + 1) = dists;
            shapeDists(j, i, dim + 1) = dists;
        end
    end
end

%% Bottleneck Distance Function
% This code comes from bottleneck_distance_example.m in the
% tutorial_examples folder

function dists = bottleneck_distances(intervalsA, intervalsB, dim)
intervalsA_dim=intervalsA.getIntervalsAtDimension(dim);
intervalsB_dim=intervalsB.getIntervalsAtDimension(dim);
dists = edu.stanford.math.plex4.bottleneck.BottleneckDistance.computeBottleneckDistance(intervalsA_dim,intervalsB_dim);
end



