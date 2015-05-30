%temp
imageName = 'missa';

outputVideo = VideoWriter(fullfile('Output','input_missa.avi'));
outputVideo.FrameRate = 15;
open(outputVideo);

%% Read Image Frames
for i = 0:2:148

    imgINumber = i
    imgPNumber = i+1;

    if imgINumber < 10
        imgIFile = sprintf('Data/%s/gray/%s00%d.ras',imageName, imageName, imgINumber);
    elseif imgINumber < 100
        imgIFile = sprintf('Data/%s/gray/%s0%d.ras',imageName, imageName, imgINumber);
    end

    if imgPNumber < 10
        imgPFile = sprintf('Data/%s/gray/%s00%d.ras',imageName, imageName, imgPNumber);
    elseif imgPNumber < 100
        imgPFile = sprintf('Data/%s/gray/%s0%d.ras',imageName, imageName, imgPNumber);
    end

    imgI = double(imread(imgIFile));
    imgP = double(imread(imgPFile));
    imgI = imgI(:,1:352);
    imgP = imgP(:,1:352);
    
    
    writeVideo(outputVideo,uint8(imgI));
    
    writeVideo(outputVideo,uint8(imgP));
    
end

close(outputVideo);