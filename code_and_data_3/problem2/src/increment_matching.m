function [diGraph, C, num_matches, R_temp, R_test] = increment_matching(diGraph, C, num_matches, R_temp, R_test, potential, ZandRTest, num_landmarks)
    i = 1;
    notDone = true;
    while i <= numel(ZandRTest) && notDone
        vertex = ZandRTest(i);
        neighbors = find(diGraph(:, vertex - num_landmarks) < 0);
        for j = 1:numel(neighbors)
            pM = neighbors(j);
            vertexIndex = vertex - num_landmarks;
            if diGraph(pM,vertexIndex) < 0 && abs(diGraph(pM,vertexIndex)) - potential(vertex) - potential(pM) == 0
                diGraph(pM,vertexIndex) = (-1)*diGraph(pM,vertexIndex);
                C(pM,vertexIndex) = 1;
                R_temp = R_temp(R_temp ~= pM);
                R_test = R_test(R_test ~= vertex);
                num_matches = num_matches + 1;
                notDone = false;
                break
            end
        end
        i = i + 1;
    end
end