function view_oversegmentation( frames, labels_idx, vname, cur_idx)
%% results of each image
[X, Y, Z] = size(frames{1});

idx = labels_idx(1 : X*Y);
label_img = reshape(idx, X, Y);
img = frames{cur_idx};

bmap = seg2bmap(label_img,Y,X);
idx = find(bmap>0);
bmapOnImg = img(:,:,1);
bmapOnImg(idx) = 1;
if Z==3
    temp = img(:,:,2);
    temp(idx) = 0;
    bmapOnImg(:,:,2) = temp;
    temp = img(:,:,3);
    temp(idx) = 0;
    bmapOnImg(:,:,3) = temp;
end
%     figure('name','bmap');
%     imshow(bmapOnImg);

% write it into floder
out_path = ['results/' vname '/']; 
if ~exist(out_path,'file')
    mkdir(out_path);
end

imwrite(bmapOnImg,strcat(out_path, 'frame', num2str(cur_idx),'.png'));


end