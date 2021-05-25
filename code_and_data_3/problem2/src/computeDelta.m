function Delta = computeDelta(Z, R_test, R_temp, costMatrix, potential, num_landmarks)
    TempandZ = intersect(Z, R_temp);
    TestandNotZ = setxor(R_test, intersect(Z, R_test));
    Delta = 0;
    for i = 1:numel(TempandZ)
        for j = 1:numel(TestandNotZ)
            vertexI = TempandZ(i);
            vertexJ = TestandNotZ(j) - num_landmarks;
            possDelta = costMatrix(vertexI, vertexJ) - potential(vertexI) - potential(vertexJ + num_landmarks);
            if i == 1 && j == 1
                Delta = possDelta;
            elseif possDelta < Delta
                Delta = possDelta;
            end
        end
    end
end