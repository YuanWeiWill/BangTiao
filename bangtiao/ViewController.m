//
//  ViewController.m
//  bangtiao
//
//  Created by gy on 2018/6/27.
//  Copyright © 2018年 gy. All rights reserved.
//

#define kScreenWidth    [UIScreen mainScreen].bounds.size.width
#define kScreenHeight    [UIScreen mainScreen].bounds.size.Height
#define RATE(x)  ((x)*kScreenWidth/375.f)

#import "ViewController.h"
#import "Masonry.h"
#import <objc/runtime.h>
#import <arpa/inet.h>
#import <netinet/in.h>
#import <sys/socket.h>

@interface Person: NSObject

@end

@implementation Person

- (void)foo {
    NSLog(@"Doing foo");//Person的foo函数
}

@end

@interface ViewController ()<NSStreamDelegate>{
    
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
    int _clientSocket;
}

@property(nonatomic,strong)UIImageView *imageView1;
@property(nonatomic,strong)UIImageView *imageView2;
@property(nonatomic,strong)UIImageView *imageView3;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    
}

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    
    NSLog(@"%@",[NSThread currentThread]);
    
    //  NSStreamEventOpenCompleted = 1UL << 0,    //输入输出流打开完成
    //  NSStreamEventHasBytesAvailable = 1UL << 1,//有字节可读
    //  NSStreamEventHasSpaceAvailable = 1UL << 2,//可以发放字节
    //  NSStreamEventErrorOccurred = 1UL << 3,    //连接出现错误
    //  NSStreamEventEndEncountered = 1UL << 4    //连接结束
    
    switch(eventCode) {
            
        case NSStreamEventOpenCompleted:
            
            NSLog(@"输入输出流打开完成");
            
            break;
            
        case NSStreamEventHasBytesAvailable:
            
            NSLog(@"有字节可读");
            
            [self readData];
            
            break;
            
        case NSStreamEventHasSpaceAvailable:
            
            NSLog(@"可以发送字节");
            
            break;
            
        case NSStreamEventErrorOccurred:
            
            NSLog(@"连接出现错误");
            
            break;
            
        case NSStreamEventEndEncountered:

            [_inputStream close];
            
            [_outputStream close];
            
            //从主运行循环移除
            
            [_inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            
            [_outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            
            break;
            
        default:
            
            break;
            
    }
}

- (void)connectToHost:(id)sender {
    
    //1.建立连接
    
    NSString *host =@"127.0.0.1";
    int port =12345;
    
    // 定义C语言输入输出流
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)host, port, &readStream, &writeStream);
    
    // 把C语言的输入输出流转化成OC对象
    _inputStream = (__bridge NSInputStream *)(readStream);
    _outputStream = (__bridge NSOutputStream *)(writeStream);
    
    // 设置代理
    _inputStream.delegate = self;
    _outputStream.delegate = self;
    
    // 把输入输入流添加到主运行循环 不添加主运行循环 代理有可能不工作
    [_inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    // 打开输入输出流
    [_inputStream open];
    [_outputStream open];
    
}

- (void)loginBtnClick:(id)sender {

    //登录的指令11
    NSString *loginStr =@"iam:zhangsan";
    
    //把Str转成NSData
    NSData *data =[loginStr dataUsingEncoding:NSUTF8StringEncoding];
    [_outputStream write:data.bytes maxLength:data.length];
    
}

-(void)readData{
    
    //建立一个缓冲区 可以放1024个字节
    uint8_t buf[1024];
    
    //返回实际装的字节数
    NSInteger len = [_inputStream read:buf maxLength:sizeof(buf)];
    
    //把字节数组转化成字符串
    NSData *data =[NSData dataWithBytes:buf length:len];
    
    //从服务器接收到的数据
    NSString *recStr =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",recStr);
    
    [self reloadDataWithText:recStr];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    NSString *text =textField.text;
    
    NSLog(@"%@",text);
    
    //聊天信息
    NSString *msgStr = [NSString stringWithFormat:@"msg:%@",text];
    
    //把Str转成NSData10
    NSData *data =[msgStr dataUsingEncoding:NSUTF8StringEncoding];
    
    //刷新表格
    [self reloadDataWithText:msgStr];
    
    //发送数据
    [_outputStream write:data.bytes maxLength:data.length];
    
    //发送完数据，清空textField
    textField.text =nil;
    
    return YES;
}

-(void)reloadDataWithText:(NSString *)text{
    
//    [self.chatMsgs addObject:text];
//
//    [self.tableView reloadData];
//
//    //数据多，应该往上滚动
//
//    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:self.chatMsgs.count -1inSection:0];
//
//    [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.view endEditing:YES];
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    
    return YES;
}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    if ([NSStringFromSelector(aSelector) isEqualToString:@"foo"]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];//签名，进入forwardInvocation
    }
    
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    SEL sel = anInvocation.selector;
    
    Person *p = [Person new];
    if([p respondsToSelector:sel]){
        [anInvocation invokeWithTarget:p];
    }
    else {
        [self doesNotRecognizeSelector:sel];
    }
    
}

void fooMethod(id obj, SEL _cmd) {
    NSLog(@"Doing foo");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

