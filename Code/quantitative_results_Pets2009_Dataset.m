% To get the accuracy for the Second Senario of the S3 subset, use the following: 
gt = ones(378,1)*-1;
gt(336:378)=1;
ground_truth_label =gt(3:377);
[TPR,FPR,INFO] = vl_roc(ground_truth_label, score_anomaly_euclidean)
ground_truth_label(ground_truth_label==-1)=0;
score_anomaly =score_anomaly_euclidean >=INFO.eerThreshold;
% This fucntion evaluates the performance of a classification model by 
% calculating the common performance measures: Accuracy, Sensitivity, 
% Specificity, Precision, Recall, F-Measure, G-mean.
EVAL = Evaluate(ground_truth_label,score_anomaly) 
