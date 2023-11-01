function result = createParcTensor(parcName,outFolder,k)

parcName
outFolder

% Add Needed Paths
sbci_path = genpath('/work/users/a/a/aallen1/SBCI_Data/');
tree_path = genpath('/work/users/a/a/aallen1/ConConNest/');
addpath(sbci_path)
addpath(tree_path)

% Parse Input 

% Process parcellation based on parcName

if any(strcmpi(parcName,{'yeo_17','desk','dest','bn','hcp'}))
    file_name = parcName;
    [sc_tensor,all_scs,parc_size,all_ids] = processParcellation(parcName,''); 
else
    [sc_tensor, all_scs, parc_size,all_ids] = processParcellation(parcName, k); 
    file_name = char(parcName + "_" + string(k)); 
end

% Save Parcellation Tensor   
outFolder
file_name
save([outFolder,'/ParcTensors/',file_name,'_sc_tensor.mat'], 'parcName', 'parc_size', 'sc_tensor', 'all_ids', '-v7.3');

clear sc_tensor; 

% Do PCA 
if size(all_scs,1) < size(all_scs,2)
   [~,all_scores,~,~] = fastpca(all_scs);
else
   [~,all_scores,~,~,~] = pca(all_scs);
end

all_scores = [all_ids all_scores];

% Save Output 
writematrix(all_scores,[outFolder,'/PCScores/',file_name,'_all_pc_scores.csv']);

result = 1;
end

%% Function to Process Parcellations %%
function [sc_tensor,all_scs,parc_size,all_ids] = processParcellation(parcName, k)

    % Initialize variables
    [~, idx] = scToParc(parcName, 0, true,k,1);
    n_subs  = 0;

    for i = 1:10
        load('sc_ids_'+string(i)+'.mat')
        n_subs = n_subs + length(sc_ids); 
    end

    parc_size = length(unique(idx));
    sc_tensor = zeros(parc_size, parc_size, n_subs);
    all_scs = zeros(n_subs,parc_size*(parc_size-1)/2); 
    all_ids = zeros(n_subs, 1);
    sub_count = 0;
    
    % Process data for each subject
    for i = 1:10
        tic
        load(['sc_ids_', num2str(i)])
        load(['sbci_sc_tensor_', num2str(i), '.mat'])
        num_subs = size(sbci_sc_tensor, 3);
        
        % Process subject data
        for j = 1:num_subs
            sub_count = sub_count + 1;
            all_ids(sub_count) = sc_ids(j);
            sc_tensor(:, :, sub_count) = scToParc(parcName, sbci_sc_tensor(:, :, j), false, k,1);
            all_scs(sub_count,:) = vectorizeMat(sc_tensor(:,:,sub_count)); 
        end
        
        "Finished Tensor " + string(i) 
        toc
        clear sbci_sc_tensor
    end
end



    

