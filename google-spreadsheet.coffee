
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
        @key = @url.match(/list\/(.*?)\//)[1]
    else
      @key = @sourceIdentifier
    @jsonUrl = "http://spreadsheets.google.com/feeds/list/" + @key + "/od6/public/basic?alt=json-in-script"

class GoogleSpreadsheet
  load: (callback) ->
    url = @jsonUrl + "&callback=GoogleSpreadsheet.callback"
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
    @jsonUrl = "http://spreadsheets.google.com/feeds/list/" + @key + "/od6/public/basic?alt=json-in-script"

  save: ->
    localStorage["GoogleSpreadsheet."+@type] = JSON.stringify(this)

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

GoogleSpreadsheet.callback = (data) ->
  result = []
  for row in data.feed.entry
    rowData = {}
    for cell in row.content.$t.split(", ")
      cell = cell.split(": ")
      rowData[cell[0]]=cell[1]
    result.push(rowData)
  googleUrl = new GoogleUrl(data.feed.id.$t)
  googleSpreadsheet = GoogleSpreadsheet.find({jsonUrl:googleUrl.jsonUrl})
  if googleSpreadsheet == null
    googleSpreadsheet = new GoogleSpreadsheet()
    googleSpreadsheet.googleUrl(googleUrl)
  googleSpreadsheet.data = result
  googleSpreadsheet.save()
  googleSpreadsheet
