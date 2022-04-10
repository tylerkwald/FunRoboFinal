classdef SharpIR

    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        pinList
        arduino
        ranges
        sampleSize
    end

    methods
        %% Constructor
        function obj = SharpIR(arduino, pinList)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.arduino = arduino;
            obj.pinList = pinList;
            for i=1:length(pinList)
                configurePin(arduino, pinList(i), 'AnalogInput');
            end

            obj.ranges = zeros(length(pinList));

        end


        %% Sense

        function scan(obj)
            for i=1:length(obj.pinList)
                obj.ranges(i) = obj.readSharp(obj.filter(obj.collectPoint(obj.pinList(i))));
            end
        end

        function rangeData = collectPoint(obj, pin)
            rangeData = [null]*obj.sampleSize;
            for i = 1:collections
                rangeData(i) = readVoltage(obj.arduino, pin);
                pause(0.001);
            end
        end
        
        function final = filter(rangesIn)
            len = length(rangesIn);
            sorted = sort(rangesIn);
            trimmed = sorted(floor(len/3) : ceil(2*len/3));
            final = mean(trimmed);
        
        end
        
        function range = readSharp(rangeIn)
            a = 0.00654925;
            b = 0.120685;
            c = -0.16023;
            range = (1 / ((a * rangeIn) + b)) + c;
        end
    end
end