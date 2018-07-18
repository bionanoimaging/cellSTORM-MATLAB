% Author: K. Giewekemeyer
%
% Implements the Kaiser-Bessel window for an array of dimension N (NxN) with
% N even, according to T. Butz "Fourier-Transformation für Fussgaenger", 3rd
% ed., Teubner, 2003, p. 97. The definition of the middle (the zero) is in 
% accordance with the definition of the centered dft. Other options are 
% probably possible, the important aspect is that the function
% weighted by the Kaiser-Bessel-Funtion becomes fully periodizable.
% Note: generally a choice of beta = 8 is good, beta = 0 corresponds to the
% hat-function.
%
% Last modified and checked on 06.10.2010.

function val = kaiser_bessel(beta,data)

if ndims(data) > 2
    
    error('Only dimensions <= 2 supported.');

elseif (size(data,1) > 1 && size(data,2) > 1)
    
    if size(data,2) ~= size(data,1)
        error('Only square inputs supported for two-dimensional data.');
    end
    N = size(data,1);
    [nx,ny] = meshgrid((1:N)-floor(N/2)-1,(1:N)-floor(N/2)-1);
    r = sqrt(nx.^2+ny.^2);
    val = zeros(size(data));
    val(r<=floor(N/2)) = besseli(0,beta*sqrt(1 - (2*r(r<=floor(N/2))/N).^2))/besseli(0,beta);    
    
else
    
    N = length(data);
    n = (1:N)-floor(N/2)-1;
    val = besseli(0,beta*sqrt(1 - (2*n/N).^2))/besseli(0,beta);
    if size(data,1) > size(data,2)
        val = val';
    end
    
end