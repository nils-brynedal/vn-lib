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
with System;
with Ada.Text_IO;
with Buffers;
with Global_Settings;
with VN;
with VN.Application_Information;
with VN.Message.Factory;
with VN.Message.Local_Hello;
with VN.Message.Assign_Address;
with VN.Message.Assign_Address_Block;
with VN.Message.Request_Address_Block;
with VN.Message.Request_LS_Probe;
with VN.Message.Distribute_Route;
with Interfaces;

package SM_X is

   task type SM_L(Pri : System.Priority;
                     Cycle_Time : Positive;
                     Task_ID : Positive;
                     Increment_By : Positive) is
      pragma Priority(Pri);
   end SM_L;

   private

      -- package Natural_Buffer is
      --   new Buffers(Natural);

      package VN_Logical_Address_Buffer is
         new Buffers(VN.VN_Logical_Address);

      package Unsigned_8_Buffer is
         new Buffers(Interfaces.Unsigned_8);

      SM_x_Info: VN.Application_Information.VN_Application_Information;

      Basic_Msg: VN.Message.VN_Message_Basic;
      Local_Hello_Msg: VN.Message.Local_Hello.VN_Message_Local_Hello;
      Assign_Address_Msg: VN.Message.Assign_Address.VN_Message_Assign_Address;
      Assign_Address_Block_Msg: VN.Message.Assign_Address_Block.VN_Message_Assign_Address_Block;
      Request_Address_Block_Msg: VN.Message.Request_Address_Block.VN_Message_Request_Address_Block;
      Request_LS_Probe_Msg: VN.Message.Request_LS_Probe.VN_Message_Request_LS_Probe;
      Distribute_Route_Msg: VN.Message.Distribute_Route.VN_Message_Distribute_Route;

      Recv_Status: VN.Receive_Status;
      Send_Status: VN.Send_Status;

      Version: VN.Message.VN_Version;

      Sent_CAS_Request_LS_Probe : boolean := false;
      CAS_CUUID: Interfaces.Unsigned_8;
      CAS_Logical_Address: VN.VN_Logical_Address := VN.LOGICAL_ADDRES_UNKNOWN;

      LS_CUUID: Interfaces.Unsigned_8;
      LS_Logical_Address: VN.VN_Logical_Address := VN.LOGICAL_ADDRES_UNKNOWN;

      Temp_Uint8: Interfaces.Unsigned_8;
      Temp_Logical_Address: VN.VN_Logical_Address := VN.LOGICAL_ADDRES_UNKNOWN;

      Received_Address_Block : VN.VN_Logical_Address := VN.LOGICAL_ADDRES_UNKNOWN;
      Assigned_Address : VN.VN_Logical_Address := VN.LOGICAL_ADDRES_UNKNOWN;

      -- TODO: Change this buffer to some kind of data store.
      Assign_Address_Buffer: Unsigned_8_Buffer.Buffer(10);

      -- TODO: Change this buffer to some kind of data store.
      Request_LS_Probe_Buffer: VN_Logical_Address_Buffer.Buffer(10);

      -- TODO: Change this buffer to some kind of data store.
      Request_Address_Block_Buffer: Unsigned_8_Buffer.Buffer(10);

      function Get_Address_To_Assign(CUUID_Uint8: in Interfaces.Unsigned_8)
         return VN.VN_Logical_Address;

      function Has_Received_Address_Block return Boolean;

end SM_X;
