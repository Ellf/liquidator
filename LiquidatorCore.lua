-----------------------------------------------------------------------
-- LiquidatorCore.lua
-----------------------------------------------------------------------
Liquidator = LibStub("AceAddon-3.0"):NewAddon("Liquidator", "AceConsole-3.0", "AceEvent-3.0")
LiquidatorFrame = {} -- so this sets up a blank table for our functions
tblMainPanel = {} --construct an empty table

-----------------------------------------------------------------------
-- Set up some local variable
-----------------------------------------------------------------------
local total_value_of_bags = 0
local total_value_of_bank = 0
local VendorTotal = 0
local AuctionTotal = 0
local Auc_value_of_bags = 0
local Auc_value_of_bank = 0
local bagname = ""
lineHeight = 5
lineCount = 6

_G["Liquidator"] = Liquidator
Liquidator.version = GetAddOnMetadata("Liquidator", "Version")

-----------------------------------------------------------------------
-- OnInitialize function
-- Added 17/05/2011 for Ace3 conversion
-----------------------------------------------------------------------
function Liquidator:OnInitialize()
	Liquidator.db = LibStub("AceDB-3.0"):New("LiquidatorDB", DATABASE_DEFAULTS, 'Default')
	-- Code that you want to run when the addon is first loaded goes here
	--Call clsdatabase this checks the databased version, and to see if there is data in the database
	Liquidator:CheckMasterDatabase();
	-- Set up some slash commands
	self:RegisterChatCommand("lr", "ChatCommand")
	self:RegisterChatCommand("liquidator", "ChatCommand")
end

function Liquidator:ChatCommand(input)
	Liquidator:Print("Currently not active - please press ESC and choose Interface -> addons -> Liquidator.")
end

-----------------------------------------------------------------------
-- OnEnable function
-- Added 17/05/2011 for Ace3 conversion
-----------------------------------------------------------------------
function Liquidator:OnEnable()
	LiquidatorFrame:Initialize()
	--self:Print("Liquidator is running")
	--Load Options Table from Ace3ConfigCore
	Liquidator:LoadOptionsTables()
	self:RegisterEvent("BANKFRAME_OPENED")
	self:RegisterEvent("BANKFRAME_CLOSED")
	self:RegisterEvent("BAG_UPDATE") 
	self:RegisterEvent("LOOT_CLOSED")
	self:RegisterEvent("GUILDBANKFRAME_OPENED") --not tested
	self:RegisterEvent("GUILDBANKFRAME_CLOSED")
	boolIsBankOpen = false;
	Liquidator:AddBags()
end

