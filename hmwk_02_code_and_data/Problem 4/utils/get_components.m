nv = length(S.surface.X);

T = S.surface.TRIV;

I = [T(:,1);T(:,2);T(:,3)];
J = [T(:,2);T(:,3);T(:,1)];
S = double(F(I)==F(J));

In = [I;J;I;J];
Jn = [J;I;I;J];
Sn = [S;S;S;S];

A = sparse(In,Jn,Sn,nv,nv);

C = components(A);

%%
nc = max(C);
An = zeros(nc,nc);
for i=1:nc
    for j=i+1:nc
        iss = max(double((C(In) == i & C(Jn) == j) | (C(In) == j & C(Jn) == i)));
        An(i,j) = iss;
        An(j,i) = iss;
    end
end

Cls = unique([C F],'rows');

X = plot_graph_wbgl(An,{L{Cls(:,2)}});

