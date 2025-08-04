#import "WechatOpensdk.h"

@interface WechatOpensdk ()

@end

@implementation WechatOpensdk
RCT_EXPORT_MODULE()

- (NSNumber *)multiply:(double)a b:(double)b {
    NSNumber *result = @(a * b);

    return result;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURL:) name:@"RCTOpenURLNotification" object:nil];
        // 添加微信响应通知监听器
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWechatResp:) name:@"WechatOpensdkResp" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)handleOpenURL:(NSNotification *)aNotification
{
    NSString * aURLString =  [aNotification userInfo][@"url"];
    NSURL * aURL = [NSURL URLWithString:aURLString];

    if ([WXApi handleOpenURL:aURL delegate:self])
    {
        return YES;
    } else {
        return NO;
    }
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

/**
 首次注册微信
 */
- (void)registerApp:(NSString *)appid universalLink:(NSString *)universalLink resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {

  // 开启微信SDK日志，如果遇到一些失败的话
//  [WXApi startLogByLevel:WXLogLevelDetail logBlock:^(NSString *log) {
//      NSLog(@"WeChatSDK Log: %@", log);
//  }];

  NSLog(@"微信 registerApp %@", appid);
  self.appId = appid;
  BOOL OK = [WXApi registerApp:appid universalLink:universalLink];
  NSLog(@"微信 registerApp 返回值 %d", OK);

  // 调用自检函数，如果遇到一些失败的话
//  [WXApi checkUniversalLinkReady:^(WXULCheckStep step, WXCheckULStepResult* result) {
//      NSLog(@"微信自检 %@, %u, %@, %@", @(step), result.success, result.errorInfo, result.suggestion);
//  }];

  resolve(OK ? @(1) : @(0));
}

/**
 是否安装了微信
 */
- (void)isAppInstalled:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    resolve([WXApi isWXAppInstalled] ? @(1) : @(0));
}

/**
 打开微信APP
 */
- (void)openApp:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  if(![WXApi openWXApp]) {
    NSLog(@"微信旧SDK打开微信失败，退回到新API");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"] options:@{} completionHandler:nil];
  }
  resolve(nil);
}


//RCT_EXPORT_METHOD(sendRequest:(NSString *)openid resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
//  BaseReq* req = [[BaseReq alloc] init];
//  req.openID = openid;
//
//  [WXApi sendReq:req completion:^(BOOL completion){
//    completion ? resolve(nil) : reject(@"ERROR", @"SDK Error", nil);
//  }];
//}
//
//RCT_EXPORT_METHOD(sendSuccessResponse:resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
//  BaseResp* resp = [[BaseResp alloc] init];
//  resp.errCode = WXSuccess;
//
//  [WXApi sendResp:resp completion:^(BOOL completion){
//    completion ? resolve(nil) :reject(@"ERROR", @"SDK Error", nil);
//  }];
//}
//
//RCT_EXPORT_METHOD(sendErrorCommonResponse:(NSString *)message resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
//    BaseResp* resp = [[BaseResp alloc] init];
//    resp.errCode = WXErrCodeCommon;
//    resp.errStr = message;
//
//    [WXApi sendResp:resp completion:^(BOOL completion){
//      completion ? resolve(nil) :reject(@"ERROR", @"SDK Error", nil);
//    }];
//}
//
//RCT_EXPORT_METHOD(sendErrorUserCancelResponse:(NSString *)message resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
//    BaseResp* resp = [[BaseResp alloc] init];
//    resp.errCode = WXErrCodeUserCancel;
//    resp.errStr = message;
//
//
//    [WXApi sendResp:resp completion:^(BOOL completion){
//      completion ? resolve(nil) :reject(@"ERROR", @"SDK Error", nil);
//    }];
//}



/**
 微信授权
 */
- (void)auth:(JS::NativeWechatOpensdk::AuthProps &)data resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    self.resolver = resolve;
    self.rejecter = reject;
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = data.scope();
    req.state = data.state();

    [WXApi sendReq:req completion:^(BOOL completion){
//        completion ? resolve(nil) : reject(@"ERROR", @"SDK Error", nil);
    }];
}

/**
 分享文件
 */
