#import <WechatOpensdkSpec/WechatOpensdkSpec.h>

#import <React/RCTBridgeModule.h>
#import <React/RCTImageLoader.h>
#import <React/RCTEventDispatcher.h>
#import <WechatOpenSDK/WXApi.h>
#import <WechatOpenSDK/WXApiObject.h>


@interface WechatOpensdk : NSObject <NativeWechatOpensdkSpec, WXApiDelegate>

  @property NSString* appId;
  @property RCTPromiseResolveBlock resolver;
  @property RCTPromiseRejectBlock rejecter;


@end
