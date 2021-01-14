WebBanking{
  version = 1.0,
  url = 'https://tresor.one',
  services = {'Tresor.one'},
  description = 'Fetches portfolio from Tresor.one'
}

function SupportsBank (protocol, bankCode)
  return bankCode == 'Tresor.one' and protocol == ProtocolWebBanking
end

local connection
local portfolio

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  connection = Connection()
  portfolio = username
end

function ListAccounts (knownAccounts)
  local account = {
    name = 'Tresor.one',
    accountNumber = portfolio,
    portfolio = true,
    type = AccountTypePortfolio
  }

  return {account}
end

function RefreshAccount (account, since)
  local securities = {}

  response = connection:get('https://api.tresor.one/v1/portfolios/' .. portfolio)
  json = JSON(response):dictionary()

  local holdings = json['holdings']
  for index, values in pairs(holdings) do
    securities[#securities+1] = {
      name = values['security']['name'],
      isin = values['security']['isin'],
      securityNumber = values['security']['wkn'],
      currency = nil,
      quantity = values['position']['shares'],
      price = values['position']['currentPrice'],
      purchasePrice = values['position']['purchasePrice']
    }
  end

  return {securities=securities}
end

function EndSession ()
end
