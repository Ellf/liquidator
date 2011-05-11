-----------------------------------------------------------------------------------
-- Set up some local variable to track time and values
-----------------------------------------------------------------------------------
local bag_value = 0
local bank_value = 0
local total_value_of_bags = 0
local total_value_of_bank = 0
local VendorTotal = 0
local AuctionTotal = 0
local Auc_value_of_bags = 0
local Auc_value_of_bank = 0

-----------------------------------------------------------------------------------
-- OnLoad function
-----------------------------------------------------------------------------------
function Liquidator_OnLoad(frame)
	frame:RegisterForClicks("RightButtonUp")
	frame:RegisterForDrag("LeftButton")
	frame:RegisterEvent("BANKFRAME_OPENED")
	frame:RegisterEvent("BANKFRAME_CLOSED")
	frame:RegisterEvent("BAG_UPDATE")
	frame:RegisterEvent("LOOT_CLOSED")
	Liquidator_AddBags()
end

-----------------------------------------------------------------------------------
-- Define the events needed for the addon
-----------------------------------------------------------------------------------
function Liquidator_OnEvent(frame, event, ...)
	if event == "BANKFRAME_OPENED" or event == "BANKFRAME_CLOSED" then
		--Player opened bank
		--print("DEBUG: bank frame opened")
		bank_value = 0
		total_value_of_bank = 0
		Auc_value_of_bank = 0
		Liquidator_AddBank()
	else
	if event == "LOOT_CLOSED" or event == "BAG_UPDATE" then
		bank_value = 0
		bag_value = 0
		total_value_of_bags = 0
		Auc_value_of_bags = 0
		-- Auc_value_of_bank = 0
		Liquidator_AddBags()
		Liquidator_AddBank()
	end
	end
end


-----------------------------------------------------------------------------------
-- This is defunct maybe used at some point in the future
-----------------------------------------------------------------------------------
function Liquidator_ReportValue()
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
function Liquidator_AddBank()

local itemSellPrice = 0
local itemID = 0
local itemBagCount = 1
local itemStackCount = 1

total_value_of_bank = 0

for i = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
   bagslots = GetContainerNumSlots(i)
   
   for bagslotscounter = 1, bagslots do
      itemID = GetContainerItemID(i, bagslotscounter)

      if (itemID == nil) then
         --print("DEBUG: itemID = nil")
      else
         itemSellPrice = select(11, GetItemInfo(itemID))
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
		itemStackCount = select(2, GetContainerItemInfo(BANK_CONTAINER, bagslotscounter))
		total_value_of_bank = total_value_of_bank + (itemSellPrice * itemStackCount)
	end
end

----------------------------------------------------------------------------------
-- If Actioneer is installed, calculate the value of items as per Appraiser value
----------------------------------------------------------------------------------
if AucAdvanced then

	bagslots = GetContainerNumSlots(BANK_CONTAINER) --default bank
	Auc_value_of_bank = 0
	for bagslotscounter = 1, bagslots do
		itemID = GetContainerItemID(BANK_CONTAINER, bagslotscounter)
		if (itemID == nil) then
			--print("DEBUG: itemID = nil")
		else
			--itemSellPrice = select(11, GetItemInfo(itemID))
			itemBagCount = select(2, GetContainerItemInfo(BANK_CONTAINER, bagslotscounter))
			itemSellPrice = AucAdvanced.GetModule("Util","Appraiser").GetPrice(itemID)
			Auc_value_of_bank = Auc_value_of_bank + (itemSellPrice * itemBagCount)
		end
	end

end

liquidator_printCash()

end


-----------------------------------------------------------------------------------
-- Add the value of all your bags
-----------------------------------------------------------------------------------
function Liquidator_AddBags()

local itemSellPrice = 0
local itemID = 0
local itemBagCount = 1
local itemStackCount = 1

total_value_of_bags = 0

for i = 0, NUM_BAG_SLOTS do
   bagslots = GetContainerNumSlots(i)
   for bagslotscounter = 1, bagslots do
      itemID = GetContainerItemID(i, bagslotscounter)

      if (itemID == nil) then
         --print("DEBUG: itemID = nil")
      else
         itemSellPrice = select(11, GetItemInfo(itemID))
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
      if (itemID == nil) then
         --print("DEBUG: itemID = nil")
      else
         --itemSellPrice = select(11, GetItemInfo(itemID))
		 itemBagCount = select(2, GetContainerItemInfo(i, bagslotscounter))
         itemSellPrice = AucAdvanced.GetModule("Util","Appraiser").GetPrice(itemID)
		 Auc_value_of_bags = Auc_value_of_bags + (itemSellPrice * itemBagCount)
      end
   end
end

end

liquidator_printCash()

end

function liquidator_printCash()

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

	-- Vendor Values
	LiquidatorFrameVendorBags:SetTextColor(0.5, 0.5, 1)
	LiquidatorFrameVendorBags:SetText(VendorBags)
	LiquidatorFrameVendorBagsSale:SetText(VendorBagsSale)
	LiquidatorFrameVendorBank:SetText(VendorBank)
	LiquidatorFrameVendorBankSale:SetText(VendorBankSale)
	LiquidatorFrameVendorTxtTotal:SetTextColor(0.5, 1, 0.5)
	LiquidatorFrameVendorTxtTotal:SetText(VendorTxtTotal)
	LiquidatorFrameVendorTotal:SetTextColor(0.5, 1, 0.5)
	LiquidatorFrameVendorTotal:SetText(VendorTotal)
	-- Auctioneer Values
	LiquidatorFrameAuctionBags:SetTextColor(0.5, 0.5, 1)
	LiquidatorFrameAuctionBags:SetText(AuctionBags)
	LiquidatorFrameAuctionBagsSale:SetText(AuctionBagsSale)
	LiquidatorFrameAuctionBank:SetText(AuctionBank)
	LiquidatorFrameAuctionBankSale:SetText(AuctionBankSale)
	LiquidatorFrameAuctionTxtTotal:SetTextColor(0.5, 1, 0.5)
	LiquidatorFrameAuctionTxtTotal:SetText(AuctionTxtTotal)
	LiquidatorFrameAuctionTotal:SetTextColor(0.5, 1, 0.5)
	LiquidatorFrameAuctionTotal:SetText(AuctionTotal)

end
