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
--  Copyright 2014, Nils Brynedal Ignell (nils.brynedal@gmail.com)
------------------------------------------------------------------------------

-- Summary:
-- VN.Communication.CAN.Logic is a package that implements the logic
-- of the VN-CAN protocol itself.
-- This file includes:
-- Definition of lowlevel datatypes, constants and operations as well as
-- definition of abstract base class Duty. Duty is a base class for
-- each of the state machines that constitute the implementation of
-- the VN-CAN protocol.


with Interfaces;
use Interfaces;
with VN.Message;

package VN.Communication.CAN.Logic is

   GIVE_DEBUG_OUTPUT : constant integer := 0;

   procedure DebugOutput(str : String; level : Integer; newLine : boolean := true);

   ASSIGN_CAN_ADDRESS 	: CAN_Message_Type := 1;
   CAN_MASTER_ASSIGNED 	: CAN_Message_Type := 2;
   ADDRESS_QUESTION 	: CAN_Message_Type := 3;
   ADDRESS_ANSWER 	: CAN_Message_Type := 4;
   PING 		: CAN_Message_Type := 5;
   PONG 		: CAN_Message_Type := 6;
   START_TRANSMISSION 	: CAN_Message_Type := 7;
   FLOW_CONTROL 	: CAN_Message_Type := 8;
   TRANSMISSION 	: CAN_Message_Type := 9;
   DISCOVERY_REQUEST    : CAN_Message_Type := 10;
   COMPONENT_TYPE	: CAN_Message_Type := 11;

   type VN_Message_Internal is
      record
         Data		: VN.Message.VN_Message_Basic;
         NumBytes	: Interfaces.Unsigned_16;
         Receiver 	: CAN_Address_Receiver;
         Sender		: CAN_Address_Sender;
      end record;

   type Duty is abstract tagged limited private;

   procedure Update(this : in out Duty;
                    msg : CAN_Message_Logical;
                    bMsgReceived : boolean;
                    msgOut : out CAN_Message_Logical;
                    bWillSend : out boolean) is abstract;

   type Duty_Ptr is access all Duty'Class;

   type Node_SM is abstract tagged limited private;

   procedure Update(this : in out Node_SM;
                    msgsBuffer : in out CAN_Message_Buffers.Buffer;
                    ret : out CAN_Message_Buffers.Buffer) is abstract;

   procedure Send(this : in out Node_SM;
                  msg : VN.Message.VN_Message_Basic;
                  result : out VN.Send_Status) is abstract;

   procedure Receive(this : in out Node_SM;
                     msg : out VN.Message.VN_Message_Basic;
                     status : out VN.Receive_Status) is abstract;

   --This function is only used for testing:
   procedure GetCANAddress(this : in out Node_SM;
                           address : out CAN_Address_Sender;
                           isAssigned : out boolean) is abstract;

   type Node_SM_Ptr is access all Node_SM'Class;

private

   type Duty is abstract tagged limited
      record
         null;
      end record;

     type Node_SM is abstract tagged limited
      record
         null;
      end record;
end VN.Communication.CAN.Logic;