-----------------------------------------------------------------------
-- Initialize the new LUA only frame
-- 20 May for Ace3 conversion
--
-- Here is the layout as of version 0.51
--					Liquidator - v0.xx (using xxxxxxx)	| x = -10
--			Vendor Bags:					GG SS CC	| x = -20
--			Vendor Bank:					GG SS CC	| x = -32
--			Total:							GG SS CC	| x = -44
--			Auction Bags:					GG SS CC	| x = -56
--			Auction Bank:					GG SS CC	| x = -68
--			Total:							GG SS CC	| x = -80
-----------------------------------------------------------------------
function LiquidatorFrame:Initialize()
	
	local tenX = 10
	local minustenX = -10
	
	-- This just prints to the default chat window that we are ready to go
	Liquidator:Print("Initialized. Version: " .. Liquidator.version)
	
	Liquidator:TableofStuffs() --load word table
	
	-- okay, lets start to create the main frame
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:EnableMouse(true) --self explanatory
	frame:SetMovable(true)  --and again
	frame:IsResizable(true) --not yet implemented
	frame:SetHeight(Liquidator.db.profile.frameHeight) --we set height based on the profile db value
	frame:SetWidth(Liquidator.db.profile.frameWidth)   --we set width based on the profile db value
	frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", Liquidator.db.profile.frameLeft, Liquidator.db.profile.frameTop) --create the frame anchored at profile db values frameLeft,frameTop
	
	frame:SetBackdrop({
      bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],    --look for a better background
      edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
      tile = true, tileSize = 16, edgeSize = 16,
      insets = {left = 5, right = 5, top = 5, bottom = 5}})
	frame:SetBackdropColor(.4, .4, .4, 1) --will be adding controls to change colours in future version
	frame:SetBackdropBorderColor(1, 1, 1, 1)

	LiquidatorFrame.frame = frame 
	
	title = frame:CreateFontString()
	title:SetPoint('CENTER', frame, 'TOP', tblMainPanel[2], tblMainPanel[3])
	title:SetFontObject(GameFontNormal)
	title:SetText(tblMainPanel[1])
	LiquidatorFrame.title = title
	
	VendorBags = frame:CreateFontString()
	VendorBags:SetPoint('TOPLEFT', frame, 'TOPLEFT', tblMainPanel[5], tblMainPanel[6])
	VendorBags:SetFontObject(GameFontNormal)
	LiquidatorFrame.VendorBags = VendorBags
	
	VendorBagsSale = frame:CreateFontString()
	VendorBagsSale:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', minustenX, -20)
	VendorBagsSale:SetFontObject(GameFontNormal)
	LiquidatorFrame.VendorBagsSale = VendorBagsSale
	
	VendorBank = frame:CreateFontString()
	VendorBank:SetPoint('TOPLEFT', frame, 'TOPLEFT', tenX, -32)
	VendorBank:SetFontObject(GameFontNormal)
	LiquidatorFrame.VendorBank = VendorBank
	
	VendorBankSale = frame:CreateFontString()
	VendorBankSale:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', minustenX, -32)
	VendorBankSale:SetFontObject(GameFontNormal)
	LiquidatorFrame.VendorBankSale = VendorBankSale

	VendorTxtTotal = frame:CreateFontString()
	VendorTxtTotal:SetPoint('TOPLEFT', frame, 'TOPLEFT', tenX, -44)
	VendorTxtTotal:SetFontObject(GameFontNormal)
	LiquidatorFrame.VendorTxtTotal = VendorTxtTotal
	
	VendorTotal = frame:CreateFontString()
	VendorTotal:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', minustenX, -44)
	VendorTotal:SetFontObject(GameFontNormal)
	LiquidatorFrame.VendorTotal = VendorTotal
	
	-- Auction Values
	AuctionBags = frame:CreateFontString()
	AuctionBags:SetPoint('TOPLEFT', frame, 'TOPLEFT', tenX, -56)
	AuctionBags:SetFontObject(GameFontNormal)
	LiquidatorFrame.AuctionBags = AuctionBags
	
	AuctionBagsSale = frame:CreateFontString()
	AuctionBagsSale:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', minustenX, -56)
	AuctionBagsSale:SetFontObject(GameFontNormal)
	LiquidatorFrame.AuctionBagsSale = AuctionBagsSale
	
	AuctionBank = frame:CreateFontString()
	AuctionBank:SetPoint('TOPLEFT', frame, 'TOPLEFT', tenX, -68)
	AuctionBank:SetFontObject(GameFontNormal)
	LiquidatorFrame.AuctionBank = AuctionBank
	
	AuctionBankSale = frame:CreateFontString()
	AuctionBankSale:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', minustenX, -68)
	AuctionBankSale:SetFontObject(GameFontNormal)	
	LiquidatorFrame.AuctionBankSale = AuctionBankSale
	
	AuctionTxtTotal = frame:CreateFontString()
	AuctionTxtTotal:SetPoint('TOPLEFT', frame, 'TOPLEFT', tenX, -80)
	AuctionTxtTotal:SetFontObject(GameFontNormal)	
	LiquidatorFrame.AuctionTxtTotal = AuctionTxtTotal
	
	AuctionTotal = frame:CreateFontString()
	AuctionTotal:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', minustenX, -80)
	AuctionTotal:SetFontObject(GameFontNormal)	
	LiquidatorFrame.AuctionTotal = AuctionTotal
	

	frame:SetScript("OnMouseDown", function(self, button)
		if ( button == "LeftButton" ) then
			self:StartMoving()
		end
		end)
		
	frame:SetScript("OnMouseUp",function(self, button)
		if ( button == "LeftButton" ) then
			self:StopMovingOrSizing()
			Liquidator:SaveFramePosition()
		end
	end)
	
