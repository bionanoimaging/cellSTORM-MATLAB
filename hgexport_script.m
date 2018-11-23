function hgexport_script(myName, myWidth, myHeight, myFixedFontSize, myResolution, myformat, myFontName, myunits, myFontMode, myRenderer)
% Export of Figure with a lot of options
% hgexport_script(myName, myWidth, myHeight, myFixedFontSize, myformat, myFontName, myunits, myFontMode, myRenderer)
% https://de.mathworks.com/matlabcentral/answers/77447-size-of-exported-pdf-with-given-font-size
%

if nargin < 10
    options.Renderer = 'painters';
else
    options.Renderer = myRenderer;
end

if nargin < 9
    options.FontMode = 'Fixed'; %This line and next are the important bit
else
    options.FontMode = myFontMode;
end

if nargin < 8
    options.units = 'centimeters';
else
    options.units = myunits;
end

if nargin < 7
    options.FontName = 'arial';
else
    options.FontName = myFontName;
end

if nargin < 6
    options.format = 'png'; %or whatever options you'd like
else
    options.format = myformat;
end

if nargin < 5
    options.Resolution = 300; %or whatever options you'd like
else
    options.Resolution = myResolution;
end

if nargin < 4
    options.FixedFontSize = 12;
else
    options.FixedFontSize = myFixedFontSize;
end

if nargin < 3
    options.Height = 10;
else
    options.Height = myHeight;
end

if nargin < 2
    options.Width = 10;
else
    options.Width = myWidth;
end

if nargin < 2
    myName = 'NoName.png'
end


hgexport(gcf,myName,options);


end