- (void)shareFile:(JS::NativeWechatOpensdk::ShareFileProps &)data resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    self.resolver = resolve;
    self.rejecter = reject;
    NSString *url = data.url();
    WXFileObject *file =  [[WXFileObject alloc] init];
    file.fileExtension = data.ext();
    NSData *fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString: url]];
    file.fileData = fileData;

    WXMediaMessage *message = [WXMediaMessage message];
    message.title = data.title();
    message.mediaObject = file;

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    auto scene = data.scene();
    req.scene = scene.has_value() ? (int)scene.value() : 0;

    [WXApi sendReq:req completion:^(BOOL completion){
//        completion ? resolve(nil) : reject(@"ERROR", @"SDK Error", nil);
    }];
}

// 分享文字
- (void)shareText:(JS::NativeWechatOpensdk::ShareTextProps &)data resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    self.resolver = resolve;
    self.rejecter = reject;
    NSString *text = data.text();
    if (text == NULL || [text isEqual:@""]) {
        reject(@"ERROR", @"shareText: The value of text cannot be empty.", nil);
        return;
    }

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = YES;
    req.text = text;
    auto scene = data.scene();
    req.scene = scene.has_value() ? (int)scene.value() : 0;

    [WXApi sendReq:req completion:^(BOOL completion){
//        completion ? resolve(nil) : reject(@"ERROR", @"SDK Error", nil);
    }];
}

// 分享图片
- (void)shareImage:(JS::NativeWechatOpensdk::ShareImageProps &)data resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    self.resolver = resolve;
    self.rejecter = reject;
    NSString *imageUrl = data.imageUrl();
    if (imageUrl == NULL  || [imageUrl isEqual:@""]) {
      reject(@"ERROR", @"shareImage: The value of ImageUrl cannot be empty.", nil);
      return;
    }

    // 根据路径下载图片
    UIImage *image = [self getImageFromURL:imageUrl];
    // 从 UIImage 获取图片数据
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    // 用图片数据构建 WXImageObject 对象
    WXImageObject *imageObject = [WXImageObject object];
    imageObject.imageData = imageData;

    WXMediaMessage *message = [WXMediaMessage message];
    // 利用原图压缩出缩略图，确保缩略图大小不大于32KB
    message.thumbData = [self compressImage: image toByte:32678];
    message.mediaObject = imageObject;

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    auto scene = data.scene();
    req.scene = scene.has_value() ? (int)scene.value() : 0;

    [WXApi sendReq:req completion:^(BOOL completion){
//        completion ? resolve(nil) : reject(@"ERROR", @"SDK Error", nil);
    }];
}

// 分享本地图片
- (void)shareLocalImage:(JS::NativeWechatOpensdk::ShareLocalImageProps &)data resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    self.resolver = resolve;
    self.rejecter = reject;
    NSString *imageUrl = data.imageUrl();
    if (imageUrl == NULL  || [imageUrl isEqual:@""]) {
    reject(@"ERROR", @"shareImage: The value of ImageUrl cannot be empty.", nil);
      return;
    }

    // 根据路径下载图片
    UIImage *image = [UIImage imageWithContentsOfFile:imageUrl];
    // 从 UIImage 获取图片数据
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    // 用图片数据构建 WXImageObject 对象
    WXImageObject *imageObject = [WXImageObject object];
    imageObject.imageData = imageData;

    WXMediaMessage *message = [WXMediaMessage message];
    // 利用原图压缩出缩略图，确保缩略图大小不大于32KB
    message.thumbData = [self compressImage: image toByte:32678];
    message.mediaObject = imageObject;

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    auto scene = data.scene();
    req.scene = scene.has_value() ? (int)scene.value() : 0;

    [WXApi sendReq:req completion:^(BOOL completion){
//        completion ? resolve(nil) : reject(@"ERROR", @"SDK Error", nil);
    }];
}

