function prune_struct = cost_comp_prune(dendo,sc,fcn)

% Get Matrix that contains the descendants of each node 
node_mat = getNodeMatrix(dendo); 
max_node = size(node_mat,1);
max_leaf = length(dendo)+1; % Max number of terminal leafs

% Set initial inner and terminal nodes
inner_nodes = max_leaf+1:1:max_node; 
term_nodes = 1:1:length(dendo)+1; 

% Create list to hold relevant values 
node_fit_list = zeros(max_node,1); 
pruned_branch_list = [];
length_list = []; 
alphaSeq = []; 
numb_leafs_dropped = [];

%% Calculate node fit for each inner node %%
for node = inner_nodes
    descen_finder = find(node_mat(node,:)==1); % Find all descendants of inner node
    leafs = descen_finder(descen_finder <= max_leaf); % Find all observations pooled into node
    node_fit = fcn(leafs,sc); 
    node_fit_list(node) = node_fit; 
end

%% Start Weakest-Link Pruning %% 
while length(term_nodes) > 1
    g_fcn_list = []; % Holds values of g_fcn for each inner node

    % Begin loop through inner nodes
    for node = inner_nodes    

        % Find all descendants of inner node
        descen_finder = find(node_mat(node,:)==1); 

        %% Branch Fit %%
        % Find terminal nodes of Branch
        find_terms = descen_finder(any(descen_finder == term_nodes(:))); 
        branch_fit = 0; 
        
        % Begin loop over terminal nodes of branch
        for term = find_terms
            if term > max_leaf                           
                find_descen = find(node_mat(term,:)==1); % Find descendants of this terminal node 
                branch_fit = branch_fit + node_fit_list(term); 
            end
        end
        % End loop over terminal nodes of branch

        % Populate g_fcn_list 
        g_fcn = (node_fit_list(node) - branch_fit) / (length(find_terms)-1);
        g_fcn_list = [g_fcn_list g_fcn]; 

    end % End loop over inner nodes 

    % Find Weakest Link 
    min_g = min(g_fcn_list); 
    alphaSeq = [alphaSeq min_g]; 
    
    % Drop Weakest Link
    prune_node = inner_nodes(g_fcn_list == min_g); 
    prune_node = prune_node(1); % Drop out first node if there is a tie (CHANGE LATER)
    pruned_branch_list = [pruned_branch_list prune_node]; 
    drop_nodes = find(node_mat(prune_node,:)==1); % Find all deleted nodes 
    numb_leafs_dropped = [numb_leafs_dropped length(drop_nodes)]; 

    % Update Inner Nodes 
    inner_nodes(inner_nodes == prune_node) = []; % Remove pruned node from list of inner nodes
    [~,col] = find(inner_nodes == drop_nodes(:)); 
    inner_nodes(col) = []; % Remove all dropped leafs from list of inner nodes
     
    % Update Terminal Nodes
    [~,col] = find(term_nodes == drop_nodes(:));
    term_nodes(col) = []; % Remove dropped nodes from terminal node list
    term_nodes = [term_nodes prune_node]; % Add pruned node to terminal node list
    length_list = [length_list length(term_nodes)]; % Keep track of length of list of terminal node list 

end
% End while loop 

% Save Pruning Variables 
prune_struct.alphaSeq = alphaSeq; % List of alpha parameter at each step
prune_struct.lengthSeq = length_list; % # of terminal nodes in tree at each step
prune_struct.node_mat = node_mat; 
prune_struct.numbLeafs = numb_leafs_dropped; % # of leaves dropped at each step
prune_struct.treeSeq = pruned_branch_list; % List of which node is pruned at each step

end




function node_matrix = getNodeMatrix(dendo)
% Function to create matrix where each row is a node and 
% each column is a leaf. The entry is 1 if the node is a parent of the
% leaf
max_this = dendo(:,[1 2]);
max_this = max_this(:);
numb_nodes = max(max_this);
max_leaves = size(dendo,1)+1;

%node_matrix = zeros(numb_nodes,max_leaves); 
node_matrix = zeros(numb_nodes,numb_nodes+1); 
for node_iter = numb_nodes:-1:1
    
    if node_iter <= max_leaves
        node_matrix(node_iter,node_iter) = 1; 
    else
    
    node_hold = dendo(node_iter-max_leaves,1:2);

    pass = true; 
    while(pass)
        
        if all(node_hold <= max_leaves)
            node_matrix(node_iter,node_hold) = 1;
            pass = false;
            break; 
        else 
            node_matrix(node_iter,node_hold) = 1;
        end
        
        nest = [];

        for node = node_hold
            if node <= max_leaves
                nest = [nest node]; 
            else
                lookup = dendo(node - max_leaves,1:2); 
                nest = [nest lookup]; 
            end                
        end 
        
        node_hold = nest; 
    
    end
    
    end
    
end

node_matrix = [node_matrix; ones(1,size(node_matrix,2))]; 

end



