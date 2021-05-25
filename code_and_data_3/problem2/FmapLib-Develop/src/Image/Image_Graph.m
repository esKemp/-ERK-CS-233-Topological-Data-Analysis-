classdef Image_Graph < Graph
    % A class representing a Graph object associated with an Image object.
    %
    % (c) Achlioptas, Guibas  - 2015  -  http://www.fmaplib.org
    
    properties (GetAccess = public, SetAccess = private)
        I;          %  (Image) - Underlying Image object.
    end
        
    methods (Access = public)
        % Class Constructor.               
        function obj = Image_Graph(in_image, varargin)
            % in_image      - (Image) associated with the Graph.
            % varargin{1}   - (String) describing
            %
                                    
            if nargin == 0                     % Set up super-class (Graph) arguments.
                super_args = cell(0);
            else
                if ischar(varargin{1})
                    [w, h] = size(in_image);                               
                    if strcmp('r_radius_connected', varargin{1})
                        radius = varargin{2};
                        G = Graph.generate('r_radius_connected', h, w, radius);
                    else                    
                        G = Graph.generate(varargin{1}, h, w);
                    end
                    super_args{1} = G.A;       % Adjacency matrix.            
                    super_args{2} = false;     % is_directed attribute.
                    super_args{3} = G.name;    % Graph's name.
                elseif isa(varargin{1}, 'Graph')
                    G = varargin{1};
                    super_args{1} = G.A;          
                    super_args{2} = G.is_directed;
                    super_args{3} = G.name;                        
                else
                    error('vargargin{1} must be either a string specifying a graph, or a Graph.');
                end
            end                        
            obj@Graph(super_args{:})            % End of super-class invocation.
            
            if nargin == 0                      % Set Image.
                obj.I = Image();
            else
                obj.I = in_image;             
            end            
        end
                
        function [I] = graph_node_to_pixel_index(obj, nodes)
            % Convert column-expanded nodes of pixel matrix (i.e.m nodes of graph), to 2D (i,j) indices for pixels.
            %
            %            
            h = obj.I.height;            
            I = zeros(length(nodes), 2);            
            I(:,2) = ceil(nodes ./ double(h));             % y
            I(:,1) = nodes - ((I(:,2) - 1) * h );          % x  
        end

        function obj = adjust_weights_via_feature_differences(obj, features, recipie, varargin)            
            [h, w, ~] = size(features);            
            if h ~= obj.I.height || w ~= obj.I.width    % TODO-P maybe better align with graph dimensions
                error('Feature dimensions are not compatible with the stored image.');
            end
                        
            if strcmp(recipie, 'normalized_cut')                
                options = struct('sigma_f', 'median', 'sigma_s', 'median');
                options = load_key_value_input_pairs(options, varargin{:});
                
                [i, j, vals]   = find(obj.A);
                sigma          = check_and_derive_sigma(options.sigma_s, vals);
                spatial_dists  = sparse(i, j, exp(-((vals).^2) ./ sigma) );
                
                [node_from, node_to] = obj.all_edges();
                from_index = obj.graph_node_to_pixel_index(node_from);
                to_index   = obj.graph_node_to_pixel_index(node_to);                
                edges      = obj.num_edges;
                assert(size(to_index,1) == edges);
                feature_dists  = zeros(edges, 1);
                for i = 1:edges                                 
                    f_from = squeeze(features(from_index(i,1), from_index(i,2), :));
                    f_to   = squeeze(features(to_index(i,1), to_index(i,2), :));
                    feature_dists(i) = norm(f_from - f_to);
                end
                sigma = check_and_derive_sigma(options.sigma_f, feature_dists);        
                                              
                feature_dists = exp( - ((feature_dists).^2) ./ sigma);                                
                num_nodes     = obj.num_vertices;
                feature_dists = sparse(node_from, node_to, feature_dists, num_nodes, num_nodes);    % Put values back in adjacecny matrix format.
                feature_dists = feature_dists + feature_dists';
                feature_dists = feature_dists .* spatial_dists;
                assert( all(nonzeros(feature_dists) > 0));
                                               
                obj.A         = feature_dists;
                obj.name      = [obj.name '_feat_adjusted'];
                assert(issymmetric(obj.A));                
                assert(obj.num_edges == edges);
            else
                error('Not implemented yet.')
            end
            
            function [newsigma] = check_and_derive_sigma(sigma, values)
                if strcmp(sigma, 'median')                    
                    newsigma = 2 * (median(values(:)))^2;                    
                else
                    if sigma <= 0
                        error('Provided standard deviation parameters must be all possitive.')
                    end     
                    newsigma = sigma;
                end
            end          
        end
        
        function obj = copy(this)
            % Define what is copied when a deep copy is performed.                    
            % Instantiate new object of the same class.
            obj = feval(class(this));      
                        
            % Copy all non-hidden properties (including dynamic ones)            
            p = properties(this);            
            for i = 1:length(p)
                if ~isprop(obj, p{i})   % Adds all the dynamic properties.
                    obj.addprop(p{i});
                end                
                obj.(p{i}) = this.(p{i});
            end           
        end
        
        function obj = set_new_image(obj, new_image)
            if size(new_image) ~= size(obj.I)
                warning('Updating the Image Graph with a new Image of different size than the original.')
            end
            obj.I = new_image;
        end
             
               
    end
    
    methods (Access = private)
        function [] = add_or_reset_property(obj, propname, value)
            % Check if the dynamic property already exists. In this case it
            % only updates it via the setter and the varargin. Otherwise, 
            % it first adds it on the object.            
            if isprop(obj, propname)
                obj.(propname) = value;
            else
                obj.addprop(propname);
                obj.(propname) = value;
            end
        end        
    end

end