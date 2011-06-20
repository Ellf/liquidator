selectedToonDelete = ""
LWOptionsGeneral =
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
			frameWidth = 
			{
				type = 'range',
				min = 150,
				max = 500,
				name = "Width:",
				desc = "The width of the frame.",
				order = 3,
				
				--width = "",
			},
			frameHeight = 
			{
				type = 'range',
				min = 80,
				max = 500,
				name = "Height:",
				desc = "The height of the frame.",
				order = 4,
				--width = "full",
			},
			locationDesc = 
			{
				type = 'description',
				name = "These are the default location for launching Liquidator.",
				order = 5,
			},
			frameLeft = 
			{
				type = 'input',
				name = "Location: X",
				desc = "The X coordinate of the Liquidator frame.",
				order = 6,
				--width = "full",
			},
			frameTop = 
			{
				type = "input",
				name = "Location: Y",
				desc = "The Y coordinate of the Liquidator frame.",
				order = 7,
			},
			headerPriceOptions = 
			{
				order = 8,
				type = "header",
				name = "Other Shizzle",
				cmdHidden = true,
			},
		},
}

LWOptionsSkins ={
	name = "Liquid-Wealth: ToolTip Skinning",
	type = 'group',
	desc = "Options for Skinning The ToolTip",
	args = 
		{
			generalheader = 
			{
				order = 1,
				type = "header",
				name = "ToolTip Skinning Settings",
				cmdHidden = true,
			},
			TicTacSkinning = 
			{
				type = 'toggle',
				name = "Enable TicTac Skinning",
				desc = "Enables the skinning of the tooltip using TicTac for Skinning. Note: If you want to clear the skin you have to disable this, and then Reload UI",
				order = 2,
				disabled = function() return not (_G.TipTac and _G.TipTac.AddModifiedTip) end,

			},
		},
}

LWOptionsDatabase ={
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
			lwConfigVerbs = 
			{
				order = 2,
				type = "description",
				name = "Liquidator Version: "..GetAddOnMetadata("Liquidator", "Version").."\nLiquidator (Final) Database Version: \nLiquidator Database Version: ",
				fontSize = "medium",
				cmdHidden = true,
			},
			resetDatabases = 
			{
				type = 'execute',
				name = "Reset All Data",
				desc = "This will clear all databases with in Liquid-Wealth. Use this if you are having database problems, or if you have old databases.",
				order = 3,
				func = function()
					Liquidator:resetMasterDatabases()
				end,
			},
			removeCharFromDB = 
			{
				order = 4, type = "select",
				name = "Reset Selected Toon Data",
				desc = "Select Toon To Remove From Database.",
				set = function(_,v)
					local tableList={}
					for i,_ in pairs(Liquid_Wealth.db.realm.toon) do
						table.insert(tableList,i)
					end
					Liquidator:removeToonFromDB(tableList[v])
				end,
				values = function() 
					local tableList={}
					for i,_ in pairs(Liquid_Wealth.db.realm.toon) do
						local toonWIcon = Liquid_Wealth:BuildIcons(Liquid_Wealth.db.realm.toon[i].unitID).." ".."|c"..Liquid_Wealth:ClassColor(Liquid_Wealth.db.realm.toon[i].unitID)..i.."|r"
						table.insert(tableList,toonWIcon)
					end 
					return tableList 
				end,
			},
		},
}

CommandLineOptionsRTC = {
	name = "Remote Toon Config",
	type = "group",
	args = {
	confdesc = {
			order = 1,
			type = "description",
			name = "Please change your setting below",
			cmdHidden = true,
		},
    generalheader = {
		 order = 2,
		 type = "header",
		 name = "Vender & Auction Addon Settings",
		},
	nulloption = {
			order = 3,
			type = "description",
			name = " ",
			cmdHidden = true,
		},
    RanTest = {
			type = "execute",
			name = "Ran Test",
			order = 9,
			desc = "Ran Text.",
			func = function() 
            serializedData = Liquidator:Serialize("NPS")
            Liquidator:SendCommMessage("LMAC", serializedData , "WHISPER", "wildorebar") end,
		},
	}
}
		
function Liquidator:LoadOptionsTables()
	local AceConfig=LibStub("AceConfig-3.0")
	AceConfig:RegisterOptionsTable("Liquidator", LWOptionsGeneral, {"lr", "liquidator"})
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Liquidator Skin",LWOptionsSkins)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Liquidator Database",LWOptionsDatabase)
	
	
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Liquidator","Liquidator")
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Liquidator Skin", "ToolTip Skinning","Liquidator")
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Liquidator Database", "Database","Liquidator")
	--LibStub("LibAboutPanel").new("Liquidator", "Liquidator")
end