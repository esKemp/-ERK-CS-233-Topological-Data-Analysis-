function feature = hog_extraction(im)
% Extracts the HoG feature for a single input image.
% Input:
%   - im : image HxW
% Output:
%   - feature : HoG feature size H

% ------ Your code here ------- %
% TODO extract HoG feature for the image and store in feature variable
%      Remember to resize the image to 120x120 first.

feature = hog(im);

% ----------------------------- %
end