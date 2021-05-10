function f2v = tri2f2v(T)

nf = size(T,1);
nv = max(max(T));
I = [T(:,1);T(:,2);T(:,3)];
J = [1:nf,1:nf,1:nf]';
S = ones(length(I),1);
f2v = sparse(I,J,S,nv,nf);