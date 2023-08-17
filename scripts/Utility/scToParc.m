function [parc_sc, idx_no_cc] = scToParc(parcType, full_sc, onlyIDX, varargin)

    % Use inputParser to handle optional arguments
    p = inputParser;
    addRequired(p, 'parcType', @(x) any(validatestring(x, {'full','external', 'flat', 'tree'})));
    addRequired(p, 'full_sc', @isnumeric);
    addRequired(p, 'onlyIDX', @islogical);
    addParameter(p, 'k', 0, @isnumeric);
    
    % Define optional arguments based on parcType
    switch lower(parcType)
        case 'external'
            addParameter(p, 'name', '', @ischar);
        case 'flat'
            addParameter(p, 'method', '', @(x) any(validatestring(x, {'kmeans', 'spectral'})));
        case 'tree'
            addParameter(p, 'data_name', '', @ischar);
            addParameter(p, 'tree_method', '', @ischar);
            addParameter(p, 'link_method', '', @ischar);
            addParameter(p, 'dist', '', @ischar);
            addParameter(p, 'prune_method', '', @ischar);
            addParameter(p, 'error_method', '', @ischar);
    end
    
    % Parse input arguments
    parse(p, parcType, full_sc, onlyIDX, varargin{:});
    args = p.Results;

    sbci_map = load('sbci_mapping.mat');
    sbci_mapping = sbci_map.sbci_mapping; 

    if strcmpi(parcType,"full")
        corp = load("hcp_corpus_mask.mat");
        if onlyIDX
            idx_no_cc = setdiff(1:4121,corp.corpus_mask);
            parc_sc = 0;
        else 
            parc_sc = full_sc; 
            parc_sc(corp.corpus_mask,:) = []; 
            parc_sc(:,corp.corpus_mask) = []; 
        end

    %% Handle External Parcellations %% 
    elseif strcmpi(parcType,"external")
        if isempty(args.name)
            error('Name is required for parcType "external".')
        end
        name = args.name;
        validNames = ["yeo_17","desk","bn","hcp","dest"];
        
        if ~any(strcmpi(name,validNames))
            error('Invalid name. Allowed names are "yeo_17","desk","bn","hcp","dest".')
        end
        parc_dat = load([name,'_parc.mat']);
        parc = parc_dat.parc; 
        parc.labels = parc.labels.';
        idx = parc.labels'; 
        if onlyIDX 
            idx_no_cc = idx(~(idx==4)); % Remove CC 
            parc_sc = 0;
        else
            parc_sc = parcellate_sc(full_sc,parc,sbci_mapping,'roi_mask',4,'merge_lr',false); 
        end
        
    %% Handle Flat Parcellations %% 
    elseif strcmpi(parcType, 'flat')
        if isempty(args.method)|| args.k == 0
            error('Method and k required for parcType "flat".');
        end
        
        method = args.method;
        validMethods = ["kmeans", "spectral"];
        if ~any(strcmpi(method, validMethods))
            error('Invalid method. Allowed values are "kmeans" or "spectral".');
        end
        
        idx_dat = load("idx_"+method+"_"+string(k)+".mat");
        idx = idx_dat.idx;  
        if onlyIDX
            idx_no_cc = idx(~(idx==4)); % Remove CC 
            parc_sc = 0; 
        else
            parc.labels=idx; 
            [~,I] = sort(idx); 
            parc.sorted_idx = I;
            parc_sc = parcellate_sc(full_sc,parc,sbci_mapping,'roi_mask',4); 
        end

    %% Handle Tree Parcellations %% 
    elseif strcmpi(parcType, 'tree')
        %if nargin ~= 17
        %    keyboard
        %    error('Incorrect number of input arguments for parcType "tree".');
        %end
        
        data_name = args.data_name;
        tree_method = args.tree_method;
        link_method = args.link_method;
        dist = args.dist;
        prune_method = args.prune_method;
        error_method = args.error_method;
        k = args.k; 

        
        %tree_dat = load("/work/users/a/a/aallen1/TreePrune/PruneResults/"+...
        %    data_name+"_"+tree_method+"_"+link_method+"_"+dist+ "_"+prune_method+ "_"+...
        %    error_method +"_prune_struct.mat");

        tree_dat = load(data_name+"_"+tree_method+"_"+link_method+"_"+dist+ "_"+prune_method+ "_"+...
            error_method +"_prune_struct.mat");
        prune_struct= tree_dat.prune_struct; 

        if strcmpi(tree_method,"bottom_up")
               if strcmpi(prune_method,"cc")
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
               % Prune Tree
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
        elseif strcmpi(tree_method,"top_down")
            % Prune Tree
            idx = getBiKMeansClusts(prune_struct.include_rows,prune_struct.term_nodes_mat,k);
            if onlyIDX
                idx_no_cc = idx(~(idx==4)); % Remove CC
                parc_sc = 0; 
            else
                parc.labels = idx; 
                [~,I] = sort(parc.labels); 
                parc.sorted_idx = I;                
                parc_sc = parcellate_sc(full_sc,parc,sbci_mapping,'roi_mask',4); % Remove CC (Coded as 4 in pruned trees) 
            end

        else
            error("Invalid Tree Method")
        end

    % Throw Error 
    else
        error('Invalid parcType. Allowed values are "flat", "tree", or "external".');
    end

end
