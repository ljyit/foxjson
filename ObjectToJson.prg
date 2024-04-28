Set Library To foxjson.dll ADDITIVE 
Clear 
*���¼����json
Use (_foxcode) Shared  
Scatter name tmp memo 
?ObjectToJson(tmp)
Use 

*Ƕ�׶���
obj=CreateObject("empty")
obj2=CreateObject("empty")
AddProperty(obj2,"name","test")
AddProperty(obj,"child",obj2)
?ObjectToJson(obj)

*����
obj3=CreateObject("collection") 
obj3.Add(123)
obj3.Add("456")
?ObjectToJson(obj3)

*����ͼ���Ƕ��
AddProperty(obj,"expand",obj3)
?ObjectToJson(obj)

*����ֻ�����Զ�������
?ObjectToJson(_screen)
_screen.AddProperty("my","123")
?ObjectToJson(_screen)
 

*-------------------------------------------------------------------------------
*�� �� ����ObjectToJson
*�������ܣ���һ��VFP����ת��Ϊjson�ַ���
*�Ρ�������object
*�� �� ֵ��
*�������ߣ�ľ��
*�������ڣ�2018-10-15
*������ע��ֻת�����ԣ����������飬���϶���ӳ��Ϊjson������
*-------------------------------------------------------------------------------
PROCEDURE ObjectToJson(obj,mode)
	Local jsonObj,vValue
	Do case
	Case  Vartype(obj)=="C"
	*�ַ���ȥ��ǰ��ո�
		jsonObj=json_Create(Alltrim(obj))
	Case Vartype(obj) $ "INLCX"  
	*���飬�߼���NULL ����ֱ��ʶ��
		jsonObj=json_Create(obj)
	Case Vartype(obj)= "Y"  
	*����ȥ������
		jsonObj=json_Create(Alltrim(Transform(obj,"@Z")))
	Case Vartype(obj)=="O"
		If PemStatus(obj,"baseclass",5) and obj.baseClass=="Collection"
		*����
			jsonObj=json_Create({})
			Local x 
			*vfp bug:ʹ�� for each in obj �ᵼ��AMembers()��ȡ��������
			For x=1 to obj.Count
				json_Append(jsonObj ,ObjectToJson(obj.item(x) ,.T.))
			EndFor 
		Else
		*����
			Local aProps[1],cName
			jsonObj=json_Create()
			If AMembers(aProps,obj,0,"U")>0  &&�����Ҫȫ������Ӧ��ΪAMembers(aProps,obj��
				FOR EACH cName in aProps
					If Type("obj."+cName)="U"
						*�����޷����ʵ����ԣ�����_screen.ActiveForm
						Loop 
					EndIf 
					json_Append(jsonObj ,ObjectToJson(obj.&cName,.T.),Lower(cName))  &&ȫ��Сд
				EndFor 
			EndIf 
		EndIf 
	Otherwise 
	*��������תΪ�ַ�
		jsonObj=json_Create(Transform(obj,"@T"))
	EndCase 	
	
	If mode
		Return jsonObj  &&�ݹ�ʱ�����ڲ�ָ��
	EndIf 
	
	*����Json�ַ���
	Local cRetData
	cRetData=json_ToString(jsonObj)
	json_Delete(jsonObj)
	Return cRetData	
EndProc