-- TODO: Doing list commands in the channel you are in!
-- Macro Profiles
local MPS_Version = "2.4.1"
local WoWversion = 30300 --50200
MPS = LibStub("AceAddon-3.0"):NewAddon("Profiles: Macros", "AceConsole-3.0", "AceEvent-3.0","AceTimer-3.0")

local MAX_ACCOUNT_MACROS, MAX_CHARACTER_MACROS = 36, 18

--Char specific macros
minMacros = 1
charMacros = MAX_ACCOUNT_MACROS + 1
maxMacros = MAX_ACCOUNT_MACROS+MAX_CHARACTER_MACROS


function MPS:OnInitialize()
   MPdb = LibStub("AceDB-3.0"):New("ProfilesMacros",nil,"Default")
   MPglobaldb = LibStub("AceDB-3.0"):New("ProfilesMacrosG",nil,"Default")
	MPS:SetupOptions()

	if MPdb.char.MPSLoadProfileAtStart == 1 then
		MPS:RegisterEvent("PVP_REWARDS_UPDATE")
	end
end

function MPS:PVP_REWARDS_UPDATE(event, addonname)
	-- When logging on for the first time
	-- Load active profile after


	-- Correct WoW version!
	if select(4, GetBuildInfo()) == WoWversion then

		MPS:UnregisterEvent("PVP_REWARDS_UPDATE")

		-- Save a restore point if empty db
		if not MPS:ExistsProfile("Restore [LOCKED]") and not MPSSAVERESTORE then
			MPSSAVERESTORE=1
			MPS:SaveMacroProfile("Restore [LOCKED]")
			MPSSAVERESTORE=nil
		end

		if MPdb.char.Active_profile and MPdb.char.Active_profile ~= "Restore [LOCKED]" then
			MPS:LoadMacroProfile(MPdb.char.Active_profile)
		end
	end

	-- Different WoW version!
	if select(4, GetBuildInfo()) ~= WoWversion then
		MPS:UnregisterEvent("PVP_REWARDS_UPDATE")
		MPS:Echo("This addon is not compatible with this version of WoW. Please update it from curse.com")
	end
end

-- ProfilesHub: Send message to all slaves that we are now exporting profile
function MPS:PreExport(name)
	MPS:SendAceMsg("export",name) -- ProfilesHub
end

-- This is an alias for ProfilesHub
function MPS:Export(...)
	MPS:ExportCharProfile(...)
end

-- Export char profile to global
function MPS:ExportCharProfile(name)
	if MPS:ExistsProfile(name) then
		local orig_profile = MPdb:GetCurrentProfile()

		MPglobaldb:SetProfile("General: "..name)
		MPdb:SetProfile(name)

		-- MPglobaldb.profile = MPdb.profile
		for index, value in orderedPairs(MPdb.profile) do
		  MPglobaldb.profile[index] = value
		end

		MPdb:SetProfile(orig_profile)

		return 1
	else
		MPS:Echo("No such profile exists: "..name)
		return nil
	end
end


-- TODO: Hook onto macrowindow to "lock" a macro
-- TODO: Hook onto macrowindow to select macros from a dropdown...ir if i should automate everything by spec.

function MPS:Echo(text)
	if PROFILES_TYST then return nil end
   DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000Profiles: Macros - "..text)
   return 1
end

-- ProfilesHub: Send message to all slaves that we are now saving profile
function MPS:PreSaveMacroProfile(name)
	MPS:SendAceMsg("save",name) -- ProfilesHub
end

-- This function should NOT BE CALLED DIRECTLY.
-- Should only be called by slave event!

