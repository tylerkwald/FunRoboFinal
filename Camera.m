classdef Camera
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        cam;
        intrinsics;
        tagSize;
    end

    methods
        function obj = Camera()
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.cam = webcam(1);
            obj.cam.WhiteBalance = "manual";
            obj.cam.Brightness = 0;
            %obj.intrinsics = cameraIntrinsics([5*1600 5*1200], [800 600], [1200 1600]);
            obj.intrinsics = cameraIntrinsics([2.2820e+03 2.2839e+03], [876.5396 641.8974], [1200 1600], ...
                "RadialDistortion", [-0.4397 0.6058])
            obj.tagSize = 0.165;
        end

        function show(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            preview(obj.cam)
        end

        function I = disp_tags(obj)
            I = undistortImage(snapshot(obj.cam),obj.intrinsics,"OutputView","same");
            [id,loc,pose] = readAprilTag(I, "tag36h11", obj.intrinsics, obj.tagSize);
            worldPoints = [0 0 0; obj.tagSize/2 0 0; 0 obj.tagSize/2 0; 0 0 obj.tagSize/2];
            % Get image coordinates for axes.
            for i = 1:length(pose)
            % Get image coordinates for axes.
                if abs(max(loc(:, 1, i)) - min(loc(:, 1, i))) > 50
                    imagePoints = worldToImage(obj.intrinsics,pose(i).Rotation, pose(i).Translation,worldPoints);
    
                    % Draw colored axes.
                    I = insertShape(I,"Line",[imagePoints(1,:) imagePoints(2,:); ...
                    imagePoints(1,:) imagePoints(3,:); imagePoints(1,:) imagePoints(4,:)], ...
                    "Color",["red","green","blue"],"LineWidth",7);
    
                    I = insertText(I,loc(:,:,i),id(i),"BoxOpacity",1,"FontSize",25);
                end
                imshow(I);
            end
        end

        function [id,loc, pose] = poses(obj)
            % 
            I = undistortImage(snapshot(obj.cam),obj.intrinsics,"OutputView","same");
            [id,loc,pose] = readAprilTag(I, "tag36h11", obj.intrinsics, obj.tagSize);
            %imshow(I);
        end
        
        function [newPosition, pose, tag] = updatePositionApril(obj)
           [id, loc, pose] = obj.poses();
           if size(id) ~= 0
           tag = id(1);
           [newPosition] = pose(1,1).Translation;
           else
           newPosition = -1;
           tag = -1;
           end
        end
        
        function [newPosition, tag, Position, angle, pose, v] = scanForTags(obj, cameraServo)

            cameraServo.moveServo(0)
            pause(1.0)
            while true
                [newPosition, pose, tag] = obj.updatePositionApril();
                v =  transpose(pose(1,1).T) * [0; 0; 0; 1];
                 if tag ~= -1
                     if tag == 5 && v(3) < 1.75
                        
                    distance = sqrt(newPosition(1)^2 + newPosition(3)^2);
                    angle = cameraServo.getPosition() * 210;
                    xOffSet = distance * cosd(angle);
                    yOffSet = distance * sind(angle);
                    Position = [xOffSet, yOffSet];
                    matrix = transpose(pose(1,1).T)
                      %v = [0, 0, 0, 1] * (pose(1,1).T)^-1;     
                    return
                     end
                 end
                 if cameraServo.getPosition() < 0.2
                     direction = 1;
                 end
                 if  cameraServo.getPosition() > 0.8 
                     direction = -1;
                 end

                 cameraServo.moveServo(cameraServo.getPosition() + .1* direction)
                     pause(.5)
            end           
            tag = -1;
            newPosition = -1;
        end
        
        function [Position, angle, tag] = getAprilPosition(obj)%, cameraServo)
            [newPosition, pose, tag] = obj.updatePositionApril();
            if tag ~= -1
               distance = sqrt(newPosition(1)^2 + newPosition(3)^2);
               angle = atand(newPosition(1)/newPosition(3));
               angle = angle + 90;%cameraServo.getPosition() * 210;
               xOffSet = distance * cosd(angle);
               yOffSet = distance * sind(angle);
               Position = [xOffSet, yOffSet];
%                matrix = transpose(pose(1,1).T);
%                       %v = [0, 0, 0, 1] * (pose(1,1).T)^-1;
%                v =  transpose(pose(1,1).T) * [0; 0; 0; 1];
            else
                Position = [0,0];
                angle = 90;
            end
        end

        function goForBridge(obj)
            img = snapshot(obj.cam);
            imtool(img)
        end
    end
end