end

-----------------------------------------------------------------------
-- OnDisable function
-- Added 17/05/2011 for Ace3 conversion
-----------------------------------------------------------------------
function Liquidator:OnDisable()
end

-----------------------------------------------------------------------
-- OnLoad function
-----------------------------------------------------------------------
function Liquidator:OnLoad(frame)

end

-----------------------------------------------------------------------
-- Guild bank functions
-----------------------------------------------------------------------
function Liquidator:GUILDBANKFRAME_OPENED()
end

function Liquidator:GUILDBANKFRAME_CLOSED()
end

-----------------------------------------------------------------------
-- PLAYER_ENTERING_WORLD event
-- Added 19/05/2011 for Ace3 conversion
-----------------------------------------------------------------------
function Liquidator:PLAYER_ENTERING_WORLD()
	-- This is where we'll try to create a frame using only lua code
	-- 22 May for Ace3 conversion
	--LiquidatorFrame:Initialize()
	
	self:RegisterEvent("BAG_UPDATE") --Fires many times (once for each slot in each container) during the login / UI load process. An addon which does extensive processing for this event should register it only after PLAYER_ENTERING_WORLD has fired if they are not interested in processing each event individually during the load process. *Shamelessly taken from clscore.lua (liquid wealth) as a reminder!!
	--Liquidator:Print("DEBUG: woot, PLAYER_ENTERED_WORLD")
	Liquidator:AddBags()

end

-----------------------------------------------------------------------
-- BANKFRAME_OPENED event
-- Added 18/05/2011 for Ace3 conversion
-----------------------------------------------------------------------
function Liquidator:BANKFRAME_OPENED()
	--self:RegisterEvent("BANKFRAME_OPENED")
	--Liquidator:Print("Yahoo!, the bankframe is open")
		-- Code added 19/05 to calculate the value of the bank
		boolIsBankOpen = true;
		total_value_of_bank = 0
		Auc_value_of_bank = 0
		Liquidator:AddBank()
		Liquidator:AddBags()
end

-----------------------------------------------------------------------
-- BANKFRAME_CLOSED event
-- Added 18/05/2011 for Ace3 conversion
-----------------------------------------------------------------------
function Liquidator:BANKFRAME_CLOSED()
	--self:RegisterEvent("BANKFRAME_CLOSED")
	--Liquidator:Print("Yahoo!, the bankframe is closed")
		-- Code added 19/05
		boolIsBankOpen = false;
		total_value_of_bank = 0
		Auc_value_of_bank = 0
		Liquidator:AddBank()
end

-----------------------------------------------------------------------
-- BAG_UPDATE event
-- Added 18/05/2011 for Ace3 conversion
-----------------------------------------------------------------------
function Liquidator:BAG_UPDATE()
	--self:RegisterEvent("BAG_UPDATE")
	--Liquidator:Print("Sweet, the bag_update code has run!")
		--Player looted an item or moved stuff around in his bank or bag
		--Liquidator:Print("BAG_UPDATE")
		total_value_of_bags = 0
		Auc_value_of_bags = 0
		Liquidator:AddBags()
		if boolIsBankOpen == true then --check to see if bankframe is open and if so...
			Auc_value_of_bank = 0
			total_value_of_bank = 0
			Liquidator:AddBank()
		end
end

