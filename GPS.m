classdef GPS
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        gps;
        data;
        roverX;
        roverY;
        roverHeading;
    end

    methods
        function obj = GPS(comPort)
            % Construct an instance of this class
            %   Detailed explanation goes here
            obj.gps = NEO_M8U_USB(comPort);         % Create a GPS Class Instance, replace COM7 with your COM#
            pause(2);                          % Let GPS get up to speed
        end

        function readGPS(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
             % the function neo.getBasic()
            % returns a struct with fields: longitude, lattitude, roll, pitch, and heading.
                   
            obj.data = neo.getBasic();
            obj.roverX = obj.data.longitude;
            obj.roverY = obj.data.lattitude;
            obj.roverHeading = obj.data.heading;
        end

        function showGPS(obj)
            % Create a stand alone figure to plot GPS rover position data in
            gpsRoverPlot=figure('Name','Rover Position','NumberTitle','off','Visible','on');

            % Zoom down the plot to the Olin Oval coordinates in Latitude and Longitude
            geolimits([42.29246 42.29418],[-71.26537 -71.26258])

            % Plot out a trail line bewteen two waypoints just to demo line drawing
            geoplot([42.293 42.294],[-71.265 -71.262],'y-')
            hold on;
            % plot rover poition, you can change this line to plot roverX and RoverY 
            geoplot(42.2935, -71.264, 'r*')

            % Import a satellite photo basemap to draw on
            geobasemap satellite
            legend('Rover GPS Track')
            movegui(gpsRoverPlot,'south');

            title('Planetary Rover Position')
        end

    end
end