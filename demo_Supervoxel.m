function demo_Supervoxel
%Demo function for video segmentation using supervoxel
%2013.11 - Liang Yuling

addpath(genpath('algorithms'));

% parameter settng 
sigma = 30; %gaussian parameter 
PATCH_SIZE = 25; % initial supervoxel size(seeds) 12-200sp
alpha = 0.0003; % RW parameter

pictureDir  = './data';
pictureName = 'VideoIndependenceDay'; %'ice'
numFrame    = 53;                       %80

%% Initialize and place seeds
out_path = ['results/' pictureName]; 
if ~exist(out_path,'file')
    mkdir(out_path);
end

times = zeros(1, numFrame);
frame = imread(sprintf('%s/%s/%08d.jpg', pictureDir, pictureName, 1));
[X, Y, Z] = size(frame); N = X*Y;
seeds = place_seeds(X, Y, PATCH_SIZE); 

%% main routine
for cur_idx = 1 : numFrame
    tseg = tic;
    disp('***************************************');
    % read image
    frame = imread(sprintf('%s/%s/%08d.jpg', pictureDir, pictureName, cur_idx));
    %grayScale = rgb2gray(img);
    
    % just PARW(f_i) segmentation
    if Z > 1
        img = colorspace('Lab<-', frame); % convert color space
    end
    imgVals = reshape(img,N,Z);
    [~, edges] = lattice(X,Y); clear points;
    weights = makeweights(edges,imgVals,sigma);
    W = adjacency(edges,weights,N); clear edges weights;
    [probs, labels_idx] = CT_I(W, img, seeds, alpha);

    label_img = reshape(labels_idx, X, Y);
    bmap = seg2bmap(label_img,Y,X);
    idx = find(bmap>0);
    bmapOnImg = frame(:,:,1);
    bmapOnImg(idx) = 255;
    if Z==3
        temp = frame(:,:,2);
        temp(idx) = 0;
        bmapOnImg(:,:,2) = temp;
        temp = frame(:,:,3);
        temp(idx) = 0;
        bmapOnImg(:,:,3) = temp;
    end
    
    % write it into floder
    imwrite(bmapOnImg, sprintf('%s/%08d.jpg', out_path, cur_idx));
    times(cur_idx) = toc(tseg);
end

fprintf('Supervoxel on %d frames in %.2f sec (%.2f fps)\n', numFrame, sum(times), 1/mean(times));

end