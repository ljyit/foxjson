Set Library To foxjson.dll  ADDITIVE 
Set Procedure To foxjson ADDITIVE 
Clear 
Local obj as foxJson
obj=CreateObject("foxJson")

obj.Append("name","json")
?obj.item(1).value,  obj.item(1).type ,  obj.item(1).Key

?"Basic object  ==========================="
obj.Append("age",12)
obj.Append("maried",.f.)
obj.Append("money",123.45)
obj.Append("tails",null)
?obj.Count,obj.ToString()

?"Basic array  ==========================="
arr=CreateObject("foxJson",{})
arr.Append(123)
arr.Append("abc")
arr.Append(null)
arr.Append(123.45)
arr.Append(.f.)
?arr.ToString()

?"object in array ==========================="
arr.Append(obj)
?arr.ToString()

?"array in object  ==========================="
obj.Append("expand",arr)
?obj.ToString()

obj.Remove("name")  && delete name
obj.Remove(1)	&&delete age
?obj.item("expand").item(1).value 
?obj.item("expand").type

* vfp bug, method is error
*obj.item("expand").remove(1)
v=obj.item("expand")
v.remove(1)  && delete value 123
?v.ToString()

?obj.ToString()

 

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
	Procedure Init(value)
		If Pcount()=0
			this._Object=json_Create()
			Return 
		EndIf 
		
		If Vartype(value) $"INLCXD"  &&数值，小数，逻辑，字符，null,array
			this._Object=json_Create(value)
			Return 
		EndIf 
		
		If Vartype(value)="O" and value.Class==this.Class 
			this._Object=json_Parse( val.ToString())
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
		
		If InList(json_Type(this._Object,name),4,5)
			*数组和对像
			oJson =NewObject(this.Class)
			json_Delete(oJson._Object)
			
			oJson._Object=json_Value(this._Object,name)
			json_AddRef(oJson._Object)
			Return oJson
		EndIf 
		
		*值类型
		oJson=NewObject("empty")
		AddProperty(oJson,"Value",json_Value(this._Object,name))
		AddProperty(oJson,"Type",json_Type(this._Object,name))
		If this.isObject()
			If Vartype(name) $ "IN" 
				AddProperty(oJson,"Key",json_Key(this._Object,name))
			Else
				AddProperty(oJson,"Key",name)
			EndIf 
		EndIf 
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
		Return json_toString(this._Object)
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
		If this.isObject() or this.isArray()
			Error(2061)
		EndIf 
		Return json_Value(this._Object)
	EndProc 
	*======================================================================
	Procedure Key_Access
		Return json_Key(this._Object)
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
EndDefine 