function [min_idx min_dist] = find_point(S1,cursor_info)

x = cursor_info.Position;
s = S1.surface;

C = bsxfun(@minus,[s.X s.Y s.Z],x);

dists = sum(C.^2,2);

min_idx = find(dists == min(dists));
min_dist = dists(min_idx);
end

