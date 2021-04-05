--
--
--
-- Manual profiles
--  by Fulgerul
--
--  This is a trigger module for Profiles: * that reverts addon_object
--	to the old way of saving and loading profiles, through manual /commands
--	
-- Enabling this trigger will cause all other triggers to disable
-- Disabling the trigger does NOT actually disable as we want CMD line iface

----------- [ Config ] --------

-- Main addon object containing AceEvent
local addon_obj = MPS
-- Where do we find save,load and delete ?

local save_profile_ref 	= "PreSaveMacroProfile"
local load_profile_ref 	= "PreLoadMacroProfile"
local del_profile_ref 	= "PreDeleteProfile"
local export_profile_ref 	= "ExportCharProfile"

-- SLASH specific code
SLASH_MP1 = "/mp"
-------------------------------

local addon_obj_mod = addon_obj:NewModule("Manual Profiles", "AceConsole-3.0", "AceEvent-3.0")


-- Module loaded
-- Disable all other triggers
function addon_obj_mod:OnEnable()
-----------------------------
--
--	Change SlashCmdList!
--
-----------------------------

	SlashCmdList["MP"] = 
	function(msg)
	   local cmd, arg = string.split(" ", msg, 2)
	   cmd = string.lower(cmd or "")
	   arg = arg or ""
	   
		if (cmd == "version") then
			addon_obj:Echo("Profiles: Macros v"..MPS_Version)
		elseif (cmd=="list")then
			addon_obj:ListProfiles()
		elseif (cmd=="" or arg=="")then
			addon_obj:Echo(SLASH_MP1.." delete <name>")
			addon_obj:Echo(SLASH_MP1.." save <name>")
			addon_obj:Echo(SLASH_MP1.." load <name>")
			addon_obj:Echo(SLASH_MP1.." export")
			addon_obj:Echo(SLASH_MP1.." list")
			addon_obj:Echo(SLASH_MP1.." version * Not implemented yet")
			addon_obj:Echo(SLASH_MP1.." debug [on|off] * Not implemented yet")
		elseif (cmd=="save")then
			addon_obj[save_profile_ref](addon_obj, arg)
		elseif (cmd=="load" and arg~="")then
			addon_obj[load_profile_ref](addon_obj, arg)
		elseif (cmd=="delete" and arg~="")then
			addon_obj[del_profile_ref](addon_obj, arg) -- Thanks Adirelle :)
		elseif (cmd=="export")then
			addon_obj[export_profile_ref](addon_obj, arg)
		else    
			addon_obj:Echo("wrong entry")
	   end
	end
end