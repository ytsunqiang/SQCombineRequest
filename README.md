# SQCombineRequest
对AFNetworking网络封装,便于网络顺序执行、并序执行
# 使用示例
```
//创建单个网络请求
- (SQCombineRequestItem *)createItemWithKey:(NSString *)key {
    //创建网络请求
    SQCombineRequestItem *item = [[SQCombineRequestItem alloc] init];
    //将要开始
    item.requestWillStart = ^(SQCombineRequestItem *requestItem) {
        NSLog(@"will start    %@", key);
    };
    //获取网络请求参数
    item.requestParam = ^NSDictionary *(NSDictionary *data){
         //data为前面的网络请求成功之后传递过来的数据
        NSLog(@"getParam   %@  %@",key, data);
        return @{@"q": @"你好"};
    };
    //网络的url  （接口有时不可用）
    item.url = @"https://dict.youdao.com/jsonapi";
    //网络请求方式
    item.method = SQCRNetMethodGet;
    //成功回调
    item.successBlock = ^(id data, SQCombineRequestResult *result) {
        //传递给下一个网络请求的数据
        result.dataToNextRequest = @{key: key};
        //如果校验数据不符合要求，要停止网络请求,执行下面即可
        //result.stop = YES;
        NSLog(@"success   %@", key);
    };
    //失败回调
    item.failBlock = ^(id error) {
        NSLog(@"fail    %@", key);
    };
    return item;
}

```
## 1、单个网络请求
```
    //创建网络请求
    SQCombineRequestItem *item = [self createItemWithKey:@"single"];
    //开始请求
    [item start];
```
结果
```
2021-08-31 19:33:18.736320+0800 SQCombineRequestDemo[20020:93993] will start    single
2021-08-31 19:33:18.736533+0800 SQCombineRequestDemo[20020:93993] getParam   single  (null)
2021-08-31 19:33:19.122764+0800 SQCombineRequestDemo[20020:93993] success   single
2021-08-31 19:33:19.123052+0800 SQCombineRequestDemo[20020:93993] dealloc SQCombineRequestItem
```

## 2、串行网络请求
```
        //创建串行网络
    self.chainRequest = [[SQCombineChainRequest alloc] init];
    //串行网络所有请求执行成功
    self.chainRequest.successBlock = ^(id data, SQCombineRequestResult *result) {
        NSLog(@"chainRequest success");
    };
    //任何网络请求执行失败,或者任何一个网络成功回调里面stop传YES,都会走到这里
    self.chainRequest.failBlock = ^(id error) {
        NSLog(@"chainRequest fail");
    };
    
    for (int i = 0; i < 3; i++) {
        //创建网络请求
        SQCombineRequestItem *item = [self createItemWithKey:[NSString stringWithFormat:@"%d", i]];
        [self.chainRequest addRequest:item];
    }
    [self.chainRequest start];
```
结果
```
2021-08-31 19:34:44.030914+0800 SQCombineRequestDemo[20020:93993] will start    0
2021-08-31 19:34:44.031103+0800 SQCombineRequestDemo[20020:93993] getParam   0  (null)
2021-08-31 19:34:44.310259+0800 SQCombineRequestDemo[20020:93993] success   0
2021-08-31 19:34:44.310585+0800 SQCombineRequestDemo[20020:93993] will start    1
2021-08-31 19:34:44.310916+0800 SQCombineRequestDemo[20020:93993] getParam   1  {
    0 = 0;
}
2021-08-31 19:34:44.617736+0800 SQCombineRequestDemo[20020:93993] success   1
2021-08-31 19:34:44.618036+0800 SQCombineRequestDemo[20020:93993] will start    2
2021-08-31 19:34:44.618327+0800 SQCombineRequestDemo[20020:93993] getParam   2  {
    0 = 0;
    1 = 1;
}
2021-08-31 19:34:44.874603+0800 SQCombineRequestDemo[20020:93993] success   2
2021-08-31 19:34:44.874899+0800 SQCombineRequestDemo[20020:93993] chainRequest success
```
## 3、并行网络请求
```
    //创建并行网络
    self.batchRequest = [[SQCombineBatchRequest alloc] init];
    //串行网络所有请求执行成功
    self.batchRequest.successBlock = ^(id data, SQCombineRequestResult *result) {
        NSLog(@"batchRequest success");
    };
    //任何网络请求执行失败,或者任何一个网络成功回调里面stop传YES,都会走到这里
    self.batchRequest.failBlock = ^(id error) {
        NSLog(@"batchRequest fail");
    };
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < 3; i++) {
        //创建网络请求
        SQCombineRequestItem *item = [self createItemWithKey:[NSString stringWithFormat:@"%d",i]];
        item.successBlock = ^(id data, SQCombineRequestResult *result) {
            NSLog(@"success %d",i);
        };
        [items addObject:item];
    }
    [self.batchRequest addRequests:items];
    [self.batchRequest start];
```

结果
```
2021-08-31 19:36:08.543819+0800 SQCombineRequestDemo[20020:93993] will start    0
2021-08-31 19:36:08.544094+0800 SQCombineRequestDemo[20020:93993] getParam   0  (null)
2021-08-31 19:36:08.545526+0800 SQCombineRequestDemo[20020:93993] will start    1
2021-08-31 19:36:08.545700+0800 SQCombineRequestDemo[20020:93993] getParam   1  (null)
2021-08-31 19:36:08.547276+0800 SQCombineRequestDemo[20020:93993] will start    2
2021-08-31 19:36:08.547774+0800 SQCombineRequestDemo[20020:93993] getParam   2  (null)
2021-08-31 19:36:09.025486+0800 SQCombineRequestDemo[20020:93993] success 2
2021-08-31 19:36:09.027692+0800 SQCombineRequestDemo[20020:93993] success 0
2021-08-31 19:36:09.061978+0800 SQCombineRequestDemo[20020:93993] success 1
2021-08-31 19:36:09.062164+0800 SQCombineRequestDemo[20020:93993] batchRequest success

```
## 4、组合使用

