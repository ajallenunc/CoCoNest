function [parc_sc, idx_no_cc] = scToParc(parcName, full_sc, onlyIDX, k, doEC)

    % Load SBCI Mapping 
    load('sbci_mapping.mat');

    % If parcName is "full", then SC matrix wont be parcellated but the 
    % corpus callosum will be removed. 
    if strcmpi(parcName,"full")
        corp = load("hcp_corpus_mask.mat");
        if onlyIDX
            idx_no_cc = setdiff(1:4121,corp.corpus_mask);
            parc_sc = 0;
        else 
            parc_sc = full_sc; 
            parc_sc(corp.corpus_mask,:) = []; 
            parc_sc(:,corp.corpus_mask) = []; 
        end

    % Handle External Parcellations  
    elseif any(strcmpi(parcName,{'yeo_17','desk','dest','bn','hcp'}))
        parc_dat = load([parcName,'_parc.mat']);
        parc = parc_dat.parc; 
        parc.labels = parc.labels.';
        idx = parc.labels'; 
        if onlyIDX 
            idx_no_cc = idx(~(idx==4)); % Remove CC 
            parc_sc = 0;
        else
            parc_sc = parcellate_sc(full_sc,parc,sbci_mapping,'roi_mask',4,'merge_lr',false); 
        end
    % Handle Tree Parcellations 
    else
        tree_dat = load(parcName+"_prune_struct.mat");
        prune_struct= tree_dat.prune_struct; 

        if doEC
           % Prune Tree
           [idx,~,~] = fast_term_to_clusters(prune_struct.treeSeq,prune_struct.node_mat,find(prune_struct.lengthSeq <= k,1),prune_struct.link);
        else
           my_corp = load('hcp_corpus_mask.mat');
           anti_corp = setdiff(1:4121,my_corp.corpus_mask);                 
           horiz_cut = cluster(prune_struct.link,'maxclust',k);  
           idx = zeros(4121,1);
           idx(anti_corp) = horiz_cut;
           find_4 = find(idx ==4);
           idx(my_corp.corpus_mask) = 4; 
           idx(find_4) = max(unique(idx))+1; 
        end

        if onlyIDX
            idx_no_cc = idx(~(idx==4)); % Remove CC
            parc_sc = 0; 
        else
            % Parcellate SC
            parc.labels = idx;
            [~,I] = sort(idx);
            parc.sorted_idx = I;
            parc_sc = parcellate_sc(full_sc,parc,sbci_mapping,'roi_mask',4); % Remove CC (Coded as 4 in pruned trees) 

        end
    end
end

