local MPS = LibStub("AceAddon-3.0"):GetAddon("Profiles: Macros")

----------------------------

local getOpt, setOpt
do
   function getOpt(info)
      local key = info[#info]
      local boolean_conversion = false
      
      -- Ugly hack because lua sees false and 0 different from perl
      if MPdb.char[key] == 0 then
         boolean_conversion = false
      elseif MPdb.char[key] == 1 then
         boolean_conversion = true
      else
         boolean_conversion = MPdb.char[key]
      end
      
      return boolean_conversion
   end
   
   function setOpt(info, value)
      local key = info[#info]
      local boolean_conversion = false
      
      -- Ugly hack because lua sees false and 0 different from perl
      if value == false then
         boolean_conversion = 0
      elseif value == true then
         boolean_conversion = 1
      else
         boolean_conversion = value
      end
      
      MPdb.char[key] = boolean_conversion
      return boolean_conversion
   end
end

local options, moduleOptions = nil, {}
local function getOptions()
   if not options then
      options = {
         type = "group",
         args = {
            general = {
               type = "group",
               inline = true,
               name = "",
               args = {
                  
				  -- ProfilesSynch = {
                     -- type = "toggle",
                     -- name = "Synchronize with the Profile: Addons series",
                     -- desc = "",
                     -- order = 101,
                     -- width = "full",
                     -- get = getOpt,
                     -- set = function (info,value) 
                        -- if KPSdb.char.KLSaddonEnabled == 0 then 
                           -- KPSdb.char.KLSaddonEnabled = 1
                           -- KPS:Enable()
                        -- else
                           -- KPSdb.char.KLSaddonEnabled = 0
                           -- KPS:Disable()
                        -- end
                     -- end,
                  -- },
				  
                  MPSLoadProfileAtStart = {
                     type = "toggle",
                     name = "Load profile at start",
                     desc = "",
                     order = 101,
                     width = "full",
                     get = getOpt,
                     set = function (info,value) 
                        local dbg = setOpt(info, value)
                     end,
                  },
				 
               },
			   },
         },
      }
      for k,v in pairs(moduleOptions) do
         options.args[k] = (type(v) == "function") and v() or v
      end
   end
   return options
end


function MPS:SetupOptions()
   self.optFrames = {}
   LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Profiles: Macros", getOptions)
   self.optFrames.MPS = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Profiles: Macros", "Profiles: Macros", nil, "general")
   --self:RegisterModuleOptions("Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db), "Profiles")
end

function MPS:RegisterModuleOptions(name, optTable, displayName)
   moduleOptions[name] = optTable
   self.optFrames[name] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Profiles: Macros", displayName or name, "Profiles: Macros", name)
end
