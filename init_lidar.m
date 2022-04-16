function init_lidar(lidar)
    set(lidar,'Timeout',3);                     %set communication link timeout
    set(lidar,'InputBufferSize',20000);         %set data input buffer size
    set(lidar,'Terminator','LF/CR');            %set data stream terminator for fprintf
    pause(2);
    fopen(lidar);                   %connects the serial port object, the lidar
    pause(2);                     %pauses to allow command to transmit
    fprintf(lidar,'SCIP2.0');       %writes string cmd to the lidar
    pause(2);                     %pause to allow cmd to the lidar
    fscanf(lidar);                  %reads ASCII data from the device connected to lidar
    pause(2);
    fprintf(lidar,'VV');            %pause to allow data to be read
    pause(2);
    fscanf(lidar,'BM');
    pause(2);
    fscanf(lidar);
    pause(2);
    fprintf(lidar,'MD0044072500');  %dont worry about what commands are sent for now
    pause(2);
    fscanf(lidar);
    pause(2);
    clc
end