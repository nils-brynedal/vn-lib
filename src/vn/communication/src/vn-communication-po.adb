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
with Buffers;
-- with Ada.Text_IO;

package body VN.Communication.PO is

   protected body VN_PO is

      -- Procedures used from the SM_L side
      procedure Send_To_Other(Message: in VN.Message.VN_Message_Basic;
                              Status: out VN.Send_Status) is
      begin
         if VN_Message_Buffer.Full(Buffer_To_Other) then
            Status := VN.ERROR_BUFFER_FULL;
         else
            Status := VN.OK;
            VN_Message_Buffer.Insert(Message, Buffer_To_Other);
         end if;
      end Send_To_Other;

      procedure Receive_From_Other(Message: out VN.Message.VN_Message_Basic;
                     Status: out VN.Receive_Status) is
      begin
         -- Ada.Text_IO.Put_Line("PO receive_from_other runs");
         if VN_Message_Buffer.Empty(Buffer_To_SM_L) then
            Status := VN.NO_MSG_RECEIVED;
         else
            VN_Message_Buffer.Remove(Message, Buffer_To_SM_L);

            if VN_Message_Buffer.Empty(Buffer_To_SM_L) then
               Status := VN.MSG_RECEIVED_NO_MORE_AVAILABLE;
            else
               Status := VN.MSG_RECEIVED_MORE_AVAILABLE;
            end if;
         end if;
      end Receive_From_Other;

      -- Procedures used from the application side
      procedure Send_To_SM_L(Message: in VN.Message.VN_Message_Basic;
                      Status: out VN.Send_Status) is
      begin
         if VN_Message_Buffer.Full(Buffer_To_SM_L) then
            Status := VN.ERROR_BUFFER_FULL;
         else
            Status := VN.OK;
            VN_Message_Buffer.Insert(Message, Buffer_To_SM_L);
         end if;
      end Send_To_SM_L;

      procedure Receive_From_SM_L(Message: out VN.Message.VN_Message_Basic;
                     Status: out VN.Receive_Status) is
      begin
         -- Ada.Text_IO.Put_Line("PO receive_from_SM_L runs");
         if VN_Message_Buffer.Empty(Buffer_To_Other) then
            Status := VN.NO_MSG_RECEIVED;
         else
            VN_Message_Buffer.Remove(Message, Buffer_To_Other);

            if VN_Message_Buffer.Empty(Buffer_To_Other) then
               Status := VN.MSG_RECEIVED_NO_MORE_AVAILABLE;
            else
               Status := VN.MSG_RECEIVED_MORE_AVAILABLE;
            end if;
         end if;
      end Receive_From_SM_L;

      -- Get buffer length
      function Get_Buffer_Length_To_Other return Integer is
      begin
         return Buffer_Length_To_Other;
      end Get_Buffer_Length_To_Other;

      -- Get buffer length
      function Get_Buffer_Length_To_SM_L return Integer is
      begin
         return Buffer_Length_To_SM_L;
      end Get_Buffer_Length_To_SM_L;

   end VN_PO;

end VN.Communication.PO;
