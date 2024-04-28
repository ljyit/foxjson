*test 
Set Library To foxjson.dll 
TEXT TO cJson NOSHOW TEXTMERGE PRETEXT 15
{
	"name":"lee"
	,"age":32
	,"childs":[
		{"name":"aaa","age":1}
		,{"name":"mm","age":3}
	]
	,"array":[
		[1,2,3]
		,[4,5,6]
	]
}	
ENDTEXT
oJson=JsonToObject(cJson )
?oJson.name
?oJson.age
?oJson.childs(1).name
?oJson.array(2).item(2)  &&vfp不支持数组中的数组写法，所以要使用item
*-------------------------------------------------------------------------------
*函 数 名：JsonToObject
*功　　能：将JSON转换为VFP对像，其中JSON数组转换为VFP的集合
*参　　数：JSON字符串
*返 回 值：object
*作　　者：木瓜
*更新日期：2018-10-16
*备　　注：json的键允许空格数字等，转换成功的前提是JSON键能符合VFP变量命名规则
*-------------------------------------------------------------------------------
Procedure JsonToObject(cJson)
	If Vartype(cJson)<>"C"
		Error(11)
	EndIf 
	
	Local jsonObj,vRetValue
	jsonObj=json_Parse(cJson)
	If not InList(json_Type(jsonObj),4,5)
		vRetValue=json_value(jsonObj)
	Else
		vRetValue=JsonToObject_Value(jsonObj)
	EndIf 
	
	json_Delete(jsonObj)
	Return vRetValue
EndProc 
Procedure JsonToObject_Value(jsonObj)
	Local nType,vRet,nCount ,x
	nType=json_Type(jsonObj)
	DO CASE
	Case nType=4
	*object
		vRet=CreateObject("empty")
		nCount=json_Childs(jsonObj)
		For x=1 to nCount
			If InList(json_Type(jsonObj,x),4,5)
				AddProperty(vRet,json_Key(jsonObj,x), JsonToObject_Value(json_Value(jsonObj,x)))
			Else
				AddProperty(vRet,json_Key(jsonObj,x), json_Value(jsonObj,x))
			EndIf 
		EndFor 
	Case nType=5
	*Array
		vRet=CreateObject("Collection")
		nCount=json_Childs(jsonObj)
		For x=1 to nCount
			If InList(json_Type(jsonObj,x),4,5)
				vRet.Add(JsonToObject_Value(json_Value(jsonObj,x)))
			Else
				vRet.Add(json_Value(jsonObj,x))
			EndIf 
		EndFor 
	Otherwise
	*basic value
		vRet=json_value(jsonObj)
	EndCase

	Return vRet
EndProc 
*-------------------------------------------------------------------------------
