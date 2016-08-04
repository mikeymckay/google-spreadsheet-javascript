
###
Updated versions can be found at https://github.com/mikeymckay/google-spreadsheet-javascript
###



class GoogleUrl
  constructor: (@sourceIdentifier) ->
    if (@sourceIdentifier.match(/http(s)*:/))
      @url = @sourceIdentifier
      try
        @key = @url.match(/key=(.*?)&/)[1]
      catch error
        @key = @url.match(/(cells|list)\/(.*?)\//)[2]
    else
      @key = @sourceIdentifier
    @jsonCellsUrl = "https://spreadsheets.google.com/feeds/cells/" + @key + "/od6/public/basic?alt=json-in-script"
    @jsonListUrl = "https://spreadsheets.google.com/feeds/list/" + @key + "/od6/public/basic?alt=json-in-script"
    @jsonUrl = @jsonCellsUrl

class GoogleSpreadsheet
  load: (callback) ->
    
    url = @googleUrl.jsonCellsUrl + "&callback=GoogleSpreadsheet.callbackCells"
    $('body').append("<script src='" +url+ "'/>")
    jsonUrl = @jsonUrl
    safetyCounter = 0
    waitUntilLoaded = ->
      result = GoogleSpreadsheet.find({jsonUrl:jsonUrl})
      if safetyCounter++ > 20 or (result? and result.data?)
        clearInterval(intervalId)
        callback(result)
    intervalId = setInterval( waitUntilLoaded, 200)
    result if result?

  url: (url) ->
    this.googleUrl(new GoogleUrl(url))

  googleUrl: (googleUrl) ->
    throw "Invalid url, expecting object not string" if typeof(googleUrl) == "string"
    @url = googleUrl.url
    @key = googleUrl.key
    @jsonUrl = googleUrl.jsonUrl
    @googleUrl = googleUrl

  save: ->
    localStorage["GoogleSpreadsheet."+@key] = JSON.stringify(this)

GoogleSpreadsheet.bless = (object) ->
  result = new GoogleSpreadsheet()
  for key,value of object
    result[key]=value
  result

GoogleSpreadsheet.find = (params) ->
  try
    for item of localStorage
      if item.match(/^GoogleSpreadsheet\./)
        itemObject = JSON.parse(localStorage[item])
        for key,value of params
          if itemObject[key] == value
            return GoogleSpreadsheet.bless(itemObject)
# Need this to handle differences in localStorage between chrome and firefox TODO make dry
  catch error
    for item in localStorage
      if item.match(/^GoogleSpreadsheet\./)
        itemObject = JSON.parse(localStorage[item])
        for key,value of params
          if itemObject[key] == value
            return GoogleSpreadsheet.bless(itemObject)
  return null

GoogleSpreadsheet.callbackCells = (data) ->
  googleUrl = new GoogleUrl(data.feed.id.$t)
  googleSpreadsheet = GoogleSpreadsheet.find({jsonUrl:googleUrl.jsonUrl})
  if googleSpreadsheet == null
    googleSpreadsheet = new GoogleSpreadsheet()
    googleSpreadsheet.googleUrl(googleUrl)
  googleSpreadsheet.data = (cell.content.$t for cell in data.feed.entry)
  googleSpreadsheet.save()
  googleSpreadsheet


### TODO (Handle row based data)
GoogleSpreadsheet.callbackList = (data) ->