-----------------------------------------------------------------------
-- LOOT_CLOSED event
-- Added 18/05/2011 for Ace3 conversion
-----------------------------------------------------------------------
function Liquidator:LOOT_CLOSED()
	--self:RegisterEvent("LOOT_CLOSED")
	--Liquidator:Print("Yahoo!, the Loot frame is closed")
		-- Player looted an item or moved stuff around in his bank or bag
		total_value_of_bags = 0
		Auc_value_of_bags = 0
				  
		Liquidator:AddBags()
		if boolIsBankOpen == true then --check to se if bankframe is open which can happen if you have Gobble. Time is money, friend.
			Auc_value_of_bank = 0
			total_value_of_bank = 0
			Liquidator:AddBank()
		end
end

-----------------------------------------------------------------------
-- This is defunct maybe used at some point in the future
-----------------------------------------------------------------------
function Liquidator:ReportValue()
	local msgformat = "%d seconds spent in combat with %d incoming damage. Average incoming DPS was %.2f"
	local msg = string.format(msgformat, total_time, total_damage, average_dps)
	if GetNumPartyMembers() > 0 then
		SendChatMessage(msg, "PARTY")
	else
		ChatFrame1:AddMessage(msg)
	end
end


-----------------------------------------------------------------------
--                    =============
-- This works out the == B A N K == value
--                    =============
-- Determine if the bank is open and calculate as required, otherwise make note.
-----------------------------------------------------------------------
function Liquidator:AddBank()

local itemSellPrice = 0
local itemID = 0
local itemBagCount = 1
local itemStackCount = 1

--total_value_of_bank = 0

for i = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
   bagslots = GetContainerNumSlots(i)
   
   for bagslotscounter = 1, bagslots do
      itemID = GetContainerItemID(i, bagslotscounter)

      if (itemID == nil) then
         --print("DEBUG: itemID = nil")
      else
         -- itemSellPrice = simply the sell vendor price
		 itemSellPrice = select(11, GetItemInfo(itemID))
		 if itemSellPrice == nil then
			itemSellPrice = 0
		 end
		 itemBagCount = select(2, GetContainerItemInfo(i, bagslotscounter)) -- this is the stack number
         total_value_of_bank = total_value_of_bank + (itemSellPrice * itemBagCount)
      end
   end
end

bagslots = GetContainerNumSlots(BANK_CONTAINER) --default bank (-1)
for bagslotscounter = 1, bagslots do
	itemID = GetContainerItemID(BANK_CONTAINER, bagslotscounter)
	
	if (itemID == nil) then
		--print("DEBUG: itemID = nil")
	else
		itemSellPrice = select(11, GetItemInfo(itemID))
		if (itemSellPrice == nil) then
			itemSellPrice = 0
		end
		itemStackCount = select(2, GetContainerItemInfo(BANK_CONTAINER, bagslotscounter))
		total_value_of_bank = total_value_of_bank + (itemSellPrice * itemStackCount)
		Liquidator.db.char.total_value_of_bank = total_value_of_bank
	end
end

-----------------------------------------------------------------------
-- If Auction addons are installed, calculate the value of items
-----------------------------------------------------------------------
bagslots = GetContainerNumSlots(BANK_CONTAINER) --default bank
--Auc_value_of_bank = 0

for bagslotscounter = 1, bagslots do
	itemID = GetContainerItemID(BANK_CONTAINER, bagslotscounter)
	if (itemID == nil) then
		--print("DEBUG: itemID = nil")
	else
		--itemSellPrice = select(11, GetItemInfo(itemID))
		itemBagCount = select(2, GetContainerItemInfo(BANK_CONTAINER, bagslotscounter))
		
		if Liquidator.db.profile.selectedAuctionAddon == "Auc-Advanced" then itemSellPrice = AucAdvanced.GetModule("Util","Appraiser").GetPrice(itemID)
		elseif Liquidator.db.profile.selectedAuctionAddon == "Auctionator" then itemSellPrice = Atr_GetAuctionBuyout(itemID)
		end
		
		if (itemSellPrice) == nil then
			itemSellPrice = 0
		end
		Auc_value_of_bank = Auc_value_of_bank + (itemSellPrice * itemBagCount)
	end
end

