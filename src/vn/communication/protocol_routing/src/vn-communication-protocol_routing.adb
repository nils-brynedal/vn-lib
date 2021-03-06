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
-- Protocol_Routing is a middle layer between the subnets and the
-- application layer. The Protocol_Routing package will decide on
-- which subnet to send a VN message sent by the application layer
-- and whether a VN message received via a subnet shall be
-- delivered to the application layer or sent to another
-- subnet, and if so, which one.

-- ToDo: This implementation only handles one route between to points.

with VN;
with VN.Message;
use VN.Message;

with VN.Message.Local_Hello;
with VN.Message.Distribute_Route;
with VN.Message.Assign_Address;
with VN.Message.Assign_Address_Block;

package body VN.Communication.Protocol_Routing is

   procedure Send(this : in out Protocol_Routing_Type;
                             Message: in VN.Message.VN_Message_Basic;
                             Status: out VN.Send_Status) is

      found   : Boolean;
      address : Protocol_Address_Type;

      msgAssignAddr 	 : VN.Message.Assign_Address.VN_Message_Assign_Address;
      msgAssignAddrBlock : VN.Message.Assign_Address_Block.VN_Message_Assign_Address_Block;
   begin

      if not this.Initiated then
         this.Init;
      end if;

      -- ASSIGN_ADDR and ASSIGN_ADDR_BLOCK are routed on their receiver's
      -- CUUID since the receiver does not have a logical address yet
      if Message.Header.Opcode = VN.Message.OPCODE_ASSIGN_ADDR then
         VN.Message.Assign_Address.To_Assign_Address(Message, msgAssignAddr);
         CUUID_Protocol_Routing.Search(this.myCUUIDTable, msgAssignAddr.CUUID, address, found);

