classdef RingBuffer    
    properties % (Access = private)
        buffer;
        ttags;
        size;
        indLast;
    end

    methods
        function obj = RingBuffer(bufObj,len)
            obj.buffer = repmat(bufObj,1,len);
            obj.ttags = uint64(zeros(1,len));
            obj.size = 0;
            obj.indLast = 0;
        end

        function obj = reset(obj)
            obj.size = 0;
            obj.indLast = 0;
        end

        function size = getSize(obj)
            size = obj.size;
        end        

        function nextInd = getNextInd(obj)
            if obj.indLast == length(obj.buffer)
                nextInd = 1;
            else
                nextInd = obj.indLast + 1;
            end
        end

        function prevInd = getPrevInd(obj)
            if obj.indLast == 1 && obj.size == length(obj.buffer)
                prevInd = length(obj.buffer);
            elseif obj.indLast > 1
                prevInd = obj.indLast - 1;
            else
                prevInd = 0;
            end
        end

        function obj = addData(obj,bufObj,ttag)
            nextInd = getNextInd(obj);
            obj.buffer(nextInd) = bufObj;
            obj.ttags(nextInd) = ttag;
            obj.indLast = nextInd;
            
            if obj.size < length(obj.buffer)
                obj.size = obj.size + 1;
            end
        end

        function bufObj = getData(obj,ind)
            if ind >= 1 && ind <= obj.size
                bufObj = obj.buffer(ind);
            else
                bufObj = [];
            end
        end

        function indLast = getLastInd(obj)
            indLast = obj.indLast;       
        end

        function bufObj = getLastData(obj)
            if obj.indLast > 0
                bufObj = obj.buffer(obj.indLast);
            else
                bufObj = [];
            end
        end

        function indOut = decIndex(obj,indIn)
            if indIn == 1 && obj.size == length(obj.buffer)
                indOut = length(obj.buffer);
            elseif indIn > 1
                indOut = indIn - 1;
            else
                indOut = 0;
            end
        end

        function [ind,status] = getLastIndLe(obj,ttag)
            ind = 0;
            status = false;

            if obj.size > 0
                i = obj.size;
                tmpInd = obj.indLast;
                while i > 0
                    if obj.ttags(tmpInd) <= ttag
                        status = true;
                        ind = tmpInd;
                        break;
                    end
                    tmpInd = decIndex(obj,tmpInd);
                    i = i - 1;
                end
            end
        end
    end
end

