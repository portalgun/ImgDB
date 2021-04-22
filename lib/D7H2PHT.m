function [Iout W] = D7H2PHT(I)

% function Iout = D7H2PHT(I)
%
% convert D7H image to luminance image

if size(I,3) == 1 && size(I,2) == 3 % converts [n*m 3] -> [n m 3] 
    I = reshape(I,[sqrt(size(I,1))*[1 1] size(I,2)]);
end
if size(I,3) ~= 3 && size(I,2) ~= 3
   error(['D7H2PHT: WARNING! size(I) = [' num2str(size(I)) ']']); 
end

sensD7H = bsxfun(@rdivide,D7Hsensitivity,max(D7Hsensitivity));
sensPHT = PHTsensitivity;

W = sensD7H\sensPHT;

Iout = reshape(I,[size(I,1)*size(I,2) size(I,3)])*W;
Iout = reshape(Iout,[size(I,1) size(I,2)]);