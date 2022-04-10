classdef LIDAR
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        lidar;          % The lidar serial connection
        pol_data;       % The polar data [angles, distances]
        cart_data;      % The cartesian data [X, Y]
    end

    methods (Static)

        function close()
            fprintf(lidar, 'QT');
            fclose(lidar);
            clear lidar;
        end
    end
    
    methods
        %% Constructor
        function obj = LIDAR(comPort)
            serialObjs = instrfind;      %Read instrument objects from memory to MATLAB workspace
            if ~isempty(serialObjs)      %If there are old objects, close them
                fclose(serialObjs);      %close serial port attatched to old Lidar
                delete(serialObjs);      %delete old lidar objects
            end
            lidar = serial(comPort,'BaudRate', 115200);  %create a serial port for Lidar
            set(lidar,'Timeout',2);                     %set communication link timeout
            set(lidar,'InputBufferSize',20000);         %set data input buffer size
            set(lidar,'Terminator','LF/CR');            %set data stream terminator for fprintf
            fopen(lidar);                   %connects the serial port object, the lidar
            pause(0.3);                     %pauses to allow command to transmit
            fprintf(lidar,'SCIP2.0');       %writes string cmd to the lidar
            pause(0.3);                     %pause to allow cmd to the lidar
            fscanf(lidar);                  %reads ASCII data from the device connected to lidar
            fprintf(lidar,'VV');            %pause to allow data to be read
            pause(0.3);
            fscanf(lidar,'BM');
            pause(0.3);
            fscanf(lidar);
            fprintf(lidar,'MD0044072500');  %dont worry about what commands are sent for now
            pause(0.3);
            fscanf(lidar);
            clc
        end
        
        %% SENSE
        function scan(obj, cutoffDist)
            %Filters data to exclude points outside of cut off distance 
            %Takes A in mm, angles in rad, cut off distance in mm
            %Returns filtered data matrix

            angles = (-120:240/682:120-240/682) * pi / 180;

            [A] = FunRoboLidarScan(obj.lidar);
            
            A(A > cutoffDist) = 0;
            A(A < 40) = 0;
            
            obj.pol_data = [angles; A];

            X = obj.pol_data(2, :).*cos(obj.pol_data(1, :));          % Trig to find x-coord
            Y = obj.pol_data(2, :).*sin(obj.pol_data(1, :));          % Trig to find y-coord 
            obj.cart_data = [X; Y];
        end

        %% Prewritten Lidar Interface Functions

        function [rangescan]=FunRoboLidarScan(lidar)
            proceed=0;
            fprintf(lidar,'GD0044072500');
            
            while (proceed==0)
                if lidar.BytesAvailable >= 2134
                    data = fscanf(lidar,'%c',2134);
                    proceed = 1;
                end
            end
            
            i = find(data == data(13));
            rangedata=data(i(3)+1:end-1);
            
            for j=0:31
                onlyrangedata((64*j)+1:(64*j)+64)=rangedata(1+(66*j):64+(66*j));
            end
            
            j=0;
            
            for i=1:floor(numel(onlyrangedata)/3)
                encodeddist(i,:)=[onlyrangedata((3*j)+1) onlyrangedata((3*j)+2) onlyrangedata((3*j)+3)];
                j=j+1;
            end
            
            for k=1:size(encodeddist,1)
                rangescan(k)=decodeSCIP(encodeddist(k,:));
            end
        end
        
        function rangeval=decodeSCIP(rangeenc)
            % Function to decode range information transmitted using SCIP2.0 protocol.
            % Works for only two and three bit encoding.
            % Author- Shikhar Shrestha, IIT Bhubaneswar
            
            % Check for 2 or 3 Character Encoding
            if rangeenc(1)=='0' && rangeenc(2)=='0' && rangeenc(3)=='0'
                rangeval=0;
                return;
            end
            if rangeenc(1)=='0'
                dig1=((rangeenc(2)-'!')+33);
                dig2=((rangeenc(3)-'!')+33);
                dig1sub=dig1-48;
                dig2sub=dig2-48;
                dig1bin=dec2bin(dig1sub,6);
                dig2bin=dec2bin(dig2sub,6);
                rangeval=bin2dec([dig1bin dig2bin]);
                return;
            else
                dig1=((rangeenc(1)-'!')+33);
                dig2=((rangeenc(2)-'!')+33);
                dig3=((rangeenc(3)-'!')+33);
                dig1sub=dig1-48;
                dig2sub=dig2-48;
                dig3sub=dig3-48;
                dig1bin=dec2bin(dig1sub,6);
                dig2bin=dec2bin(dig2sub,6);
                dig3bin=dec2bin(dig3sub,6);
                rangeval=bin2dec([dig1bin dig2bin dig3bin]);
                return;
                
            end
        end
    end
end