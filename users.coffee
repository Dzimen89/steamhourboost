jf = require 'jsonfile'
chalk = require 'chalk'
inquirer = require 'inquirer'
Steam = require 'steam'

POSSIBLE_GAMES = [
  {name: 'CS GO', value: '730', checked: true}
  {name: 'Dota 2', value: '570', checked: true}
  {name: 'Mount & Blade', value: '22100', checked: true}
  {name: 'Mount & Blade: Warband', value: '48700', checked: true}
  {name: 'Firefall', value: '227700', checked: true}
  {name: 'Dead Island', value: '91310', checked: true}
  {name: 'Enemy Front', value: '256190', checked: true}
  {name: 'EU IV', value: '236850', checked: true}
  {name: 'F.E.A.R 2 PO', value: '16450', checked: true}
  {name: 'F.E.A.R 3', value: '21100', checked: true}
  {name: 'Limbo', value: '48000', checked: true}
  {name: 'Lords Of The Fallen' value: '265300', checked: true}
  {name: 'Lucius', value: '218640', checked: true}
  {name: 'Medieval II TW', value: '4700', checked: true}
  {name: 'Rome: TW', value: '4760', checked: true}
  {name: 'Portal', value: '400', checked: true}
  {name: 'Portal 2', value: '620', checked: true}
  {name: 'Wiesiek 2', value: '20920', checked: true}
  {name: 'Tomb Raider', value: '203160', checked: true}
  {name: 'The Binding of Isaac', value: '113200', checked: true}
  {name: 'Garry's mod', value: '4000', checked: true}
  {name: 'Condemend: Crominal Origins', value: '4720', checked: true}
  {name: 'ORION: Prelude', value: '104900', checked: true}
  {name: 'Lichdom: Battlemage', value: '261760', checked: true}
  {name: 'Surgeon Simulator', value: '233720', checked: true}
  {name: 'Contagion', value: '238430', checked: true}
  {name: 'I am Bread', value: '327890', checked: true}
  {name: 'TheHunter: Primal', value: '322920', checked: true}
  {name: 'Nosferatu: The wrath of Malachi', value: '283290', checked: true}
  {name: 'Team Fortress 2', value: '440', checked: true}
]

account = null

class SteamAccount
  accountName: null
  password: null
  authCode: null
  shaSentryfile: null
  games: []

  constructor: (@accountName, @password, @games) ->
    @steamClient = new Steam.SteamClient
    @steamClient.on 'loggedOn', @onLogin
    @steamClient.on 'sentry', @onSentry
    @steamClient.on 'error', @onError

  testLogin: (authCode=null) =>
    @steamClient.logOn
      accountName: @accountName,
      password: @password,
      authCode: authCode,
      shaSentryfile: @shaSentryfile

  onSentry: (sentryHash) =>
    @shaSentryfile = sentryHash.toString('base64')

  onLogin: =>
    console.log(chalk.green.bold('✔ ') + chalk.white("Sucessfully logged into '#{@accountName}'"))
    setTimeout =>
      database.push {@accountName, @password, @games, @shaSentryfile}
      jf.writeFileSync('db.json', database)
      process.exit(0)
    , 1500

  onError: (e) =>
    if e.eresult == Steam.EResult.InvalidPassword
      console.log(chalk.bold.red("X ") + chalk.white("Logon failed for account '#{@accountName}' - invalid password"))
    else if e.eresult == Steam.EResult.AlreadyLoggedInElsewhere
      console.log(chalk.bold.red("X ") + chalk.white("Logon failed for account '#{@accountName}' - already logged in elsewhere"))
    else if e.eresult == Steam.EResult.AccountLogonDenied
      query = {type: 'input', name: 'steamguard', message: 'Please enter steamguard code: '}
      inquirer.prompt query, ({steamguard}) =>
        @testLogin(steamguard)

# Load database
try
  database = jf.readFileSync('db.json')
catch e
  database = []

query = [
  {type: 'input', name: 'u_name', message: 'Enter login name: '}
  {type: 'password', name: 'u_password', message: 'Enter password: '}
  {type: 'checkbox', name: 'u_games', message: 'Please select games to be boosted: ', choices: POSSIBLE_GAMES}
]

inquirer.prompt query, (answers) ->
  account = new SteamAccount(answers.u_name, answers.u_password, answers.u_games)
  account.testLogin()
