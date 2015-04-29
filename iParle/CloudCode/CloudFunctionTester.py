import json,httplib
connection = httplib.HTTPSConnection('api.parse.com', 443)
connection.connect()
connection.request('POST', '/1/functions/addUserToConvoByUsername', json.dumps({
       "username": "test1",
       "convoId": "wuxLc8VgGz"
     }), {
       "X-Parse-Application-Id": "n3twpTW37Eh9SkLFRWM41bjmw2IoYPdb2dh3OAQC",
       "X-Parse-REST-API-Key": "IoJbgCApWyrOwn4MyMEk6XIV5TLpxhqwHq7PsESw",
       "Content-Type": "application/json"
     })
result = json.loads(connection.getresponse().read())
print result