![image.png](https://upload-images.jianshu.io/upload_images/3150123-f24a0d8fe563b0e0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

图中b c d作为item添加到上面灰色串行网络中，e f g作为item添加到下面灰色串行网络中， 两个灰色又作为item加入到黄色的并行网络中。绿色跟黄色又作为item加入到蓝色串行网络中。

```
    //组合使用代码
    //创建请求a
    SQCombineRequestItem *a = [self createItemWithKey:@"a"];
    //创建bcd串行请求
    SQCombineChainRequest *bcd = [[SQCombineChainRequest alloc] init];
    for (NSString *key in @[@"b", @"c", @"d"]) {
         //分别添加b c d网络添加到bcd串行网络中
        [bcd addRequest:[self createItemWithKey:key]];
    }
    //b c d成功
    bcd.successBlock = ^(id data, SQCombineRequestResult *result) {
        NSLog(@"bcd success");
    };
    //创建efg串行网络
    SQCombineChainRequest *efg = [[SQCombineChainRequest alloc] init];
    for (NSString *key in @[@"e", @"f", @"g"]) {
        //分别将e f g网络添加到efg串行网络中
        [efg addRequest:[self createItemWithKey:key]];
    }
    //e f g 成功
    efg.successBlock = ^(id data, SQCombineRequestResult *result) {
        NSLog(@"efg success");
    };
    //创建bcd、efg并行的网络请求
    SQCombineBatchRequest *batch = [[SQCombineBatchRequest alloc] init];
    //并行网络请求添加bcd efg
    [batch addRequests:@[bcd, efg]];
    //创建最终的串行网路请求
    self.chainRequest = [[SQCombineChainRequest alloc] init];
    //串行网络请求添加请求a
    [self.chainRequest addRequest:a];
    // 串行网络添加并行组合
    [self.chainRequest addRequest:batch];
    //所有网络执行成功后的回调
    self.chainRequest.successBlock = ^(id data, SQCombineRequestResult *result) {
        NSLog(@"self.chainRequest success");
    };
    //开启网络调用
    [self.chainRequest start];
```

结果
```
2021-08-31 16:58:56.384953+0800 SQCombineRequestDemo[59480:691163] will start    a
2021-08-31 16:58:56.385118+0800 SQCombineRequestDemo[59480:691163] getParam   a  (null)
2021-08-31 16:58:57.027075+0800 SQCombineRequestDemo[59480:691163] success   a
2021-08-31 16:58:57.027291+0800 SQCombineRequestDemo[59480:691163] will start    b
2021-08-31 16:58:57.027492+0800 SQCombineRequestDemo[59480:691163] getParam   b  {
    a = a;
}
2021-08-31 16:58:57.028726+0800 SQCombineRequestDemo[59480:691163] will start    e
2021-08-31 16:58:57.028925+0800 SQCombineRequestDemo[59480:691163] getParam   e  {
    a = a;
}
2021-08-31 16:58:57.245229+0800 SQCombineRequestDemo[59480:691163] success   b
2021-08-31 16:58:57.245410+0800 SQCombineRequestDemo[59480:691163] will start    c
2021-08-31 16:58:57.245549+0800 SQCombineRequestDemo[59480:691163] getParam   c  {
    a = a;
    b = b;
}
2021-08-31 16:58:57.257827+0800 SQCombineRequestDemo[59480:691163] success   e
2021-08-31 16:58:57.258210+0800 SQCombineRequestDemo[59480:691163] will start    f
2021-08-31 16:58:57.258544+0800 SQCombineRequestDemo[59480:691163] getParam   f  {
    a = a;
    e = e;
}
2021-08-31 16:58:57.442234+0800 SQCombineRequestDemo[59480:691163] success   c
2021-08-31 16:58:57.442402+0800 SQCombineRequestDemo[59480:691163] will start    d
2021-08-31 16:58:57.442552+0800 SQCombineRequestDemo[59480:691163] getParam   d  {
    a = a;
    b = b;
    c = c;
}
2021-08-31 16:58:57.476281+0800 SQCombineRequestDemo[59480:691163] success   f
2021-08-31 16:58:57.476442+0800 SQCombineRequestDemo[59480:691163] will start    g
2021-08-31 16:58:57.476596+0800 SQCombineRequestDemo[59480:691163] getParam   g  {
    a = a;
    e = e;
    f = f;
}
2021-08-31 16:58:57.634532+0800 SQCombineRequestDemo[59480:691163] success   d
2021-08-31 16:58:57.634791+0800 SQCombineRequestDemo[59480:691163] bcd success
2021-08-31 16:58:57.669988+0800 SQCombineRequestDemo[59480:691163] success   g
2021-08-31 16:58:57.670142+0800 SQCombineRequestDemo[59480:691163] efg success
2021-08-31 16:58:57.670261+0800 SQCombineRequestDemo[59480:691163] self.chainRequest success
```


pod导入方式
```
//自带网络请求工具、使用的是AFNetworking 4.0版本，如果冲突可以使用下面方式导入
pod 'SQCombineRequest'
//不带网络工具，不依赖AFNetworking，要自己设置SQCombineRequestItem的netRequestTool属性
pod 'SQCombineRequest/SQCombineRequestCombine'
```
