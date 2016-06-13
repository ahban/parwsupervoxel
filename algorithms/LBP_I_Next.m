function center_points = LBP_I_Next(probs, labels_idx, center_points, phi, img)
% save each group seeds for next group's inialize seeds

[X, Y, ~] = size(img);
N = X * Y;

% get last frame's label_img of each iteration
idx_label = labels_idx(1 : N);
idx_probs = probs(1: N);
label_img = reshape(idx_label, X, Y);
prob_map = reshape(idx_probs, X, Y);

% center relocate and sp split
Cmt = 1 - prob_map;
Wx_all = exp(-Cmt/phi);
centers_new = [];
Ncenters = length(center_points);
for i = 1:Ncenters
    %%% center relocation
    [r, c] = find(label_img==i);
    Cmt_s = Cmt(label_img==i);
    Wx = Wx_all(label_img==i);
    mask = repmat(center_points(i,:), length(r), 1); 
    dists = sqrt(sum((mask-[r c]).^2, 2));

    % exclude the center point,avoid NaN value
    idx_centre = dists==0;
    Cmt_s(idx_centre) = [];
    r(idx_centre) = [];
    c(idx_centre) = [];
    dists(idx_centre) = [];
    Wx(idx_centre) = [];
    mass = sum(Wx.*(Cmt_s./dists));
    cp_new(1) = sum(Wx.*(Cmt_s./dists).*r)/mass;
    cp_new(2) = sum(Wx.*(Cmt_s./dists).*c)/mass;
    centers_new = [centers_new; cp_new]; 
end 
center_points = round(centers_new); 

% exclude NaN
[idx_nan, ~] = find(isnan(center_points));
center_points(idx_nan, :) = [];  %去除 idx_nan 所在的行

end