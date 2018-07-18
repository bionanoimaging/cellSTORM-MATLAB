%=========================================================================
% Computes the Fourier Shell Correlation (FSC) between two given 2d- or
% 3d-images. In the 2D-setting this is also known as the Fourier Ring
% correlation (FRC).
%
% By comparing the FSC between two indepedent reconstructions
% of an object from two different data sets to the 1/2-bit-threshold
% curve, the achieved resolution can be estimated.
%
%
% example: for 2D
% defina beta
% im1 = rand(2048);
% im2 = rand(2048);
% frc = FSC(im1, im2, p);
% figure
% hold on
% plot(frc.nu, frc.frc, 'DisplayName', 'FRC')
% plot(frc.nu, frc.T_hbit, 'DisplayName', '1/2 bit Threshold')
% plot(frc.nu, frc.T_bit, 'DisplayName', '1 bit Threshold')
% hold off
% legend show

% example: for 3D, note no bessel window is applied
% im1 = rand([512, 512, 512]);
% im2 = rand([512, 512, 512]);
% frc = FSC(im1, im2, p);
% figure
% hold on
% plot(frc.nu, frc.frc, 'DisplayName', 'FRC')
% plot(frc.nu, frc.T_hbit, 'DisplayName', '1/2 bit Threshold')
% plot(frc.nu, frc.T_bit, 'DisplayName', '1 bit Threshold')
% hold off
% legend show
% Last modified on July 28th, 2016 by Simon Maretzke
% adapted output structure to match old impl by JH  57598
%=========================================================================


function [Q] = FSC( im1, im2, p)


% Input arguments:
%
%       im1: 2d- or 3d-array containing the first image to be correlated
%       im2: size(im1)-array containing the second image to be correlated
%       p:  parameter struct
%
% Output arguments:
%       struct Q with fields:
%       frc: length ceil(norm(size(im1))/2) vector containing the computed values
%            of the Fourier shell correlation of the images im1, im2, in ascending
%            order of frequencies.
%    T_hbit: size(fsc)-vector containing the values of the 1/2-bit-threshold
%            curve for the FSC.
%    T_bit: size(fsc)-vector containing the values of the 1-bit-threshold
%            curve for the FSC.
%      nu: size(fsc)-vector containing the Fourier frequencies corresponding
%            to the values of fsc and t_hbit.
%      no_r: number of bits per ring/shell

if nargin < 3
    beta = 7;
    warning(['There is no width for the Kaiser Bessel window defined,',...
        'using standard value (beta = 7)']);
else
    if isfield(p, 'beta') == 1
        beta = p.beta;
    else
        beta = 7;
        warning(['There is no width for the Kaiser Bessel window defined,',...
            'using standard value (beta = 7)']);
    end
end


N = size(im1);
ndim = numel(N);    % 2d or 3d?

% Compute Fourier transforms
if (ndim == 2)
    im1_fft = fftn(im1 .* kaiser_bessel(beta, ones(size(im1))));
    im2_fft = fftn(im2 .* kaiser_bessel(beta, ones(size(im2))));
else
    im1_fft = fftn(im1);
    im2_fft = fftn(im2);
end

% Compute norm of the wave vector for all points in Fourier space
xi = 0;
for jj = 1:ndim
    xi = bsxfun( @plus, xi, reshape( ( -floor(0.5*N(jj)) : ceil(0.5*N(jj))-1 ).^2, [ones([1,jj-1]), N(jj), ones([1,2-jj])] ) );
end
xi = sqrt(ifftshift(xi));

% Round values to integers for distribution to different Fourier shells
shells = round(xi)+1;

% Number of Fourier frequencies in each cell
n_xi = accumarray(shells(:), ones([numel(shells),1]));
num_xi = numel(n_xi);

% Compute correlation on shells
Q.frc =    real( accumarray(shells(:), im1_fft(:) .* conj(im2_fft(:)), [num_xi, 1]) ) ...
        ./ sqrt( accumarray(shells(:), abs(im1_fft(:)).^2, [num_xi, 1]) .* accumarray(shells(:), abs(im2_fft(:)).^2, [num_xi, 1]) );

% Restrict to values on shells that are fully contained within the image
Q.frc = Q.frc(1:ceil((min(N)+1)/2));
n_xi = n_xi(1:ceil((min(N)+1)/2));

% 1/2-bit threshold curve
Q.T_hbit = ( 0.2071 + 1.9102 ./ n_xi.^(1/(ndim-1))  ) ./ ( 1.2071 + 0.9102 ./ n_xi.^(1/(ndim-1)));

% 1-bit threshold curve
Q.T_bit = ( 0.5 + 2.4142 ./ n_xi.^(1/(ndim-1))  ) ./ ( 1.5 + 1.4142 ./ n_xi.^(1/(ndim-1)));

% frequency vector
%freq = pi .* linspace(0,1,numel(fsc)).';
% frequencis
num_xi = numel(n_xi);
delta_nu = 1/(2*num_xi);
Q.nu = delta_nu*(0:floor(num_xi)-1)';
% number of elements per ring/shell
Q.no_r = n_xi;

end

