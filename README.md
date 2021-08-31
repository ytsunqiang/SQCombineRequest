# SQCombineRequest
对AFNetworking网络封装,便于网络顺序执行、并序执行
#使用示例

##1、单个网络请求
```
    //创建网络请求
    SQCombineRequestItem *item = [[SQCombineRequestItem alloc] init];
    //将要开始
    item.requestWillStart = ^(SQCombineRequestItem *requestItem) {
        NSLog(@"will start    ");
    };
    //获取网络请求参数
    item.requestParam = ^NSDictionary *(NSDictionary *data){
        NSLog(@"getParam     %@", data);
        return @{@"sid": @"28654780"};
    };
    //网络的url
    item.url = @"https://api.apiopen.top/getSingleJoke";
    //网络请求方式
    item.method = SQCRNetMethodGet;
    //成功回调
    item.successBlock = ^(id data, SQCombineRequestResult *result) {
        NSLog(@"success    %@", data);
        result.dataToNextRequest = @{@"ddd": @"dddd"};
    };
    //失败回调
    item.failBlock = ^(id error) {
        NSLog(@"fail    ");
    };
    //开始请求
    [item start];
```
结果
```
2021-08-31 15:52:02.170799+0800 SQCombineRequestDemo[43980:613200] will start
2021-08-31 15:52:02.170973+0800 SQCombineRequestDemo[43980:613200] getParam     (null)
2021-08-31 15:52:02.525585+0800 2021-08-31 15:52:02.770994+0800 SQCombineRequestDemo[43980:613200] success    {
    code = 200;
    message = "\U6210\U529f!";
    result =     {
        comment = 9;
        down = 7;
        forward = 3;
        header = "http://wimg.spriteapp.cn/profile/large/2018/08/14/5b721ea4242da_mini.jpg";
        name = "\U8d75\U83d3\U83d3";
        passtime = "2018-09-30 02:55:02";
        sid = 28654780;
        text = "\U8fd9\U96be\U9053\U662f\U4f20\U8bf4\U4e2d\U7684\U8138\U5239\Uff1f";
        thumbnail = "http://wimg.spriteapp.cn/picture/2018/0927/5bacc729ae94b__b.jpg";
        type = video;
        uid = 12745266;
        up = 99;
        video = "http://wvideo.spriteapp.cn/video/2018/0927/5bacc729be874_wpd.mp4";
    };
}
2021-08-31 15:52:02.771277+0800 SQCombineRequestDemo[43980:613200] dealloc SQCombineRequestItem
```

##2、串行网络请求
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
        SQCombineRequestItem *item = [[SQCombineRequestItem alloc] init];
        //将要开始
        item.requestWillStart = ^(SQCombineRequestItem *requestItem) {
            NSLog(@"%@", [NSString stringWithFormat:@"will start    %d", i]);
        };
        //获取网络请求参数
        item.requestParam = ^NSDictionary *(NSDictionary *data){
            NSLog(@"getParam  %d --   %@",i, data);
            return @{@"sid": @"28654780"};
        };
        //网络的url
        item.url = @"https://api.apiopen.top/getSingleJoke";
        //网络请求方式
        item.method = SQCRNetMethodGet;
        //成功回调
        item.successBlock = ^(id data, SQCombineRequestResult *result) {
            NSLog(@"success    %@", data);
            NSString *index = [NSString stringWithFormat:@"%d", i];
            result.dataToNextRequest = @{index: index};
        };
        //失败回调
        item.failBlock = ^(id error) {
            NSLog(@"fail    ");
        };
        [self.chainRequest addRequest:item];
    }
    [self.chainRequest start];
```
结果
```
2021-08-31 16:09:22.360619+0800 SQCombineRequestDemo[48115:635881] will start    0
2021-08-31 16:09:22.360790+0800 SQCombineRequestDemo[48115:635881] getParam  0 --   (null)
2021-08-31 16:09:22.989267+0800 SQCombineRequestDemo[48115:635881] success    {
    code = 200;
}
2021-08-31 16:09:22.989466+0800 SQCombineRequestDemo[48115:635881] will start    1
2021-08-31 16:09:22.989624+0800 SQCombineRequestDemo[48115:635881] getParam  1 --   {
    0 = 0;
}
2021-08-31 16:09:23.160840+0800 SQCombineRequestDemo[48115:635881] success    {
    code = 200;
}
2021-08-31 16:09:23.161338+0800 SQCombineRequestDemo[48115:635881] will start    2
2021-08-31 16:09:23.161816+0800 SQCombineRequestDemo[48115:635881] getParam  2 --   {
    0 = 0;
    1 = 1;
}
2021-08-31 16:09:23.352502+0800 SQCombineRequestDemo[48115:635881] success    {
    code = 200;
}
2021-08-31 16:09:23.352690+0800 SQCombineRequestDemo[48115:635881] chainRequest success
```
##3、并行网络请求
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
        SQCombineRequestItem *item = [[SQCombineRequestItem alloc] init];
        //将要开始
        item.requestWillStart = ^(SQCombineRequestItem *requestItem) {
            NSLog(@"will start    %d", i);
        };
        //获取网络请求参数
        item.requestParam = ^NSDictionary *(NSDictionary *data){
            NSLog(@"getParam  %d --   %@",i, data);
            return @{@"sid": @"28654780"};
        };
        //网络的url
        item.url = @"https://api.apiopen.top/getSingleJoke";
        //网络请求方式
        item.method = SQCRNetMethodGet;
        //成功回调
        item.successBlock = ^(id data, SQCombineRequestResult *result) {
            NSLog(@"success    %d", i);
        };
        //失败回调
        item.failBlock = ^(id error) {
            NSLog(@"fail    %d",i);
        };
        [items addObject:item];
    }
    [self.batchRequest addRequests:items];
    [self.batchRequest start];
```

结果
```
2021-08-31 16:40:11.210396+0800 SQCombineRequestDemo[55196:670369] will start    0
2021-08-31 16:40:11.210590+0800 SQCombineRequestDemo[55196:670369] getParam  0 --   (null)
2021-08-31 16:40:11.214721+0800 SQCombineRequestDemo[55196:670369] will start    1
2021-08-31 16:40:11.214999+0800 SQCombineRequestDemo[55196:670369] getParam  1 --   (null)
2021-08-31 16:40:11.217880+0800 SQCombineRequestDemo[55196:670369] will start    2
2021-08-31 16:40:11.218077+0800 SQCombineRequestDemo[55196:670369] getParam  2 --   (null)
2021-08-31 16:40:11.867361+0800 SQCombineRequestDemo[55196:670369] success    2
2021-08-31 16:40:11.904609+0800 SQCombineRequestDemo[55196:670369] success    0
2021-08-31 16:40:11.905174+0800 SQCombineRequestDemo[55196:670369] success    1
2021-08-31 16:40:11.905373+0800 SQCombineRequestDemo[55196:670369] batchRequest success
```
##4、组合使用

![image.png](https://upload-images.jianshu.io/upload_images/3150123-f24a0d8fe563b0e0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



图中b c d作为item添加到上面灰色串行网络中，e f g作为item添加到下面灰色串行网络中， 两个灰色又作为item加入到黄色的并行网络中。绿色跟黄色又作为item加入到蓝色串行网络中。

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
