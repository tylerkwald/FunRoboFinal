classdef Servo
   %class to control the servos on board the robot (camera pan, and steering)
   properties
     robotServo;
   end
   
   methods
       function obj = Servo(robotArduino, servoPin)
           %initalizes the function and sets up the variables to use
           obj.robotServo = setUpServo(robotArduino, servoPin);
       end

       function moveServo(obj, moveAngle)
           %moves the servo
            writePosition(obj.robotServo, moveAngle);
       end
       
       function currentPosition = getPosition(obj)
           %returns the angle that the servo is at
            currentPosition = readPosition(obj.robotServo);
       end
       
       function [robotServo] = setUpServo(robotArduino, servoPin)
           %sets up the pin on the arduino for the servo.
           configurePin(robotArduino, servoPin, "DigitalOutput");
           robotServo = servo(robotArduino, servoPin, "MinPulseDuration", 1120 * 10 ^ -6, "MaxPulseDuration", 1925 * 10 ^ -6);          
       end
   end
end