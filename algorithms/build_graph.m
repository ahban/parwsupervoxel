function affinity_sparse = build_graph(video, cur_idx, cross_num, sigma, ratio)

affinity_sparse=[];

%last frame don't seg CT(i,i+1)
if(cur_idx==video.numFrame)
    return;
end

N = video.X * video.Y;
%% Compute spatial color affinity
% disp('computing spatial pixel adjacencies based on color & pixel flow...');
new_edges = [];
new_weights = [];
cur_frame = cur_idx-1;
for iframe = 1 : cross_num
    img = video.frame{cur_frame+iframe};
    [X, Y, Z] = size(img); N = X*Y; 
    if Z > 1 
        Lab = colorspace('Lab<-', img); % convert color space           
    end
    imgVals = reshape(Lab,N,Z);
    [~, edges] = lattice(X,Y,1); clear points;    
    weights = makeweights(edges,imgVals,sigma);
    new_edges = [new_edges; edges + (iframe-1)*N];
    new_weights = [new_weights; weights];
end
spatial_score = [new_edges, new_weights];

%% Compute temporal color affinity
temporal_score = temporal_affinity(video, cross_num, cur_idx, sigma, ratio);

%% Add optical flow 
W = [spatial_score; temporal_score];
adjmat_sparse = sparse(W(:,1), W(:,2), W(:,3), cross_num*N, cross_num*N);
adjmat_sparse = adjmat_sparse + adjmat_sparse';
[sup1, sup2, affinity] = find( tril(adjmat_sparse, -1) );  %下三角的值，返回>0的下标【x,y,score】
affinity_sparse = motion_affinity(sup1, sup2, affinity, video, cross_num, cur_idx);
% disp(' affinity computed over!');

end