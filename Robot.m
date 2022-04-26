classdef Robot
    
    properties
        steeringServo;
        cameraServo;
        sharpIR;
        lidar;
        driveMotor;
        robotArduino;
        gps;
    end

    methods

        function obj = Robot(arduinoComport, steeringPin, cameraSteerPin, sharpPinList, gpsComport, lidarComport, drivePin)
            robotArduino = Arduino(arduinoComport);
            camerServo = Camera();
            gps = GPS(gpsComport);
            lidar = LIDAR(lidarComport);
            steeringServo = Motor(robotArduino, steeringPin);
            driveMotor = Motor(robotArduino, drivePin);
            cameraServo = Motor(robotArduino, cameraSteerPin);
            sharpIR = SharpIR(robotArduino, sharpPinList);
        end
    end
end