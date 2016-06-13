function video = energy_opts(video, affinity_sparse, center_points, cross_num, cur_idx, alpha, sigma)

%parameters
phi = 8;  % phi = 0.8;
disp(['start to segmentation frame ' num2str(cur_idx)]);

img = video.frame{1,cur_idx};
[X, Y, Z] = size(img); N = X*Y;

%% perform CT(i), generate SP(i)
if Z > 1,
    img = colorspace('Lab<-', img); % convert color space
end;
imgVals = reshape(img,N,Z);
[~, edges] = lattice(X,Y); clear points;
weights = makeweights(edges,imgVals,sigma);
W = adjacency(edges,weights,N); clear edges weights;
[probs, labels_idx] = CT_I(W, img, center_points, alpha);

if(cur_idx ~= video.numFrame)
    %% perform LBP(i), generate Seeds(i)_new
    I_new_center = LBP_I(probs, labels_idx, center_points, phi, img);

    %% perform CT(i,i+1), generate SP(i)_new
    [probs, labels_idx] = doRandomWalk(affinity_sparse, img, I_new_center, cross_num, alpha);
    
   %% perform OPT(i,i+1), generate Seeds(i+1) for next frame i+1
    %找到可信流，（1,0） 看seeds是否在这些可信流中间，在的话更新位置（根据流值），否则不更新
    [idx_x, idx_y] = find(video.flow_reliab{cur_idx}); %%当前帧的可信flow坐标
    idx_flow = (idx_y-1)*video.X + idx_x;
    idx_center = (I_new_center(:,2) - 1)*video.X + I_new_center(:,1);
    [~,iflow,icenter] = intersect(idx_flow,idx_center);

    reliab_Vx = video.Vx{cur_idx}(video.flow_reliab{cur_idx}); %当前帧的可信flow值
    reliab_Vy = video.Vy{cur_idx}(video.flow_reliab{cur_idx});
    tmp1=I_new_center(:,1);
    tmp2=I_new_center(:,2);
    tmp1(icenter) = tmp1(icenter) + reliab_Vx(iflow);
    tmp2(icenter) = tmp2(icenter) + reliab_Vy(iflow);
    Next_new_center(:, 1) = min(round(tmp1), video.X); 
    Next_new_center(:, 2) = min(round(tmp2), video.Y);
    %save Seeds(i+1) for next iteration
    video.seeds = Next_new_center;  

    
%     %%%test
%     %% perform LBP(i), generate Seeds(i)_new
%     I_new_center2 = LBP_I_Next(probs, labels_idx, I_new_center, phi, img);
% 
%     %% perform CT(i,i+1), generate SP(i)_new
%     [probs, labels_idx] = doRandomWalk(affinity_sparse, img, I_new_center2, cross_num, alpha);
%     
%     %% perform OPT(i,i+1), generate Seeds(i+1) for next frame i+1
%     %找到可信流，（1,0） 看seeds是否在这些可信流中间，在的话更新位置（根据流值），否则不更新
%     [idx_x, idx_y] = find(video.flow_reliab{cur_idx}); %%当前帧的可信flow坐标
%     idx_flow = (idx_y-1)*video.X + idx_x;
%     idx_center = (I_new_center2(:,2) - 1)*video.X + I_new_center2(:,1);
%     [~,iflow,icenter] = intersect(idx_flow,idx_center);
% 
%     reliab_Vx = video.Vx{cur_idx}(video.flow_reliab{cur_idx}); %当前帧的可信flow值
%     reliab_Vy = video.Vy{cur_idx}(video.flow_reliab{cur_idx});
%     tmp1=I_new_center2(:,1);
%     tmp2=I_new_center2(:,2);
%     tmp1(icenter) = tmp1(icenter) + reliab_Vx(iflow);
%     tmp2(icenter) = tmp2(icenter) + reliab_Vy(iflow);
%     Next_new_center(:, 1) = min(round(tmp1), video.X); 
%     Next_new_center(:, 2) = min(round(tmp2), video.Y);
%     %save Seeds(i+1) for next iteration
%     video.seeds = Next_new_center;  
end

%% save SP(i)_new (save segmentation result of frame I)
view_oversegmentation(video.frame, labels_idx, video.vname, cur_idx);

end
