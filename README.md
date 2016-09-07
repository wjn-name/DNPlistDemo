# DNPlistDemo
本地存储之plist序列化

##1.沙盒
苹果的本地化存储都是放在沙盒中保存的,一般情况下iOS程序只能访问自己的沙盒目录

####Document: 最常用的目录,iTunes同步时会同步此文件夹,一般存储重要数据
      NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    //第一个参数:要搜索的目录名称
    //第二个参数:搜索的范围(这里选的是当前应用的沙盒目录)
    //第三个参数:是否展开波浪线显示(如果为NO,则路径显示形式为 "~/xxx" )

####Library: 
    1)Caches: itunes同步时不会同步此文件夹,一般存储数据量大但非重要数据
    NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES).firstObject;
    
    2)Preferences: itunes同步会同步此文件夹,通常保护用户的设置信息
    不要直接在这里面创建设置文件,应该通过NSUserDefaults类来对程序的偏好进行设置

####tmp: itunes不会同步此文件,系统可能在应用没有运行的时候将其内容删除
    NSString *path = NSTemporaryDirectory();

##2.plist文件(序列化)

plist只能将某些特定类通过XML文件的方式保存到沙盒中,支持类型有以下几种:

      NSArray, NSMutableArray;              //数组
      NSDictionary, NSMutableDictionary;    //字典
      NSData, NSMutableData;                //二进制数据
      NSString, NSMutableString;            //字符串
      NSNumber;                             //基本数据
      NSDate;                               //日期
















