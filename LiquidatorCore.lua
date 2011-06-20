-----------------------------------------------------------------------------------
-- Liquidator.lua
-----------------------------------------------------------------------------------
Liquidator = LibStub("AceAddon-3.0"):NewAddon("Liquidator", "AceConsole-3.0", "AceEvent-3.0")
LiquidatorFrame = {}

-----------------------------------------------------------------------------------
-- Set up some local variable
-----------------------------------------------------------------------------------
local total_value_of_bags = 0
local total_value_of_bank = 0
local VendorTotal = 0
local AuctionTotal = 0
local Auc_value_of_bags = 0
local Auc_value_of_bank = 0

_G["Liquidator"] = Liquidator
Liquidator.version = GetAddOnMetadata("Liquidator", "Version")

-----------------------------------------------------------------------------------
-- OnInitialize function
-- Added 17/05/2011 for Ace3 conversion
-----------------------------------------------------------------------------------
function Liquidator:OnInitialize()
	-- Code that you want to run when the addon is firt loaded goes here
	-- Set up some slash commands
	--self:RegisterChatCommand("lr", "ChatCommand")
	self:RegisterChatCommand("liquidator", "ChatCommand")
end

function Liquidator:ChatCommand(input)
	Liquidator:Print("Please use /lr to show options!")
end

-----------------------------------------------------------------------------------
-- OnEnable function
-- Added 17/05/2011 for Ace3 conversion
-----------------------------------------------------------------------------------
function Liquidator:OnEnable()
	LiquidatorFrame:Initialize()
	--self:Print("Liquidator is running")
	self:RegisterEvent("BANKFRAME_OPENED")
	self:RegisterEvent("BANKFRAME_CLOSED")
	self:RegisterEvent("BAG_UPDATE") 
	self:RegisterEvent("LOOT_CLOSED")	
	boolIsBankOpen = false;
	Liquidator:AddBags()
end

