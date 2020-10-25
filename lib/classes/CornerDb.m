classdef CornerDb
    properties (SetAccess='private', GetAccess='public')
        Location;
        Metric;
        Features;
        NumBits;
        Size;
        Capacity;
        Timeout;
        SlotEmpty;
        InState;
        DoMeasUpdate;
    end

    properties (Constant)
        TIMEOUT_THRES = 10;
    end
    
    methods
        function obj = CornerDb(capacity)
            obj.Location = single(zeros(capacity,2));
            obj.Metric = single(zeros(capacity,1));
            obj.Features = uint8(zeros(capacity,64));
            obj.NumBits = 512;
            obj.Size = 0;
            obj.Capacity = capacity;
            obj.Timeout = uint8(zeros(1,capacity));
            obj.SlotEmpty = true(1,capacity);
            obj.InState = false(1,capacity);
            obj.DoMeasUpdate = false(1,capacity);
        end
        
        function obj = add(obj,corners,features)
            cornerInd = 1;
            for i=1:1:obj.Capacity
                if cornerInd > corners.Count
                    break;
                end
                if obj.SlotEmpty(i)
                    obj.Location(i,:) = corners.Location(cornerInd,:);
                    obj.Metric(i) = corners.Metric(cornerInd);
                    obj.Features(i,:) = features.Features(cornerInd,:);
                    obj.Timeout(i) = 0;
                    obj.SlotEmpty(i) = false;
                    obj.InState(i) = false;
                    obj.DoMeasUpdate(i) = false;
                    obj.Size = obj.Size + 1;
                    cornerInd = cornerInd + 1;
                end
            end
        end
        
        function obj = update(obj,indexPairs,newCorners,newFeatures)
            % increment timeout counter for all corners
            for i=1:1:obj.Capacity
                if ~obj.SlotEmpty(i)
                    obj.Timeout(i) = obj.Timeout(i) + 1;
                end
            end
            
            % set measurement request update to false, because measurement
            % update can only be done if there is a match with known corner
            obj.DoMeasUpdate(1:end) = false;
            
            % update matched corners, reset timeout field
            for i=1:1:size(indexPairs,1)
                obj.Location(indexPairs(i,1),:) = newCorners.Location(indexPairs(i,2),:);
                obj.Metric(indexPairs(i,1)) = newCorners.Metric(indexPairs(i,2));
                obj.Features(indexPairs(i,1),:) = newFeatures.Features(indexPairs(i,2),:);
                obj.DoMeasUpdate(indexPairs(i,1)) = true;
                obj.Timeout(indexPairs(i,1)) = 0;
            end
            
            % free slots if timeout is reached
            for i=1:1:obj.Capacity
                if ~obj.SlotEmpty(i) && obj.Timeout(i) > obj.TIMEOUT_THRES
                    obj.SlotEmpty(i) = true;
                    obj.Size = obj.Size - 1;
                end
            end
            
            % fill free slots with new features
            numFreeSlots = obj.Capacity - obj.Size;
            
            if numFreeSlots > 0
                indNew = setdiff(1:1:newFeatures.NumFeatures, indexPairs(:,2));
                newCornersTmp = newCorners(indNew);
                [~,ind] = sort(newCornersTmp.Metric,'descend');
                if length(ind) > numFreeSlots
                    ind = ind(1:numFreeSlots);
                end
                if ~isempty(ind)
                    newFeaturesTmp = binaryFeatures(newFeatures.Features(indNew(ind),:));
                    obj = obj.add(newCornersTmp(ind),newFeaturesTmp);
                end
            end
        end
    end
end