for i = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
   bagslots = GetContainerNumSlots(i)
   
   for bagslotscounter = 1, bagslots do
      itemID = GetContainerItemID(i, bagslotscounter)
      if (itemID == nil) then
         --print("DEBUG: itemID = nil")
      else
         itemBagCount = select(2, GetContainerItemInfo(i, bagslotscounter))
	  
		if Liquidator.db.profile.selectedAuctionAddon == "Auc-Advanced" then itemSellPrice = AucAdvanced.GetModule("Util","Appraiser").GetPrice(itemID)
		elseif Liquidator.db.profile.selectedAuctionAddon == "Auctionator" then itemSellPrice = Atr_GetAuctionBuyout(itemID)
		end
		
		if (itemSellPrice == nil) then
		--Liquidator:Print(Auc_value_of_bank .. " : " .. Liquidator.db.char.Auc_value_of_bank)
			itemSellPrice = 0
		end
		
		 Auc_value_of_bank = Auc_value_of_bank + (itemSellPrice * itemBagCount)
		 Liquidator.db.char.Auc_value_of_bank = Auc_value_of_bank
		 --Liquidator:Print(Auc_value_of_bank .. " : " .. Liquidator.db.char.Auc_value_of_bank)
      end
   end
end
	
Liquidator:printCash()

-- end of Liquidator_AddBank() function
end


-----------------------------------------------------------------------
--                    =============
-- This works out the ==  B A G  == value
--                    =============
-- Add the value of all your bags including auction addon values
-- Part One is the vendor value
-- Part Two is the auction value
-----------------------------------------------------------------------
function Liquidator:AddBags()

local itemSellPrice = 0
local itemID = 0
local itemBagCount = 1
local itemStackCount = 1


-- PART ONE vendor value --
total_value_of_bags = 0

for i = 0, NUM_BAG_SLOTS do
	bagslots = GetContainerNumSlots(i)
		for bagslotscounter = 1, bagslots do
		itemID = GetContainerItemID(i, bagslotscounter)

			if (itemID == nil)  or (itemSellPrice == nill) then
			--print("DEBUG: itemID = nil")
			else
			itemSellPrice = select(11, GetItemInfo(itemID))
			if (itemSellPrice == nil) then
			itemSellPrice = 0
			end
			itemBagCount = select(2, GetContainerItemInfo(i, bagslotscounter))
			total_value_of_bags = total_value_of_bags + (itemSellPrice * itemBagCount)
			end
		end
end

-- PART TWO auction value --
Auc_value_of_bags = 0

for i = 0, 4 do
   bagslots = GetContainerNumSlots(i)
   for bagslotscounter = 1, bagslots do
      itemID = GetContainerItemID(i, bagslotscounter)
      if (itemID == nil) or (itemSellPrice == nil) then
         -- ignore the nil value
      else
         --itemSellPrice = select(11, GetItemInfo(itemID))
		 itemBagCount = select(2, GetContainerItemInfo(i, bagslotscounter))
         if Liquidator.db.profile.selectedAuctionAddon == "Auc-Advanced" then itemSellPrice = AucAdvanced.GetModule("Util","Appraiser").GetPrice(itemID)
		elseif Liquidator.db.profile.selectedAuctionAddon == "Auctionator" then itemSellPrice = Atr_GetAuctionBuyout(itemID)
		end
		if (itemSellPrice == nil) then
			itemSellPrice = 0
		end
		 Auc_value_of_bags = Auc_value_of_bags + (itemSellPrice * itemBagCount)
		 Liquidator.db.char.Auc_value_of_bags = Auc_value_of_bags
      end
   end
end

--[[
for i = 1, NUM_BAG_SLOTS do
	local invID = ContainerIDToInventoryID(i)
	bagLink = GetInventoryItemLink("player", invID);
   --bagname = GetBagName(i)
   --if bagname == nil then 
	--bagname = "unknown" 
   --end
   Liquidator:Print("DEBUG: Bag " .. bagLink)
end
]]

