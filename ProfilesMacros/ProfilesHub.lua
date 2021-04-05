
----------- [ Config ] --------

-- Main addon object containing AceEvent
-- We assume you have OBJ:SAVE() and OBJ:LOAD!
local addon_object = MPS

-- When to run as slave.
local SLAVE_PRIO = 2
local SLAVE_NAME = "Macros"
-------------------------------


-- Globals

-- Contains the registered slaves
if not Profiles_global_que then
	Profiles_global_que = {}
end

-- Contains a copy of Profiles_global_que
-- This is later modified by master function
local Profiles_global_que_local = {}

-- Contains the current master and its commands
-- Get nilled out once master is done
if not Profiles_master_flag then
	Profiles_master_flag = {}
end
	
-- Register with the Global Profiles Que
if not Profiles_global_que[SLAVE_PRIO] then
	Profiles_global_que[SLAVE_PRIO] = SLAVE_NAME
else
	addon_object:Echo("ERROR: Register "..SLAVE_NAME..":" ..SLAVE_PRIO)
end

-- Wait for master to call my Slave_controller() (Register event SLAVE_NAME)
-- Look for this command at the bottom of this file

-- Broadcast if master, report action done if slave
function addon_object:SendAceMsg(...)
	
	-- action = "save"/profile_name = "test"
	local action,profile_name = ...
	
	-- No one has claimed master! Claim it!
	if Profiles_master_flag[name] == nil then
		
	
		Profiles_global_que_local = copyTable(Profiles_global_que)

		
		Profiles_master_flag = 
		{
			name = SLAVE_NAME,
			master_action = action,
			master_profile_name = profile_name,
		}
		
		addon_object:Master_controller()
	else
		return -- I am slave: Blocked outgoing messages
	end
end

function addon_object:Master_controller(...)
	
	
	--print("MASTER: "..SLAVE_NAME,Profiles_global_que_local[1],Profiles_global_que_local[2],Profiles_global_que_local[3],Profiles_master_flag.name,Profiles_master_flag.master_action,Profiles_master_flag.master_profile_name)
	
	-- Get ready for slaves, when slave is done he will call Master_controller() again
	addon_object:RegisterMessage("Profiles_Master_controller","Master_controller")
	
	-- Proccess slaves
	for prio,slave in orderedPairs(Profiles_global_que_local) do
			-- Mark slave as done
			Profiles_global_que_local[prio] = nil 
			
			-- Command slave to do masters action
			-- slave = "Macros"
			
			if slave then
				addon_object:SendMessage(slave)
				return
			end
	end
	
	-- All slaves are done
	addon_object:UnregisterMessage("Profiles_Master_controller")
	--addon_object:Echo(SLAVE_NAME.." master done!")
	Profiles_master_flag = 
	{
		name = nil,
		master_action = nil,
		master_profile_name = nil,
	}
end

function addon_object:Slave_controller(...)
	
	--print("SLAVE: "..SLAVE_NAME,Profiles_global_que_local[1],Profiles_global_que_local[2],Profiles_global_que_local[3],Profiles_master_flag.name,Profiles_master_flag.master_action,Profiles_master_flag.master_profile_name)
	if Profiles_master_flag.master_action == "save" then
		addon_object:Save(Profiles_master_flag.master_profile_name)
	end
	
	if Profiles_master_flag.master_action == "load" then
		addon_object:Load(Profiles_master_flag.master_profile_name)
	end
	
	if Profiles_master_flag.master_action == "delete" then
		addon_object:Delete(Profiles_master_flag.master_profile_name)
	end
	
	if Profiles_master_flag.master_action == "list" then
		addon_object:ListProfiles()
	end
	
	if Profiles_master_flag.master_action == "export" then
		addon_object:Export(Profiles_master_flag.master_profile_name)
	end
	
	-- Report back to master, done with actions
	addon_object:SendMessage("Profiles_Master_controller")
end

-- Wait for master to call my Slave_controller() (Register event SLAVE_NAME)
addon_object:RegisterMessage(SLAVE_NAME,"Slave_controller",SLAVE_NAME)