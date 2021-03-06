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
-- CAN_Interface is a protected object that holds a VN.Communication.CAN.Logic.SM.Main_Duty.
-- CAN_Interface is to be used by two tasks: One higher level task and
-- CAN_task, a lower level task that handles CAN communication.

-- Each task that accesses an instance of CAN_Interface will do so using an
-- access variable (pointer).

-- Please note: If the Ravenscar profile had not been used, the CAN_Task
-- would have been put inside CAN_Interface which would have simplyfied the
-- interface of CAN_SM_Type. This would however violate the NO_TASK_HIERARCY
-- restriction that the Ravenscar profile imposes.

with VN;
with VN.Communication.CAN;
with VN.Communication.CAN.CAN_Filtering;
with VN.Communication.CAN.Logic.SM;
with VN.Communication.CAN.Logic.Node;

package VN.Communication.CAN.CAN_Interface is

 type Unit_Type is (SM_CAN, Node);

   type Private_Data(theUCID   : access VN.Communication.CAN.UCID;
                     theCUUID  : access VN.VN_CUUID;
                     theFilter : VN.Communication.CAN.CAN_Filtering.CAN_Filter_Access;
                     unitType  : Unit_Type) is limited private;

   protected type CAN_Interface_Type(theUCID   : access VN.Communication.CAN.UCID;
                                     theCUUID  : access VN.VN_CUUID;
                                     theFilter : VN.Communication.CAN.CAN_Filtering.CAN_Filter_Access;
                                     unitType  : Unit_Type) is
        new VN.Communication.Com with

      overriding procedure Send(Message: in VN.Message.VN_Message_Basic;
                                Status: out VN.Send_Status);

      overriding procedure Receive(Message : out VN.Message.VN_Message_Basic;
                                   Status: out VN.Receive_Status);


      ----------- FUNCTIONS FOR CAN_task ---------------------
      procedure Update(msgsBuffer : in out VN.Communication.CAN.CAN_Message_Buffers.Buffer;
                       ret : out VN.Communication.CAN.CAN_Message_Buffers.Buffer);
      --------------------------------------------------------

   private
      isInitialized : Boolean := false;
      data : Private_Data(theUCID, theCUUID, theFilter, unitType);
   end CAN_Interface_Type;

   type CAN_Interface_Access is access all CAN_Interface_Type;

private

   type Private_Data(theUCID   : access VN.Communication.CAN.UCID;
                     theCUUID  : access VN.VN_CUUID;
                     theFilter : VN.Communication.CAN.CAN_Filtering.CAN_Filter_Access;
                     unitType  : Unit_Type) is
      record
         case unitType is
            when SM_CAN =>
               SMDuty : VN.Communication.CAN.Logic.SM.SM_Duty(theUCID, theCUUID, theFilter);
            when Node =>
               nodeDuty : VN.Communication.CAN.Logic.Node.Node_Duty(theUCID, theCUUID, theFilter);
         end case;
      end record;

end VN.Communication.CAN.CAN_Interface;
