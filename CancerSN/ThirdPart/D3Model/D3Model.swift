//
//  D3Model.swift
//  D3Model
//
//  Created by mozhenhau on 15/2/12.
//  Copyright (c) 2015年 mozhenhau. All rights reserved.
//

import Foundation

open class D3Model:NSObject{
    required override public init(){}
    //MARK: json转到model
    open class func jsonToModel<T>(_ dics:AnyObject?)->T!{
        if dics == nil {
            return nil
        }
        var dic:AnyObject!
        if dics is NSArray{
            dic = dics!.lastObject as AnyObject!
        }
        else{
            dic = dics
        }
        
        //get mirror
        let obj:AnyObject = self.init() //新建对象
        let properties:Mirror! = Mirror(reflecting: obj)
        
        if dic != nil{
            if let b = AnyBidirectionalCollection(properties.children) {
               // for i in b.index(b.endIndex, offsetBy: -30, limitedBy: b.startIndex)! ... b.endIndex {  //因为是继承NSObject对象的，0是NSObject，所以从1开始
                for bEelment in b {  //因为是继承NSObject对象的，0是NSObject，所以从1开始

                let pro = bEelment
                let key = pro.0        //pro  name
                let type = pro.1    // pro type
                    
                switch type {
                case is Int,is Int64,is Float,is Double,is Bool,is NSNumber,is NSInteger, is Int16, is Int32, is Int8:  //base type
                    let value = (dic?.object(forKey: key!) as AnyObject)
                    if (value != nil) && ((value is NSNull) == false){
                        obj.setValue(value, forKey: key!)
                    }
                    break
                    
                case is String:
                    let value: AnyObject! = dic?.object(forKey: key!) as AnyObject
                    if value != nil{
                        obj.setValue(value.description, forKey: key!)
                    }
                    break
                    
                case is Array<String>:  //arr string
                    if let nsarray = dic?.object(forKey: key!) as? NSArray {
                        var array:Array<String> = []
                        for el in nsarray {
                            if let typedElement = el as? String {
                                array.append(typedElement)
                            }
                        }
                        obj.setValue(array, forKey: key!)
                    }
                    break
                    
                    
                case is Array<Int>:   //arr int
                    if let nsarray = dic?.object(forKey: key!) as? NSArray {
                        var array:Array<Int> = []
                        for el in nsarray {
                            if let typedElement = el as? Int {
                                array.append(typedElement)
                            }
                        }
                        obj.setValue(array, forKey: key!)
                    }
                    break
                    
                default:      //unknow
                    let otherType = Mirror(reflecting: type).subjectType
                    switch otherType{
                    case is Optional<String>.Type,is Optional<NSNumber>.Type,is Optional<NSInteger>.Type,is Optional<Array<String>>.Type,is Optional<Array<Int>>.Type, is ImplicitlyUnwrappedOptional<String>.Type:
                        obj.setValue(dic?.object(forKey: key!), forKey: key!)
                        break
                    
                    default:
                        print(otherType)
                        let name:String = String(describing: otherType)
                        let className = getClassName(name as NSString) as String

                        let clz:AnyClass! = NSClassFromString(className)
                        print(clz)
                        if clz != nil{
                            if let data = dic.object(forKey: key!) as? NSArray{
                                let value = clz.jsonToModelList(data)
                                obj.setValue(value, forKey: key!)
                            }
                            else{
                                let value = dic.object(forKey: key!)
                                obj.setValue!((clz as! D3Model.Type).jsonToModel(value as AnyObject?),forKey:key!)
                            }
                        }
                        else{
                            print("unknown property")
                        }
                        break
                    }
                }
            }
        }
        }
        else{
            return nil
        }
        return (obj as! T)
    }
    
    //MARK: json转到model list,传入anyobject
    open class func jsonToModelList(_ data:AnyObject?)->Array<AnyObject>{
        if data == nil{
            return []
        }

        var objs:Array<AnyObject> = []
        if let dics = data as? NSArray{
            
            for i in 0..<dics.count{
                let dic:AnyObject = dics[i] as AnyObject
                objs.append(jsonToModel(dic))
            }
        }
        return objs
    }

    
    //从一串Optional<*******>找到类名字符串
    fileprivate class func getClassName(_ name:NSString)->NSString!{
        var range = name.range(of: "<.*>", options: NSString.CompareOptions.regularExpression)
        if range.location != NSNotFound{
            range.location += 1
            range.length -= 2
            return getClassName(name.substring(with: range) as NSString)
        }
        else{
            return name
        }
    }
}
