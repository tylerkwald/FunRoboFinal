classdef LIDAR
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        lidar;          % The lidar serial connection
        pol_data;       % The polar data [angles, distances]
        cart_data;      % The cartesian data [X, Y]
    end

    
    methods
        %% Constructor
        function obj = LIDAR(comPort)
            serialObjs = instrfind;      %Read instrument objects from memory to MATLAB workspace
            if ~isempty(serialObjs)      %If there are old objects, close them
                fclose(serialObjs);      %close serial port attatched to old Lidar
                delete(serialObjs);      %delete old lidar objects
            end
            pause(0.3);
            obj.lidar = serial(comPort,'BaudRate', 115200);  %create a serial port for Lidar
            set(obj.lidar,'Timeout',3);                     %set communication link timeout
            set(obj.lidar,'InputBufferSize',20000);         %set data input buffer size
            set(obj.lidar,'Terminator','LF/CR');            %set data stream terminator for fprintf
            pause(0.3);
            fopen(obj.lidar);                   %connects the serial port object, the lidar
            pause(0.3);                     %pauses to allow command to transmit
            fprintf(obj.lidar,'SCIP2.0');       %writes string cmd to the lidar
            pause(0.3);                     %pause to allow cmd to the lidar
            fscanf(obj.lidar);                  %reads ASCII data from the device connected to lidar
            pause(0.3);
            fprintf(obj.lidar,'VV');            %pause to allow data to be read
            pause(0.3);
            fscanf(obj.lidar,'BM');
            pause(0.3);
            fscanf(obj.lidar);
            pause(0.3);
            fprintf(obj.lidar,'MD0044072500');  %dont worry about what commands are sent for now
            pause(0.3);
            fscanf(obj.lidar);
            pause(0.3);
            clc
        end

        function close(obj)
            fprintf(obj.lidar, 'QT');
            fclose(obj.lidar);
            clear obj.lidar;
        end
     
        %% SENSE
        function data = scan(obj, cutoffDist)
            %Filters data to exclude points outside of cut off distance 
            %Takes A in mm, angles in rad, cut off distance in mm
            %Returns filtered data matrix

            angles = (-120:240/682:120-240/682) * pi / 180;

            [A] = FunRoboLidarScan(obj.lidar);
            disp(A);
            
            A(A > cutoffDist) = 0;
            A(A < 20) = 0;
            
            obj.pol_data = [angles; A];

            X = obj.pol_data(2, :).*cos(obj.pol_data(1, :));          % Trig to find x-coord
            Y = obj.pol_data(2, :).*sin(obj.pol_data(1, :));          % Trig to find y-coord 
            data = [X; -Y];
        end
        
        %% GEtters and Setters
        function cart_data = get_cart(obj)
            cart_data = obj.cart_data;
        end
    
    end
end