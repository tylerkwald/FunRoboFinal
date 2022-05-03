clear vars
camera = Camera();
%camera.show()
% pause(4.0)
% I = camera.disp_tags();
% [id, lock, pose]= camera.poses();
% distance = zeros(size(pose));
% p = size(pose);
% for i = 1:p(2)
% %get the distance from the translation matrix (if you want the x and y
% %shift as well you use h(1) and h(2)
% h = pose(1,i).Translation;
% distance(i) = h(3);
%end
clc                     % clear command window
clear                   % clear MATLAB workspace
clf
camera = Camera();
%camera.show()
% robotArduino = arduino('COM3','Nano33BLE',"Libraries",{'Servo','I2C'});
%  servoPin = "D6";
%  cameraServo = Motor(robotArduino, servoPin);
%  cameraServo.getPosition()
%  cameraServo.moveServo(0.5)
%  cameraServo.getPosition()
%steerServo.moveServo(0.1)
%writePosition(cameraServo.robotServo, 0.1);
%[newPosition, tag] = camera.scanForTags(cameraServo);
[newPosition, tag] = camera.updatePositionApril;
disp(newPosition)
disp(tag)
%[tag, newPosition] = camera.updatePositionApril()




