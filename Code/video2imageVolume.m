function ImgVol =video2imageVolume(video)
mov = VideoReader(video);
i=1;
while hasFrame(mov)
    img = rgb2gray(readFrame(mov));
    ImgVol(:,:,i)=img;
    i=i+1;
end
end