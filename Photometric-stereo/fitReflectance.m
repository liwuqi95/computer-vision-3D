function [n, albedo] = fitReflectance(im, L)
% [n, albedo] = fitReflectance(im, L)
%
% Input:
%   im - nPix x nDirChrome array of brightnesses,
%   L  - 3 x nDirChrome array of light source directions.
% Output:
%   n - nPix x 3 array of surface normals, with n(k,1:3) = (nx, ny, nz)
%       at the k-th pixel.
%   albedo - nPix x 1 array of estimated albdedos


% YOU NEED TO COMPLETE THIS


% compute g
g = (im * L') / (L * L');

% take the magnituede for each pixel
albedo = vecnorm(g')';

% find the unit normal vecto for each pixel
n = g ./ repmat(albedo, 1, 3);



return;


