classdef Arbiter
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        heading;
        speed;
    end

    methods
        function obj = Arbiter()
            obj.heading = 0.55;
            obj.speed = 0.3;
        end

        function [heading, speed] = arbitrate(obj, WF, OA)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            steeringWave = WF(1,:) + OA(1,:); % wall following brainwave, 2 * n array with heading and speed arrays respectively
            speedWave = WF(2,:) + OA(2,:); % obstacle avoidance brainwave, 2 * n array with heading and speed arrays respectively
            heading = max(steeringWave);
            speed = max(speedWave);

        end
    end
end