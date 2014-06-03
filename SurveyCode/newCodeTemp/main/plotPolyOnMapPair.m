%Ryan Brummet
%University of Iowa

function [ ] = plotPolyOnMapPair( data, mapInfo )
    %mapInfo should be a 1x11 vector consisting of %targetAttr, mapAttr, 
    %Samples, deg, mapCoef, and RMSD where mapCoef consists of 6 columns
    %(decreasing order)
    
    labels{1} = 'sp';
    labels{2} = 'le';
    labels{3} = 'ld';
    labels{4} = 'ld2';
    labels{5} = 'lcl';
    labels{6} = 'ap';
    labels{7} = 'qol';
    labels{8} = 'im';
    labels{9} = 'st';
    
    
    figure;
    for k = 1 : 9
        if k ~= mapInfo(1,1)
            clearvars mapPairSet
            mapPairSet(1,size(data,2)) = NaN;
            indexTemp = 1;
            for n = 1 : size(data,1)
                if ~isnan(data(n,13 + k)) && ...
                    ~isnan(data(n,13 + mapInfo(1,1)))
                    mapPairSet(indexTemp,1) = data(n,13 + k);
                    mapPairSet(indexTemp,2) = data(n,13 + mapInfo(1,1));
                    indexTemp = indexTemp + 1;
                end
            end
            index = find(k == mapInfo(:,2));
            polyFitX = 1:.1:100;
            polyFitY = mapInfo(index,5)*(polyFitX.^5) + ...
                mapInfo(index,6)*(polyFitX.^4) + ...
                mapInfo(index,7)*(polyFitX.^3) + ...
                mapInfo(index,8)*(polyFitX.^2) + ...
                mapInfo(index,9)*(polyFitX.^1) + ...
                mapInfo(index,10)*(polyFitX.^0);
            
            subplot(3,3,k);
            scatter(mapPairSet(:,1),mapPairSet(:,2),'r');
            hold on;
            plot(polyFitX,polyFitY);
            hold off;
            ylabel(labels{mapInfo(1,1)});
            xlabel(labels{k});
            axis([0 100 0 100]);
        else
            continue;
        end
    end
end