--           VN.Text_IO.Put_Line("Protocol routing: OPCODE_ASSIGN_ADDR, CUUID(1)= " & msgAssignAddr.CUUID(1)'Img &
--                                 " address found = " & found'Img);

         -- Since we assign an logical address, we know that this logical address exists on this subnet
         -- (We know that the receiver exists on that subnet because of the CUUID routing)
         Protocol_Router.Insert(this.myTable, msgAssignAddr.Assigned_Address, address); --new

      elsif Message.Header.Opcode = VN.Message.OPCODE_ASSIGN_ADDR_BLOCK and
        Message.Header.Destination = VN.LOGICAL_ADDRES_UNKNOWN then --new

         VN.Message.Assign_Address_Block.To_Assign_Address_Block(Message, msgAssignAddrBlock);
         CUUID_Protocol_Routing.Search(this.myCUUIDTable, msgAssignAddrBlock.CUUID, address, found);

         -- Since we assign an logical address, we know that this logical address exists on this subnet
         -- (We know that the receiver exists on that subnet because of the CUUID routing)
         Protocol_Router.Insert(this.myTable, msgAssignAddrBlock.Assigned_Base_Address, address); --new
      else
         Protocol_Router.Search(this.myTable, Message.Header.Destination, address, found);

--           VN.Text_IO.Put_Line("Protocol routing: Normal message. Destination " & Message.Header.Destination'Img &
--                                 " address found = " & found'Img);

      end if;

      if found then
         if address = 0 then -- the case when the message is to be sent back to the application layer
            Status := ERROR_UNKNOWN; -- ToDo, what do we do if this happens!!???
         else

--              if Message.Header.Opcode = 16#73# then
--                 VN.Text_IO.Put_Line("Sent REQUEST_LS_PROBE from " & Message.Header.Source'img &
--                                       " sent to " & Message.Header.Destination'Img &
--                                       " rerouted onto subnet " & address'Img & " numberOfInterfaces= " & this.numberOfInterfaces'Img);
--
--              elsif Message.Header.Opcode = 16#78# then
--                 VN.Text_IO.Put_Line("Sent PROBE_REQUEST from " & Message.Header.Source'img &
--                                       " sent to " & Message.Header.Destination'Img &
--                                       " rerouted onto subnet " & address'Img & " numberOfInterfaces= " & this.numberOfInterfaces'Img);
--              end if;

            if Message.Header.Opcode /= VN.Message.OPCODE_LOCAL_HELLO and
              Message.Header.Opcode /= VN.Message.OPCODE_LOCAL_ACK then
               -- Add routing info,
               --Protocol_Address_Type(0) means that the message shall be returned to the application layer
               Protocol_Router.Insert(this.myTable, Message.Header.Source, Protocol_Address_Type(0));
            end if;

            this.myInterfaces(Integer(address)).Send(Message, Status);
         end if;
      else
         Status := ERROR_NO_ADDRESS_RECEIVED; --should not really happen?
         VN.Text_IO.Put_Line("Error no address received for message sent from " & Message.Header.Source'Img &
                               " to " & Message.Header.Destination'Img);
      end if;
   end Send;


   procedure Receive(this : in out Protocol_Routing_Type;
                                Message : out VN.Message.VN_Message_Basic;
                                Status: out VN.Receive_Status) is

      procedure Handle_Distribute_Route(Message: in VN.Message.VN_Message_Basic;
                                        source : Protocol_Address_Type) is

         msgDistribute : VN.Message.Distribute_Route.VN_Message_Distribute_Route;
      begin
         VN.Message.Distribute_Route.To_Distribute_Route(Message, msgDistribute);
         Protocol_Router.Insert(this.myTable, msgDistribute.Component_Address, source);

--           VN.Text_IO.Put_Line("Protocol routing: Received route to Destination " & msgDistribute.Component_Address'Img &
--                                 " source = " & source'Img);
      end Handle_Distribute_Route;

      procedure HandleCUUIDRouting(Message : VN.Message.VN_Message_Basic;
                                   source : Protocol_Address_Type) is

         msgLocalHello : VN.Message.Local_Hello.VN_Message_Local_Hello;
      begin
         VN.Message.Local_Hello.To_Local_Hello(Message, msgLocalHello);
         CUUID_Protocol_Routing.Insert(this.myCUUIDTable, msgLocalHello.CUUID, source);
      end HandleCUUIDRouting;

      tempMsg    : VN.Message.VN_Message_Basic;
      tempStatus : VN.Receive_Status;
      stop          : boolean := false;
      firstLoop     : boolean := true;
      wasNextInTurn : Protocol_Address_Type := this.nextProtocolInTurn;

      found      : Boolean;
      address    : Protocol_Address_Type;
      sendStatus : VN.Send_Status;
   begin

      if this.numberOfInterfaces > 0 then
         while firstLoop or (not stop and wasNextInTurn /= this.nextProtocolInTurn) loop

            firstLoop := false;
            this.myInterfaces(this.nextProtocolInTurn).Receive(tempMsg, tempStatus);

            --TODO, this will need to be updated if more options for VN.Receive_Status are added:
            if tempStatus = VN.MSG_RECEIVED_NO_MORE_AVAILABLE or
              tempStatus = VN.MSG_RECEIVED_MORE_AVAILABLE then

               --A special case of retreiving routing info:
               if tempMsg.Header.Opcode = VN.Message.OPCODE_LOCAL_HELLO then
                  HandleCUUIDRouting(tempMsg, this.nextProtocolInTurn);

               elsif tempMsg.Header.Opcode /= VN.Message.OPCODE_LOCAL_ACK then
                  Protocol_Router.Insert(this.myTable, tempMsg.Header.Source,
                                         Protocol_Address_Type(this.nextProtocolInTurn));
               end if;

               --Get routing info from Distribute Route messages:
               if tempMsg.Header.Opcode = VN.Message.OPCODE_DISTRIBUTE_ROUTE then
                  Handle_Distribute_Route(tempMsg, this.nextProtocolInTurn);
--                 else
--                    VN.Text_IO.Put_Line("Protocol routing: Message not OPCODE_DISTRIBUTE_ROUTE");
               end if;

               --Check if the message shall be re-routed onto a subnet, or returned to the application layer:
               --LocalHello, LocalAck, AssignAddr and AssignAddrBlock (with destination address = VN.LOGICAL_ADDRES_UNKNOWN)
               --shall always be sent to the application layer
               if tempMsg.Header.Opcode /= VN.Message.OPCODE_LOCAL_HELLO and
                 tempMsg.Header.Opcode /= VN.Message.OPCODE_LOCAL_ACK and
                 tempMsg.Header.Opcode /= VN.Message.OPCODE_ASSIGN_ADDR and
                 not (tempMsg.Header.Opcode = VN.Message.OPCODE_ASSIGN_ADDR_BLOCK and tempMsg.Header.Destination = VN.LOGICAL_ADDRES_UNKNOWN) then

                  Protocol_Router.Search(this.myTable, tempMsg.Header.Destination, address, found);

                  if found and address /= 0 then --  address = 0 means send to Application layer

--                       if tempMsg.Header.Opcode = 16#73# then
--                          VN.Text_IO.Put_Line("Received REQUEST_LS_PROBE from " & tempMsg.Header.Source'img &
--                                           " sent to " & tempMsg.Header.Destination'Img
--                                              & " rerouted onto subnet " & address'Img & " numberOfInterfaces= " & this.numberOfInterfaces'Img);
--
--                       elsif Message.Header.Opcode = 16#78# then
--                          VN.Text_IO.Put_Line("Sent PROBE_REQUEST rom " & tempMsg.Header.Source'img &
--                                                " sent to " & tempMsg.Header.Destination'Img
--                                              & " rerouted onto subnet " & address'Img & " numberOfInterfaces= " & this.numberOfInterfaces'Img);
--                       end if;

                     this.myInterfaces(address).Send(tempMsg, sendStatus); --Pass the message on to another subnet
                     tempStatus := VN.NO_MSG_RECEIVED;

--                       VN.Text_IO.Put_Line("Protocol routing: Message rerouted to Destination " & tempMsg.Header.Destination'Img);

                     stop := false;
                  else
                     stop := true;
                  end if;
               else
                  stop := true;
               end if;

               if stop then
                  Status  := tempStatus;
                  Message := tempMsg;
               end if;
            else
               Status  := tempStatus;
            end if;

            this.nextProtocolInTurn := this.nextProtocolInTurn rem this.numberOfInterfaces;
            this.nextProtocolInTurn := this.nextProtocolInTurn + 1;
         end loop;
      else
         Status := VN.NO_MSG_RECEIVED;
      end if;
   end Receive;

   procedure Add_Interface(this : in out Protocol_Routing_Type;
                           theInterface : VN.Communication.Com_Access) is
      TOO_MANY_INTERFACES : exception;
   begin
      if this.numberOfInterfaces >= MAX_NUMBER_OF_SUBNETS then
         raise TOO_MANY_INTERFACES;
      end if;

      for i in Interface_Array'First .. Interface_Array'First + this.numberOfInterfaces - 1 loop
         if this.myInterfaces(i) = theInterface then
            return;
         end if;
      end loop;

      this.myInterfaces(Interface_Array'First + this.numberOfInterfaces) := theInterface;
      this.numberOfInterfaces := this.numberOfInterfaces + 1;
   end Add_Interface;

   procedure Init(this : in out Protocol_Routing_Type) is -- ToDo: For testing only!!!!!!!!!!
--      testCUUID : VN.VN_CUUID := (others => 42);
   begin
--        this.Initiated := true;
--        Protocol_Router.Insert(this.myTable, 1337, Protocol_Address_Type(1));
--        CUUID_Protocol_Routing.Insert(this.myCUUIDTable, testCUUID, Protocol_Address_Type(1));

--        GNAT.IO.Put_Line("Protocol_Routing initiated");
      null;
   end Init;

end VN.Communication.Protocol_Routing;
