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

###基本用法: 以存入字典为例,其他类型类似

1)数据写入

      - (void)writeUserInfoToPlist {
          // 获取存储路径
          NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
          // 将path路径与文件名片接起来组成新的路径
          NSString *fileName = [path stringByAppendingPathComponent:@"userinfo.plist"];
          NSDictionary *userInfoDict = @{@"name":@"张三", @"age":@16};
          // 自动写入该plist文件中
          [userInfoDict writeToFile:fileName atomically:YES];
      }

2)数据读取

      - (NSDictionary *)readUserInfoFromPlist {
          NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
          NSString *fileName = [path stringByAppendingPathComponent:@"userinfo.plist"];
          NSDictionary *userInfoDict = [NSDictionary dictionaryWithContentsOfFile:fileName];
          return userInfoDict;
      }


3)删除整个plist文件

      - (void)deleteUserInfoPlist {
          NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
          NSString *fileName = [path stringByAppendingPathComponent:@"userinfo.plist"];
          NSFileManager *fileManager = [[NSFileManager alloc] init];
          if ([fileManager fileExistsAtPath:fileName]) {
               [fileManager removeItemAtPath:fileName error:nil];
          }
      }


###接下来我们以实际的项目需求为例,建立一个新闻信息本地收藏

1)添加新闻
在添加新闻信息的时候,我们需要考虑的问题有:是否有该plist文件,如果没有则需要创建,如果有,则直接写入

      /**
       *  添加新闻
       *
       *  @param dict      新闻详细信息
       *  @param articalId 新闻Id 作为信息的唯一标示
       */
      - (void)saveNewsWithDict:(NSMutableDictionary *)dict withKey:(NSString *)articalId{
          if (articalId.length == 0) { return; }
          
          NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
          NSString *fileName = [path stringByAppendingPathComponent:@"newsCollection.plist"];
          NSFileManager *fileManager = [[NSFileManager alloc] init];
          // 判断plist文件是否存在,不存在就创建
          if (![fileManager fileExistsAtPath:fileName]) {
              // 判断创建是否成功
              if (![fileManager createFileAtPath:fileName contents:nil attributes:nil]) {
                  NSLog(@"create plist error");
              } else {
                  NSDictionary *newsMessageDict = [NSDictionary dictionaryWithObjectsAndKeys:dict, articalId, nil];
                  BOOL isSaveSuccess = [newsMessageDict writeToFile:fileName atomically:YES];
                  NSLog(@"save state : %d", isSaveSuccess);
              }
          } else { // 若plist存在
              // 存plist中取出信息
              NSMutableDictionary *newsMessageDict = [[NSMutableDictionary alloc] initWithContentsOfFile:fileName];
              // 添加信息
              [newsMessageDict setObject:dict forKey:articalId];
              BOOL isSaveSuccess = [newsMessageDict writeToFile:fileName atomically:YES];
              NSLog(@"save state : %d", isSaveSuccess);
          }
          
      }

2)读取全部的新闻信息 以ID排序输出一个数组

      /**
       *  读取全部的新闻信息
       */
      - (NSMutableArray *)readAllNewsMessageFromPlist {
          NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
          NSString *fileName = [path stringByAppendingPathComponent:@"newsCollection.plist"];
          // 获取存储的信息
          NSMutableDictionary *newsMessageDict = [[NSMutableDictionary alloc] initWithContentsOfFile:fileName];
          // 获取所有key 顺便排序下
          NSArray *keyValue = [[newsMessageDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
          
          NSMutableArray *newsMessageArray = [[NSMutableArray alloc] init];
          [keyValue enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
              NSDictionary *dict = [newsMessageDict objectForKey:obj];
              [newsMessageArray addObject:dict];
          }];
          NSLog(@"news message array : %@", newsMessageArray);
          return newsMessageArray;
      }


3)删除某个新闻

      /**
       *  删除某个新闻
       *
       *  @param newsId 要删除的新闻ID
       */
      - (void)deleteNewsMessageFromPlistWithID:(NSString *)newsId {
          NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
          NSString *fileName = [path stringByAppendingPathComponent:@"newsCollection.plist"];
          // 获取存储的信息
          NSMutableDictionary *newsMessageDict = [[NSMutableDictionary alloc] initWithContentsOfFile:fileName];
          [newsMessageDict removeObjectForKey:newsId];
          BOOL isSaveSuccess = [newsMessageDict writeToFile:fileName atomically:YES];
          if (isSaveSuccess) {
              NSLog(@"delete newsid %@ is success", newsId);
          }
      }



虽然plist可以存储数据,但是还是不建议用plist来存储这种数据量比较大的数据,读写速度都会相对较慢,影响性能,像这种存储新闻数据的最好还是建数据库存比较好.

