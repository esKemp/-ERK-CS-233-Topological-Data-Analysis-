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
function [vids, names] = load_landmark_file(filepath)

    fid = fopen(filepath);
    landmarks = textscan(fid,'%d,%s','delimiter','\n');
    vids = double(landmarks{1});
    names = landmarks{2};
    
    % NOTE: Make vertex ids start at 1 (Matlab-style).
    vids = vids + 1;
    
    fclose(fid);
end