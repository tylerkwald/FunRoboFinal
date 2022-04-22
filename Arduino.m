classdef Arduino
    
    properties
        robotArduino;
    end
    
    methods
        function obj = Arduino(COMPORT)
                % SETUPARDUINO creates and configures an arduino to be a simple robot
                % controller. It requires which COM port your Arduino is attached to as its
                % input and returns an Arduino object called robotArduino
                % create a global Arduino object so taht it can be used in functions
                obj.robotArduino = arduino(COMPORT, "Uno", "Libraries", "Servo");
        end
    end
    
end