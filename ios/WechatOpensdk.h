#import <WechatOpensdkSpec/WechatOpensdkSpec.h>

#import <React/RCTImageLoader.h>
#import <React/RCTEventDispatcher.h>
#import <WechatOpenSDK/WXApi.h>
#import <WechatOpenSDK/WXApiObject.h>

// define share type constants
#define RCTWXShareTypeNews @"news"
#define RCTWXShareTypeThumbImageUrl @"thumbImage"
#define RCTWXShareTypeImageUrl @"imageUrl"
#define RCTWXShareTypeImageFile @"imageFile"
#define RCTWXShareTypeImageResource @"imageResource"
#define RCTWXShareTypeText @"text"
#define RCTWXShareTypeVideo @"video"
#define RCTWXShareTypeAudio @"audio"
#define RCTWXShareTypeFile @"file"

#define RCTWXShareType @"type"
#define RCTWXShareTitle @"title"
#define RCTWXShareDescription @"description"
#define RCTWXShareWebpageUrl @"webpageUrl"
#define RCTWXShareImageUrl @"imageUrl"

#define RCTWXEventName @"WeChat_Resp"
#define RCTWXEventNameWeChatReq @"WeChat_Req"

@interface WechatOpensdk : NSObject <NativeWechatOpensdkSpec>

  @property NSString* appId;
  @property RCTPromiseResolveBlock resolver;
  @property RCTPromiseRejectBlock rejecter;

@end
