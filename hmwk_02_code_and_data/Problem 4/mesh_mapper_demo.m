%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% MAPPER ALGORITHM IN MATLAB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% based on the paper %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% "Topological Methods for the Analysis of High Dimensional Data Sets and 3D Object Recognition" %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% by Gurjeet Singh, Facundo Memoli and Gunnar Carlsson %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% (c) Maks Ovsjanikov, Vignesh Ganapathi-Subramanian, Leonidas J. Guibas - 2016  %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
clear all;
clc;

addpath('utils/');
addpath('matlab_bgl/');
addpath('shapes/');

%Enter input shape
test_shape = 'victoria23.off';

S = read_off_shape(test_shape);

fprintf('Read shape %s with %d vertices\n', test_shape, S.surface.nv);

fprintf('computing the input function...');tic;

% As an example, we consider the hks function.
f = S.surface.Z;

%Plot the function on the shape considered
subplot(1,2,1);
plot_function_tosca(S.surface, f);
fprintf('done\n');toc;

% Normalize the function to be between 0 and 1
f = (f-min(f))/(max(f)-min(f));

% Number of intervals to consider
ints = 10;

% By default we take the range of each interval to be double the gap
% between intervals, to make sure that intervals overlap.
gap = 2/ints-1e-9;

fprintf('Computing the Mapper graph with %d intervals...', ints); tic;
% This variable will store, in each column i, the connected components
% associated with i^th interval.
Z = zeros(S.surface.nv,ints);
cm = 0;
z = size(f);
lenZ = z(1);
for i=1:ints
    Fmin =(i-1)/ints;
    Fmax =Fmin+gap;
    
    F = zeros(size(f));
    % The indicator function of the interval.
    % ENTER YOUR CODE HERE - to set all values of F in the pre-image of f
    % within Fmin and Fmax to be 1.
    
    for j = 1:lenZ
        if (f(j) >= Fmin) && (f(j) <= Fmax)
            F(j) = 1;
        end 
    end
    
    % Compute the connected components of the indicator function of the
    % interval.
    % ENTER YOUR CODE HERE - to obtain connected components of F in shape S.
    
    C = function_components(S, F);
    
    % Remove the components corresponding to the 0 value -- not associated
    % with the indicator of the function.
    C(F==0) = 0;
    
    % Renumber the remaining components and add them to the list.
    [~,~,c] = unique(C);
    c = c - 1;
    c(c>0) = c(c>0) + cm;
    cm = max(c);
    Z(:,i) = c;
end

% ENTER YOUR CODE HERE - 
% Create the adjacency matrix An. Note that every component associated with
% i^th interval can only be adjacent to a component associated with either
% (i-1)^th or (i+1)^th interval. Use the function unique to find all unique
% pairs of rows between ith and (i+1)th columns of Z. For every unique row pair
% between column i and column i+1 of Z, add an edge between the vertices
% which define the unique row pair.
comps = unique(Z);
comps = comps(2:end);
arrCompSize = size(comps);
nc = arrCompSize(1);

An = zeros(nc,nc);

for i = 1:(ints - 1)
    compsCurr = unique(Z(:,i));
    compsCurr = compsCurr(2:end);
    compsNext = unique(Z(:,i+1));
    compsNext = compsNext(2:end);
    
    for j = 1:length(compsCurr)
        for h = 1:length(compsNext)
            r = find(Z(:,i) == compsCurr(j) & Z(:,i+1) == compsNext(h));
            if ~isempty(r)
                An(compsCurr(j), compsNext(h)) = 1;
                An(compsNext(h), compsCurr(j)) = 1;
            end
        end
    end
    
end

fprintf('done\n');toc;

% Create labels for the visualization.
Ls = {};
cc = 1;
for k=1:ints
    for j=1:length(unique(Z(:,k)))-1
        Ls{cc} = num2str(k);
        cc = cc+1;
    end
end
subplot(1,2,2);
X = plot_graph_wbgl(An,Ls);
axis square;
hold off;
