--
--
--
--  Keyboard Layout Saver: Equipment manager
--  by Fulgerul
--
--  This is a trigger module for Keyboard Layout Saver that changes profiles
--  when the user changes Equipment manager sets
--
--
--


KLS_EQM = KLS:NewModule("KLS: Equipment manager", "AceConsole-3.0", "AceEvent-3.0","AceTimer-3.0")

-- Wait for Equipment manager to start
function KLS_EQM:OnEnable()
KLS:DebugMsg("KLS: Equipment manager - OnEnable()")

if not CanUseEquipmentSets() then
	print("EQM Disabled!")
else
	print("KLS: Equipment manager ON")
	KLS_EQM:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
end



end

function KLS_EQM:EQUIPMENT_SWAP_FINISHED(_,_,KLS_EQM_SET) 
KLS:DebugMsg("KLS: Equipment manager - EQUIPMENT_SWAP_FINISHED()")

     if (KLS:ExistsProfile(KLS_EQM_SET) == nil)then
         KLS:DebugMsg("KLS: Equipment manager: OnUpdate() - No keybinds specified for spec "..KLS_EQM_SET..". Saving keybinds...");
         KLS:SaveProfil(KLS_EQM_SET)
     else
         KLS:DebugMsg("KLS: Equipment manager: OnUpdate() -   "..KLS_EQM_SET..". loading keybinds...");
         KLS:LoadProfil(KLS_EQM_SET)
     end
end

-- Module disabled
function KLS_EQM:OnDisable()
KLS:DebugMsg("KLS: Equipment manager - OnDisable()")
        
    KLS_EQM:UnregisterEvent("EQUIPMENT_SWAP_FINISHED")  
    
    DEFAULT_CHAT_FRAME:AddMessage("KLS: Equipment manager OFF")
end

-- 
-- 
-- function KLS_EQM:OnDelete(KLSoutfit)
-- KLS:DebugMsg("KLS: Equipment manager - OnDelete()")
-- 
    -- if not KLSoutfit then return end
    -- 
    -- -- Do we have keybinds for this spec ?
    -- local specialization = "Equipment manager - "..KLSoutfit
    -- KLS:DeleteProfil(specialization)
    -- KLS_EQM:OnUpdate()
-- end
-- 
