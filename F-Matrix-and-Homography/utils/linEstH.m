function [H, Sa] = linEstH(left, right, NUM_RESCALE)
% [H, Sa] = linEstH(left, right, NUM_RESCALE)
% Estimate the homography matrix H from two 3 x n matrices of
% corresponding points left and right.
% Here left(:,k) x (H * right(:,k)) apprx= 0 where x denotes
% the 3D cross product.
% NUM_RESCALE (default TRUE) uses Hartley's rescaling. Always use
% rescaling, unless you wish to show how badly the un-normalized
% algorithm works.
% Returns H along with the singular values Sa of the 2nPts x 9 homogeneous
% linear system for H.

if nargin < 3
    NUM_RESCALE = 1;
end

nPts = size(left,2);
if nPts < 4 | nPts ~= size(right,2)
    fprintf(2,'lineEstH: Innappropriate number of left and right points.');
    H = [];
    return;
end

if size(left,1) == 2
    left = [left; ones(1, nPts)];
else % Normalize to pixel coords
    left = left./repmat(left(3,:), 3,1);
end
if size(right,1) == 2
    right = [right; ones(1, nPts)];
else % Normalize to pixel coords
    right = right./repmat(right(3,:), 3,1);
end

imPts = cat(3, left, right);

%% Rescale image data for numerical stability.
if NUM_RESCALE
    Knum = repmat(eye(3), [1,1,2]);
    %%% Rescale for numerical stability
    mn = sum(imPts(1:2,:,:),2)/nPts;
    mns = reshape(mn, [2 1 2]);
    var = sum(sum((imPts(1:2,:,:)-repmat(mns, [1 nPts 1])).^2,2)/nPts, 1);
    %% Scale image points so that sum of variances of x and y = 2.
    scl = sqrt(2./var(:));
    %% Sanity: varScl =  var .* reshape(scl.^2, [1 1 2]) % Should be 2
    
    %% Scale so x and y variance is roughly 1, translate so image mean (x,y) is zero.
    Knum(1:2,3,:) = -mn;
    Knum(1:2,:,:) = Knum(1:2,:,:).*repmat(reshape(scl, [1 1 2]), [2, 3,1]);
    for kIm = 1:2
        imPts(:,:,kIm) = reshape(Knum(:,:,kIm),3,3) * imPts(:,:,kIm);
    end
    %% Sanity check
    % sum(imPts(1:2,:,:),2)/nPts  % Should be [0 0]'
    % sum(sum(imPts(1:2,:,:).^2,2)/nPts,1) % Should be 2.
end


%% Make constraint matrix A.

left = reshape(imPts(:,:,1), [3 nPts]);
right = reshape(imPts(:,:,2), [3 nPts]);

A = [];

for i = 1 :size(left, 2)
    
    l_p = left(:, i);
    r_p = right(:, i);
    
    A(end+1,:) = [0 0 0 -l_p(1) -l_p(2) -1 r_p(2)*l_p(1) r_p(2)*l_p(2) r_p(2)];
    A(end+1,:) = [l_p(1) l_p(2) 1 0 0 0 -r_p(1)*l_p(1) -r_p(1)*l_p(2) -r_p(1)];
    
end

% similar code from linEstF
[Ua Sa Va] = svd(A); Sa = diag(Sa);
H = reshape(Va(:,end), 3,3)';

if NUM_RESCALE
    H = inv(reshape(Knum(:,:,2),3,3)) * H * reshape(Knum(:,:,1),3,3);
end

H = H / norm(H);

end


