function result = createConDataHCP(parcName,outFolder)

% Output arguments
parcName
outFolder

% Add needed paths 
coco_path = genpath("/work/users/a/a/aallen1/ConConNest"); 
sbci_path = genpath('/users/a/a/aallen1/SBCI_Data/');
addpath(coco_path); 
addpath(sbci_path); 

% Load data
sbci_mapping = load("sbci_mapping").sbci_mapping; 
parc_struct = load(parcName+"_parc.mat").parc; 
hcp_ids = readmatrix("hcp_all_ids.csv");

% Initialize variables
n_subs = length(hcp_ids); 
K = length(unique(parc_struct.labels)) - 1; % -1 for CC  
all_scs = zeros(n_subs,(K*(K-1)/2)); 
sub_count = 1; 
hold_ids = zeros(n_subs,1); 

% Process data for each subject
for i = 1:10
    tic
    load(['sc_ids_', num2str(i)])
    load(['sbci_sc_tensor_', num2str(i), '.mat'])
    num_subs = size(sbci_sc_tensor, 3);

    % Process subject data
    for j = 1:num_subs
        sub_sc = sbci_sc_tensor(:,:,j); 
        sub_sc = sub_sc + sub_sc'; 
        sub_sc = parcellate_sc(sub_sc,parc_struct,sbci_mapping,'roi_mask',4);

        all_scs(sub_count,:) = vectorizeMat(sub_sc);
        hold_ids(sub_count) = sc_ids(j);
        sub_count = sub_count + 1; 

    end

    "Finished Tensor " + string(i)
    toc
    clear sbci_sc_tensor
end

sub_count
all_scs = [hold_ids all_scs]; 
writematrix(all_scs,sprintf("%s/ConData/%s_all_scs.csv",outFolder,parcName)); 



result = 1
end



