function mat = devectorizeVec(v)
    % Calculate the size of the original matrix
    n = (sqrt(1 + 8*length(v)) - 1) / 2; % Solve for N in L = N(N-1)/2 
    n = n+1; 
    if floor(n) ~= n
        error('Invalid vector length. Cannot form a square matrix.');
    end
    
    % Initialize the matrix
    mat = zeros(n);
    
    % Create an index mask for the lower triangular part (excluding diagonal)
    mask = tril(true(size(mat)), -1);
    
    % Fill the lower triangular part of the matrix
    
    mat(mask) = v;
    
    % Symmetrize the matrix
    mat = mat + mat' - diag(diag(mat));
end
