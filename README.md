# SocketServiceDemo

学习使用，包含 socket 服务器和 socket 客户端的demo


```
     防止粘包问题的几个方法：
     
     1、消息定长，例如每个报文的大小为固定长度200字节,如果不够，空位补空格；
     [_socket readDataToLength:<#(NSUInteger)#> withTimeout:<#(NSTimeInterval)#> tag:<#(long)#>]
     
     2、在包尾增加回车换行符进行分割，例如FTP协议, CRLFData等
     [_socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:<#(NSTimeInterval)#> tag:<#(long)#>]
     
     3、将消息分为消息头和消息体，消息头中包含表示消息总长度（或者消息体长度）的字段，通常设计思路是消息头的第一个字段用int来表示消息的总长度
```
     
     
