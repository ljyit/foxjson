*���������ʾ��ֱ�ӵ���fll�����еĻ�������
*��������Щ����������װ�ɸ���������vfp����


Set Library To  foxjson.dll
 
*create a json object,like a boy
json=json_Create()
json_Append(json,json_Create("json" +Chr(13)+"hello" ),"name")
json_Append(json,json_Create(12),"age")
json_Append(json,json_Create(.f.),"married")
json_Append(json,json_Create(12.34),"money")
json_Append(json,json_Create(null),"tail")

?json_ToString(json)

 Wait 
*create a json array
arr=json_create({})  
json_Append(arr,json_Create("this is a array"))
*add object to array
json_addRef(json)  && locked,the next statement will be use
json_Append(arr,json)
json_Append(arr,json_parse(json_toString(json)))

?json_ToString(arr)
Wait 
json_Remove(arr,2) && remove from array,unlocked
?json_ToString(arr)

Wait 
*add array to object
json_Append(json,arr,"cloned")


?json_ToString(json)

json_Delete(json)
Return 

json=json_Create("test")

?json_ToString(json)


json_Delete(json)


*
json=json_Parse(["abc"])
?json_Value(json)
json_Delete(json)

*����
json=json_Parse('{"name":"��","age":25,"tail":null,"bool":true,"double":123.45}')
?json
*�ӵĸ���
?"childs count:",json_childs(json)
*������ֵ
?json_Value(json,"name")
?json_Value(json,"age")
?json_Value(json,"tail")
*�����������ֵ
nCount=json_childs(json)
 ?"before :===="
For x=1 to nCount
	?"enum:",json_key(json,x),json_Value(json,x),json_type(json,x)	
EndFor 


*ɾ��
?json_Remove(json,1)
 nCount=json_Childs(json)
 ?"after delete:===="
For x=1 to nCount
	?"enum:",json_key(json,x),json_Value(json,x),json_type(json,x)	
EndFor 


json_Delete(json)


*����
json=json_Parse('["str",123.4,333,false,null]')
?json_Value(json,1)
?json_Value(json,2)
?json_Value(json,3)
?json_Value(json,4)
?json_Value(json,5)
?json_Childs(json)

?json_Remove(json,2)
 nCount=json_Childs(json)
For x=1 to nCount
	?"enum:",json_Value(json,x),json_type(json,x)	
EndFor 


json_Delete(json)



json=json_Parse('["str",{"name":123,"age":456},false,null]')
?json
?json_Value(json,1)

j2=json_Value(json,2)
 nCount=json_Childs(j2)
For x=1 to nCount
	?"enum:",json_Key(j2,x),json_Value(j2,x),json_type(j2,x)	
EndFor 
json_AddRef(j2)
json_Delete(j2)

json_Delete(json)



 
