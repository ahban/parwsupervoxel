function seeds = place_seeds(height, width, PATCH_SIZE)
% Initialize and place seeds, only for the first frame

% place seeds for the first frame(取中心，注意右下边时排除掉)
bSize = PATCH_SIZE/2;
numSeeds = 1;
for y = bSize : PATCH_SIZE-2 : width
    for x = bSize : PATCH_SIZE-2 : height-1
%         seeds(numSeeds, 1) = x + (y-1) * height;  %idx
%         seeds(numSeeds, 2) = numSeeds;  %label
        seeds(numSeeds, 1) = x;  
        seeds(numSeeds, 2) = y;        
        numSeeds = numSeeds + 1;
    end
end

seeds(:,1) =  min(round(seeds(:,1)), height);
seeds(:,2) =  min(round(seeds(:,2)), width);
end