-----------------------------------------------------------------------------------
-- Initialize the new LUA only frame
-- 20 May for Ace3 conversion
-----------------------------------------------------------------------------------
function LiquidatorFrame:Initialize()
	Liquidator:Print("Initialized. Version: " .. Liquidator.version)
	Liquidator:LoadOptionsTables()
	-- okay, lets start to create the frame
	local frame = CreateFrame("Frame", nil, Minimap)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:IsResizable(true)
	frame:SetHeight(100)
	frame:SetWidth(275)
	frame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", -0, -30)
	
	frame:SetBackdrop({
      bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
      edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
      tile = true, tileSize = 16, edgeSize = 16,
      insets = {left = 5, right = 5, top = 5, bottom = 5}})
	frame:SetBackdropColor(.3, .3, .3, .3)
	frame:SetBackdropBorderColor(1, 1, 1, 1)

	LiquidatorFrame.frame = frame
	
	title = frame:CreateFontString()
	title:SetPoint('CENTER', frame, 'TOP', 0, -10)
	title:SetFontObject(GameFontNormal)
	title:SetText('Liquidator - ' .. Liquidator.version)
	LiquidatorFrame.title = title
	
	VendorBags = frame:CreateFontString()
	VendorBags:SetPoint('TOPLEFT', frame, 'TOPLEFT', 10, -20)
	VendorBags:SetFontObject(GameFontNormal)
	LiquidatorFrame.VendorBags = VendorBags
	
	VendorBagsSale = frame:CreateFontString()
	VendorBagsSale:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -10, -20)
	VendorBagsSale:SetFontObject(GameFontNormal)
	LiquidatorFrame.VendorBagsSale = VendorBagsSale
	
	VendorBank = frame:CreateFontString()
	VendorBank:SetPoint('TOPLEFT', frame, 'TOPLEFT', 10, -32)
	VendorBank:SetFontObject(GameFontNormal)
	LiquidatorFrame.VendorBank = VendorBank
	
	VendorBankSale = frame:CreateFontString()
	VendorBankSale:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -10, -32)
	VendorBankSale:SetFontObject(GameFontNormal)
	LiquidatorFrame.VendorBankSale = VendorBankSale

	VendorTxtTotal = frame:CreateFontString()
	VendorTxtTotal:SetPoint('TOPLEFT', frame, 'TOPLEFT', 10, -44)
	VendorTxtTotal:SetFontObject(GameFontNormal)
	LiquidatorFrame.VendorTxtTotal = VendorTxtTotal
	
	VendorTotal = frame:CreateFontString()
	VendorTotal:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -10, -44)
	VendorTotal:SetFontObject(GameFontNormal)
	LiquidatorFrame.VendorTotal = VendorTotal
	
	-- Auctioneer Values
	AuctionBags = frame:CreateFontString()
	AuctionBags:SetPoint('TOPLEFT', frame, 'TOPLEFT', 10, -56)
	AuctionBags:SetFontObject(GameFontNormal)
	LiquidatorFrame.AuctionBags = AuctionBags
	
	AuctionBagsSale = frame:CreateFontString()
	AuctionBagsSale:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -10, -56)
	AuctionBagsSale:SetFontObject(GameFontNormal)
	LiquidatorFrame.AuctionBagsSale = AuctionBagsSale
	
	AuctionBank = frame:CreateFontString()
	AuctionBank:SetPoint('TOPLEFT', frame, 'TOPLEFT', 10, -68)
	AuctionBank:SetFontObject(GameFontNormal)
	LiquidatorFrame.AuctionBank = AuctionBank
	
	AuctionBankSale = frame:CreateFontString()
	AuctionBankSale:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -10, -68)
	AuctionBankSale:SetFontObject(GameFontNormal)	
	LiquidatorFrame.AuctionBankSale = AuctionBankSale
	
	AuctionTxtTotal = frame:CreateFontString()
	AuctionTxtTotal:SetPoint('TOPLEFT', frame, 'TOPLEFT', 10, -80)
	AuctionTxtTotal:SetFontObject(GameFontNormal)	
	LiquidatorFrame.AuctionTxtTotal = AuctionTxtTotal
	
	AuctionTotal = frame:CreateFontString()
	AuctionTotal:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -10, -80)
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
			--Liquidator:SaveFramePosition()
		end
	end)
	
end

-----------------------------------------------------------------------------------
-- OnDisable function
-- Added 17/05/2011 for Ace3 conversion
-----------------------------------------------------------------------------------
function Liquidator:OnDisable()
end

-----------------------------------------------------------------------------------
-- OnLoad function
-----------------------------------------------------------------------------------
function Liquidator:OnLoad(frame)

end

-----------------------------------------------------------------------------------
-- PLAYER_ENTERING_WORLD event
-- Added 19/05/2011 for Ace3 conversion
-----------------------------------------------------------------------------------
function Liquidator:PLAYER_ENTERING_WORLD()
	-- This is where we'll try to create a frame using only lua code
	-- 22 May for Ace3 conversion
	--LiquidatorFrame:Initialize()
	
	self:RegisterEvent("BAG_UPDATE")
	--Liquidator:Print("DEBUG: woot, PLAYER_ENTERED_WORLD")
	Liquidator:AddBags()

end

-----------------------------------------------------------------------------------
-- BANKFRAME_OPENED event
-- Added 18/05/2011 for Ace3 conversion
-----------------------------------------------------------------------------------
function Liquidator:BANKFRAME_OPENED()
	--self:RegisterEvent("BANKFRAME_OPENED")
	--Liquidator:Print("Yahoo!, the bankframe is open")
		-- Code added 19/05 to calculate the value of the bank
		boolIsBankOpen = true;
		total_value_of_bank = 0
		Auc_value_of_bank = 0
		Liquidator:AddBank()
end

