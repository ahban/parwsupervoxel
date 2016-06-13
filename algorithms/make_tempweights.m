function weights = make_tempweights(edges,vals_cur,vals_nex,sigma,EPSILON)

%Constants
if nargin < 5
    EPSILON = 1e-5;
end

%Compute intensity differences
if sigma > 0
    valDistances=sqrt(sum((vals_cur(edges(:,1),:)- ...
        vals_nex(edges(:,2),:)).^2,2));
    valDistances=normalize(valDistances); %Normalize to [0,1]
else
    valDistances=zeros(size(edges,1),1);
    sigma=0;
end


%Compute Gaussian weights
weights=exp(-(sigma*valDistances)) + EPSILON;

end