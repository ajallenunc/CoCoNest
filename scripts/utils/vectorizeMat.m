function v = vectorizeMat(mat)

    if istriu(mat) || istril(mat)
        mat = mat + mat' - diag(diag(mat)); % Symmetrize Matrix
    end
    mask = tril(true(size(mat)),-1); 
    v = mat(mask).'; % Create Vector

end