# react-native-wechat-opensdk

微信开放平台SDK，支持 Expo / ReactNative 0.80+ ，使用 Typescript + Swift + Kotlin

## Installation

1. 安装 npm 包
```sh
npm install react-native-wechat-opensdk
or
yarn add react-native-wechat-opensdk
```

2. 配置安卓 / Android
   - 2.1 展开目录到 android/app/src/main/java/YOUR_PACKAGE，也就是 MainApplication.kt 同级
   - 2.2 新建 wxapi 目录
   - 2.3 新建 `WXEntryActivity.kt` 文件并粘贴以下代码，更改 YOUR_PACKAGE 为你的真实APP的包名
   ```kotlin
     // 更改后示例 package com.my.rn.wxapi，即 YOUR_PACKGE=com.my.rn
     package YOUR_PACKAGE.wxapi

     import android.app.Activity
     import android.os.Bundle
     import YOUR_PACKAGE.wxapi.WechatModule.Companion.handleWXIntent

      class WXEntryActivity : Activity() {
        override fun onCreate(savedInstanceState: Bundle?) {
          super.onCreate(savedInstanceState)
          handleWXIntent(intent)
          finish()
        }
      }
   ```
   - 2.4 新建 `WXPayEntryActivity.kt` 文件并粘贴以下代码，更改 YOUR_PACKAGE 为你的真实APP的包名
   ```kotlin
     // 更改后示例 package com.my.rn.wxapi，即 YOUR_PACKAGE=com.my.rn
     package YOUR_PACKAGE.wxapi

     import android.app.Activity
     import android.os.Bundle
     import YOUR_PACKAGE.wxapi.WechatModule.Companion.handleWXIntent

      class WXPayEntryActivity : Activity() {
        override fun onCreate(savedInstanceState: Bundle?) {
          super.onCreate(savedInstanceState)
          handleWXIntent(intent)
          finish()
        }
      }
   ```
   - 2.5 更改 AndroidManifest.xml，添加以下配置，注意替换 YOUR_PACKAGE
   ```xml
    <manifest>
    ...
       <application>
        <activity android:name=".wxapi.WXEntryActivity" android:label="@string/app_name" android:theme="@android:style/Theme.Translucent.NoTitleBar" android:exported="true" android:taskAffinity="YOUR_PACKAGE" android:launchMode="singleTask"/>
        <activity android:name=".wxapi.WXPayEntryActivity" android:label="@string/app_name" android:theme="@android:style/Theme.Translucent.NoTitleBar" android:exported="true" android:taskAffinity="YOUR_PACKAGE" android:launchMode="singleTask"/>
       </application>
    </manifest>
    ```

