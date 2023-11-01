function [idx_corp,my_parc,idx_no_corp] = tree2IDX(prune_struct,k)

% Parse Prune Struct
prune_list = prune_struct.treeSeq; 
node_matrix = prune_struct.node_mat; 
dendo = prune_struct.link; 
choice = find(prune_list <= k,1); % When to stop pruning

% Setup Vars
load('hcp_corpus_mask.mat')
anti_corpus = setdiff(1:4121,corpus_mask); 
max_leaf = (size(node_matrix,1) + 1)/ 2; 
term_nodes = 1:size(dendo,1)+1; 

step = 1; 
for prune_node = prune_list

    % Update Terminal Nodes
    term_nodes = [term_nodes prune_node]; 
    
    drop_leafs = find(node_matrix(prune_node,:)==1); 
     
    [~,col] = find(term_nodes == drop_leafs(:));
    term_nodes(col) = [];  
    
    % Stop pruning
    if (step == choice)       
        break;
    end
    
    step = step+1; 

end

idx_corp = zeros(4121,1);
idx_no_corp = zeros(max_leaf,1); 
id = 1; 

% Label Terminal nodes 
for t = term_nodes
    get_nest = find(node_matrix(t,:)==1); 
    get_obser = get_nest(get_nest <= max_leaf); 
    idx_corp(anti_corpus(get_obser),:) = id; 
    idx_no_corp(get_obser) = id; 
    id = id+1; 
end

% CC coded as for for black color in distinguishable_colors matlab function
find_4 = find(idx_corp == 4); 
idx_corp(find_4) = id; 
idx_corp(corpus_mask) = 4; 

% Create Parcellation Structure for SBCI Scripts
my_parc.labels = idx_corp; 
[~,I] = sort(idx_corp); 
my_parc.sorted_idx = I; 
my_parc.term_nodes = term_nodes; 
my_parc.link = dendo; 
my_parc.node_mat = node_matrix; 

end

