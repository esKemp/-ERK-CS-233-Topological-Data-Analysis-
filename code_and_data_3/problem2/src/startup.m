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
fmap_lib_path = '../FmapLib-Develop/';
addpath(genpath(fullfile(fmap_lib_path, '/src/')));
run(fullfile(fmap_lib_path, 'src',...
    'External_code', 'Geodesics', 'mex_compile.m'));
