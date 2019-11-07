function Vs30=getVs30(p,opt)

baseline = opt.baseline;
source   = opt.source;
Nsource  = length(source);
Nsites   = size(p,1);
Vs30     = ones(Nsites,1)*baseline;

if Nsource ==1 && strcmp(source{1},' ')
    return
end

Lat = p(:,1);
Lon = p(:,2);

for i=Nsource:-1:1
    fname = opt.source{i};
    if contains(fname,'.kml')
        kml = kml2struct(fname);
        vLat = kml.Lat(~isnan(kml.Lat));
        vLon = kml.Lon(~isnan(kml.Lon));
        IN  = inpolygon(Lat,Lon,vLat,vLon);
        if any(IN)
            Vs30(IN)= str2double(kml.Description);
        end
        
    else
        DATA=load(fname);
        fldname = fields(DATA);
        fldname = fldname{1};
        
        switch fldname
            case 'raster' % tiff file (e.g., from USGS)
                source = DATA.raster; 
                Npoly = length(source);
                for j=1:Npoly
                    r = source(j);
                    IN  = inpolygon(Lat,Lon,r.box(:,2),r.box(:,1));
                    if any(IN)
                        img       = double(imread(r.tif));
                        lon       = linspace(r.box(1,1),r.box(2,1),r.nlon);
                        lat       = linspace(r.box(2,2),r.box(1,2),r.nlat);
                        [LON,LAT] = meshgrid(lon,lat);
                        Vs30(IN)  = interp2(LON,LAT,img,Lon(IN),Lat(IN));
                    end
                end
            case 'microzone' %simple matfile
                source = DATA.microzone;
                Npoly = length(source);
                for j=1:Npoly
                    r = source(j);
                    IN  = inpolygon(Lat,Lon,r.Lat,r.Lon);
                    if any(IN)
                        Vs30(IN)  = source(j).Vs30;
                    end
                end
        end
    end
end

