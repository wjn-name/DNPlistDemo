//
//  ViewController.m
//  DNPlistDemo
//
//  Created by mainone on 16/9/8.
//  Copyright © 2016年 wjn. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *authorTextField;
@property (weak, nonatomic) IBOutlet UITextField *newsIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *newsContentTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)saveNewsMessage:(UIButton *)sender {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.titleTextField.text forKey:@"title"];
    [dict setObject:self.authorTextField.text forKey:@"author"];
    [dict setObject:self.newsIDTextField.text forKey:@"newsid"];
    [dict setObject:self.newsContentTextField.text forKey:@"newscontent"];
    
    [self saveNewsWithDict:dict withKey:self.newsIDTextField.text];
}

- (IBAction)deleteNewsMessage:(UIButton *)sender {
    [self deleteNewsMessageFromPlistWithID:@"1002"];
}

- (IBAction)readNewsMessage:(UIButton *)sender {
    [self readAllNewsMessageFromPlist];
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
