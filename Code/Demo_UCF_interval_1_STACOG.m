 clear all; 
% % setup;
% % TrnData = get_image_vol_from_videos('E:\Ahmed Nady\PCANet_demo\Normal_Abnormal_Crowd\Normal Crowds\','*.mov');
% % TstData = get_image_sequence_of_specific_dirct('E:\Ahmed Nady\PCANet_demo\Normal_Abnormal_Crowd\Abnormal Crowds\','*.mov');
% 
interval=1;
currentFolder = pwd
cd ('F:\master degree\Dataset\Normal_Abnormal_Crowd\Normal Crowds\'); % please replace "..." by your images path
a = dir('*.mat'); % directory of images, ".jpg" can be changed, for example, ".bmp" if you use
for i = 1: 10
    matFilePath = getfield(a, {i}, 'name');
    load (matFilePath)
    training_features{i} = test_features;
    clear  test_features
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
     score_anomaly_euclidean =min(pdist2(test_features',medoids,'euclidean'),[],2);
     score_anomaly{i,1}=score_anomaly_euclidean;
     ground_truth_label{i,1}=ones(size(test_features,2),1);
     clear score_anomaly_euclidean test_features
 end
 cd(currentFolder);
 
 
 
 currentFolder = pwd
cd ('F:\master degree\Dataset\Normal_Abnormal_Crowd\Normal Crowds\'); % please replace "..." by your images path
   load TrainingFeatures_9.mat
score_anomaly_euclidean =min(pdist2(test_features',medoids,'euclidean'),[],2);
score_anomaly{9,1}=score_anomaly_euclidean;
ground_truth_label{9,1}=ones(size(test_features,2),1)*-1;
clear score_anomaly_euclidean test_features

load TrainingFeatures_8.mat
score_anomaly_euclidean =min(pdist2(test_features',medoids,'euclidean'),[],2);
score_anomaly{10,1}=score_anomaly_euclidean;
ground_truth_label{10,1}=ones(size(test_features,2),1)*-1;
clear score_anomaly_euclidean test_features

cd(currentFolder);
gnd =cell2mat(ground_truth_label);
predicted = cell2mat(score_anomaly);
vl_roc(gnd, predicted)