function F = hks_surface(S, ts)
    C = [S.surface.X S.surface.Y S.surface.Z];
    W = cotWeights(C, S.surface.TRIV);
    A = vertexAreas(C, S.surface.TRIV);

    A = A/sum(A);
    [e,v] = eigs(W,spdiags(A,0,S.surface.nv,S.surface.nv),100,-1e-5);

    [v,order] = sort(diag(v),'ascend');

    L.evals = v;
    L.evecs = e(:,order);
    L.A = spdiags(A,0,S.surface.nv,S.surface.nv);
    
    F = hks(L, ts);
end