Liquidator:printCash()

end


----------------------------------------------------------------------------------------
--
--  This is the function that prints the information to the screen
--  Returns: Nothing
--
----------------------------------------------------------------------------------------
function Liquidator:printCash()

	local title = tblMainPanel[1]  .. " |cffeda55f(Using: " .. Liquidator.db.profile.selectedAuctionAddon .. ")|r"
	
	local VendorBags = tblMainPanel[4]
	local VendorBagsSale = GetCoinTextureString(total_value_of_bags)
	local VendorBank = "Vendor Bank:"
	--Liquidator:Print("DEBUG: db.char.total_value_of_b    vbb ank : " .. Liquidator.db.char.total_value_of_bank)
	if (Liquidator.db.char.total_value_of_bank == 0) or Liquidator.db.char.total_value_of_bank == nil then 
		VendorBankSale = "Visit Bank"
		Liquidator.db.char.total_value_of_bank = 0
	else
		VendorBankSale = 0
		VendorBankSale = GetCoinTextureString(Liquidator.db.char.total_value_of_bank) --(total_value_of_bank) --<--
	end
	
	local VendorTxtTotal = "Total:"
	local VendorTotal = GetCoinTextureString(total_value_of_bags + Liquidator.db.char.total_value_of_bank)
	
	local AuctionBags = "Auction Bags:"
	local AuctionBagsSale = GetCoinTextureString(Liquidator.db.char.Auc_value_of_bags) --(Auc_value_of_bags) using db value
	local AuctionBank = "Auction Bank:"
	--Liquidator:Print("DEBUG: db.char.Auc_value_of_bank : " .. Liquidator.db.char.Auc_value_of_bank)
	if (Liquidator.db.char.Auc_value_of_bank == 0) or Liquidator.db.char.Auc_value_of_bank == nil then
		AuctionBankSale = "Visit Bank"
		--Liquidator:Print(Liquidator.db.char.Auc_value_of_bank)
		Liquidator.db.char.Auc_value_of_bank = 0
	else
		AuctionBankSale = 0
		AuctionBankSale = GetCoinTextureString(Liquidator.db.char.Auc_value_of_bank) --(Auc_value_of_bank)  --<--
	end
	
	
	local AuctionTxtTotal = "Total:"
	local AuctionTotal = GetCoinTextureString(Liquidator.db.char.Auc_value_of_bags + Liquidator.db.char.Auc_value_of_bank)

	--Liquidator:Print(VendorBags .. " : " .. VendorBagsSale)
	
	LiquidatorFrame.title:SetText(title)
	
	if Liquidator.db.profile.ExcludeBags then --option Enable Bags is enabled
		LiquidatorFrame.VendorBags:SetText(VendorBags)
		LiquidatorFrame.VendorBagsSale:SetText(VendorBagsSale)
		else
		LiquidatorFrame.VendorBags:SetText("")
		LiquidatorFrame.VendorBagsSale:SetText("")
		VendorTotal = GetCoinTextureString(Liquidator.db.char.total_value_of_bank)
		AuctionTotal = GetCoinTextureString(Liquidator.db.char.Auc_value_of_bank)
	end
	
	if Liquidator.db.profile.ExcludeBank then
		LiquidatorFrame.VendorBank:SetText(VendorBank)
		LiquidatorFrame.VendorBankSale:SetText(VendorBankSale)
		else
		LiquidatorFrame.VendorBank:SetText("")
		LiquidatorFrame.VendorBankSale:SetText("")
		VendorTotal = GetCoinTextureString(total_value_of_bags)
		AuctionTotal = GetCoinTextureString(Liquidator.db.char.Auc_value_of_bags)
	end
	
	if Liquidator.db.profile.ExcludeTotals then
		LiquidatorFrame.VendorTxtTotal:SetTextColor(0.5, 1, 0.5)
		LiquidatorFrame.VendorTxtTotal:SetText(VendorTxtTotal)
		LiquidatorFrame.VendorTotal:SetTextColor(0.5, 1, 0.5)
		LiquidatorFrame.VendorTotal:SetText(VendorTotal)
		else
		LiquidatorFrame.VendorTxtTotal:SetText("")
		LiquidatorFrame.VendorTotal:SetText("")
	end
	
	-- Auctioneer Values
	LiquidatorFrame.AuctionBags:SetTextColor(0.5, 0.5, 1)
	if Liquidator.db.profile.ExcludeBags then
		LiquidatorFrame.AuctionBags:SetText(AuctionBags)
		LiquidatorFrame.AuctionBagsSale:SetText(AuctionBagsSale)
		else
		LiquidatorFrame.AuctionBags:SetText("")
		LiquidatorFrame.AuctionBagsSale:SetText("")
	end
	if Liquidator.db.profile.ExcludeBank then
		LiquidatorFrame.AuctionBank:SetTextColor(0.5, 0.5, 1)
		LiquidatorFrame.AuctionBank:SetText(AuctionBank)
		LiquidatorFrame.AuctionBankSale:SetText(AuctionBankSale)
		else
		LiquidatorFrame.AuctionBank:SetText("")
		LiquidatorFrame.AuctionBankSale:SetText("")
	end

	if Liquidator.db.profile.ExcludeTotals then
		LiquidatorFrame.AuctionTxtTotal:SetTextColor(0.5, 1, 0.5)
		LiquidatorFrame.AuctionTxtTotal:SetText(AuctionTxtTotal)
		LiquidatorFrame.AuctionTotal:SetTextColor(0.5, 1, 0.5)
		LiquidatorFrame.AuctionTotal:SetText(AuctionTotal)
		else
		LiquidatorFrame.AuctionTxtTotal:SetText("")
		LiquidatorFrame.AuctionTotal:SetText("")
	end
