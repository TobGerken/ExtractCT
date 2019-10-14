
% Get Coordinates

sites= {'US_Ho1', 'US_MMS', 'US_UMB', 'CA_Ca1','US_Bar', ...
        'US_Seg', 'US_Ses', 'US_Vcm', 'US_Wjs', 'CA_Ca2', 'US_Mpj', 'CA_Ca3', ...
        'US_Men', 'US_FR2', 'US_Pnp', 'US_ARc', 'US_ARM' };

LatLon = {[45.2041, -68.7402], [39.3232, -86.4131], [45.5598, -84.7138], [49.8673, -125.3336], [44.0646, -71.28808] , ...
          [34.3623, -106.7020], [34.3349, -106.7442], [35.888447, -106.532114], [34.425489, -105.861545], [49.8705, -125.2909], [34.4385, -106.2377], [49.5346, -124.9004], ...
          [43.07725, -89.402984], [29.9494900, -97.9962300], [43.0896, -89.415827], [35.54649, -98.0400], [36.6058, -97.4888]};

Elevation = [60,275, 234, 300, 272 , ...
             1596, 1604, 3030, 1931, 300, 2196, NaN, ...
             260, 272, 260, 472, 314];

DataDir =  'D:\OneDrive - The Pennsylvania State University\Projects\ACT-America\Data\CarbonTracker_2017'       ;
DataDir = '~/scratch/three-hourly/';
WorkDir = '~/scratch/RubiscoWS/Matlab/ExtractCT' ; 

Vars ={'bio_flux_opt','ocn_flux_opt','fossil_flux_imp','fire_flux_imp'}; 

init = true ;
clobber = true ;
% Vars to load

SDay = datenum(2000,01,01);
EDay = datenum(2017,02,19);
EDay = datenum(2018,01,01);

cd(WorkDir)

for day = SDay:EDay
   DStr = datestr(day,'yyyymmdd') ;
   
   FName = [DataDir 'CT2017.flux1x1.' DStr '.nc'];
   
   Lats = ncread(FName,'latitude');
   Lons = ncread(FName,'longitude');
   DecTime = ncread(FName,'decimal_time');
   UTC = ncread(FName,'time');
   
   if init 
      % get closest index for each site    
      for s= 1:length(sites)
            SiteStruct.(sites{s}).Lat = LatLon{s}(1);
            SiteStruct.(sites{s}).Lon = LatLon{s}(2);
            SiteStruct.(sites{s}).Elevation = Elevation;
            % get closest lat index
            % get closest lon index
            [~,Lat_i] = min(abs(LatLon{s}(1)-Lats));
            [~,Lon_i] = min(abs(LatLon{s}(2)-Lons));
            SiteStruct.(sites{s}).Lon_i = Lon_i;
            SiteStruct.(sites{s}).Lat_i = Lat_i;
            
            dist = distance_greatcircle(LatLon{s}(1), LatLon{s}(2), Lats(Lat_i), Lons(Lon_i));
            SiteStruct.(sites{s}).distance = dist/180*pi*6371;
            
            
            if clobber 
               % Prep Output files
               header = 'Year, Month, Day, UTC, ' ;
               for v = Vars
                    header =strcat(header, [', ' v{1}]);
               end  
               units = [', , , hours, mol m-2 s-1, mol m-2 s-1, mol m-2 s-1, mol m-2 s-1'];
               
               FNameOut = ['CT2017_' sites{s} '.csv'];
               fid = fopen(FNameOut, 'w');
               fprintf(fid,['Site Name:,  %s \n'],strrep(sites{s},'_','-'));
               fprintf(fid,['Site Latitude:, %f \n'],SiteStruct.(sites{s}).Lat);
               fprintf(fid,['Site Longitude:, %f \n'],SiteStruct.(sites{s}).Lon);
               fprintf(fid,['CarbonTracker Version:, CT2017 \n']);
               fprintf(fid,['CT Source:, ftp://aftp.cmdl.noaa.gov/products/carbontracker/co2/CT2017/fluxes/three-hourly/ \n']);
               fprintf(fid,['CT Latitude:, %f \n'],Lats(Lat_i));
               fprintf(fid,['CT Longitude:, %f \n'],Lons(Lon_i));
               fprintf(fid,['Distance from Site to CT Coord (km):, %f \n'],SiteStruct.(sites{s}).distance);
               fprintf(fid,'\n');
               fprintf(fid,[header '\n']); 
               fprintf(fid,[units '\n']); 
               fclose(fid);
            end
            
      end
      init = false ;
   end
   
   for v = Vars
       
       var = ncread(FName,v{1});
       
       for s = 1:length(sites)
           
           OutSite.(v{1}) = squeeze(var( SiteStruct.(sites{s}).Lon_i, SiteStruct.(sites{s}).Lat_i, :)) ;

       end
       
       
   end
   
   % Write Output
   	DV = datevec(day);
    Year = repmat(DV(1),[8,1]);
    Month = repmat(DV(2),[8,1]);
    Day = repmat(DV(3),[8,1]);
    for s = 1:length(sites)
         FNameOut = ['CT2017_' sites{s} '.csv'];
         
         N = nan(8,9);
         N(:,1) = Year;
         N(:,2) = Month;
         N(:,3) = Day;
         N(:,4) = UTC*24;
         
         for v = 1:length(Vars)
             N(:,4+v) = OutSite.(Vars{v}) ;
         end
         
         dlmwrite(FNameOut,N,'-append','delimiter',',')
         
    end
   
   
end