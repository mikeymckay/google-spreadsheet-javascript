$(document).ready ->
  module "Basic Unit Test"
  test "Sample test", ->
    expect(1)
    equals(4/2,2)

  module "Google Spreadsheet"
  url = "https://spreadsheets.google.com/pub?key=0Ago31JQPZxZrdHF2bWNjcTJFLXJ6UUM5SldEakdEaXc&hl=en&output=html"

  QUnit.testStart = (name) ->
    console.log name

  test "Load from URL", ->
    expect(2)
    expectedKey = "0Ago31JQPZxZrdHF2bWNjcTJFLXJ6UUM5SldEakdEaXc"
    expectedJsonUrl = "http://spreadsheets.google.com/feeds/cells/" + expectedKey + "/od6/public/basic?alt=json-in-script"
    googleUrl = new GoogleUrl(url)
    equals(googleUrl.key, expectedKey)
    equals(googleUrl.jsonUrl, expectedJsonUrl)

  test "Save and find", ->
    googleSpreadsheet = new GoogleSpreadsheet()
    googleSpreadsheet.url(url)
    googleSpreadsheet.type = "test"
    googleSpreadsheet.save()
    result = GoogleSpreadsheet.find({url:url})
    equals(JSON.stringify(result),JSON.stringify(googleSpreadsheet))

#  Not working for some reason
#  test "Parsing", ->
#    expect(1)
#    # This is how to test callback functions - use stop() and start()
#    stop()
#    jQuery.getJSON "testsCallbackCellsData.json", (data) ->
#      result = GoogleSpreadsheet.callbackCells(data)
#      equals(result.data.length,10)
#      start()

  test "Load and parse", ->
    expect(1)
    localStorage.clear()
    googleSpreadsheet = new GoogleSpreadsheet()
    googleSpreadsheet.url(url)
    googleSpreadsheet.type = "test"
    googleSpreadsheet.save()
    stop()
    googleSpreadsheet.load (result) ->
      equals(result.data.length,10)
      start()

  test "Load and parse long and complex text cell", ->
    expect(1)
    localStorage.clear()
    googleSpreadsheet = new GoogleSpreadsheet()
    googleSpreadsheet.url("https://spreadsheets.google.com/pub?key=0Ago31JQPZxZrdGJSZTY2MHU4VlJ3RnNtdnNDVjRjLVE&hl=en&output=html")
    googleSpreadsheet.type = "test"
    googleSpreadsheet.save()
    stop()
    googleSpreadsheet.load (result) ->
      console.log result
      equals(result.data[0].match(/correctement/).length, 1)
      start()
