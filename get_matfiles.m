function predicted_labels = get_matfiles( basePath,extension)
% %loop through each training sample
    %basePath = 'F:\master degree\Dataset\UCSD_Anomaly_Dataset\UCSDped1\Train\';
    currentFolder = pwd
   count=0;
    img_index =0;
    test = cell(177,1);
    cd (basePath); % please replace "..." by your images path
    a = dir(extension); % directory of images, ".jpg" can be changed, for example, ".bmp" if you use
    mat_count = length(a);
    for i = 1: mat_count
        MatName = getfield(a, {i}, 'name');
        load(MatName);
        count  =count+length(test);
        for ind=1:length(test)
            img_index =img_index+1;
            score_anomaly_map = cell2mat((test{ind,1}));
            predicted_labels(img_index,1) = max(max(score_anomaly_map));
        end
    end
    
   cd(currentFolder);
end