-----------------------------------------------------------------------------------
-- BANKFRAME_CLOSED event
-- Added 18/05/2011 for Ace3 conversion
-----------------------------------------------------------------------------------
function Liquidator:BANKFRAME_CLOSED()
	--self:RegisterEvent("BANKFRAME_CLOSED")
	--Liquidator:Print("Yahoo!, the bankframe is closed")
		-- Code added 19/05
		boolIsBankOpen = false;
		total_value_of_bank = 0
		Auc_value_of_bank = 0
		Liquidator:AddBank()
end

-----------------------------------------------------------------------------------
-- BAG_UPDATE event
-- Added 18/05/2011 for Ace3 conversion
-----------------------------------------------------------------------------------
function Liquidator:BAG_UPDATE()
	--self:RegisterEvent("BAG_UPDATE")
	--Liquidator:Print("Sweet, the bag_update code has run!")
		-- Player looted an item or moved stuff around in his bank or bag
		--Liquidator:Print("BAG_UPDATE")
		total_value_of_bags = 0
		Auc_value_of_bags = 0
				  
		Liquidator:AddBags()
		if boolIsBankOpen == true then
			Auc_value_of_bank = 0
			total_value_of_bank = 0
			Liquidator:AddBank()
		end
end

-----------------------------------------------------------------------------------
-- LOOT_CLOSED event
-- Added 18/05/2011 for Ace3 conversion
-----------------------------------------------------------------------------------
function Liquidator:LOOT_CLOSED()
	--self:RegisterEvent("LOOT_CLOSED")
	--Liquidator:Print("Yahoo!, the Loot frame is closed is open")
		-- Player looted an item or moved stuff around in his bank or bag
		total_value_of_bags = 0
		Auc_value_of_bags = 0
				  
		Liquidator:AddBags()
		if boolIsBankOpen == true then
			Auc_value_of_bank = 0
			total_value_of_bank = 0
			Liquidator:AddBank()
		end
end

-----------------------------------------------------------------------------------
-- This is defunct maybe used at some point in the future
-----------------------------------------------------------------------------------
function Liquidator:ReportValue()
	local msgformat = "%d seconds spent in combat with %d incoming damage. Average incoming DPS was %.2f"
	local msg = string.format(msgformat, total_time, total_damage, average_dps)
	if GetNumPartyMembers() > 0 then
		SendChatMessage(msg, "PARTY")
	else
		ChatFrame1:AddMessage(msg)
	end
end


-----------------------------------------------------------------------------------
-- This works out the bank value
-- Determine if the bank is open and calculate as required, otherwise make note.
-----------------------------------------------------------------------------------
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
         itemSellPrice = select(11, GetItemInfo(itemID))
		 if itemSellPrice == nil then
			itemSellPrice = 0
		 end
		 itemBagCount = select(2, GetContainerItemInfo(i, bagslotscounter))
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
	end
end

----------------------------------------------------------------------------------
-- If Actioneer is installed, calculate the value of items as per Appraiser value
----------------------------------------------------------------------------------
if AucAdvanced then

bagslots = GetContainerNumSlots(BANK_CONTAINER) --default bank
--Auc_value_of_bank = 0

for bagslotscounter = 1, bagslots do
	itemID = GetContainerItemID(BANK_CONTAINER, bagslotscounter)
	if (itemID == nil) then
		--print("DEBUG: itemID = nil")
	else
		--itemSellPrice = select(11, GetItemInfo(itemID))
		itemBagCount = select(2, GetContainerItemInfo(BANK_CONTAINER, bagslotscounter))
		itemSellPrice = AucAdvanced.GetModule("Util","Appraiser").GetPrice(itemID)
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
		 itemSellPrice = AucAdvanced.GetModule("Util","Appraiser").GetPrice(itemID)
		 if (itemSellPrice == nil) then
			itemSellPrice = 0
		end
		 Auc_value_of_bank = Auc_value_of_bank + (itemSellPrice * itemBagCount)
      end
   end
end
	
end

Liquidator:printCash()

-- end of Liquidator_AddBank() function
end


