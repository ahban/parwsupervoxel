function video = opticalFlow(video,labels_img,iframe)

    % optical flow  һ֡6���㣬һ������
    s_global = 1;
    for k1 = 1:size(labels_img,2)
        num_sp(k1) = max(labels_img{1,k1}(:));  %labels_img��ͬ��superpixel��num_sp��һ֡��sp����
        stats{1,k1} = regionprops(labels_img{1,k1}, 'Centroid', 'Area');
        video.sup_idx_range(k1,1) = s_global;    %sup_idx_range ��ǰ֡��6�������ʼ����ֹ����
        video.sup_idx_range(k1,2) = s_global + num_sp(k1) - 1;
        video.sup_centers{1,k1} = reshape([stats{1,k1}(:).Centroid], [2, numel(stats{1,k1})] )'; %��ǰ֡6�����sp����
        video.sup_area{1,k1} = [stats{1,k1}(:).Area]'; %��ǰ֡6�����sp���
    end        
    

    if iframe < length(video.frame) %��ǰ�ָ��֡
		[Vx,Vy,reliab] = optFlowLk(video.grayscale_frames(:,:,iframe), video.grayscale_frames(:,:,iframe+1), [], 4, 3, 3e-6, 0 );
		reliab = reliab > 3e-6;

		video.Vx(:,:,iframe) = Vx;   
        video.Vy(:,:,iframe) = Vy;
		video.flow_reliab(:,:,iframe) = reliab;

        % sp��LK
        patch_size = 200;        
        for k2 = 1:size(labels_img,2) %һ֡�����в�
            s_patch = 1;
            for s = 1:num_sp(k2) %һ�������sp��patch��  
                sup_idx = labels_img{1,k2}==s; %ȡ����ǰ��patch����С=img��С
                reliable_pixels = reliab(sup_idx); %ȡ����ǰpatch��pixle-flow
                numReliab = sum(reliable_pixels); %��ǰpatch��pixle-flow ����flow(=1)����

                [y_sp,x_sp] = find(sup_idx); %��ǰpatch��img�е�����
                weights = exp(- ( (x_sp-video.sup_centers{1,k2}(s_patch, 1)).^2 + ...
                    (y_sp-video.sup_centers{1,k2}(s_patch, 2)).^2 ) / patch_size); %��patch��ÿ��pixel���롮patch������
                sum_weights = sum(weights(reliable_pixels));
                
                if(numReliab > 0)
                    video.supSpeed{1,k2}(s_patch, 1) = sum(Vx(sup_idx & reliab).*weights(reliable_pixels)) / sum_weights; %ÿ��ÿ��patch��Ϊ1��flow��speed
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
        
    else %���һ֡��û��flow
        for kt=1:size(labels_img,2)
            video.supSpeed{1,kt} = zeros(num_sp(kt),2);
            video.supSpeedReliab{1,kt} = zeros(num_sp(kt),2);
        end
    end  
end