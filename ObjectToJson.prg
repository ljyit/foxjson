Set Library To foxjson.dll ADDITIVE 
Clear 
*表记录生成json
Use (_foxcode) Shared  
Scatter name tmp memo 
?ObjectToJson(tmp)
Use 

*嵌套对像
obj=CreateObject("empty")
obj2=CreateObject("empty")
AddProperty(obj2,"name","test")
AddProperty(obj,"child",obj2)
?ObjectToJson(obj)

*集合
obj3=CreateObject("collection") 
obj3.Add(123)
obj3.Add("456")
?ObjectToJson(obj3)

*对像和集合嵌套
AddProperty(obj,"expand",obj3)
?ObjectToJson(obj)

*基类只处理自定义属性
?ObjectToJson(_screen)
_screen.AddProperty("my","123")
?ObjectToJson(_screen)
 

*-------------------------------------------------------------------------------
*函 数 名：ObjectToJson
*功　　能：将一个VFP对像转换为json字符串
*参　　数：object
*返 回 值：
*作　　者：木瓜
*更新日期：2018-10-15
*备　　注：只转换属性，不处理数组，集合对像映射为json的数组
*-------------------------------------------------------------------------------
PROCEDURE ObjectToJson(obj,mode)
	Local jsonObj,vValue
	Do case
	Case  Vartype(obj)=="C"
	*字符型去掉前后空格
		jsonObj=json_Create(Alltrim(obj))
	Case Vartype(obj) $ "INLCX"  
	*数组，逻辑，NULL 可以直接识别
		jsonObj=json_Create(obj)
	Case Vartype(obj)= "Y"  
	*货币去掉符号
		jsonObj=json_Create(Alltrim(Transform(obj,"@Z")))
	Case Vartype(obj)=="O"
		If PemStatus(obj,"baseclass",5) and obj.baseClass=="Collection"
		*集合
			jsonObj=json_Create({})
			Local x 
			*vfp bug:使用 for each in obj 会导致AMembers()获取不到属性
			For x=1 to obj.Count
				json_Append(jsonObj ,ObjectToJson(obj.item(x) ,.T.))
			EndFor 
		Else
		*对像
			Local aProps[1],cName
			jsonObj=json_Create()
			If AMembers(aProps,obj,0,"U")>0  &&如果需要全部属性应改为AMembers(aProps,obj）
				FOR EACH cName in aProps
					If Type("obj."+cName)="U"
						*忽略无法访问的属性，比如_screen.ActiveForm
						Loop 
					EndIf 
					json_Append(jsonObj ,ObjectToJson(obj.&cName,.T.),Lower(cName))  &&全部小写
				EndFor 
			EndIf 
		EndIf 
	Otherwise 
	*其它类型转为字符
		jsonObj=json_Create(Transform(obj,"@T"))
	EndCase 	
	
	If mode
		Return jsonObj  &&递归时返回内部指针
	EndIf 
	
	*返回Json字符串
	Local cRetData
	cRetData=json_ToString(jsonObj)
	json_Delete(jsonObj)
	Return cRetData	
EndProc