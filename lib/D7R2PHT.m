function [Iout W] = D7R2PHT(I)

% function Iout = D7R2PHT(I)
%
% convert D7R image to luminance image


if size(I,3) == 1 && size(I,2) == 3 % converts [n*m 3] -> [n m 3] 
    I = reshape(I,[sqrt(size(I,1))*[1 1] size(I,2)]);
end
if size(I,3) ~= 3 && size(I,2) ~= 3
   error(['D7R2PHT: WARNING! size(I) = [' num2str(size(I)) ']']); 
end

sensD7R = bsxfun(@rdivide,D7Rsensitivity,max(D7Rsensitivity));
sensPHT = PHTsensitivity;

W = sensD7R\sensPHT;
Iout = reshape(I,[size(I,1)*size(I,2) size(I,3)])*W;