// 分享音乐
- (void)shareMusic:(JS::NativeWechatOpensdk::ShareMusicProps &)data resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    self.resolver = resolve;
    self.rejecter = reject;
    WXMusicObject *musicObject = [WXMusicObject object];
    musicObject.musicUrl = data.musicUrl();
    musicObject.musicLowBandUrl = data.musicLowBandUrl();
    musicObject.musicDataUrl = data.musicDataUrl();
    musicObject.musicLowBandDataUrl = data.musicLowBandDataUrl();

    WXMediaMessage *message = [WXMediaMessage message];
    message.title = data.title();
    message.description = data.description();
    NSString *thumbImageUrl = data.thumbImageUrl();
    if (thumbImageUrl != NULL && ![thumbImageUrl isEqual:@""]) {
      // 根据路径下载图片
      UIImage *image = [self getImageFromURL:thumbImageUrl];
      message.thumbData = [self compressImage: image toByte:32678];
    }
    message.mediaObject = musicObject;
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    auto scene = data.scene();
    req.scene = scene.has_value() ? (int)scene.value() : 0;

    [WXApi sendReq:req completion:^(BOOL completion){
//        completion ? resolve(nil) : reject(@"ERROR", @"SDK Error", nil);
    }];
}

// 分享视频
- (void)shareVideo:(JS::NativeWechatOpensdk::ShareVideoProps &)data resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    self.resolver = resolve;
    self.rejecter = reject;
    WXVideoObject *videoObject = [WXVideoObject object];
    videoObject.videoUrl = data.videoUrl();
    videoObject.videoLowBandUrl = data.videoLowBandUrl();
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = data.title();
    message.description = data.description();
    NSString *thumbImageUrl = data.thumbImageUrl();
    if (thumbImageUrl != NULL && ![thumbImageUrl isEqual:@""]) {
      UIImage *image = [self getImageFromURL:thumbImageUrl];
      message.thumbData = [self compressImage: image toByte:32678];
    }
    message.mediaObject = videoObject;
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    auto scene = data.scene();
    req.scene = scene.has_value() ? (int)scene.value() : 0;

    [WXApi sendReq:req completion:^(BOOL completion){
//        completion ? resolve(nil) : reject(@"ERROR", @"SDK Error", nil);
    }];
}

// 分享网页
- (void)shareWebpage:(JS::NativeWechatOpensdk::ShareWebpageProps &)data resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    self.resolver = resolve;
    self.rejecter = reject;
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = data.webpageUrl();
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = data.title();
    message.description = data.description();
    NSString *thumbImageUrl = data.thumbImageUrl();
    if (thumbImageUrl != NULL && ![thumbImageUrl isEqual:@""]) {
      UIImage *image = [self getImageFromURL:thumbImageUrl];
      message.thumbData = [self compressImage: image toByte:32678];
    }
    message.mediaObject = webpageObject;
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    auto scene = data.scene();
    req.scene = scene.has_value() ? (int)scene.value() : 0;

    [WXApi sendReq:req completion:^(BOOL completion){
//        completion ? resolve(nil) : reject(@"ERROR", @"SDK Error", nil);
    }];
}

// 分享小程序
- (void)shareMiniProgram:(JS::NativeWechatOpensdk::ShareMiniProgramProps &)data resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    self.resolver = resolve;
    self.rejecter = reject;
    WXMiniProgramObject *object = [WXMiniProgramObject object];
    object.webpageUrl = data.webpageUrl();
    object.userName = data.userName();
    object.path = data.path();
    NSString *hdImageUrl = data.hdImageUrl();
    if (hdImageUrl != NULL && ![hdImageUrl isEqual:@""]) {
      UIImage *image = [self getImageFromURL:hdImageUrl];
      // 压缩图片到小于128KB
      object.hdImageData = [self compressImage: image toByte:131072];
    }
    object.withShareTicket = data.withShareTicket();
    auto miniProgramType = data.miniProgramType();
    int miniProgramTypeValue = miniProgramType.has_value() ? (int)miniProgramType.value() : 0;
    object.miniProgramType = [self integerToWXMiniProgramType:miniProgramTypeValue];
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = data.title();
    message.description = data.description();
    //兼容旧版本节点的图片，小于32KB，新版本优先
    //使用WXMiniProgramObject的hdImageData属性
    NSString *thumbImageUrl = data.thumbImageUrl();
    if (thumbImageUrl != NULL && ![thumbImageUrl isEqual:@""]) {
      UIImage *image = [self getImageFromURL:thumbImageUrl];
      message.thumbData = [self compressImage: image toByte:32678];
    }
    message.mediaObject = object;
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    auto scene = data.scene();
    req.scene = scene.has_value() ? (int)scene.value() : 0;

    [WXApi sendReq:req completion:^(BOOL completion){
//        completion ? resolve(nil) : reject(@"ERROR", @"SDK Error", nil);
    }];
}

