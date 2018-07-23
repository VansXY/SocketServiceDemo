//
//  ViewController.m
//  socketService
//
//  Created by 肖扬 on 2018/7/23.
//  Copyright © 2018年 肖扬. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

@interface ViewController ()<GCDAsyncSocketDelegate> {
    BOOL needConnect;
    BOOL isSelected;
}
/**
 socket
 */
@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (weak, nonatomic) IBOutlet UITextView *sendMessageLabel;
@property (weak, nonatomic) IBOutlet UITextView *recMessageLabel;
/**
 receive
 */
@property (nonatomic, strong) NSString *receiveText;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    isSelected = NO;
    [self getConnection];
//    [self acceptSocket];
}

/// 可以用来建立一个socket服务端，指定一个端口号，LocalHost为ip
//- (void)acceptSocket {

/*
 1.手机开热点(谁当服务端 host就写谁的ip地址)
 
 2.开热点的手机称为服务端  连接此热点的其他手机称为客户端
 
 3.GCDAsyncSocket这个类采用的是TCP连接 由于要经历3次握手 耗时一点 故实效性不高
 有时间我会继续学习一下GCDAsyncUdpSocket这个类 采用的是UDP 实效性好一点
 
 4.scoket还是很强大的 从它的代理方法中 就可以知道服务端和客户端是可以进行交互的
 
 PS:iPhone手机
 
 本Demo为服务端Demo
 
 配合学习请看客户端Demo
 */
//    BOOL result = [self.serverSocket acceptOnPort:8000 error:&error];
//    if (result) {
//        //开放成功
//        NSLog(@"开放成功");
//    }else{
//        //开放失败
//        NSLog(@"开放失败");
//    }
//}


- (IBAction)SetConnectButton:(id)sender {
    [self getConnection];
}
- (IBAction)SendMessageButton:(id)sender {
//    [_socket writeData:[_sendMessageLabel.text dataUsingEncoding:NSUTF8StringEncoding] withTimeout:20.0 tag:1];
    NSLog(@"_sendMessageLabel = %@", _sendMessageLabel.text);
    [self.socket writeData:[_sendMessageLabel.text dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
}



static NSString *hostAddress = @"172.17.88.210";
static int hostPort = 8000;

//判断是否是连接的状态
-(BOOL)isConnected {
    return _socket.isConnected;
}

//断开连接
-(void)disConnect {
    needConnect = NO;
    [_socket disconnect];
}

//取得连接
-(void)getConnection {
    if (![_socket isConnected]) {
        [self disConnect];
        [self setupConnection];
    }
}

//建立连接
-(NSError *)setupConnection {
    if (nil == _socket)
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *err = nil;
    NSLog(@"IP: %@, port:%i", hostAddress, hostPort);
    if (![_socket connectToHost:hostAddress  onPort:hostPort error:&err]) {
        NSLog(@"Connection error : %@",err);
    } else {
        err = nil;
    }
    needConnect = YES;
    return err;
}

-(void)sendCMD {
    [self getConnection];
    NSString* cmd = @"BBBB1,zzc,202cb962ac59075b964b07152d234b70,201304182033EEEE\n";
    NSData *data = [cmd dataUsingEncoding:NSUTF8StringEncoding];
    [_socket writeData:data withTimeout:20 tag:1];
}

// MARK: socket代理
//socket连接成功后的回调代理
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"onSocket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    [self listenData];
}

//socket连接断开后的回调代理
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    [_socket disconnect];
}

//socket发送消息成功的回调
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"发送成功：%ld", tag);
}

//读到数据后的回调代理
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"receive datas from method 1");
    _receiveText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
//    NSError *error = nil;
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONWritingPrettyPrinted) error:&error];
//    if (error) {
//        NSLog(@"error = %@", error);
//    } else {
        _recMessageLabel.text = _receiveText;
//    }
    [self listenData];
}


//发起一个读取的请求，当收到数据时后面的didReadData才能被回调
-(void)listenData {
    /*
     防止粘包问题的几个方法：
     
     1、消息定长，例如每个报文的大小为固定长度200字节,如果不够，空位补空格；
     [_socket readDataToLength:<#(NSUInteger)#> withTimeout:<#(NSTimeInterval)#> tag:<#(long)#>]
     
     2、在包尾增加回车换行符进行分割，例如FTP协议, CRLFData等
     [_socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:<#(NSTimeInterval)#> tag:<#(long)#>]
     
     3、将消息分为消息头和消息体，消息头中包含表示消息总长度（或者消息体长度）的字段，通常设计思路是消息头的第一个字段用int来表示消息的总长度
     */
    [_socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}



@end
