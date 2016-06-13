function video = opticalFlow(video,labels_img,iframe)

    % optical flow  一帧6个层，一个光流
    s_global = 1;
    for k1 = 1:size(labels_img,2)
        num_sp(k1) = max(labels_img{1,k1}(:));  %labels_img等同于superpixel，num_sp：一帧的sp个数
        stats{1,k1} = regionprops(labels_img{1,k1}, 'Centroid', 'Area');
        video.sup_idx_range(k1,1) = s_global;    %sup_idx_range 当前帧，6个层的起始、终止坐标
        video.sup_idx_range(k1,2) = s_global + num_sp(k1) - 1;
        video.sup_centers{1,k1} = reshape([stats{1,k1}(:).Centroid], [2, numel(stats{1,k1})] )'; %当前帧6个层的sp中心
        video.sup_area{1,k1} = [stats{1,k1}(:).Area]'; %当前帧6个层的sp面积
    end        
    

    if iframe < length(video.frame) %当前分割的帧
		[Vx,Vy,reliab] = optFlowLk(video.grayscale_frames(:,:,iframe), video.grayscale_frames(:,:,iframe+1), [], 4, 3, 3e-6, 0 );
		reliab = reliab > 3e-6;

		video.Vx(:,:,iframe) = Vx;   
        video.Vy(:,:,iframe) = Vy;
		video.flow_reliab(:,:,iframe) = reliab;

        % sp与LK
        patch_size = 200;        
        for k2 = 1:size(labels_img,2) %一帧的所有层
            s_patch = 1;
            for s = 1:num_sp(k2) %一层的所有sp（patch）  
                sup_idx = labels_img{1,k2}==s; %取出当前的patch。大小=img大小
                reliable_pixels = reliab(sup_idx); %取出当前patch的pixle-flow
                numReliab = sum(reliable_pixels); %当前patch的pixle-flow 可信flow(=1)个数

                [y_sp,x_sp] = find(sup_idx); %当前patch在img中的坐标
                weights = exp(- ( (x_sp-video.sup_centers{1,k2}(s_patch, 1)).^2 + ...
                    (y_sp-video.sup_centers{1,k2}(s_patch, 2)).^2 ) / patch_size); %‘patch内每个pixel’与‘patch’距离
                sum_weights = sum(weights(reliable_pixels));
                
                if(numReliab > 0)
                    video.supSpeed{1,k2}(s_patch, 1) = sum(Vx(sup_idx & reliab).*weights(reliable_pixels)) / sum_weights; %每层每个patch中为1的flow的speed
                    video.supSpeed{1,k2}(s_patch, 2) = sum(Vy(sup_idx & reliab).*weights(reliable_pixels)) / sum_weights;
                    video.supSpeedReliab{1,k2}(s_patch,1) = (numReliab / video.sup_area{1,k2}(s_patch)) > 0.1;
                else
                    video.supSpeed{1,k2}(s_patch, 1) = 0;
                    video.supSpeed{1,k2}(s_patch, 2) = 0;
                    video.supSpeedReliab{1,k2}(s_patch, 1) = 0;
                end
                
                s_patch = s_patch + 1;
            end  
        end
        
    else %最后一帧，没有flow
        for kt=1:size(labels_img,2)
            video.supSpeed{1,kt} = zeros(num_sp(kt),2);
            video.supSpeedReliab{1,kt} = zeros(num_sp(kt),2);
        end
    end  
end