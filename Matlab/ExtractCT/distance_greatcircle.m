function [arclen] = distance_greatcircle(lat1,lon1,lat2,lon2)
%distance_greatcircle Calculates great circle distance in radians
%   function to calulate arclen in radians based on coordinates

lat1 = lat1*pi()/180;
lon1 = lon1*pi()/180;
lat2 = lat2*pi()/180;
lon2 = lon2*pi()/180;

a = sin((lat2-lat1)/2).^2 + cos(lat1) .* cos(lat2) .* sin((lon2-lon1)/2).^2;
% this should not be neccesary, but for safety
a(a<0) = 0;
a(a>1) = 1;

arclen = 2 * atan2(sqrt(a), sqrt(1-a)) ;

arclen = arclen*180/pi(); 
end

