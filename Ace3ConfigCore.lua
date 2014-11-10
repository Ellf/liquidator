selectedToonDelete = ""
LQOptionsGeneral =
{
	type = 'group',
	name = "Liquidator",
	cmdInline = false,
	args = 
	{
		generalheaderDes = 
		{
			order = 1,
			type = "description",
			name = "You can edit the setting below to adjust how the Liquidator frame looks.",
			cmdHidden = true,
		},
		headerDisplay = 
		{
			order = 2,
			type = "header",
			name = "Frame size and position",
			cmdHidden = true,
		},
		SizeDesc = 
		{
			order = 3,
			type = 'description',
			name = "The default width and height are (w:250, h:100)",

		},
		frameWidth = 
		{
			order = 4,
			type = 'range',
			min = 150,
			max = 500,
			step = 1,
			name = "Width:",
			desc = "The width of the frame.",
			set = function (_, v) 
				Liquidator.db.profile.frameWidth = v 
				LiquidatorFrame.frame:SetWidth(v) 
			end,
			get = function (info) return Liquidator.db.profile.frameWidth end,
		},
		frameHeight = 
		{
			order = 5,
			type = 'range',
			min = 80,
			max = 500,
			step = 1,
			name = "Height:",
			desc = "The height of the frame.",
			set = function (_, v)  
				Liquidator.db.profile.frameHeight = v 
				LiquidatorFrame.frame:SetHeight(v) 
			end,
			get = function (info) return Liquidator.db.profile.frameHeight end,
		},
		locationDesc = 
		{
			order = 6,
			type = 'description',
			name = "Default X = 10; default Y = 740 - from bottomleft of screen",

		},
		frameLeft = 
		{
			order = 7,
			type = 'input',
			name = "Location: X",
			desc = "The X coordinate of the Liquidator frame.",
			set = function (_, v) Liquidator.db.profile.frameLeft = v end,
			get = function (info) return Liquidator.db.profile.frameLeft end,
		},
		frameTop = 
		{
			order = 8,
			type = "input",
			name = "Location: Y",
			desc = "The Y coordinate of the Liquidator frame.",
			set = function (_, v) Liquidator.db.profile.frameTop = v end,
			get = function (info) return Liquidator.db.profile.frameTop end,
		},
		headerPriceOptions =
		{
		  order = 9,
		  type = "header",
		  name = "Auction Addon Settings",
		  cmdHidden = true,
		},
		auctionheaderDes = 
		{
			order = 10,
			type = "description",
			name = "Choose which auction pricing addon you wish to pull data from. If you change the addon type, you should reopen your bank to recalculate.",
			cmdHidden = true,
		},
		auctionselect =
		{
		  order = 11,
		  type = "select",
		  name = "Auction Addon List",
		  desc = "Select Auction Pricing Addon.",
		  values = function() 
			return Liquidator:listLoadedAuctions() 
			end,
		  disabled = function()
			_, noindex = Liquidator:listLoadedAuctions()
			return noindex
		  end,
		  get = function() return Liquidator.db.profile.selectedAuctionAddon end,
		  set = function(_, v) Liquidator.db.profile.selectedAuctionAddon = v
		  Liquidator:AddBags() --> printCash()
		  Liquidator:AddBank()
		  end,
		},
		bagExcludeHeader = 
		{
			order = 12,
			type = "header",
			name = "Exclusions",
			cmdHidden = true,
		},
		bagExcludeDesc = 
		{
			order = 13,
			type = "description",
			name = "Exclude or include which bags you wish to appear in Liquidator.",
			cmdHidden = true,
		},
		bagExcludeBags =
		{
			order = 14,
			type = "toggle",
			name = "Enable Bags",
			desc = "Toggle on or off showing your bags in Liquidator.",
			width = "full",
			get = function() return Liquidator.db.profile.ExcludeBags end,
			set = function(_, v) 
				Liquidator.db.profile.ExcludeBags = v 
				if Liquidator.db.profile.ExcludeBags then --TRUE
					--Liquidator.db.profile.frameHeight = Liquidator.db.profile.frameHeight + (lineCount * lineHeight)
					--LiquidatorFrame.frame:SetHeight(Liquidator.db.profile.frameHeight)
					--Liquidator:Print("1: lineCount: " .. lineCount .. ": lineHeight: " .. lineHeight .. " : frameHeight: " .. Liquidator.db.profile.frameHeight)
					lineCount = lineCount + 2
				else
					lineCount = lineCount - 2
					--Liquidator.db.profile.frameHeight = Liquidator.db.profile.frameHeight - (lineCount * lineHeight)
					--LiquidatorFrame.frame:SetHeight(Liquidator.db.profile.frameHeight)
					--Liquidator:Print("2: lineCount: " .. lineCount .. ": lineHeight: " .. lineHeight .. " : frameHeight: " .. Liquidator.db.profile.frameHeight)
				end
				Liquidator:printCash()
			end,
		},
		bagExcludeBank =
		{
			order = 15,
			type = "toggle",
			name = "Enable Bank",
			desc = "Toggle on or off showing your bank in Liquidator.",
			width = "full",
			get = function() return Liquidator.db.profile.ExcludeBank end,
			set = function(_, v) 
				Liquidator.db.profile.ExcludeBank = v
				Liquidator:printCash()
			end,
		},
		bagExcludeTotals =
		{
			order = 16,
			type = "toggle",
			name = "Enable Totals",
			desc = "Toggle on or off the total values (good to disable when not showing both bags and bank values)",
			width = "full",
			get = function() return Liquidator.db.profile.ExcludeTotals end,
			set = function(_, v)
				Liquidator.db.profile.ExcludeTotals = v
				Liquidator:printCash()
			end,
		},
	},
}

LQOptionsDatabase ={
	name = "Liquidator: Database",
	type = 'group',
	desc = "Settings to allow addon debugging",
	args = 
		{
			generalheader = 
			{
				order = 1,
				type = "header",
				name = "Database Settings",
				cmdHidden = true,
			},
			lqConfigVerbs = 
			{
				order = 2,
				type = "description",
				name = "Liquidator Version: "..GetAddOnMetadata("Liquidator", "Version").."\nLiquidator (Final) Database Version: " .. LQcurrentDBVersion .. "\nLiquidator Database Version: ",
				fontSize = "medium",
				cmdHidden = true,
			},
			resetDatabases =
			{
			  type = 'execute',
			  name = "Reset All Data",
			  desc = "This will clear all databases with in Liquidator. Use this if you are having database problems, or if you have old databases.",
			  order = 3,
			  func = function()
				Liquidator:resetMasterDatabases()
			  end,
			},
		},
}

function Liquidator:listLoadedAuctions()
  local table = {}
  local noIndex = true
  table["--None--"] = "--None--"
  for _, addon in pairs(Liquidator.AuctioneerAddons) do
    local _, isloaded = IsAddOnLoaded(addon.name);
    if (isloaded) then --Check To See If Addon InList Is Enabled
      table[addon.name] = addon.name
      noIndex = false
    end
  end
  return table, noIndex
end
		
function Liquidator:LoadOptionsTables()
	local AceConfig=LibStub("AceConfig-3.0")
	AceConfig:RegisterOptionsTable("Liquidator", LQOptionsGeneral, { "lr", "liquidator" })
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Liquidator Database", LQOptionsDatabase)
	
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Liquidator", "Liquidator")
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Liquidator Database", "Database","Liquidator")
	LibStub("LibAboutPanel").new("Liquidator", "Liquidator")
end