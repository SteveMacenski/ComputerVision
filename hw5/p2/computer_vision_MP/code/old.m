% function are called with two types
% either cnn_cifar('coarse') or cnn_cifar('fine')
% coarse will classify the image into 20 catagories
% fine will classify the image into 100 catagories
function cnn_cifar(type, varargin)

if ~(strcmp(type, 'fine') || strcmp(type, 'coarse')) 
    error('The argument has to be either fine or coarse');
end

% record the time
tic
%% --------------------------------------------------------------------
%                                                         Set parameters
% --------------------------------------------------------------------
%
% data directory
opts.dataDir = fullfile('cifar_data','cifar') ;
% experiment result directory
opts.expDir = fullfile('cifar_data','cifar-baseline') ;
% image database
opts.imdbPath = fullfile(opts.expDir, 'imdb.mat');
% set up the batch size (split the data into batches)
opts.train.batchSize = 100 ;
% number of Epoch (iterations)
opts.train.numEpochs = 100 ;
% resume the train
opts.train.continue = true ;
% use the GPU to train
opts.train.useGpu = false ;
% set the learning rate
opts.train.learningRate = [0.002, 0.01, 0.02, 0.04 * ones(1,80), 0.004 * ones(1,10), 0.0004 * ones(1,10)] ;%[0.01, 0.04*ones(1,70), 0.002*ones(1, 15), 0.0005*ones(1,15)] ;
% set weight decay
opts.train.weightDecay = 0.0005 ;
% set momentum
opts.train.momentum = 0.9 ;
% experiment result directory
opts.train.expDir = opts.expDir ;
% parse the varargin to opts. 
% If varargin is empty, opts argument will be set as above
opts = vl_argparse(opts, varargin);

% --------------------------------------------------------------------
%                                                         Prepare data
% --------------------------------------------------------------------

imdb = load(opts.imdbPath) ;

load('net_first.mat');
%% Define network 
% The part you have to modify

net.layers = {} ;
% taken from tutorial DO NOT USE

lr = [1 10] ;

% Block 1
net.layers{end+1} = struct('type', 'conv', ...
                           'name', 'conv1', ...
                           'weights', {init_weights(5,3,192)}, ...
                           'learningRate', lr, ...
                           'stride', 1, ...
                           'dilate', 1, ...
                           'opts',{{}}, ...
                           'pad', 2) ;
net.layers{end+1} = struct('type', 'relu', 'name', 'relu1', 'leak', 0) ;
net.layers{end+1} = struct('type', 'conv', ...
                           'name', 'cccp1', ...
                           'weights', {init_weights(1,192,160)}, ...
                           'learningRate', lr, ...
                           'stride', 1, ...
                           'dilate', 1, ...
                           'opts',{{}}, ...
                           'pad', 0) ;
net.layers{end+1} = struct('type', 'relu', 'name', 'relu_cccp1', 'leak', 0) ;
net.layers{end+1} = struct('type', 'conv', ...
                           'name', 'cccp2', ...
                           'weights', {init_weights(1,160,96)}, ...
                           'learningRate', lr, ...
                           'stride', 1, ...
                           'dilate', 1, ...
                           'opts',{{}}, ...
                           'pad', 0) ;
net.layers{end+1} = struct('type', 'relu', 'name', 'relu_cccp2', 'leak', 0) ;
net.layers{end+1} = struct('name', 'pool1', ...
                           'type', 'pool', ...
                           'method', 'max', ...
                           'pool', [3 3], ...
                           'stride', 2, ...
                           'opts',{{}}, ...
                           'pad', 0) ;
%net.layers{end+1} = struct('type', 'dropout', 'name', 'dropout1', 'rate', 0.5) ;

% Block 2
net.layers{end+1} = struct('type', 'conv', ...
                           'name', 'conv2', ...
                           'weights', {init_weights(5,96,192)}, ...
                           'learningRate', lr, ...
                           'stride', 1, ...
                           'dilate', 1, ...
                           'opts',{{}}, ...
                           'pad', 2) ;
