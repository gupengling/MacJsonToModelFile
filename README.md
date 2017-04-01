# MacJsonToModelFile

## 将本地文本json格式转成本地文件
例如：

```
"school": "XX大学", "pageSize": 10, "list": [ { "userId": 33237, "goodsTypeName": "我的天", "companyName": "YiMi公司" } ], "last": false, "first": true, "des":{ "sex": "男", "like": "篮球", "class": "初一" }
```
### 将会转换成自己定义的文件名称文件在desktop／CreatFiles文件夹中

> * 比如自己定义的名称为 *BBBTest* ，将在文件夹中出现 *BBBTest.h* 和 *BBBTest.m* 文件
> * 比如你习惯性的创建多个某型可以勾选 *多文件* （多文件有点小问题，手动import无影响）

单文件具体生成代码如下：

```
//BBBTest.h
#import <Foundation/Foundation.h>

@class BBBTestList;
@class BBBTestDes;


@interface BBBTestList : NSObject

@property (nonatomic, copy)  NSString *goodsTypeName;
@property (nonatomic, copy)  NSString *userId;
@property (nonatomic, copy)  NSString *companyName;


@end



@interface BBBTest : NSObject

@property (nonatomic, copy)  NSString *school;
@property (nonatomic, assign) BOOL first;
@property (nonatomic, strong) NSArray <BBBTestList *>*list;
@property (nonatomic, strong) BBBTestDes *des;
@property (nonatomic, copy)  NSString *pageSize;
@property (nonatomic, assign) BOOL last;


@end



@interface BBBTestDes : NSObject

@property (nonatomic, copy)  NSString *sex;
@property (nonatomic, copy)  NSString *like;
@property (nonatomic, copy)  NSString *class;


@end

```

```
//BBBTest.m
#import "BBBTest.h"

@implementation BBBTestList

- (instancetype)init {
	self = [super init];
	if (self) {

	}
	return self;
}


@end



@implementation BBBTest

- (instancetype)init {
	self = [super init];
	if (self) {

	}
	return self;
}


@end



@implementation BBBTestDes

- (instancetype)init {
	self = [super init];
	if (self) {

	}
	return self;
}


@end

```
>  代码简单仅供参考，如有建议欢迎[@我](https://github.com/gupengling)。

>  欢迎交流学习