end


----------------------------------------------------------------------------------------
--
--  This is the function that saves the frame position to the db after it's been moved
--  Also prints out a debug note (to be removed)
--  Returns: Nothing
--
----------------------------------------------------------------------------------------
function Liquidator:SaveFramePosition()
frameLeft = floor(LiquidatorFrame.frame:GetLeft() +0.5)
Liquidator.db.profile.frameLeft = floor(LiquidatorFrame.frame:GetLeft() +0.5)
frameTop = floor(LiquidatorFrame.frame:GetTop() + 0.5)
Liquidator.db.profile.frameTop = floor(LiquidatorFrame.frame:GetTop() + 0.5)

--Liquidator:Print("frameLeft: " .. frameLeft .. ": frameTop: " .. frameTop)

--Liquidator:Print(tblMainPanel[1])
end

---------------------------------------------------------------------------------------
--
--  Experimental function to use tables/arrays to store the text and values
--  Returns: No sure yet
--
---------------------------------------------------------------------------------------
--			Liquidator - v0.xx (using xxxxxxx)	| x = -10
--			Vendor Bags:					GG SS CC	| x = -20
--			Vendor Bank:					GG SS CC	| x = -32
--			Total:							GG SS CC	| x = -44
--			Auction Bags:					GG SS CC	| x = -56
--			Auction Bank:					GG SS CC	| x = -68
--			Total:							GG SS CC	| x = -80

function Liquidator:TableofStuffs()

	local tMP = tblMainPanel
	local tinsert = table.insert
	
	tinsert(tMP, "Liquidator - " .. Liquidator.version)   -- .. "|cffeda55f(Using: " .. Liquidator.db.profile.selectedAuctionAddon .. ")|r")
	tinsert(tMP, 0)
	tinsert(tMP, -10)
	tinsert(tMP, "Vendor Bags: ")
	tinsert(tMP, 10)
	tinsert(tMP, -20)
	--tinsert(tMP, "GG SS CC:", xloc, yloc)
	--tinsert(tMP, "Vendor Bank: ", xloc, yloc)
	--tinsert(tMP, "Total: ", xloc, yloc)

    tblWordstable = tMP

end