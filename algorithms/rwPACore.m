function [prob1, prob2] = rwPACore(img1, img2, seeds, boundary, sigma, alpha)
%Demo function for video segmentation using supervoxel
%2013.11 - Liang Yuling

% addpath 'algorithms';
% addpath 'others';
% addpath(genpath('optical_flow'));
% addpath(genpath('Dataset'));

% % parameter setting  
% sigma = 30; %gaussian parameter 
% PATCH_SIZE = 25; % initial supervoxel size(seeds) 12-200sp
% alpha = 0.0003; % RW parameter


% video = read_video;
% load('Video_Independence Day - 00734.mat');

% Initialize and place seeds
% seeds = place_seeds(video.X, video.Y, PATCH_SIZE);    

% for cur_idx = 1 : video.numFrame
    disp('***************************************');   
%     frame = video.frame{1,cur_idx};
    [X, Y, Z] = size(img1); 
    N = X*Y;
    % %% just PARW(f_i) segmentation
    if Z > 1
        %% ???img = img/255?
        img1 = double(img1)/255;
        img2 = double(img2)/255;
        img1 = colorspace('Lab<-', img1); % convert color space
        img2 = colorspace('Lab<-', img2);
    end
    imgVals1 = reshape(img1,N,Z);
    imgVals2 = reshape(img2,N,Z);
    [~, edges] = lattice(X,Y); clear points;
    weights = makeweights(edges,imgVals,sigma);
    W = adjacency(edges,weights,N); clear edges weights;
    [probs, labels_idx] = CT_I(W, img, seeds, alpha);

    label_img = reshape(labels_idx, X, Y);
    bmap = seg2bmap(label_img,Y,X);
    idx = find(bmap>0);
    bmapOnImg = frame(:,:,1);
    bmapOnImg(idx) = 1;
    if Z==3
        temp = frame(:,:,2);
        temp(idx) = 0;
        bmapOnImg(:,:,2) = temp;
        temp = frame(:,:,3);
        temp(idx) = 0;
        bmapOnImg(:,:,3) = temp;
    end


    % write it into floder
    out_path = ['results/' video.vname '/']; 
    if ~exist(out_path,'file')
        mkdir(out_path);
    end

    imwrite(bmapOnImg,strcat(out_path, 'frame', num2str(cur_idx),'.png'));
% end
end