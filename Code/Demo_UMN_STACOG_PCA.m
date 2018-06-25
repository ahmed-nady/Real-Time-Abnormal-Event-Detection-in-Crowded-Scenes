clear all; 

TrnData = get_image_sequence_of_specific_dirct('F:\master degree\Dataset\UMN Optical Flow Magnitude\UMN Image Sequence\Scene 3\Train\','*.jpg');
 TstData = get_image_sequence_of_specific_dirct('F:\master degree\Dataset\UMN Optical Flow Magnitude\UMN Image Sequence\Scene 3\Test\','*.jpg');

training_features = extract_stacog_feature(TrnData);
%-------- PCA to reduce the dimensions
COEFF = princomp(training_features');                     %compress raws
Tw = COEFF(:,1:100)';
feaMatPCA = Tw*training_features; 

fprintf('\n ====== Training k medoids ======= \n')

 [idx,medoids] = kmedoids(feaMatPCA',5);
 tic;
 fprintf('\n=========Test STACOG Features=========\n')
 test_features = extract_stacog_feature(TstData);
 %-------- PCA to reduce the dimensions
COEFF_TstData = princomp(test_features');                     %compress raws
Tw_TstData = COEFF(:,1:100)';
feaMatPCA_TstData = Tw*test_features; 

test_samples=size(test_features,2);
score_anomaly_euclidean =min(pdist2(feaMatPCA_TstData',medoids,'euclidean'),[],2);
TimeperTest = toc;
 Averaged_TimeperTest = toc/test_samples;

fprintf('\n     Average testing time %.2f secs per test sample. \n\n',Averaged_TimeperTest);