-----------------------------------------------------------------------------------
-- Add the value of all your bags
-----------------------------------------------------------------------------------
function Liquidator:AddBags()

local itemSellPrice = 0
local itemID = 0
local itemBagCount = 1
local itemStackCount = 1

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

if AucAdvanced then

Auc_value_of_bags = 0

for i = 0, 4 do
   bagslots = GetContainerNumSlots(i)
   for bagslotscounter = 1, bagslots do
      itemID = GetContainerItemID(i, bagslotscounter)
      if (itemID == nil) or (itemSellPrice == nil) then
         --print("DEBUG: itemID = nil")
      else
         --itemSellPrice = select(11, GetItemInfo(itemID))
		 itemBagCount = select(2, GetContainerItemInfo(i, bagslotscounter))
         itemSellPrice = AucAdvanced.GetModule("Util","Appraiser").GetPrice(itemID)
		if (itemSellPrice == nil) then
			itemSellPrice = 0
		end
		 Auc_value_of_bags = Auc_value_of_bags + (itemSellPrice * itemBagCount)
      end
   end
end

end

Liquidator:printCash()

end

function Liquidator:printCash()

	local VendorBags = "Vendor Bags:"
	local VendorBagsSale = GetCoinTextureString(total_value_of_bags)
	local VendorBank = "Vendor Bank:"
	if total_value_of_bank == 0 then 
		VendorBankSale = "Visit Bank"
	else
		VendorBankSale = 0
		VendorBankSale = GetCoinTextureString(total_value_of_bank) --<--
	end
	local VendorTxtTotal = "Total:"
	local VendorTotal = GetCoinTextureString(total_value_of_bags + total_value_of_bank)
	local AuctionBags = "Auction Bags:"
	local AuctionBagsSale = GetCoinTextureString(Auc_value_of_bags)
	local AuctionBank = "Auction Bank:"
	if Auc_value_of_bank == 0 then
		AuctionBankSale = "Visit Bank"
	else
		AuctionBankSale = 0
		AuctionBankSale = GetCoinTextureString(Auc_value_of_bank)  --<--
	end
	local AuctionTxtTotal = "Total:"
	local AuctionTotal = GetCoinTextureString(Auc_value_of_bags + Auc_value_of_bank)

	--Liquidator:Print(VendorBags .. " : " .. VendorBagsSale)
	
	LiquidatorFrame.VendorBags:SetText(VendorBags)
	LiquidatorFrame.VendorBagsSale:SetText(VendorBagsSale)
	LiquidatorFrame.VendorBank:SetText(VendorBank)
	LiquidatorFrame.VendorBankSale:SetText(VendorBankSale)
	LiquidatorFrame.VendorTxtTotal:SetTextColor(0.5, 1, 0.5)
	LiquidatorFrame.VendorTxtTotal:SetText(VendorTxtTotal)
	LiquidatorFrame.VendorTotal:SetTextColor(0.5, 1, 0.5)
	LiquidatorFrame.VendorTotal:SetText(VendorTotal)
	-- Auctioneer Values
	LiquidatorFrame.AuctionBags:SetTextColor(0.5, 0.5, 1)
	LiquidatorFrame.AuctionBags:SetText(AuctionBags)
	LiquidatorFrame.AuctionBagsSale:SetText(AuctionBagsSale)
	LiquidatorFrame.AuctionBank:SetTextColor(0.5, 0.5, 1)
	LiquidatorFrame.AuctionBank:SetText(AuctionBank)
	LiquidatorFrame.AuctionBankSale:SetText(AuctionBankSale)
	LiquidatorFrame.AuctionTxtTotal:SetTextColor(0.5, 1, 0.5)
	LiquidatorFrame.AuctionTxtTotal:SetText(AuctionTxtTotal)
	LiquidatorFrame.AuctionTotal:SetTextColor(0.5, 1, 0.5)
	LiquidatorFrame.AuctionTotal:SetText(AuctionTotal)

end
