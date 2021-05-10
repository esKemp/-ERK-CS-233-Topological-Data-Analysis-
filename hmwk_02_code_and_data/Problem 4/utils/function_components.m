function C = function_components(S, F)
    T = S.surface.TRIV;

    I = [T(:,1);T(:,2);T(:,3)];
    J = [T(:,2);T(:,3);T(:,1)];
    K = double(F(I)==F(J));

    In = [I;J;I;J];
    Jn = [J;I;I;J];
    Sn = [K;K;K;K];

    nv = S.surface.nv;
    A = sparse(In,Jn,Sn,nv,nv);

    C = components(A);
end