3. 配置苹果 / iOS
 - 3.0 以下出现 APP_NAME 的地方都为你真实APP的名字
 - 3.1 项目根目录下执行 npx pod-install，安装所需SDK
 - 3.2 编辑 OC 和 Swift 的桥接头文件 ios/APP_NAME/APP_NAME-Bridging-Header.h，添加一行
  ```
   #import <WXApi.h>
  ```
 - 3.3 编辑 `ios/AppDelegate.swift` 添加如下代码，改好的文件看起来像是这样 [AppDelegate.swift](https://github.com/yybawang/react-native-wechat-opensdk/blob/master/example/ios/WechatOpensdkExample/AppDelegate.swift)
 ```swift
 public class AppDelegate: ExpoAppDelegate {

  // others
  ...




  // 包裹在此 class 下，添加以下代码 MARK: - URL Handling for WeChat Callbacks
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return WXApi.handleOpen(url, delegate: self)
  }

  func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
    return WXApi.handleOpen(url, delegate: self)
  }

  // For iOS 9.0+
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    return WXApi.handleOpen(url, delegate: self)
  }

  // Universal Links support
  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    return WXApi.handleOpenUniversalLink(userActivity, delegate: self)
  }
 }

 /**
 放到文件底部，最外层，无需包裹到 class 下
 继承微信开放平台
 */
extension AppDelegate: WXApiDelegate{
  func onReq(_ req: BaseReq) {
    NSLog("AppDelegate 收到 onReq")
    // 发送通知给 WechatOpensdk 模块
    NotificationCenter.default.post(
      name: NSNotification.Name("WechatOpensdkReq"),
      object: nil,
      userInfo: ["req": req]
    )
  }

  func onResp(_ resp: BaseResp) {
    NSLog("AppDelegate 收到 onResp")
    // 发送通知给 WechatOpensdk 模块
    NotificationCenter.default.post(
      name: NSNotification.Name("WechatOpensdkResp"),
      object: nil,
      userInfo: ["resp": resp]
    )
  }
}

 ```



## 使用 / Usage

### 1. 引入
`import Wechat from 'react-native-wechat-opensdk';`

### 2. 先测试是否可以正常使用
```js
// 自带有个示例方法，以测试是否正常引入
const result = multiply(3, 7);

// 检测微信SDK，测试是否正常返回 true
const ok = await Wechat.isAppInstalled();

// 测试 ok 之后，直接注册即可，👆上面的两行测试代码就可以删掉了
// 注册微信APP SDK
const ok = await Wechat.registerApp('wx1ad80ac9a07dceef', 'https://app.YOUR_DOMAIN.com/api/');
```



## 暴露出的微信SDK方法实例

### 微信登录
#### auth: (data: AuthProps) => Promise<AuthResult>;
```typescript
const result = await Wechat.auth({
  scope: "snsapi_userinfo",
  state: "123456",
})
```

### 分享文件
##### shareFile: (data: ShareFileProps) => Promise<ShareResult>;
```typescript
const result = await Wechat.shareFile({
  url: "https://example.com/example.md",
  title: "What's this",
});
```

### 分享文字
#### shareText: (data: ShareTextProps) => Promise<ShareResult>;
```typescript
const result = await Wechat.shareText({
  text: "Example",
});
```

### 分享网页
#### shareWebpage: (data: ShareWebpageProps) => Promise<ShareResult>;
```typescript
const result = await Wechat.shareWebpage({
  webpageUrl: "https://example.com/example.html",
  text: "Example",
  description: "Example",
  thumbImageUrl: "https://example.com/exmaple.jpg",
});
```

### 分享图片
#### shareImage: (data: ShareImageProps) => Promise<ShareResult>;
```typescript
const result = await Wechat.shareImage({
  imageUrl: "https://example.com/example.html",
});
```

### 分享手机本地图片
#### shareLocalImage: (data: ShareLocalImageProps) => Promise<ShareResult>;
```typescript
const result = await Wechat.shareLocalImage({
  imageUrl: "file:///data/0/example.jpg",
});
```

### 分享视频
#### shareVideo: (data: ShareVideoProps) => Promise<ShareResult>;
```typescript
const result = await Wechat.shareVideo({
  videoUrl: "file:///data/0/example.jpg",
  title: "Example",
  description: "Example",
  thumbImageUrl: "https://example.com/exmaple.jpg",
});
```

### 分享音乐
#### shareMusic: (data: ShareMusicProps) => Promise<ShareResult>;
```typescript
const result = await Wechat.shareMusic({
  musicUrl: "file:///data/0/example.mp3",
  title: "Example",
  description: "Example",
  thumbImageUrl: "https://example.com/exmaple.jpg",
});
```

### 分享小程序
#### shareMiniProgram: (data: ShareMiniProgramProps) => Promise<ShareResult>;
```typescript
const result = await Wechat.shareMiniProgram({
  userName: "gh_da6b5558d7xx",
  path: "pages/index/index?foo=bar",
  title: "Example",
  description: "Example",
  hdImageUrl: "https://example.com/exmaple.jpg",
  webpageUrl: "https://example.com/exmaple.html", // 必传的，指向官网即可
});
```

### 启动小程序
#### launchMiniProgram: (data: LaunchMiniProgramProps) => Promise<void>;
```typescript
const result = await Wechat.launchMiniProgram({
  userName: "gh_da6b5558d7xx",
  path: "pages/index/index?foo=bar",
});
```

### 微信支付
#### pay: (data: PayProps) => Promise<PayResult>;
```typescript
const sign = "后端接口算签对象"

const result = await Wechat.pay({
  partnerId: sign.partnerid,
  prepayId: sign.prepayid,
  nonceStr: sign.noncestr,
  timeStamp: sign.timestamp,
  package: sign.package,
  sign: sign.sign,
});
```

### 微信客服
#### customerService: (data: CustomerServiceProps) => Promise<void>;
```typescript
const result = await Wechat.customerService({
  corpId: "ww2cb4c2fc49d9cbxx",
  url: "https://work.weixin.qq.com/kfid/kfc29e03b97e07cxx"
});
```

### 选择发票
#### chooseInvoice: (data: ChooseInvoiceProps) => Promise<ChooseInvoiceResult>;
```typescript
const result = await Wechat.chooseInvoice({
  cardSign: "cardSign",
  signType: "signType",
  timeStamp: "timeStamp",
  nonceStr: "nonceStr",
});
```








## 致谢
[react-native-wechat-lib](https://github.com/little-snow-fox/react-native-wechat-lib) 感谢 little-snow-fox 一直百忙中抽空维护，使我在之前的RN开发中节省了不少开发时间


## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
