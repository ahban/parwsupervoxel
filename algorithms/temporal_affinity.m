function temporal_score = temporal_affinity(video, cross_num, cur_idx, sigma, ratio)
% compute affinity acorss frames

N = video.X * video.Y;
cur_frame = cur_idx-1;

% reshape img
imgVals = [];
for iframe = 1 : cross_num 
    img = video.frame{cur_frame+iframe};
    if video.Z > 1 
        Lab = colorspace('Lab<-', img); % convert color space           
    end
    imgVals{iframe} = reshape(Lab, N, video.Z);
end

% bulid edges to the next plane 
temporal_score = [];
for iframe = 1 : cross_num - 1
    %% 1)center nodes
    num = (1 : 1 : N)'; 
    center_edges = [num, num];
    
    % 2)oter nodes: 4-neibor
    nfirst_row = num;     
    frow_idx = (1 : video.X : N-video.X+1)';
    nfirst_row(frow_idx) = []; %因为列值=列下标
    
    nlast_row = num;      
    lrow_idx = (video.X : video.X : N)';
    nlast_row(lrow_idx) = [];
    % up 
    up_edges = [nfirst_row, nlast_row];
    % down
    down_edges = [nlast_row, nfirst_row];
    
    nfirst_col = (video.X+1 : 1 : N)';
    nlast_col = (1 : 1 : N-video.X)';
    % left (起点：左边第一列不用取)    
    left_edges = [nfirst_col, nlast_col];
    % right (起点：右边最后一列不用取)
    right_edges = [nlast_col, nfirst_col];
    
    
    %% compute weights across frames
    edges = [center_edges; up_edges; down_edges; left_edges; right_edges];
    weights = make_tempweights(edges, imgVals{iframe}, imgVals{iframe+1}, sigma);
    
    
    %% 还原到5帧node大小
    % 1)center nodes
    center_node(:,1) = num + (iframe-1)*N; 
    center_node(:,2) = num + iframe*N; 
    % 2)other nodes
    % up
    up_node(:,1) = nfirst_row + (iframe-1)*N; 
    up_node(:,2) = nlast_row + iframe*N; 
    % down
    down_node(:,1) = nlast_row + (iframe-1)*N; 
    down_node(:,2) = nfirst_row + iframe*N; 
    % left
    left_node(:,1) = nfirst_col + (iframe-1)*N; 
    left_node(:,2) = nlast_col + iframe*N; 
    % right
    right_node(:,1) = nlast_col + (iframe-1)*N; 
    right_node(:,2) = nfirst_col + iframe*N; 

    nodes = [center_node; up_node; down_node; left_node; right_node];
    temporal_score = [temporal_score; nodes, weights*ratio];
end

end