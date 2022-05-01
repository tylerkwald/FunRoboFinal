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
            obj.cam = webcam(2);
            obj.cam.WhiteBalance = "manual";
            obj.cam.Brightness = 0;
            obj.intrinsics = cameraIntrinsics([5*1600 5*1200], [800 600], [1200 1600]);
            obj.tagSize = 0.165;
        end

        function show(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            preview(obj.cam)
        end

        function I = disp_tags(obj)
            I = undistortImage(snapshot(obj.cam),obj.intrinsics,"OutputView","same");
            [id,loc,pose] = readAprilTag(I, "tag36h11", obj.intrinsics, obj.tagSize)
            worldPoints = [0 0 0; obj.tagSize/2 0 0; 0 obj.tagSize/2 0; 0 0 obj.tagSize/2]
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
                imshow(I);6
            end
        end

        function [id,loc, pose] = poses(obj)
            % 
            I = undistortImage(snapshot(obj.cam),obj.intrinsics,"OutputView","same");
            [id,loc,pose] = readAprilTag(I, "tag36h11", obj.intrinsics, obj.tagSize)
            imshow(I)
        end
        
        function [newPosition, tag] = updatePositionApril(obj)
           [id, loc, pose] = obj.poses();
           if size(id) ~= 0
           tag = id(1);
           newPosition = pose(1,1).Translation;
           else
           newPosition = -1;
           tag = -1;
           end
        end
        
        function [newPosition, tag] = scanForTags(obj, cameraServo)
            if cameraServo.getPosition() > 0
              target = -90;
            else
               target = 90;
            end
            cameraServo.movePosition(target)
            while cameraServo.getPosition() ~= target
                [newPosition, tag] = obj.updatePositionApril();
                 if tag ~= -1
                    return
                 end
           end           
        end
        
       
    end
end