Set Library To foxjson.dll  ADDITIVE 
Set Procedure To foxjson ADDITIVE 
Clear 
Local oJson as foxJson
oJson=CreateObject("foxJson")
 
oJson.Parse('{"name":"lee","age":32, "childs":[{"name":"xiao ming","age":2},{"name":"baobao","age":5}]}')
?oJson.item("name").value 
?oJson.item("age").value 
?oJson.item("childs").count
?oJson.item("childs").item(1).item("name").value 
?oJson.item("childs").item(1).item("age").value 
?oJson.item("childs").item(2).item("name").value 
?oJson.item("childs").item(2).item("age").value 
Return 