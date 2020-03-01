* class foxJson 
* 对foxjson.fll的封装类，继承自vfp的Collection类，可以像集合一样访问json数据
* by 木瓜,2013
 

Define Class foxJson as Collection 
	*Json值
	Value=""
	*值的键
	Key=""
	*值的类型
	Type=0
	*子对像个数
	Count=0
	
	*======================================================================
	*构造函数 
	Procedure Init
	Lparameters vValue
		
		If Pcount()=0
			this._Object=json_Create()
			Return 
		EndIf 
		
		If Vartype(vValue) $"INLCXD"  &&数值，小数，逻辑，字符，null,array
			this._Object=json_Create(vValue)
			Return 
		EndIf 
		
		If Vartype(vValue)="O" and vValue.Class==this.Class 
			this._Object=json_Parse( vValue.ToString())
			Return 
		EndIf 
		
		*参数错误
		Error(11)
	EndProc 
	*
	Procedure Destroy()
 		json_Delete(this._Object)
	EndProc 
	*======================================================================
	*索引器
	Procedure Item(name) as Object 
		NoDefault 
		If not Vartype(name) $ "CIN"
			Error(2061)
		EndIf 
		
		If this.isArray() and Vartype(name)="C"
			Error(2061)
		EndIf 

		Private  oJson	
		oJson=NewObject(this.Class)
		json_Delete(oJson._Object)
		If this.isObject() or this.isArray()
			oJson._Object=json_KeyValue(this._Object,name)
			oJson._ObjectIndex=name
		Else 
			oJson._Object=json_Value(this._Object,name)
		EndIf 
		json_addref(oJson._Object)
		
		Return oJson
	EndProc 
	*======================================================================
	*解析器
	Procedure Parse(cJson)
		json_Delete(this._Object)
		this._Object=json_Parse(cJson)
	EndProc 
	*======================================================================
	*ToString
	Procedure ToString()
		Return json_ToString(this._object)
	EndProc 
	*======================================================================
	*追加
	Procedure Append(cKey,vValue)  && cKey|vValue,vValue
		
		*数组
		If Pcount()=1 and this.isArray()
		
			If Vartype(cKey) $"INLCXD"  &&数值，小数，逻辑，字符，null,array
				json_Append(this._Object,json_Create(cKey))
				Return 
			EndIf 
			
			If Vartype(cKey)="O" and cKey.Class==this.Class 
				json_Append(this._Object,json_Parse( cKey.ToString()))
				Return 
			EndIf 
		
			Error(11)
			Return 
		EndIf 
		
		*对像
		If Pcount()=2 and this.isObject() and Vartype(cKey)="C"
			If Vartype(vValue) $"INLCXD"  &&数值，小数，逻辑，字符，null,array
				json_Append(this._Object,json_Create(vValue),cKey)
				Return 
			EndIf 
			
			If Vartype(vValue)="O" and vValue.Class==this.Class 
				json_Append(this._Object,json_Parse( vValue.ToString()),cKey)
				Return 
			EndIf 
		
			Error(11)
			Return 
		EndIf 
		
		Error(11)  
	EndProc 
	*======================================================================
	*移除
	Procedure Remove(cKey)  &&cKey|vIdx
		NoDefault 
		If this.IsObject() and Vartype(cKey)$"CINY"
			json_Remove(this._Object,cKey)
			Return 
		EndIf 
		
		If this.IsArray() and Vartype(cKey) $"INY"
			json_Remove(this._Object,cKey)
			Return 
		EndIf 
		
		Error(11)  
	EndProc 
	*======================================================================
	Procedure Value_Access
		If not Empty(this._ObjectIndex)
			Return json_Value(this._Object,this._ObjectIndex)			
		EndIf 
		If this.isObject() or this.isArray()
			Local oTmp
			oTmp =NewObject(this.Class)
			json_Delete(oTmp._Object)
			oTmp._Object=this._Object
			json_AddRef(oTmp._Object)  &&在Destroy中释放
			Return oTmp
		EndIf 
		Return json_Value(this._Object)
	EndProc 
	*======================================================================
	Procedure Key_Access
		Return json_Key(this._Object,this._ObjectIndex)
	EndProc 
	*======================================================================
	Procedure Count_Access
		If this.isObject() or this.isArray()
			Return json_Childs(this._Object)
		EndIf 
		Error(2061)
	EndProc 
	*======================================================================
	Procedure Type_Access
		Return json_Type(this._Object)
	EndProc 
	*======================================================================
	Procedure isNull()
		Return json_Type(this._Object)==0
	EndProc 
	
	Procedure isBool()
		Return json_Type(this._Object)==1
	EndProc 
	
	Procedure isDouble()
		Return json_Type(this._Object)==2
	EndProc 
	
	Procedure isInt()
		Return json_Type(this._Object)==3
	EndProc 
	
	Procedure isObject()
		Return json_Type(this._Object)==4
	EndProc 
	
	Procedure isArray()
		Return json_Type(this._Object)==5
	EndProc 
	
	Procedure isString()
		Return json_Type(this._Object)==6
	EndProc 
	*======================================================================
	*json object 
	*Protected _Object  	
	_Object="" 
	_ObjectIndex=""
EndDefine 


*test 
*!*	Set Library To foxjson.dll 
*!*	TEXT TO cJson NOSHOW TEXTMERGE PRETEXT 15
*!*	{
*!*		"name":"lee"
*!*		,"age":32
*!*		,"childs":[
*!*			{"name":"gg","age":1}
*!*			,{"name":"mm","age":3}
*!*		]
*!*		,"array":[
*!*			[1,2,3]
*!*			,[4,5,6]
*!*		]
*!*	}	
*!*	ENDTEXT
*!*	oJson=JsonToObject(cJson )
*!*	?oJson.name
*!*	?oJson.childs(1).name
*!*	?oJson.array(2).item(2)  &&vfp不支持数组中的数组写法，所以要使用item

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
			tmpObj=json_KeyValue(jsonObj,json_Key(jsonObj,x))
			AddProperty(vRet,json_Key(jsonObj,x), JsonToObject_Value(tmpObj))
		EndFor 
	Case nType=5
	*Array
		vRet=CreateObject("Collection")
		nCount=json_Childs(jsonObj)
		For x=1 to nCount
			tmpObj=json_KeyValue(jsonObj,x)
			vRet.Add(JsonToObject_Value(tmpObj))
		EndFor 
	Otherwise
	*basic value
		vRet=json_value(jsonObj)
	EndCase

	Return vRet
EndProc 
*-------------------------------------------------------------------------------

*!*	Set Library To foxjson.dll ADDITIVE 
*!*	Clear 
*!*	*表记录生成json
*!*	Use (_foxcode) Shared  
*!*	Scatter name tmp memo 
*!*	?ObjectToJson(tmp)
*!*	Use 

*!*	*嵌套对像
*!*	obj=CreateObject("empty")
*!*	obj2=CreateObject("empty")
*!*	AddProperty(obj2,"name","test")
*!*	AddProperty(obj,"child",obj2)
*!*	?ObjectToJson(obj)

*!*	*集合
*!*	obj3=CreateObject("collection") 
*!*	obj3.Add(123)
*!*	obj3.Add("456")
*!*	?ObjectToJson(obj3)

*!*	*对像和集合嵌套
*!*	AddProperty(obj,"expand",obj3)
*!*	?ObjectToJson(obj)

*!*	*基类只处理自定义属性
*!*	?ObjectToJson(_screen)
*!*	_screen.AddProperty("my","123")
*!*	?ObjectToJson(_screen)

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