function MPS:SaveMacroProfile(name)

	-- Global DB Code
	local DB = {}
    if string.find(name,"General:") then
		DB = MPglobaldb
	else
		DB = MPdb
	end

	-- Save a restore point if empty db
	if not MPS:ExistsProfile("Restore [LOCKED]") and not MPSSAVERESTORE then
		MPSSAVERESTORE=1
		MPS:SaveMacroProfile("Restore [LOCKED]")
		MPSSAVERESTORE=nil
	end

	-- User trying to overwrite restore point!
	if name == "Restore [LOCKED]" and not MPSSAVERESTORE then
		MPS:Echo("This profile is locked at the first run and can only be loaded!")
		return nil
	end

	-- No macros!
	local numperglobal,numperchar = GetNumMacros()
	if numperchar == 0 and numperglobal == 0 then
		MPS:Echo("Nothing to save!")
		return nil
	end

	-- Duplicate macro name!
	-- Since we are using the name to identify where its actionBar_pos is, WARN user

	DB:SetProfile(name)

	-- Solving /mp save tank X 2
	if MPS:ExistsProfile(name) then DB:ResetProfile(name) end

	MPS:Echo("Saving macros to profile "..name.."!")



	-- Save macros
	for i=minMacros,maxMacros do

		-- No more macros saved
		if GetMacroInfo(i) then
			local macro_name, texture, body = GetMacroInfo(i)
			local actionBar_pos = {};

			-- Get icon ID instead of path (needed for CreateMacro() in Load!
			texture = MPS:findIcon(texture)

			-- Icon not found, give question mark!
			if (type(texture) ~= "number") then
				texture = '1'
			end

			-- Save actionbar position
			for actionID=1, 120 do
				local _, id = GetActionInfo(actionID)
				local abmacro_name, _, _ = GetMacroInfo(id)

				if i == id then
					table.insert(actionBar_pos , actionID)
				end
			end

			-- Save the GLOBAL macro to db
			DB.profile[i] = { macro_name,'3.3.5',body,actionBar_pos,1,i,texture}
		end
	end

	MPS:SendMessage("MPS_Profiles_save",name) -- ProfilesHub
	return name
end

-- This is an alias for ProfilesHub
function MPS:Save(...)
	MPS:SaveMacroProfile(...)
end


-- ProfilesHub: Send message to all slaves that we are now loading profile
function MPS:PreLoadMacroProfile(name)
	MPS:SendAceMsg("load",name) -- ProfilesHub
end

-- This function should NOT BE CALLED DIRECTLY.
-- Should only be called by slave event!

function MPS:LoadMacroProfile(name)


	-- Global DB Code
	local DB = {}
    if string.find(name,"General:") then
		DB = MPglobaldb
	else
		DB = MPdb
	end

	-- Save a restore point if empty db
	if not MPS:ExistsProfile("Restore [LOCKED]") and not MPSSAVERESTORE then
		MPSSAVERESTORE=1
		MPS:SaveMacroProfile("Restore [LOCKED]")
		MPSSAVERESTORE=nil
	end

	-- No such profile saved
	if not MPS:ExistsProfile(name) then MPS:Echo(name.." profile not found.") return nil end

	-- In combat!
	if InCombatLockdown() then MPS:Echo("Cannot change macros in combat!") return nil end

   DB:SetProfile(name)
   MPdb.char.Active_profile = name

   MPS:Echo("Loading macros from profile "..name.."!")

	--Get rid of all the current macros
	for i=minMacros,MAX_ACCOUNT_MACROS do DeleteMacro(1)  end -- Global
	for i=charMacros,maxMacros do DeleteMacro(37) end -- Char

   --Load saved macros profile
	for index, keys in pairs(DB.profile) do
		if DB.profile[index] then

			-- Icon not found, give question mark!
			if not MPS:findIcon(keys[7]) then
				DB.profile[index][7] = '1'
				keys[7] = '1'
			end

			-- BUG: When we have these words in our macro, icon of the mod will not update!
			-- icon = 1
			if string.find(keys[3],"mod:") 			then keys[7] = '1' end
			if string.find(keys[3],"modifier") 		then keys[7] = '1' end
			if string.find(keys[3],"#showtooltip") 	then keys[7] = '1' end

			if index >= charMacros then -- CreateMacro must know if its a global or char macro
				CreateMacro(keys[1], keys[7], keys[3], 1);
			else
				CreateMacro(keys[1], keys[7], keys[3], nil);
			end

		end
	end

	-- When having multiple name_duplicates the ID is changed..update the IDS
	for savedMacro, keys in pairs(DB.profile) do
		-- Find the loaded macro with body as ID!
		for loadedMacro=1,54 do
			if select(3,GetMacroInfo(loadedMacro)) then
				if keys[3] == select(3,GetMacroInfo(loadedMacro)) and keys[1] == select(1,GetMacroInfo(loadedMacro))  then -- if saved_body == loaded_body and saved_name == loaded_ame
				-- Update its macroID in the database

					if DB.profile[savedMacro][6] ~= loadedMacro then
						DB.profile[savedMacro][6] = loadedMacro
					end
				end
			end
		end
	end



   -- Action bar handling
   for index, keys in pairs(DB.profile) do
       if DB.profile[index] and keys[4] then
			for _,v in pairs(keys[4]) do
				ClearCursor()

				-- Clear current spot
				PickupAction(v)
				ClearCursor()

				-- Restore this spot
				PickupMacro(keys[6])
				PlaceAction(v)
				ClearCursor()
			end

       end
   end

	if (IsAddOnLoaded("Blizzard_MacroUI")) then
		MacroFrame_Update() -- Blizzards own code
	end

	MPS:SendMessage("MPS_Profiles_load",name) -- ProfilesHub
	return name
end

-- This is an alias for ProfilesHub
function MPS:Load(...)
	MPS:LoadMacroProfile(...)
end

function MPS:ExistsProfile(name)
	-- Global DB Code
	local DB = {}
    if string.find(name,"General:") then
		DB = MPglobaldb
	else
		DB = MPdb
	end

    for i, key in ipairs(DB:GetProfiles()) do
      if key == name then
         return (key)
      end
    end

    return nil
end

function MPS:ListProfiles(silent, globaldb)


	-- Global DB Code
	local DB = {}
    if globaldb then 	DB = MPglobaldb
	else 				DB = MPdb 			end

	local MP_profiles = {}

	for i,k in ipairs(DB:GetProfiles()) do
		if not silent then
			MPS:Echo(" Available Profiles: ")
			MPS:Echo(' - ' .. k)
		end

		MP_profiles[k] = 0
	end


	return MP_profiles
end

-- ProfilesHub: Send message to all slaves that we are now deleting a profile
function MPS:PreDeleteProfile(name)
	MPS:SendAceMsg("delete",name)
end

function MPS:DeleteProfil(name)

	-- Global DB Code
	local DB = {}
    if string.find(name,"General:") then
		DB = MPglobaldb
	else
		DB = MPdb
	end

	if name == "Restore [LOCKED]" and not MPSSAVERESTORE then
		MPS:Echo("This profile cannot be deleted! It is locked at the first run and can only be loaded!")
		return nil
	end

	if (MPS:ExistsProfile(name)==nil)then
		MPS:Echo(name.." doesnt exist.")
		MPS:ListProfiles()

		return nil
	else
		if name == DB:GetCurrentProfile() then
			DB:SetProfile('Default')
		end
		DB:DeleteProfile(name)
		MPS:Echo(name.." deleted.")

		return name
	end
end

-- This is an alias for ProfilesHub
function MPS:Delete(...)
	MPS:DeleteProfil(...)
end

-- Get iconID from iconCache
-- input 1 -> return interface\icons\inv_misc_questionmark
-- input "interface\\icons\\inv_misc_questionmark"
local icons_table = {}
function MPS:findIcon(iconID)

   local numIcons = GetNumMacroIcons()
   for i=1,numIcons do
      local lowercase_icons = string.lower(GetMacroIconInfo(i)) -- Normalize icon path from the API
      icons_table[lowercase_icons] = i
   end


   -- String, iterate the cache and return the number of the icon
   if type(iconID) == "string" then
      iconID = string.lower(iconID)

      if icons_table[iconID] then
         return icons_table[iconID]
      else
         return 1
      end
   end

   if type(iconID) == "number" then
      for iconName,icon_value in pairs(icons_table) do
         if iconID == icon_value then

            return iconName
         end
      end
   end

   return 1
end