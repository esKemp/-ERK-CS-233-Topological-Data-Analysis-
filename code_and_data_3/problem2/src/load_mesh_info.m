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
function mesh_info = load_mesh_info(filepath)

    [dir, mesh_name, ~] = fileparts(filepath);
    info_filepath = fullfile(dir, [mesh_name, '.mat']);
    
    try
        disp(['Loading "', info_filepath, '" ...']);
        load(info_filepath); 
    catch
        % Compute point descriptors.
        [mesh, ~, descs] = compute_mesh_info(filepath);
        
        disp(['Saving "', info_filepath, '" ...']);
        save(info_filepath, 'mesh_name', 'mesh', 'descs');
    end
    
    mesh_info.name = mesh_name;
    mesh_info.mesh = mesh;
    mesh_info.descs = descs;
end
