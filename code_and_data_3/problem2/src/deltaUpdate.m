function [potential] = deltaUpdate(Delta, Z, potential, R_temp, R_test)
    TempandZ = intersect(Z, R_temp);
    TestandZ = intersect(Z, R_test);
    for i = 1:numel(TempandZ)
        vertexI = TempandZ(i);
        potential(vertexI) = potential(vertexI) + Delta;
    end
    for j = 1:numel(TestandZ)
        vertexJ = TestandZ(j);
        potential(vertexJ) = potential(vertexJ) - Delta;
    end
end