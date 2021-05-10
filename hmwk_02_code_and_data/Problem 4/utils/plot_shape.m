function plot_shape(shape)
    if (nargin == 1)
        f = shape.X.*shape.Y.*shape.Z;
    end
    trimesh(shape.TRIV, shape.X, shape.Y, shape.Z, 'FaceVertexCData', repmat([0.5 0.5 0.5],length(shape.X),1), ...
        'EdgeColor', 'k', 'FaceColor', 'interp');
    axis equal;
    axis off;
end