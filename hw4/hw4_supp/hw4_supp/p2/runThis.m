% Steve Macenski (c) 2017

% EM Algorithm for good/bad annotations from mechanical turk
clc;clear all;clf;
load('annotation_data.mat');

% constants, first 2 can't be derived since constant # per person can't be
% generally assumed
NOTES_PER_IM = 5; 
NOTES_PER_PERSON = 30;
NUM_NOTES = size(annotation_scores,1);
NUM_ANNOTATORS = length(unique(annotator_ids,'rows'));
NUM_IMAGES = length(unique(image_ids,'rows'));
SCORE_RANGE = range(ceil(annotation_scores));

% initialization
m_ = -1*ones(NUM_ANNOTATORS,1); %bool 0 or 1 for good annotator 
beta = .3*ones(NUM_ANNOTATORS,1); %Prob of annotator is good
sigma = .8; % std of image annotation, constant
mu = .4*ones(NUM_IMAGES,1); % mean of image annotation
alpha = zeros(NUM_IMAGES,NUM_ANNOTATORS);

% EM
for STEP = 1:5

    % E: estimate
    for each = 1:NUM_NOTES
        n = image_ids(each);
        m = annotator_ids(each);
        score = annotation_scores(each);
        alpha(n,m) = ( normpdf(score,mu(n),sigma) * beta(m) )  /  ...
            (  ((1-beta(m))/SCORE_RANGE) +  normpdf(score,mu(n),sigma) * beta(m)  );
    end
    
    % M: find mu, sigma, beta
    for n = 1:NUM_IMAGES
       im_scores = annotation_scores(image_ids == n);
       people = annotator_ids(image_ids == n);
       alpha_subset = alpha(n, people);
       x_Ta = im_scores' .* alpha_subset;
       mu(n) = sum(x_Ta) / sum(alpha_subset);
    end
        
    sig = 0;
    for i = 1:NUM_NOTES
       n = image_ids(i);
       m = annotator_ids(i);
       score = annotation_scores(i);       
       sig = sig + alpha(n,m)*(score-mu(n))^2;
    end
    alphasum = sum(sum(alpha));
    sigma = sqrt(sig/alphasum);
    
    
    for m = 1:NUM_ANNOTATORS
      noter_sum = sum(alpha(:,m));
      beta(m) = noter_sum / NOTES_PER_PERSON;
    end
end

% return indices of bad annotators, sigma, and mu plot
for m = 1:length(beta)
    if beta(m) < .2
        m_(m) = 0;
    else
        m_(m) = 1;
    end
end

bad_annotators = find(m_==0)'
sigma
figure(1); hold on;
subplot(1,2,1)
bar(1:size(beta),beta);hold on;plot(1:.1:size(beta),.2,'g.');legend('data','threshold');
title('Probability of good annotators, beta');xlabel('annotator');ylabel('Probability');
subplot(1,2,2)
bar(1:150,mu(1:150))
title('Estimates of mu for each image');xlabel('image');ylabel('mu');