/**
 启动小程序
 */
- (void)launchMiniProgram:(JS::NativeWechatOpensdk::LaunchMiniProgramProps &)data resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    self.resolver = resolve;
    self.rejecter = reject;
    WXLaunchMiniProgramReq *launchMiniProgramReq = [WXLaunchMiniProgramReq object];
    // 拉起的小程序的username
    launchMiniProgramReq.userName = data.userName();
    // 拉起小程序页面的可带参路径，不填默认拉起小程序首页
    launchMiniProgramReq.path = data.path();
    // 拉起小程序的类型
    auto miniProgramType = data.miniProgramType();
    int miniProgramTypeValue = miniProgramType.has_value() ? (int)miniProgramType.value() : 0;
    launchMiniProgramReq.miniProgramType = [self integerToWXMiniProgramType:miniProgramTypeValue];

    [WXApi sendReq:launchMiniProgramReq completion:^(BOOL completion){
//        completion ? resolve(nil) : reject(@"ERROR", @"SDK Error", nil);
    }];
}

/**
 一次性订阅消息
 */
- (void)subscribeMessage:(NSDictionary *)data resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    self.resolver = resolve;
    self.rejecter = reject;
    WXSubscribeMsgReq *req = [[WXSubscribeMsgReq alloc] init];
    req.scene = [data[@"scene"] integerValue];
    req.templateId = data[@"templateId"];
    req.reserved = data[@"reserved"];

    [WXApi sendReq:req completion:^(BOOL completion){
//        completion ? resolve(nil) : reject(@"ERROR", @"SDK Error", nil);
    }];
}

/**
 微信支付
 */
- (void)pay:(JS::NativeWechatOpensdk::PayProps &)data resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    self.resolver = resolve;
    self.rejecter = reject;
    PayReq* req             = [PayReq new];
    req.partnerId           = data.partnerId();
    req.prepayId            = data.prepayId();
    req.nonceStr            = data.nonceStr();
    req.timeStamp           = [data.timeStamp() longLongValue];
    req.package             = data.package();
    req.sign                = data.sign();


    [WXApi sendReq:req completion:^(BOOL completion){
//        completion ? resolve(nil) : reject(@"ERROR", @"SDK Error", nil);
    }];
}

// 选择发票
- (void)chooseInvoice:(JS::NativeWechatOpensdk::ChooseInvoiceProps &)data resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    self.resolver = resolve;
    self.rejecter = reject;
    WXChooseInvoiceReq *req = [[WXChooseInvoiceReq alloc] init];
    req.appID = self.appId;
    auto timeStamp = data.timeStamp();
    req.timeStamp = timeStamp.has_value() ? (int)timeStamp.value() : 0;
    req.nonceStr = data.nonceStr();
    req.cardSign = data.cardSign();
    req.signType = data.signType();

    [WXApi sendReq:req completion:^(BOOL completion){
//        completion ? resolve(nil) : reject(@"ERROR", @"SDK Error", nil);
    }];
}


/**
 唤醒客服
 */
- (void)customerService:(JS::NativeWechatOpensdk::CustomerServiceProps &)data resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    self.resolver = resolve;
    self.rejecter = reject;
    WXOpenCustomerServiceReq *req = [[WXOpenCustomerServiceReq alloc] init];
    req.corpid = data.corpId();
    req.url = data.url();


    [WXApi sendReq:req completion:^(BOOL completion){
//        completion ? resolve(nil) : reject(@"ERROR", @"SDK Error", nil);
    }];
}






// 获取网络图片的公共方法
- (UIImage *)getImageFromURL:(NSString *)fileURL {
    UIImage *result;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    return result;
}

- (void)getImageFromURL:(NSString *)fileURL completion:(void (^)(UIImage *image))completion {
    NSURL *url = [NSURL URLWithString:fileURL];
    NSURLSessionDataTask *downloadImageTask = [[NSURLSession sharedSession]
        dataTaskWithURL:url
      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
          if (error) {
              NSLog(@"Error downloading image: %@", error.localizedDescription);
              dispatch_async(dispatch_get_main_queue(), ^{
                  completion(nil);
              });
              return;
          }

          UIImage *downloadedImage = [UIImage imageWithData:data];
          dispatch_async(dispatch_get_main_queue(), ^{
              completion(downloadedImage);
          });
      }];

    [downloadImageTask resume];
}