net.layers{end+1} = struct('type', 'relu', 'name', 'relu2', 'leak', 0) ;
net.layers{end+1} = struct('type', 'conv', ...
                           'name', 'cccp3', ...
                           'weights', {init_weights(1,192,192)}, ...
                           'learningRate', lr, ...
                           'dilate', 1, ...
                           'opts',{{}}, ...
                           'stride', 1, ...
                           'pad', 0) ;
net.layers{end+1} = struct('type', 'relu', 'name', 'relu_cccp3', 'leak', 0) ;
net.layers{end+1} = struct('type', 'conv', ...
                           'name', 'cccp4', ...
                           'weights', {init_weights(1,192,100)}, ...
                           'learningRate', lr, ...
                           'stride', 1, ...
                           'dilate', 1, ...
                           'opts',{{}}, ...
                           'pad', 0) ;

%net.layers{end+1} = struct('type', 'dropout', 'name', 'dropout2', 'rate', 0.5) ;


net.layers{end+1} = struct('type', 'pool', ...
                           'name', 'pool3', ...
                           'method', 'avg', ...
                           'pool', [2 2], ...
                           'stride', 2, ...
                           'opts',{{}}, ...
                           'pad', 0) ;
net.layers{end+1} = struct('type', 'relu', 'name', 'relu_cccp4', 'leak', 0) ;

% Loss layer
net.layers{end+1} = struct('type', 'softmaxloss') ;


% --------------------------------------------------------------------
%                                                                Train
% --------------------------------------------------------------------

% Take the mean out and make GPU if needed
imdb.images.data = bsxfun(@minus, imdb.images.data, mean(imdb.images.data,4)) ;
if opts.train.useGpu
  imdb.images.data = gpuArray(imdb.images.data) ;
end
%% display the net
vl_simplenn_display(net);
%% start training
[net,info] = cnn_train_cifar(net, imdb, @getBatch, ...
    opts.train, ...
    'val', find(imdb.images.set == 2) , 'test', find(imdb.images.set == 3)) ;
%% Record the result into csv and draw confusion matrix
load(['cifar_data/cifar-baseline/net-epoch-' int2str(opts.train.numEpochs) '.mat']);
load(['cifar_data/cifar-baseline/imdb' '.mat']);
fid = fopen('cifar_prediction.csv', 'w');
strings = {'ID','Label'};
for row = 1:size(strings,1)
    fprintf(fid, repmat('%s,',1,size(strings,2)-1), strings{row,1:end-1});
    fprintf(fid, '%s\n', strings{row,end});
end
fclose(fid);
ID = 1:numel(info.test.prediction_class);
dlmwrite('cifar_prediction.csv',[ID', info.test.prediction_class], '-append');

val_groundtruth = images.labels(45001:end);
val_prediction = info.val.prediction_class;
val_confusionMatrix = confusion_matrix(val_groundtruth , val_prediction);
cmp = jet(50);
figure ;
imshow(ind2rgb(uint8(val_confusionMatrix),cmp));
imwrite(ind2rgb(uint8(val_confusionMatrix),cmp) , 'cifar_confusion_matrix.png');
toc

% --------------------------------------------------------------------
%% call back function get the part of the batch
function [im, labels] = getBatch(imdb, batch , set)
% --------------------------------------------------------------------
im = imdb.images.data(:,:,:,batch) ;
% data augmentation
if set == 1 % training
    % fliplr
    if rand > 0.5
        im = fliplr(im);
    end
    % noise
        
    % random crop
    
    % and other data augmentation
end


if set ~= 3
    labels = imdb.images.labels(1,batch) ;
end

function weights = init_weights(k,m,n)
    weights{1} = randn(k,k,m,n,'single') * sqrt(2/(k*k*m)) ;
    weights{2} = zeros(n,1,'single') ;