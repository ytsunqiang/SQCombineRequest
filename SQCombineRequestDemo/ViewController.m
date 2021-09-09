//
//  ViewController.m
//  SQCombineRequestDemo
//
//  Created by 孙强 on 2021/8/8.
//

#import "ViewController.h"
#import "SQCombineRequest.h"
#import <AFNetworking.h>

static NSUInteger flag = 0;

@interface ViewController ()


@property (nonatomic, strong) SQCombineChainRequest *chainRequest;

@property (nonatomic, strong) SQCombineBatchRequest *batchRequest;

@end

@implementation ViewController

- (SQCombineRequestItem *)createItemWithKey:(NSString *)key {
    //创建网络请求
    SQCombineRequestItem *item = [[SQCombineRequestItem alloc] init];
    //将要开始
    item.requestWillStart = ^(SQCombineRequestItem *requestItem) {
        NSLog(@"will start    %@", key);
    };
    //获取网络请求参数
    item.requestParam = ^NSDictionary *(NSDictionary *data){
        NSLog(@"getParam   %@  %@",key, data);
        return @{@"q": @"你好"};
    };
    //网络的url
    item.url = @"https://dict.youdao.com/jsonapi";
    //网络请求方式
    item.method = SQCRNetMethodGet;
    //成功回调
    item.successBlock = ^(id data, SQCombineRequestResult *result) {
        result.dataToNextRequest = @{key: key};
        NSLog(@"success   %@", key);
    };
    //失败回调
    item.failBlock = ^(id error) {
        NSLog(@"fail    %@", key);
    };
    return item;
}


- (void)testCombineRequest {
    SQCombineRequestItem *a = [self createItemWithKey:@"a"];
    
    SQCombineChainRequest *bcd = [[SQCombineChainRequest alloc] init];
    for (NSString *key in @[@"b", @"c", @"d"]) {
        [bcd addRequest:[self createItemWithKey:key]];
    }
    bcd.successBlock = ^(id data, SQCombineRequestResult *result) {
        NSLog(@"bcd success");
    };
    
    SQCombineChainRequest *efg = [[SQCombineChainRequest alloc] init];
    for (NSString *key in @[@"e", @"f", @"g"]) {
        [efg addRequest:[self createItemWithKey:key]];
    }
    efg.successBlock = ^(id data, SQCombineRequestResult *result) {
        NSLog(@"efg success");
    };
    
    SQCombineBatchRequest *batch = [[SQCombineBatchRequest alloc] init];
    [batch addRequests:@[bcd, efg]];
    
    self.chainRequest = [[SQCombineChainRequest alloc] init];
    [self.chainRequest addRequest:a];
    [self.chainRequest addRequest:batch];
    self.chainRequest.successBlock = ^(id data, SQCombineRequestResult *result) {
        NSLog(@"self.chainRequest success");
    };
    
    [self.chainRequest start];
    
    
}

- (void)testBatchRequest {
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
    
}

- (void)testChainRequest {
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
}

- (void)testSingleRequest {
    //创建网络请求
    SQCombineRequestItem *item = [self createItemWithKey:@"single"];
    //开始请求
    [item start];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //组合执行为先执行a, bcd顺序执行,efg顺序执行,bcd与efg并行执行
    NSArray *titles = @[@"单个网络", @"顺序执行", @"并行执行", @"组合执行"];
    for (int i = 0; i < titles.count; i ++ ) {
        NSString *title = titles[i];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100 * (i + 1), 200, 50)];
        button.backgroundColor = UIColor.orangeColor;
        [button setTitle:title forState:UIControlStateNormal];
        button.tag = i;
        [button addTarget:self action:@selector(testRequest:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)testRequest:(UIButton *)button {
    switch (button.tag) {
        case 0:
            [self testSingleRequest];
            break;
        case 1:
            [self testChainRequest];
            break;
        case 2:
            [self testBatchRequest];
            break;
        case 3:
            [self testCombineRequest];
            break;
        default:
            break;
    }
    
}


@end
