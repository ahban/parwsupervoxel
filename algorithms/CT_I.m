function [probs, labels_idx] = CT_I(W, img, seeds, alpha)
% do random walk segmentation for superpixel

% parameters
[X, Y, ~] = size(img); Num = X * Y;
seeds_idx = sub2ind(size(img), seeds(:,1), seeds(:,2));
K = length(seeds_idx);

I = sparse(1:Num,1:Num,ones(Num,1)); 
D = sparse(1:Num,1:Num,sum(W));
L = D - W;
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
