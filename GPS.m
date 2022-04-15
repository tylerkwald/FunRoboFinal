classdef GPS
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        gps;
        data;
    end

    methods
        function obj = GPS(arduino)
            % Construct an instance of this class
            %   Detailed explanation goes here
            obj.gps = gpsdev(arduino);
            obj.data;
        end

        function data = readGPS(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end