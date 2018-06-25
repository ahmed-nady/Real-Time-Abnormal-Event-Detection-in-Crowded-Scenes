 clear all; 
% % setup;
% % TrnData = get_image_vol_from_videos('E:\Ahmed Nady\PCANet_demo\Normal_Abnormal_Crowd\Normal Crowds\','*.mov');
% % TstData = get_image_sequence_of_specific_dirct('E:\Ahmed Nady\PCANet_demo\Normal_Abnormal_Crowd\Abnormal Crowds\','*.mov');
% 
 
interval=30;
currentFolder = pwd
cd ('F:\master degree\Dataset\Normal_Abnormal_Crowd\Normal Crowds\'); % please replace "..." by your images path
a = dir('*.mat'); % directory of images, ".jpg" can be changed, for example, ".bmp" if you use
for i = 1: 10
    matFilePath = getfield(a, {i}, 'name');
    load (matFilePath)
    len =size(test_features,2)-mod(size(test_features,2),interval);
    counter = 1;
    for i=1:interval:len
        matrix(:,counter) = sum(test_features(:,i:i+interval-1),2);
        counter = counter + 1;
    end
    training_features{i} = matrix;
    clear matrix test_features
end
cd(currentFolder);

fprintf('\n ====== Training k medoids ======= \n')

  [idx,medoids] = kmedoids(cell2mat(training_features)',10);
 tic;
 fprintf('\n=========Test STACOG Features=========\n')

 
 currentFolder = pwd
 cd ('F:\master degree\Dataset\Normal_Abnormal_Crowd\Abnormal Crowds\');
 a = dir('*.mat');
 for i = 1: 8
     matFilePath = getfield(a, {i}, 'name');
     load (matFilePath)
     len =size(test_features,2)-mod(size(test_features,2),interval);
    counter = 1;
    for ind=1:interval:len
        matrix(:,counter) = sum(test_features(:,ind:ind+interval-1),2);
        counter = counter + 1;
    end
     score_anomaly_euclidean =min(pdist2(matrix',medoids,'euclidean'),[],2);
     score_anomaly{i,1}=score_anomaly_euclidean;
     ground_truth_label{i,1}=ones(size(matrix,2),1);
     clear score_anomaly_euclidean matrix
 end
 cd(currentFolder);
 
 
 
 currentFolder = pwd
cd ('F:\master degree\Dataset\Normal_Abnormal_Crowd\Normal Crowds\'); % please replace "..." by your images path
   load TrainingFeatures_9.mat
len =size(test_features,2)-mod(size(test_features,2),interval);
counter = 1;
for ind=1:interval:len
matrix(:,counter) = sum(test_features(:,ind:ind+interval-1),2);
counter = counter + 1;
end
score_anomaly_euclidean =min(pdist2(matrix',medoids,'euclidean'),[],2);
score_anomaly{9,1}=score_anomaly_euclidean;
ground_truth_label{9,1}=ones(size(matrix,2),1)*-1;
clear score_anomaly_euclidean matrix

load TrainingFeatures_8.mat
len =size(test_features,2)-mod(size(test_features,2),interval);
counter = 1;
for ind=1:interval:len
matrix(:,counter) = sum(test_features(:,ind:ind+interval-1),2);
counter = counter + 1;
end
score_anomaly_euclidean =min(pdist2(matrix',medoids,'euclidean'),[],2);
score_anomaly{10,1}=score_anomaly_euclidean;
ground_truth_label{10,1}=ones(size(matrix,2),1)*-1;
clear score_anomaly_euclidean matrix

cd(currentFolder);
gnd =cell2mat(ground_truth_label);
predicted = cell2mat(score_anomaly);
vl_roc(gnd, predicted)

%  test_features = extract_stacog_feature(TstData(1));
% test_samples=size(test_features,2);
%  %score_anomaly_cityblock = zeros(test_samples,1);
% %% score_anomaly_correlation=zeros(test_samples,1);
% % for i=1:test_samples
% %     %score_anomaly_cityblock(i)= min(pdist2(test_features(:,i)',medoids,'cityblock'));
% %     score_anomaly_correlation(i) =min(pdist2(test_features(:,i)',medoids,'correlation'));
% % end
% score_anomaly_euclidean =min(pdist2(test_features',medoids,'euclidean'),[],2);
% %score_anomaly_cityblock= min(pdist2(test_features',medoids,'cityblock'),[],2);
% TimeperTest = toc;
%  Averaged_TimeperTest = toc/test_samples;
% 
% fprintf('\n     Average testing time %.2f secs per test sample. \n\n',Averaged_TimeperTest);