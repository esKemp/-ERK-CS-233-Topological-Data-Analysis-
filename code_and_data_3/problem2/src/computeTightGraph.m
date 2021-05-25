function tightGraph = computeTightGraph(diGraph, potential, num_landmarks)
    tightMatrix = zeros([2*num_landmarks 2*num_landmarks]);
    for i = 1:num_landmarks
        for j = 1:num_landmarks
            if abs(diGraph(i, j)) - potential(i) - potential(num_landmarks + j) == 0
                if diGraph(i, j) > 0
                    tightMatrix(num_landmarks + j, i) = 1;
                else
                    tightMatrix(i, num_landmarks + j) = 1;
                end
            end
        end
    end
    tightGraph = digraph(tightMatrix);
end