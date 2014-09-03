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

with Ada.Real_Time;
with Global_Settings;
with VN.Application_Information;
with VN.Message.Factory;
with VN.Message.Local_Hello;
with VN.Message.Request_Address_Block;
with VN.Message.Assign_Address_Block;
with VN.Message.Probe_Request;
with VN.Message.Probe_Reply;

package body Central_Addressing_Service is

   task body CAS is
      use Ada.Real_Time;
      use VN;
      use VN.Message;
      use VN.Message.Local_Hello;
      use VN.Message.Request_Address_Block;
      use VN.Message.Assign_Address_Block;
      use VN.Message.Probe_Request;
      use VN.Message.Probe_Reply;

      i: Integer := 1;


      Next_Period : Ada.Real_Time.Time;
      Period : constant Ada.Real_Time.Time_Span :=
                           Ada.Real_Time.Microseconds(Cycle_Time);
   begin
      CAS_Info.Logical_Address := VN.CAS_LOGICAL_ADDRESS;
      CAS_Info.Component_Type := VN.Message.Other;

      Global_Settings.Start_Time.Get(Next_Period);
      VN.Text_IO.Put_Line("CAS  STAT: Starts.");

      ----------------------------
      loop
         delay until Next_Period;

         ----------------------------
         -- Receive loop
         ----------------------------
         Global_Settings.Com_CAS.Receive(Basic_Msg, Recv_Status);

         if Recv_Status = VN.NO_MSG_RECEIVED then
            VN.Text_IO.Put_Line("CAS  RECV: Empty.");
         elsif Recv_Status = VN.MSG_RECEIVED_NO_MORE_AVAILABLE or
            Recv_Status = VN.MSG_RECEIVED_MORE_AVAILABLE    then

            VN.Text_IO.Put("CAS  RECV: ");
            Global_Settings.Logger.Log(Basic_Msg);


            if Basic_Msg.Header.Opcode = VN.Message.OPCODE_REQUEST_ADDR_BLOCK then
               To_Request_Address_Block(Basic_Msg, Request_Address_Block_Msg);
               Unsigned_8_Buffer.Insert(Request_Address_Block_Msg.CUUID(1), Assign_Address_Block_Buffer);

               -- TODO: Temporary test.
               if Basic_Msg.Header.Source /= VN.LOGICAL_ADDRES_UNKNOWN then
                  SM_L_Address := Basic_Msg.Header.Source;
               end if;

            elsif Basic_Msg.Header.Opcode = VN.Message.OPCODE_PROBE_REQUEST then
               To_Probe_Request(Basic_Msg, Probe_Request_Msg);
               VN_Logical_Address_Buffer.Insert(Probe_Request_Msg.Header.Source, Probe_Reply_Buffer);

            end if;

         end if;

         ----------------------------
         -- Send loop
         ----------------------------
        if not Unsigned_8_Buffer.Empty(Assign_Address_Block_Buffer) then
           Unsigned_8_Buffer.Remove(Temp_Uint8, Assign_Address_Block_Buffer);

           Basic_Msg := VN.Message.Factory.Create(VN.Message.Type_Assign_Address_Block);
           Basic_Msg.Header.Destination := SM_L_Address;
           Basic_Msg.Header.Source := CAS_Info.Logical_Address;

           To_Assign_Address_Block(Basic_Msg, Assign_Address_Block_Msg);
           Assign_Address_Block_Msg.CUUID := (others => Temp_Uint8);
           Assign_Address_Block_Msg.Assigned_Base_Address := Assigned_Address_Block;
           Assign_Address_Block_Msg.Response_Type := VN.Message.Valid;
           To_Basic(Assign_Address_Block_Msg, Basic_Msg);

           Assigned_Address_Block := Assigned_Address_Block + 65536;

           VN.Text_IO.Put("CAS  SEND: ");
           Global_Settings.Logger.Log(Basic_Msg);
           Global_Settings.Com_CAS.Send(Basic_Msg, Send_Status);

        elsif not VN_Logical_Address_Buffer.Empty(Probe_Reply_Buffer) then
            VN_Logical_Address_Buffer.Remove(Temp_Logical_Address, Probe_Reply_Buffer);

            Basic_Msg := VN.Message.Factory.Create(VN.Message.Type_Probe_Reply);
            Basic_Msg.Header.Source := CAS_Info.Logical_Address;
            Basic_Msg.Header.Destination := Temp_Logical_Address;

            VN.Text_IO.Put("CAS  SEND: ");
            Global_Settings.Logger.Log(Basic_Msg);
            Global_Settings.Com_Application.Send(Basic_Msg, Send_Status);

        end if;


         Next_Period := Next_Period + Period;
         i := i + 1;
         exit when i = 15;
      end loop;
      ----------------------------

      VN.Text_IO.Put_Line("CAS  STAT: Stop. Logical Address: " &
                                 CAS_Info.Logical_Address'Img);

   end CAS;

   CAS1: CAS(20, Global_Settings.Cycle_Time_Applications, 10, 3);

end Central_Addressing_Service;
