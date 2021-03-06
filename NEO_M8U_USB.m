classdef NEO_M8U_USB 
    %Sparkfun USB NEO-M8U Module Driver
    
    %Created by Fledlging Technologies Inc. on 3/22/2022
    %        www.fledgling.tech
    
   %{
    % Basic Usage:
        
            % Create Class Instance
    
        neo = NEO_M8U_USB("COM#"); % replace # with the appropriate COM port number
     
            % Get basic data
            % returns a struct with fields: longitude, lattitude, roll, pitch, and heading.
       
        basic_data = neo.getBasic()
    
    
            % ADVANCED


            % Get all avaliable messages
            % msgs = neo.read().msgs;
    

            % Get a specific message (only useful for occaisional polling of specific data, polling_freq < 1Hz)
            % msg = neo.get(msg_name)
    

            % Note: Currently enabled messages are: 
            % msg_name = 'NAV_PVT', 'NAV_STATUS', 'NAV_ATT', 'NAV_SOL', 
           
           
        % For additional info about each message's fields, 
        % units of measurments, etc, see:
        % https://cdn.sparkfun.com/assets/c/f/d/8/a/u-blox8-M8_ReceiverDescrProtSpec__UBX-13003221__Public.pdf
   %}
   
    properties (Constant)      
        DEFAULT_NAME = "USB_NEO_M8U";
        DEFAULT_BAUD_RATE = 9600;
        DEFAULT_DATA_TYPE = "uint8";
        ubx = UBX();
    end
    properties
        device;
        data;
        plot;
    end
    methods
        function obj = NEO_M8U_USB(com_port) 
            arguments
               com_port;
            end
              obj.device = serialport(com_port, NEO_M8U_USB.DEFAULT_BAUD_RATE);
            
        end
        function response = sendUBX(obj, ubx_msg)
            
            %writeRegister(obj.device, 0xFF,ubx_msg) %point to data register
           
        for i=(1:length(ubx_msg))
               write(obj.device, ubx_msg(i),"uint8"); 
        end
            
            response = obj.read();
        end
        function frames = split(obj, bulk_read)
           %{
            while isequal(bulk_read,[])
                "retrying..."
                pause(0.1);
                bulk_read = obj.read().bytes;
            end
            %}
            frames = cell(ceil(length(bulk_read)/8),1); %pre-allocate frames
            i=1;
            
            while (bulk_read(1)~=255)
                
            L = typecast(uint8(bulk_read(5:6)),'uint16');
            %length(bulk_read)
            if(L>1000)
                bulk_read(5:6)
            end
            
            frames{i} = bulk_read(1:8+L);
            bulk_read = bulk_read(9+L:end);
            i = i+1;
            
            if length(bulk_read)<=8
                %bulk_read %debug
                frames(i:end) = []; %remove unused cells in frames
                break;
            end
            end
        end
        function msg = read_next_msg(obj)
     
            msg.length = 0;
            msg.bytes = [];

            msg_sync_chars = [0, 0];

            while (msg_sync_chars(1)~=181)
                msg_sync_chars(1) = read(obj.device,1,"uint8");
            end

            msg_sync_chars(2) = read(obj.device,1,"uint8");

            if ~isequal(msg_sync_chars, [obj.ubx.sync_char_1 obj.ubx.sync_char_2])
               msg.error = "Error: Invalid message signature bits. Should be [181, 98] (uB), got: ["+msg_sync_chars(1)+ ", " +msg_sync_chars(2)+"]."
               return;
            end

            msg_head = read(obj.device, 4, "uint8");


            msg.class = obj.ubx.CLASS_ID.lookup(msg_head(1:2));


            payload_length = typecast(uint8(msg_head(3:4)),"uint16");

            msg_payload = read(obj.device, payload_length, "uint8");

            msg_checksum = read(obj.device, 2, "uint8");

            msg.bytes = [msg_sync_chars msg_head msg_payload msg_checksum];
            msg.length = length(msg.bytes);

            msg.data = obj.ubx.parse(obj.ubx.decode(msg.bytes));

        end
        function data = read(obj)
           
               first_msg = obj.read_next_msg();
               data.msgs.(first_msg.class) = first_msg.data;

               msg = obj.read_next_msg();
               

               while ~strcmp(msg.class, first_msg.class)
                data.msgs.(msg.class) = msg.data;
                msg = obj.read_next_msg();
               end
            
        end
        function msg = get(obj, class_id)
           msgs = obj.read().msgs;
           if isfield(msgs, class_id)
           msg = msgs.(class_id);
           else %assume message with that class_id is enabled
               pause(0.1);
           msg = obj.get(class_id);
           end
        end
       function basic = getBasic(obj)
             % basic data:
            try
                msgs = obj.read().msgs;
                basic.longitude = msgs.NAV_PVT.lon;
                basic.lattitude = msgs.NAV_PVT.lat;
                basic.roll = msgs.NAV_ATT.roll;
                basic.pitch = msgs.NAV_ATT.pitch;
                basic.heading = msgs.NAV_ATT.heading;
            catch
                msg = 'retrying...'
                clear msg;
                pause(0.1);
                basic = obj.getBasic();
            end 
       end
    end
end


