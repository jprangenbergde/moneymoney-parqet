WebBanking{
  version = 1.0,
  url = 'https://parqet.com',
  services = {'Parqet'},
  description = 'Fetches portfolio from Parqet'
}

function SupportsBank (protocol, bankCode)
  return bankCode == 'Parqet' and protocol == ProtocolWebBanking
end

local connection
local portfolio

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  connection = Connection()
  portfolio = username
end

function ListAccounts (knownAccounts)
  local account = {
    name = 'Parqet',
    accountNumber = portfolio,
    portfolio = true,
    type = AccountTypePortfolio
  }

  return {account}
end

function RefreshAccount (account, since)
  local securities = {}

  local postData = '{"portfolioIds": "' .. portfolio .. '", "timeframe": "today"}'
  response = connection:request('POST', 'https://api.parqet.com/v1/portfolios/assemble', postData, 'application/json')
  json = JSON(response):dictionary()

  local holdings = json['holdings']
  for index, values in pairs(holdings) do
    if values['assetType'] == "Security" then
      securities[#securities+1] = {
        name = values['sharedAsset']['name'],
        isin = values['security'],
        securityNumber = values['security']['wkn'],
        currency = nil,
        quantity = values['position']['shares'],
        price = values['position']['currentPrice'],
        purchasePrice = values['position']['purchasePrice']
      }
     elseif values['assetType'] == "Crypto" then
      securities[#securities+1] = {
        name = values['sharedAsset']['name'],
        currency = nil,
        quantity = values['position']['shares'],
        price = values['position']['currentPrice'],
        purchasePrice = values['position']['purchasePrice']
      }
     elseif values['assetType'] == "Cash" then
      securities[#securities+1] = {
        name = values['nickname'],
        currency = nil,
        quantity = values['position']['shares'],
        price = values['position']['currentPrice'],
        purchasePrice = values['position']['purchasePrice']
      }
     else
      securities[#securities+1] = {}
     end
  end

  return {securities=securities}
end

function EndSession ()
end
