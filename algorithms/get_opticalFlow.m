function video = get_opticalFlow(video, reliab_thre)
%% Compute optical flow
for iframe = 1:video.numFrame     
    if iframe < video.numFrame
        [Vx,Vy,reliab] = optFlowLk(video.grayScale_frame{iframe}, video.grayScale_frame{iframe+1}, [], 4, 3, 3e-6, 0 );
        reliab = reliab > reliab_thre;  %seeds¸Ä±äµÄ
        video.Vx{iframe} = Vx;   
        video.Vy{iframe} = Vy;
        video.flow_reliab{iframe} = reliab;
    else    
        %last frame's optical flow 
        video.Vx{iframe} = video.Vx{iframe-1};   
        video.Vy{iframe} = video.Vy{iframe-1};
        video.flow_reliab{iframe} = video.flow_reliab{iframe-1};
    end
end   

end