// 压缩图片
- (NSData *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength {
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return data;

    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength) return data;

    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
            (NSUInteger)(resultImage.size.height * sqrtf(ratio)));  // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
    }

    if (data.length > maxLength) {
        return [self compressImage:resultImage toByte:maxLength];
    }

    return data;
}

-(WXMiniProgramType) integerToWXMiniProgramType:(int)value {
    WXMiniProgramType type = WXMiniProgramTypeRelease;
    switch (value) {
        case 0:
            type = WXMiniProgramTypeRelease;
            break;
        case 1:
            type = WXMiniProgramTypeTest;
            break;
        case 2:
            type = WXMiniProgramTypePreview;
            break;
    }
    return type;
}




// 处理来自 AppDelegate 的微信响应通知
- (void)handleWechatResp:(NSNotification *)notification {
    BaseResp *resp = [notification.userInfo objectForKey:@"resp"];
    if (resp) {
        [self onResp:resp];
    }
}

#pragma mark - wx callback

-(void) onReq:(BaseReq*)req
{
  NSLog(@"收到 onReq");
//    if ([req isKindOfClass:[LaunchFromWXReq class]]) {
//        LaunchFromWXReq *launchReq = req;
//        NSString *appParameter = launchReq.message.messageExt;
//        NSMutableDictionary *body = @{@"errCode":@0}.mutableCopy;
//        body[@"type"] = @"LaunchFromWX.Req";
//        body[@"lang"] =  launchReq.lang;
//        body[@"country"] = launchReq.country;
//        body[@"extMsg"] = appParameter;
//    }
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        SendMessageToWXResp *r = (SendMessageToWXResp *)resp;

        NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
        body[@"errStr"] = r.errStr;
        body[@"lang"] = r.lang;
        body[@"country"] = r.country;
        resp.errCode == WXSuccess ? self.resolver(body) : self.rejecter(@"ERROR", resp.errStr, nil);
    }else if ([resp isKindOfClass:[SendAuthResp class]]) {
      NSLog(@"SendAuthResp OK");
        SendAuthResp *r = (SendAuthResp *)resp;
        NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
        body[@"errStr"] = r.errStr;
        body[@"state"] = r.state;
        body[@"lang"] = r.lang;
        body[@"country"] = r.country;

        if (resp.errCode == WXSuccess) {
            if (self.appId && r) {
                // ios第一次获取不到appid会卡死，加个判断OK
                [body addEntriesFromDictionary:@{@"appid":self.appId, @"code":r.code}];
                self.resolver(body);
            }
        }
        else {
            self.rejecter(@"ERROR", resp.errStr, nil);
        }
    } else if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *r = (PayResp *)resp;
        NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
        body[@"errStr"] = r.errStr;
        body[@"type"] = @(r.type);
        body[@"returnKey"] = r.returnKey;
        resp.errCode == WXSuccess ? self.resolver(body) : self.rejecter(@"ERROR", resp.errStr, nil);
    } else if ([resp isKindOfClass:[WXLaunchMiniProgramResp class]]){
        WXLaunchMiniProgramResp *r = (WXLaunchMiniProgramResp *)resp;
        NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
        body[@"errStr"] = r.errStr;
        body[@"extMsg"] = r.extMsg;
        resp.errCode == WXSuccess ? self.resolver(body) : self.rejecter(@"ERROR", resp.errStr, nil);
    } else if ([resp isKindOfClass:[WXChooseInvoiceResp class]]){
        WXChooseInvoiceResp *r = (WXChooseInvoiceResp *)resp;
        NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
        body[@"errStr"] = r.errStr;
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (WXCardItem* cardItem in r.cardAry) {
            NSMutableDictionary *item = @{@"cardId":cardItem.cardId,@"encryptCode":cardItem.encryptCode,@"appId":cardItem.appID}.mutableCopy;
            [arr addObject:item];
        }
        body[@"cards"] = arr;
        resp.errCode == WXSuccess ? self.resolver(body) : self.rejecter(@"ERROR", resp.errStr, nil);
    }
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeWechatOpensdkSpecJSI>(params);
}

@end
