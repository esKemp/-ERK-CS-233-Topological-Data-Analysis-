function Z = computeZ(R_temp, tightGraph)    
    Z = R_temp;

    for i = 1:numel(R_temp)
        s = R_temp(i);
        vertices = bfsearch(tightGraph, s);
        Z = union(Z, vertices);
    end
end