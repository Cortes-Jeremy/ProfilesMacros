--
--
--
--  Keyboard Layout Saver: Talents
--  by Fulgerul
--
--  This is a trigger module for Keyboard Layout Saver that changes profiles
--  when the user changes specs
--
--
--


KLS_Talents = KLS:NewModule("KLS: Talents", "AceConsole-3.0", "AceEvent-3.0")

local specialization = 0
local KLS_player_talent_update_counter = 0

-- Module loaded
function KLS_Talents:OnEnable()
KLS:DebugMsg("KLS: Talents - OnEnable()")
    
    DEFAULT_CHAT_FRAME:AddMessage("KLS: Talents ON")
    
    KLS:DebugMsg("KLS: Talents - OnEnable() - Registering events.")
    
    -----------------------------------------------------
	-- Dont change profiles all the time when we enter worlds.	-
	-----------------------------------------------------
    KLS_Talents:RegisterEvent("PLAYER_ENTERING_WORLD")
    KLS_Talents:RegisterEvent("PLAYER_LEAVING_WORLD")
    
    KLS_Talents:RegisterEvent("PLAYER_TALENT_UPDATE")
end


-- Module disabled
function KLS_Talents:OnDisable()
KLS:DebugMsg("KLS: Talents - OnDisable()")
        
    DEFAULT_CHAT_FRAME:AddMessage("KLS: Talents OFF")
   
    KLS:DebugMsg("KLS: Talents - OnDisable() - Unregistering events.")
    KLS_Talents:UnregisterEvent("PLAYER_ENTERING_WORLD")
    KLS_Talents:UnregisterEvent("PLAYER_LEAVING_WORLD")
    KLS_Talents:UnregisterEvent("PLAYER_TALENT_UPDATE")
end


-----------------------------------------------------
-- Dont run change profiles when we enter/leave worlds.	-
-----------------------------------------------------
function KLS_Talents:PLAYER_ENTERING_WORLD()
	KLS:DebugMsg("PLAYER_ENTERING_WORLD(): Entered")
	
    KLS_player_talent_update_counter = 0
end

function KLS_Talents:PLAYER_LEAVING_WORLD()
	KLS:DebugMsg("PLAYER_LEAVING_WORLD(): Entered")
	
    KLS_player_talent_update_counter = 0
end

-- User changed specs
function KLS_Talents:PLAYER_TALENT_UPDATE(...)
KLS:DebugMsg("KLS: Talents - PLAYER_TALENT_UPDATE()")

	 -- PLAYER_TALENT_UPDATE event must not run after PLAYER_ENTERING_WORLD
    if KLS_player_talent_update_counter == 0 then
		KLS:DebugMsg("PLAYER_TALENT_UPDATE(): First time run, returning...")
		KLS_player_talent_update_counter = 1
		return
    end
    
    specialization = KLS_Talents:GetCurrentClass();
        
        if specialization == "NOT CHOSEN TALENTS" then
            KLS:DebugMsg("KLS: Talents - PLAYER_TALENT_UPDATE(): No talent spec. returning...")
            return
        end
    KLS:DebugMsg("KLS: Talents - PLAYER_TALENT_UPDATE(): specialization now <"..specialization..">")
   
   -- Do we have keybinds for this spec ?
        if (KLS:ExistsProfile(specialization) == nil)then
            KLS:DebugMsg("KLS: Talents - PLAYER_TALENT_UPDATE(): No keybinds specified for spec "..specialization..". Saving keybinds...");
            KLS:SaveProfil(specialization)
        else
            KLS:DebugMsg("KLS: Talents - PLAYER_TALENT_UPDATE(): "..specialization..". loading keybinds...");
            KLS:LoadProfil(specialization)
        end
end

-- Helper class, helps define the current spec
function KLS_Talents:GetCurrentClass()
KLS:DebugMsg("KLS: Talents - GetCurrentClass()")

    local tree = GetPrimaryTalentTree()
    local treename = tree and select(2, GetTalentTabInfo(tree))
    if treename then
      return treename
    else
      KLS:DebugMsg("KLS: Talents - GetCurrentClass(): No talents defined!")
    return "NOT CHOSEN TALENTS";
   end
end