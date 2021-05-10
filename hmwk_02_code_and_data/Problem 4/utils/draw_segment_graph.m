function draw_segment_graph(L,V,S)
  F = zeros(size(S.surface.X,1),1);

    for k=1:length(L)
         f = zeros(size(S.surface.TRIV,1),1);
         f(V{k}) = 1;
         f2v = tri2f2v(S.surface.TRIV);
         g = min(full(f2v*f),1);
         g(F>0) = 0;
         F = F + k*g;
    end
end