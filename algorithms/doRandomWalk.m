% function [probs, labels_idx] = doRandomWalk(W, img, seeds, cross_num, alpha)
% % do random walk segmentation for supervoxel
% % cross_num : number of compute frames once a time
% 
% % parameters
% [X, Y, ~] = size(img);
% N = X * Y;
% Num = cross_num * N;
% W = sparse([W(:,1); W(:,2)], [W(:,2); W(:,1)], [W(:,3); W(:,3)], Num, Num);
% seeds_idx = sub2ind(size(img), seeds(:,1), seeds(:,2));
% K = length(seeds_idx);
% 
% I = sparse(1:Num,1:Num,ones(Num,1)); 
% D_inv = sparse(1:Num,1:Num,1./sum(W));
% lines = zeros(Num,K);
% for k = 1:K
%     lines(seeds_idx(k), k) = 1;
% end
% iD_inv = sqrt(D_inv);
% S = iD_inv * W * iD_inv; 
% Q = (I - alpha * S) \ lines;
% 
% %% normalization
% likelihoods = zeros(Num, K);
% for k = 1:K
%     likelihoods(:,k) = Q(:,k) / sum(Q(:,k));
% end
% prob = sparse(1:Num,1:Num,1./sum(likelihoods,2)) * likelihoods;
% 
% 
% %% Estimate posteriors
% [probs, labels_idx] = max(prob, [], 2); 
% 
% end

function [probs, labels_idx] = doRandomWalk(W, img, seeds, cross_num, alpha)
% do random walk segmentation for supervoxel
% cross_num : number of compute frames once a time

% parameters
[X, Y, ~] = size(img);
N = X * Y;
Num = cross_num * N;
W = sparse([W(:,1); W(:,2)], [W(:,2); W(:,1)], [W(:,3); W(:,3)], Num, Num);
seeds_idx = sub2ind(size(img), seeds(:,1), seeds(:,2));
K = length(seeds_idx);

D = sparse(1:Num, 1:Num, sum(W));
L = D-W;
I = sparse(1:Num,1:Num,ones(Num,1)); 

lines = zeros(Num,K);
for k = 1:K
    lines(seeds_idx(k), k) = 1;
end
Q = alpha*(alpha * I + L) \ lines;

%% normalization
likelihoods = zeros(Num, K);
for k = 1:K
    likelihoods(:,k) = Q(:,k) / sum(Q(:,k));
end
prob = sparse(1:Num,1:Num,1./sum(likelihoods,2)) * likelihoods;


%% Estimate posteriors
[probs, labels_idx] = max(prob, [], 2); 

end
