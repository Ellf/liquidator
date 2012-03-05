LQcurrentDBVersion = 0.11

Liquidator.AuctioneerAddons = {
  ["auc-advanced"] = { name = "Auc-Advanced", func = "GetAucAdv", check = "Auc-Advanced" },
  ["auctioneer"] = { name = "Auctioneer", func = "GetAuc4", check = "Auctioneer" },
  ["auctionator"] = { name = "Auctionator", func = "GetAuctionator", check = "Auctionator" },
  ["auctionlite"] = { name = "AuctionLite", func = "GetAuctionLite", check = "AuctionLite" },
  ["auctionmaster"] = { name = "AuctionMaster", func = "GetAuctionMaster", check = "AuctionMaster" },
};

-- declare defaults to be used in the DB
DATABASE_DEFAULTS = {
  profile =
  {
    frameWidth = 250,
    frameHeight = 100,
    frameLeft = 10,
    frameTop = 740,
  },
}

function Liquidator:CheckMasterDatabase()
  if (not Liquidator.db.global.dbversion) then
    Liquidator.db.global.dbversion = LQcurrentDBVersion
  elseif Liquidator.db.global.dbversion < LQcurrentDBVersion then
    StaticPopupDialogs["LQRESETDB"] = {
      text = "Liquidator, needs to wipe your database in order to upgrade to a new format structure. \nThis will also reload your UI.",
      button1 = "OK",
      OnAccept = function()
        Liquidator:resetMasterDatabases()
      end,
      timeout = 0,
      whileDead = 1,
      hideOnEscape = 1
    };
    StaticPopup_Show("LQRESETDB");
  end

  if not Liquidator.db.realm.guild then --Check To See If Guilds Master Index Is Present
    Liquidator.db.realm.guild = {};
  end
  if not Liquidator.db.realm.toon then --Check To See If Toons Master Index Is Present
    Liquidator.db.realm.toon = {};
  end
  if (not Liquidator.db.profile.selectedAuctionAddon) or (Liquidator.db.profile.selectedAuctionAddon == "") then --Checks To See If Selected Auction Addon Is Listed
    Liquidator:SetDefaultAuctionAPI();
  end
end

--Reset all data inside of the database
function Liquidator:resetMasterDatabases()
  Liquidator.db:ResetDB('Default')
  Liquidator.db:ResetProfile(DATABASE_DEFAULTS)
  if (not Liquidator.db.profile.selectedAuctionAddon) or (Liquidator.db.profile.selectedAuctionAddon == "") then --Checks To See If Selected Auction Addon Is Listed
    Liquidator:SetDefaultAuctionAPI();
  end
  ReloadUI()
end

--Loop though all of the Auction supported addons to see if there are loaded, 1st addon it finds, it will use that for the auction prices
function Liquidator:SetDefaultAuctionAPI()
  for index, value in pairs(Liquidator.AuctioneerAddons) do
    if IsAddOnLoaded(value.name) then
      Liquidator.db.profile.selectedAuctionAddon = value.name
      break
    end
  end
  --This will fix the Auction scaning code from erroring if it dont find anddon when on 1st run
  if (not Liquidator.db.profile.selectedAuctionAddon) or (Liquidator.db.profile.selectedAuctionAddon == "") then Liquidator.db.profile.selectedAuctionAddon = ""; end
end