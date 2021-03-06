classdef Motor
   %class to control the servos on board the robot (camera pan and steering)
   properties
     robotServo;
   end
   
   methods
       function obj = Motor(robotArduino, servoPin)
           %initalizes the function and sets up the variables to use
           obj.robotServo = servo(robotArduino, servoPin, "MinPulseDuration", 1466 * 10 ^ -6, "MaxPulseDuration", 1536 * 10 ^ -6);
       end

       function moveServo(obj, moveAngle)
           %moves the servo
            writePosition(obj.robotServo, moveAngle);
       end
       
       function moveMotor(obj, moveAngle)
            %moves the motor (used so not to confused the 2)
            writePosition(obj.robotServo, moveAngle)
       end

       function currentPosition = getPosition(obj)
           %returns the angle that the servo is at
            currentPosition = readPosition(obj.robotServo);
       end
       
   end
end