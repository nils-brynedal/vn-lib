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
--  Copyright 2014 Nils Brynedal Ignell (nils.brynedal@gmail.com)
------------------------------------------------------------------------------

with VN;
with VN.Communication;

with VN.Communication.Temp_Routing_Table;
with VN.Communication.Temp_CUUID_Routing;

package VN.Communication.Temp_Protocol_Routing is

   type Protocol_Routing_Type is
     new VN.Communication.Com with private;

   overriding procedure Send(this : in out Protocol_Routing_Type;
                             Message: in VN.Message.VN_Message_Basic;
                             Status: out VN.Send_Status);

   overriding procedure Receive(this : in out Protocol_Routing_Type;
                                Message : out VN.Message.VN_Message_Basic;
                                Status: out VN.Receive_Status);

   procedure Add_Interface(this : in out Protocol_Routing_Type;
                           theInterface : VN.Communication.Com_Access);

private

   procedure Init(this : in out Protocol_Routing_Type); -- ToDo: For testing only!!!

   --ToDo: These constants should be put in a config file of some sort
   PROTOCOL_ROUTING_TABLE_SIZE : constant VN.VN_Logical_Address := 500;
   MAX_NUMBER_OF_SUBNETS : constant Integer := 10;

   subtype Protocol_Address_Type is Integer range 0 .. MAX_NUMBER_OF_SUBNETS; --the value 0 means Application Layer
   type Interface_Array is array(1..MAX_NUMBER_OF_SUBNETS) of VN.Communication.Com_Access;

   package Protocol_Router is new VN.Communication.Temp_Routing_Table(Protocol_Address_Type);
   use Protocol_Router;

   package CUUID_Protocol_Routing  is new VN.Communication.Temp_CUUID_Routing(Protocol_Address_Type);
   use CUUID_Protocol_Routing;

   type Protocol_Routing_Type is
     new VN.Communication.Com with
      record
         myInterfaces       : Interface_Array;
         myTable 	    : Protocol_Router.Table_Type(PROTOCOL_ROUTING_TABLE_SIZE);
         nextProtocolInTurn : Protocol_Address_Type := Interface_Array'First;
         numberOfInterfaces : Natural := 0;

         Initiated : Boolean := false; -- ToDo: for testing only!!!
      end record;

end VN.Communication.Temp_Protocol_Routing;
