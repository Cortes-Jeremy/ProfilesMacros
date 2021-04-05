--
--
--
--  Keyboard Layout Saver: Outfitter
--  by Fulgerul
--
--  This is a trigger module for Keyboard Layout Saver that changes profiles
--  when the user changes Outfitter sets
--
--
--


KLS_Outfitter = KLS:NewModule("KLS: Outfitter", "AceConsole-3.0", "AceEvent-3.0","AceTimer-3.0")

-- Wait for Outfitter to start
function KLS_Outfitter:OnEnable()
KLS:DebugMsg("KLS: Outfitter - OnEnable()")

Outfitter:RegisterOutfitEvent("OUTFITTER_INIT", KLS_Outfitter:RegisterOutfitEvents())

end

function KLS_Outfitter:RegisterOutfitEvents()
	DEFAULT_CHAT_FRAME:AddMessage("KLS: Outfitter ON")
	KLS:DebugMsg("KLS: Outfitter - RegisterOutfitEvents() - Registering events.")

	Outfitter:RegisterOutfitEvent("WEAR_OUTFIT", function (pOutfit) KLS_Outfitter:OnUpdate(pOutfit) end)
	Outfitter:RegisterOutfitEvent("DELETE_OUTFIT", function (_,pOutfit) KLS_Outfitter:OnDelete(pOutfit) end)
	Outfitter:RegisterOutfitEvent("ADD_OUTFIT", function (_,pOutfit) KLS_Outfitter:OnUpdate(pOutfitt) end)
    
    -- Init
    -- Do we have keybinds for this spec ?
	
	if Outfitter:GetCurrentOutfitInfo() ~= "" then
		 local specialization = "Outfitter - "..Outfitter:GetCurrentOutfitInfo()
	            
		 if (KLS:ExistsProfile(specialization) == nil)then
			KLS:DebugMsg("KLS: Outfitter: Enable_On_ADDON_LOADED() - No keybinds specified for spec "..specialization..". Saving keybinds...");
			 KLS:SaveProfil(specialization)
		 else
			 KLS:DebugMsg("KLS: Outfitter: Enable_On_ADDON_LOADED() -   "..specialization..". loading keybinds...");
			 KLS:LoadProfil(specialization)
		 end
	end

end

function KLS_Outfitter:OnUpdate(KLSoutfit)
KLS:DebugMsg("KLS: Outfitter - OnUpdate()")

    if not KLSoutfit then return end
    
    -- Do we have keybinds for this spec ?
    local specialization = ""
    
    if KLSoutfit == "WEAR_OUTFIT" or not KLSoutfit then
        specialization = "Outfitter - "..Outfitter:GetCurrentOutfitInfo()
    else
        specialization = "Outfitter - "..KLSoutfit
    end
           
    if (KLS:ExistsProfile(specialization) == nil)then
        KLS:DebugMsg("KLS: Outfitter: OnUpdate() - No keybinds specified for spec "..specialization..". Saving keybinds...");
        KLS:SaveProfil(specialization)
    else
        KLS:DebugMsg("KLS: Outfitter: OnUpdate() -   "..specialization..". loading keybinds...");
        KLS:LoadProfil(specialization)
    end
            
end

function KLS_Outfitter:OnDelete(KLSoutfit)
KLS:DebugMsg("KLS: Outfitter - OnDelete()")

    if not KLSoutfit then return end
    
    -- Do we have keybinds for this spec ?
    local specialization = "Outfitter - "..KLSoutfit
    KLS:DeleteProfil(specialization)
    KLS_Outfitter:OnUpdate()
end

-- Module disabled
function KLS_Outfitter:OnDisable()
KLS:DebugMsg("KLS: Outfitter - OnDisable()")
        
    if (Outfitter) then
        if not Outfitter:IsInitialized() then
            Outfitter:RegisterOutfitEvent('OUTFITTER_INIT', function () KLS_Outfitter:OnEnable() end)
        else
            KLS:DebugMsg("KLS: Outfitter - OnDisable() - Unregistering events.")
            Outfitter:UnregisterOutfitEvent('WEAR_OUTFIT')
            Outfitter:UnregisterOutfitEvent('DELETE_OUTFIT',"KLS_Outfitter:OnDelete")
            Outfitter:UnregisterOutfitEvent('ADD_OUTFIT')
            Outfitter:UnregisterOutfitEvent('OUTFITTER_INIT')
        end
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("KLS: Outfitter OFF")
end