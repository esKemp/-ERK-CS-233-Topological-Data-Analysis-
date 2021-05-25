function C = hungarian_algorithm(costMatrix, num_landmarks)
% I have impelemented here the Hungarian algorithm as described in
% https://en.wikipedia.org/wiki/Hungarian_algorithm.
% I represent the temp vertices through rows and test vertices through
% cols
% 1                 ... num_landmarks   are temp vertices
% num_landmarks + 1 ... 2*num_landmarks are test vertices
% In directed graphs:
%   Negative means from temp to test
%   Positive means from test to temp

    C = zeros(num_landmarks, num_landmarks);
        
    potential = zeros(1, 2*num_landmarks);
    diGraph = (-1)*costMatrix; 
    
    R_temp = 1:num_landmarks;
    R_test = (num_landmarks + 1):(2*num_landmarks);
    
    num_matches = 0;
                
    while num_matches < num_landmarks 
        
        tightGraph = computeTightGraph(diGraph, potential, num_landmarks);
        Z = computeZ(R_temp, tightGraph);
               
        ZandRTest = intersect(Z, R_test);
        
        if ZandRTest   
            [diGraph, C, num_matches, R_temp, R_test] = increment_matching(diGraph, C, num_matches, R_temp, R_test, potential, ZandRTest, num_landmarks);
        else
            Delta = computeDelta(Z, R_test, R_temp, costMatrix, potential, num_landmarks);
            potential = deltaUpdate(Delta, Z, potential, R_temp, R_test);
        end
    end
    
end