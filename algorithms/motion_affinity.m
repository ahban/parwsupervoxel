function affinity_sparse = motion_affinity(sup1, sup2, affinity, video, cross_num, cur_idx)
% W_m = 1 - (||Vi-Vj||) / (max{||Vi||, ||Vj||})
% dis(pixel-center)*vx,vy -- speed -- flow for function

cur_frame = cur_idx-1;

affi_thresh = 0.0001;  %affinity threshold
Vx = [];  
Vy = [];
reliab = [];
N = video.X * video.Y;
motion_affinity = ones(size(sup1));
for iframe = 1: cross_num
    Vx = [Vx; video.Vx{cur_frame+iframe}(:)];
    Vy = [Vy; video.Vy{cur_frame+iframe}(:)];
    reliab = [reliab; video.flow_reliab{cur_frame+iframe}(:)];
    ind_frames(1 + (iframe-1)*N : iframe*N) = iframe;
end
speeds = [Vx, Vy];
ind_frames = ind_frames';
same_frame = ind_frames(sup1) == ind_frames(sup2);

flow_mag1 = sqrt(sum(speeds(sup1, :).^2, 2));
flow_mag2 = sqrt(sum(speeds(sup2, :).^2, 2));
flow_diff_mag = sqrt( sum((speeds(sup1, :) - speeds(sup2, :)).^2, 2) );
max_flow_mag = max(flow_mag1, flow_mag2);
flow_dist = flow_diff_mag ./ (max_flow_mag + eps);
motion_affinity_flow = max(0, min(1, 1-flow_dist));
motion_affinity_flow = (~reliab(sup1) | ~reliab(sup2)) + ...
        (reliab(sup1) & reliab(sup2)) .* motion_affinity_flow; %可信flow=motion_affinity_flow，不可信flow=1
%same frame：W=min(W_a, W_m)
motion_affinity(same_frame) = motion_affinity_flow(same_frame);  
affinity = max(affi_thresh, min(1-affi_thresh, min(motion_affinity, affinity)));
affinity = max(affi_thresh, min(1-affi_thresh, affinity));

affinity_sparse = [sup1, sup2, affinity];
end
