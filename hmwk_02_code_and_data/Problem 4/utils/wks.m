function [f] = wks(L1, ts)
    N = size(L1.evecs,2);
    D1 = L1.evecs(:,1:N).^2;
    
    evals1 = abs(L1.evals(1:N));
    M = 100;
    emin1 = log(evals1(2));
    emax1 = log(evals1(end));
    s1 = 7*(emax1-emin1)/M;
    emin1 = emin1 + 2*s1;
    emax1 = emax1 - 2*s1;
    es1 = linspace(emin1,emax1,M);
   % fprintf('%f\n',es1);
    
    T1 = exp(-((log(evals1) - ts).^2/(2*s1^2)));
    
    f = D1*T1;
%    T2 = exp(-abs(L2.evals(1:N))*ts);
%    G = D2*T2;    
    
end