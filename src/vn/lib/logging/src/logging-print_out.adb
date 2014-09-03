------------------------------------------------------------------------------
--  This file is part of VN-Lib.
--
--  VN-Lib is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  VN-Lib is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with VN-Lib.  If not, see <http://www.gnu.org/licenses/>.
--
--  Copyright 2014 Christoffer Holmstedt (christoffer.holmstedt@gmail.com)
------------------------------------------------------------------------------

with VN.Message;
use VN.Message;
with VN.Message.Local_Hello;
with VN.Message.Assign_Address;
with VN.Message.Assign_Address_Block;
with VN.Message.Request_Address_Block;
with VN.Message.Request_LS_Probe;
with VN.Message.Probe_Reply;
with VN.Message.Probe_Request;
with VN.Message.Distribute_Route;

package body Logging.Print_Out is

   procedure Log(This: in out Print_Out_Logger;
                 Message: out VN.Message.VN_Message_Basic) is
      use VN.Text_IO;
      Local_Hello_Msg: VN.Message.Local_Hello.VN_Message_Local_Hello;
      Assign_Address_Msg: VN.Message.Assign_Address.VN_Message_Assign_Address;
      Request_Address_Block_Msg:
            VN.Message.Request_Address_Block.VN_Message_Request_Address_Block;
      Assign_Address_Block_Msg:
            VN.Message.Assign_Address_Block.VN_Message_Assign_Address_Block;
      Request_LS_Probe_Msg:
            VN.Message.Request_LS_Probe.VN_Message_Request_LS_Probe;
      Probe_Request_Msg:
            VN.Message.Probe_Request.VN_Message_Probe_Request;
      Probe_Reply_Msg:
            VN.Message.Probe_Reply.VN_Message_Probe_Reply;
      Distribute_Route_Msg:
            VN.Message.Distribute_Route.VN_Message_Distribute_Route;
   begin

      if Message.Header.Opcode = OPCODE_LOCAL_HELLO then

         VN.Message.Local_Hello.To_Local_Hello(Message, Local_Hello_Msg);
         Put("Local Hello from:" &
             VN.VN_Logical_Address'Image(Local_Hello_Msg.Header.Source) &
            " to " &
            VN.VN_Logical_Address'Image(Local_Hello_Msg.Header.Destination) &
          --  " (logical addresses), Component_Type is " &
          --  VN.Message.VN_Component_Type'Image(Local_Hello_Msg.Component_Type) &
            ", CUUID is " &
            Local_Hello_Msg.CUUID(1)'Img);
         Put_Line("");

      elsif Message.Header.Opcode = OPCODE_LOCAL_ACK then
         Put_Line("Local_Ack");

      elsif Message.Header.Opcode = OPCODE_ASSIGN_ADDR then
         VN.Message.Assign_Address.To_Assign_Address(Message, Assign_Address_Msg);
         Put("Assign Address from:" &
             VN.VN_Logical_Address'Image(Assign_Address_Msg.Header.Source) &
            " to " &
            VN.VN_Logical_Address'Image(Assign_Address_Msg.Header.Destination) &
            " (logical addresses), CUUID " &
            Assign_Address_Msg.CUUID(1)'Img &
            " gets logical address " &
            Assign_Address_Msg.Assigned_Address'Img);
         Put_Line("");

      elsif Message.Header.Opcode = OPCODE_REQUEST_ADDR_BLOCK then
         VN.Message.Request_Address_Block.To_Request_Address_Block(Message, Request_Address_Block_Msg);
         Put("Request Address Block from:" &
             VN.VN_Logical_Address'Image(Request_Address_Block_Msg.Header.Source) &
            " to " &
            VN.VN_Logical_Address'Image(Request_Address_Block_Msg.Header.Destination) &
            " (logical addresses), from CUUID " &
            Request_Address_Block_Msg.CUUID(1)'Img);
         Put_Line("");

      elsif Message.Header.Opcode = OPCODE_ASSIGN_ADDR_BLOCK then
         VN.Message.Assign_Address_Block.To_Assign_Address_Block(Message, Assign_Address_Block_Msg);
         Put("Assign Address Block from:" &
             VN.VN_Logical_Address'Image(Assign_Address_Block_Msg.Header.Source) &
            " to " &
            VN.VN_Logical_Address'Image(Assign_Address_Block_Msg.Header.Destination) &
            " (logical addresses), to CUUID " &
            Assign_Address_Block_Msg.CUUID(1)'Img &
            " with logical addresses block " &
            Assign_Address_Block_Msg.Assigned_Base_Address'Img);
       --     Assign_Address_Block_Msg.Assigned_Base_Address'Img &
       --     " the request was " &
       --     Assign_Address_Block_Msg.Assigned_Base_Address'Img);
         Put_Line("");

      elsif Message.Header.Opcode = OPCODE_REQUEST_LS_PROBE then
         VN.Message.Request_LS_Probe.To_Request_LS_Probe(Message, Request_LS_Probe_Msg);
         Put("Request LS Probe from:" &
             VN.VN_Logical_Address'Image(Request_LS_Probe_Msg.Header.Source) &
            " to " &
            VN.VN_Logical_Address'Image(Request_LS_Probe_Msg.Header.Destination) &
            " (logical addresses), for logical address " &
            Request_LS_Probe_Msg.Component_Address'Img);
         Put_Line("");

      elsif Message.Header.Opcode = OPCODE_PROBE_REQUEST then
         VN.Message.Probe_Request.To_Probe_Request(Message, Probe_Request_Msg);
         Put("Probe Request from:" &
             VN.VN_Logical_Address'Image(Probe_Request_Msg.Header.Source) &
            " to " &
            VN.VN_Logical_Address'Image(Probe_Request_Msg.Header.Destination) &
            " (logical addresses)");
         Put_Line("");

      elsif Message.Header.Opcode = OPCODE_PROBE_REPLY then
         VN.Message.Probe_Reply.To_Probe_Reply(Message, Probe_Reply_Msg);
         Put("Probe Reply from:" &
             VN.VN_Logical_Address'Image(Probe_Reply_Msg.Header.Source) &
            " to " &
            VN.VN_Logical_Address'Image(Probe_Reply_Msg.Header.Destination) &
            " (logical addresses)");
         Put_Line("");

      elsif Message.Header.Opcode = OPCODE_DISTRIBUTE_ROUTE then
         VN.Message.Distribute_Route.To_Distribute_Route(Message, Distribute_Route_Msg);
         Put("Distribute Route from:" &
             VN.VN_Logical_Address'Image(Distribute_Route_Msg.Header.Source) &
            " to " &
            VN.VN_Logical_Address'Image(Distribute_Route_Msg.Header.Destination) &
            " (logical addresses), info: " &
            Distribute_Route_Msg.CUUID(1)'Img &
            " " &
            VN.VN_Logical_Address'Image(Distribute_Route_Msg.Component_Address) &
            " ");-- &
         --   VN.Message.VN_Component_Type'Image(Distribute_Route_Msg.Component_Type));
         Put_Line("");
      end if;

   end Log;

end Logging.Print_Out;
