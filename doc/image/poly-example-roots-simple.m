f = @(x,y) ...
    -(5.*y - 20.*y.^3 + 16.*y.^5).^6 + ...
        (-(5.*x - 20.*x.^3 + 16.*x.^5).^3 + ...
           5.*y - 20.*y.^3 + 16.*y.^5).^2;
X = Y = infsup ("[-2, 2]");
has_roots = n = 1;

for iter = 1 : 10
    ## Bisect
    [i,j] = ind2sub ([n,n], has_roots);
    X = infsup ([X.inf,X.inf,X.mid,X.mid],[X.mid,X.mid,X.sup,X.sup]);
    Y = infsup ([Y.inf,Y.mid,Y.inf,Y.mid],[Y.mid,Y.sup,Y.mid,Y.sup]); 
    ii = [2*(i-1)+1,2*(i-1)+2,2*(i-1)+1,2*(i-1)+2] ;
    jj = [2*(j-1)+1,2*(j-1)+1,2*(j-1)+2,2*(j-1)+2] ;
    has_roots = sub2ind ([2*n,2*n], ii, jj);
    n *= 2;
    
    ## Check if function value covers zero
    fval = f (X, Y);
    zero_contained = find (ismember (0, fval));
    
    ## Discard values without roots
    has_roots = has_roots(zero_contained);
    X = X(zero_contained);
    Y = Y(zero_contained);
endfor

colormap gray
B = false (n);
B(has_roots) = true;
imagesc (B)
axis equal
axis off
