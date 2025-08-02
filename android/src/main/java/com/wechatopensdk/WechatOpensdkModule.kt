package com.wechatopensdk

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Environment
import android.util.Base64
import android.util.Log
import androidx.annotation.Nullable
import androidx.core.content.FileProvider
import com.facebook.common.executors.UiThreadImmediateExecutorService
import com.facebook.common.internal.Files
import com.facebook.common.references.CloseableReference
import com.facebook.common.util.UriUtil
import com.facebook.datasource.DataSource
import com.facebook.drawee.backends.pipeline.Fresco
import com.facebook.imagepipeline.common.ResizeOptions
import com.facebook.imagepipeline.core.ImagePipeline
import com.facebook.imagepipeline.datasource.BaseBitmapDataSubscriber
import com.facebook.imagepipeline.image.CloseableImage
import com.facebook.imagepipeline.request.ImageRequest
import com.facebook.imagepipeline.request.ImageRequestBuilder
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Callback
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.facebook.react.modules.core.RCTNativeAppEventEmitter
import com.tencent.mm.opensdk.diffdev.DiffDevOAuthFactory
import com.tencent.mm.opensdk.diffdev.IDiffDevOAuth
import com.tencent.mm.opensdk.diffdev.OAuthErrCode
import com.tencent.mm.opensdk.diffdev.OAuthListener
import com.tencent.mm.opensdk.modelbase.BaseReq
import com.tencent.mm.opensdk.modelbase.BaseResp
import com.tencent.mm.opensdk.modelbiz.ChooseCardFromWXCardPackage
import com.tencent.mm.opensdk.modelbiz.WXOpenBusinessWebview
import com.tencent.mm.opensdk.modelbiz.WXOpenCustomerServiceChat
import com.tencent.mm.opensdk.modelmsg.SendAuth
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX
import com.tencent.mm.opensdk.modelmsg.ShowMessageFromWX
import com.tencent.mm.opensdk.modelmsg.WXFileObject
import com.tencent.mm.opensdk.modelmsg.WXImageObject
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage
import com.tencent.mm.opensdk.modelmsg.WXMiniProgramObject
import com.tencent.mm.opensdk.modelmsg.WXMusicObject
import com.tencent.mm.opensdk.modelmsg.WXTextObject
import com.tencent.mm.opensdk.modelmsg.WXVideoObject
import com.tencent.mm.opensdk.modelmsg.WXWebpageObject
import com.tencent.mm.opensdk.modelpay.PayReq
import com.tencent.mm.opensdk.modelpay.PayResp
import com.tencent.mm.opensdk.modelbiz.WXLaunchMiniProgram
import com.tencent.mm.opensdk.openapi.IWXAPI
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler
import com.tencent.mm.opensdk.openapi.WXAPIFactory
import com.tencent.mm.opensdk.constants.ConstantsAPI
import com.tencent.mm.opensdk.modelbiz.SubscribeMessage
import java.io.BufferedInputStream
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileInputStream
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.IOException
import java.io.InputStream
import java.net.HttpURLConnection
import java.net.URI
import java.net.URL
import java.util.ArrayList
import java.util.UUID

@ReactModule(name = WechatOpensdkModule.NAME)
class WechatOpensdkModule(context: ReactApplicationContext) : NativeWechatOpensdkSpec(context), IWXAPIEventHandler {

    private var appid: String? = null
    private var api: IWXAPI? = null
    private var promiser: Promise? = null

    companion object {
        const val NAME = "WechatOpensdk"
        // 缩略图大小 kb
        private const val THUMB_SIZE = 32
        private val modules = ArrayList<WechatOpensdkModule>()

        fun handleWXIntent(intent: Intent) {
            for (mod in modules) {
                mod.api?.handleIntent(intent, mod)
            }
        }
    }

    override fun getName(): String {
        return NAME
    }

    override fun initialize() {
        super.initialize()
        modules.add(this)
    }

    override fun invalidate() {
        super.invalidate()
        api?.let {
            api = null
        }
        modules.remove(this)
    }

    override fun registerApp(appid: String, universal: String, promise: Promise) {
        this.appid = appid
        api = WXAPIFactory.createWXAPI(reactApplicationContext.baseContext, appid, true)
        val ok = api?.registerApp(appid) ?: false
        promise.resolve(ok)
    }

    override fun isAppInstalled(promise: Promise) {
        Log.d("DDFDFDFDFDFDF", "是不是 " + if (api?.isWXAppInstalled == true) "YES" else "NO")
        promise.resolve(true)
    }

    override fun openApp(promise: Promise) {
        api?.openWXApp()
        promise.resolve(null)
    }

    override fun auth(data: ReadableMap, promise: Promise) {
        promiser = promise
        val req = SendAuth.Req()
        req.scope = data.getString("scope")
        req.state = data.getString("state")
        api?.sendReq(req)
    }

    /**
     * 分享文件
     */
    override fun shareFile(data: ReadableMap, promise: Promise) {
        promiser = promise
        val fileObj = WXFileObject()

        val url = data.getString("url")
        if (url?.startsWith("http") == true) {
            fileObj.fileData = loadRawDataFromURL(url)
        } else {
            val file = File(url)
            val fileUri = getFileUri(reactApplicationContext, file)
            fileObj.filePath = fileUri
        }

        val msg = WXMediaMessage()
        msg.mediaObject = fileObj
        msg.title = data.getString("title")

        val req = SendMessageToWX.Req()
        req.transaction = System.currentTimeMillis().toString()
        req.message = msg
        req.scene = if (data.hasKey("scene")) data.getInt("scene") else SendMessageToWX.Req.WXSceneSession
        api?.sendReq(req)
    }

    /**
     * 分享文本
     */
    override fun shareText(data: ReadableMap, promise: Promise) {
        promiser = promise
        //初始化一个 WXTextObject 对象，填写分享的文本内容
        val textObj = WXTextObject()
        textObj.text = data.getString("text")

        //用 WXTextObject 对象初始化一个 WXMediaMessage 对象
        val msg = WXMediaMessage()
        msg.mediaObject = textObj
        msg.description = data.getString("text")

        val req = SendMessageToWX.Req()
        req.transaction = "text"
        req.message = msg
        req.scene = if (data.hasKey("scene")) data.getInt("scene") else SendMessageToWX.Req.WXSceneSession
        api?.sendReq(req)
    }

    override fun shareImage(data: ReadableMap, promise: Promise) {
        promiser = promise
        _getImage(Uri.parse(data.getString("imageUrl")), null, object : ImageCallback {
            override fun invoke(bitmap: Bitmap?) {
                var bmp = bitmap
                val maxWidth = if (data.hasKey("maxWidth")) data.getInt("maxWidth") else -1
                if (maxWidth > 0 && bmp != null) {
                    bmp = Bitmap.createScaledBitmap(bmp, maxWidth, bmp.height / bmp.width * maxWidth, true)
                }
                // 初始化 WXImageObject 和 WXMediaMessage 对象
                val imgObj = WXImageObject(bmp)
                val msg = WXMediaMessage()
                msg.mediaObject = imgObj

                // 设置缩略图
                if (bmp != null) {
                    msg.thumbData = bitmapResizeGetBytes(bmp, THUMB_SIZE)
                }

                // 构造一个Req
                val req = SendMessageToWX.Req()
                req.transaction = "img"
                req.message = msg
                // req.userOpenId = getOpenId();
                req.scene = if (data.hasKey("scene")) data.getInt("scene") else SendMessageToWX.Req.WXSceneSession
                api?.sendReq(req)
            }
        })
    }

    override fun shareLocalImage(data: ReadableMap, promise: Promise) {
        promiser = promise
        var fs: FileInputStream? = null
        try {
            var path = data.getString("imageUrl")
            if (path?.indexOf("file://") ?: -1 > -1) {
                path = path?.substring(7)
            }
            fs = FileInputStream(path)
            val bmp = BitmapFactory.decodeStream(fs)

            // 初始化 WXImageObject 和 WXMediaMessage 对象
            val imgObj = WXImageObject(bmp)
            val msg = WXMediaMessage()
            msg.mediaObject = imgObj
            // 设置缩略图
            msg.thumbData = bitmapResizeGetBytes(bmp, THUMB_SIZE)
            bmp.recycle()
            // 构造一个Req
            val req = SendMessageToWX.Req()
            req.transaction = "img"
            req.message = msg
            // req.userOpenId = getOpenId();
            req.scene = if (data.hasKey("scene")) data.getInt("scene") else SendMessageToWX.Req.WXSceneSession
            api?.sendReq(req)

        } catch (e: FileNotFoundException) {
            promise.reject("ERROR", e.message)
        }
    }

    override fun shareMusic(data: ReadableMap, promise: Promise) {
        promiser = promise
        // 初始化一个WXMusicObject，填写url
        val music = WXMusicObject()
        music.musicUrl = if (data.hasKey("musicUrl")) data.getString("musicUrl") else null
        music.musicLowBandUrl = if (data.hasKey("musicLowBandUrl")) data.getString("musicLowBandUrl") else null
        music.musicDataUrl = if (data.hasKey("musicDataUrl")) data.getString("musicDataUrl") else null
        music.musicUrl = if (data.hasKey("musicUrl")) data.getString("musicUrl") else null
        music.musicLowBandDataUrl = if (data.hasKey("musicLowBandDataUrl")) data.getString("musicLowBandDataUrl") else null
        // 用 WXMusicObject 对象初始化一个 WXMediaMessage 对象
        val msg = WXMediaMessage()
        msg.mediaObject = music
        msg.title = if (data.hasKey("title")) data.getString("title") else null
        msg.description = if (data.hasKey("description")) data.getString("description") else null

        if (data.hasKey("thumbImageUrl")) {
            _getImage(Uri.parse(data.getString("thumbImageUrl")), null, object : ImageCallback {
                override fun invoke(bmp: Bitmap?) {
                    // 设置缩略图
                    if (bmp != null) {
                        msg.thumbData = bitmapResizeGetBytes(bmp, THUMB_SIZE)
                    }
                    // 构造一个Req
                    val req = SendMessageToWX.Req()
                    req.transaction = "music"
                    req.message = msg
                    req.scene = if (data.hasKey("scene")) data.getInt("scene") else SendMessageToWX.Req.WXSceneSession
                    api?.sendReq(req)
                }
            })
        } else {
            // 构造一个Req
            val req = SendMessageToWX.Req()
            req.transaction = "music"
            req.message = msg
            req.scene = if (data.hasKey("scene")) data.getInt("scene") else SendMessageToWX.Req.WXSceneSession
            api?.sendReq(req)
        }
    }

    override fun shareVideo(data: ReadableMap, promise: Promise) {
        promiser = promise
        // 初始化一个WXVideoObject，填写url
        val video = WXVideoObject()
        video.videoUrl = if (data.hasKey("videoUrl")) data.getString("videoUrl") else null
        video.videoLowBandUrl = if (data.hasKey("videoLowBandUrl")) data.getString("videoLowBandUrl") else null
        //用 WXVideoObject 对象初始化一个 WXMediaMessage 对象
        val msg = WXMediaMessage(video)
        msg.title = if (data.hasKey("title")) data.getString("title") else null
        msg.description = if (data.hasKey("description")) data.getString("description") else null

        if (data.hasKey("thumbImageUrl")) {
            _getImage(Uri.parse(data.getString("thumbImageUrl")), null, object : ImageCallback {
                override fun invoke(bmp: Bitmap?) {
                    // 设置缩略图
                    if (bmp != null) {
                        msg.thumbData = bitmapResizeGetBytes(bmp, THUMB_SIZE)
                    }
                    // 构造一个Req
                    val req = SendMessageToWX.Req()
                    req.transaction = "video"
                    req.message = msg
                    req.scene = if (data.hasKey("scene")) data.getInt("scene") else SendMessageToWX.Req.WXSceneSession
                    api?.sendReq(req)
                }
            })
        } else {
            // 构造一个Req
            val req = SendMessageToWX.Req()
            req.transaction = "video"
            req.message = msg
            req.scene = if (data.hasKey("scene")) data.getInt("scene") else SendMessageToWX.Req.WXSceneSession
            api?.sendReq(req)
        }
    }

    /**
     * 分享网页
     */
    override fun shareWebpage(data: ReadableMap, promise: Promise) {
        promiser = promise
        // 初始化一个WXWebpageObject，填写url
        val webpage = WXWebpageObject()
        webpage.webpageUrl = if (data.hasKey("webpageUrl")) data.getString("webpageUrl") else null

        //用 WXWebpageObject 对象初始化一个 WXMediaMessage 对象
        val msg = WXMediaMessage(webpage)
        msg.title = if (data.hasKey("title")) data.getString("title") else null
        msg.description = if (data.hasKey("description")) data.getString("description") else null

        if (data.hasKey("thumbImageUrl")) {
            _getImage(Uri.parse(data.getString("thumbImageUrl")), null, object : ImageCallback {
                override fun invoke(bmp: Bitmap?) {
                    // 设置缩略图
                    if (bmp != null) {
                        msg.thumbData = bitmapResizeGetBytes(bmp, THUMB_SIZE)
                    }
                    // 构造一个Req
                    val req = SendMessageToWX.Req()
                    req.transaction = "webpage"
                    req.message = msg
                    req.scene = if (data.hasKey("scene")) data.getInt("scene") else SendMessageToWX.Req.WXSceneSession
                    api?.sendReq(req)
                }
            })
        } else {
            // 构造一个Req
            val req = SendMessageToWX.Req()
            req.transaction = "webpage"
            req.message = msg
            req.scene = if (data.hasKey("scene")) data.getInt("scene") else SendMessageToWX.Req.WXSceneSession
            api?.sendReq(req)
        }
    }

    /**
     * 分享小程序
     */
    override fun shareMiniProgram(data: ReadableMap, promise: Promise) {
        promiser = promise
        val miniProgramObj = WXMiniProgramObject()
        // 兼容低版本的网页链接
        miniProgramObj.webpageUrl = if (data.hasKey("webpageUrl")) data.getString("webpageUrl") else null
        // 正式版:0，测试版:1，体验版:2
        miniProgramObj.miniprogramType = if (data.hasKey("miniProgramType")) data.getInt("miniProgramType") else WXMiniProgramObject.MINIPTOGRAM_TYPE_RELEASE
        // 小程序原始id
        miniProgramObj.userName = if (data.hasKey("userName")) data.getString("userName") else null
        // 小程序页面路径；对于小游戏，可以只传入 query 部分，来实现传参效果，如：传入 "?foo=bar"
        miniProgramObj.path = if (data.hasKey("path")) data.getString("path") else null
        val msg = WXMediaMessage(miniProgramObj)
        // 小程序消息 title
        msg.title = if (data.hasKey("title")) data.getString("title") else null
        // 小程序消息 desc
        msg.description = if (data.hasKey("description")) data.getString("description") else null

        val thumbImageUrl = if (data.hasKey("hdImageUrl")) data.getString("hdImageUrl") else if (data.hasKey("thumbImageUrl")) data.getString("thumbImageUrl") else null

        if (thumbImageUrl != null && thumbImageUrl != "") {
            _getImage(Uri.parse(thumbImageUrl), null, object : ImageCallback {
                override fun invoke(bmp: Bitmap?) {
                    // 小程序消息封面图片，小于128k
                    if (bmp != null) {
                        msg.thumbData = bitmapResizeGetBytes(bmp, 128)
                    }
                    // 构造一个Req
                    val req = SendMessageToWX.Req()
                    req.transaction = "miniProgram"
                    req.message = msg
                    req.scene = if (data.hasKey("scene")) data.getInt("scene") else SendMessageToWX.Req.WXSceneSession

                    api?.sendReq(req)
                }
            })
        } else {
            // 构造一个Req
            val req = SendMessageToWX.Req()
            req.transaction = "miniProgram"
            req.message = msg
            req.scene = if (data.hasKey("scene")) data.getInt("scene") else SendMessageToWX.Req.WXSceneSession

            api?.sendReq(req)
        }
    }

    override fun launchMiniProgram(data: ReadableMap, promise: Promise) {
        val req = WXLaunchMiniProgram.Req()
        // 填小程序原始id
        req.userName = data.getString("userName")
        //拉起小程序页面的可带参路径，不填默认拉起小程序首页
        req.path = data.getString("path")
        // 可选打开 开发版，体验版和正式版
        req.miniprogramType = data.getInt("miniProgramType")

        api?.sendReq(req)
        promise.resolve(null)
    }

    /**
     * 一次性订阅消息
     */
    fun subscribeMessage(data: ReadableMap, promise: Promise) {
        val req = SubscribeMessage.Req()
        req.scene = if (data.hasKey("scene")) data.getInt("scene") else SendMessageToWX.Req.WXSceneSession
        req.templateID = data.getString("templateId")
        req.reserved = data.getString("reserved")

        api?.sendReq(req)
        promise.resolve(null)
    }

    override fun pay(data: ReadableMap, promise: Promise) {
        promiser = promise
        val payReq = PayReq()
        if (data.hasKey("partnerId")) {
            payReq.partnerId = data.getString("partnerId")
        }
        if (data.hasKey("prepayId")) {
            payReq.prepayId = data.getString("prepayId")
        }
        if (data.hasKey("nonceStr")) {
            payReq.nonceStr = data.getString("nonceStr")
        }
        if (data.hasKey("timeStamp")) {
            payReq.timeStamp = data.getString("timeStamp")
        }
        if (data.hasKey("sign")) {
            payReq.sign = data.getString("sign")
        }
        if (data.hasKey("package")) {
            payReq.packageValue = data.getString("package")
        }
        if (data.hasKey("extData")) {
            payReq.extData = data.getString("extData")
        }
        payReq.appId = appid

        api?.sendReq(payReq)
    }

    override fun chooseInvoice(data: ReadableMap, promise: Promise) {
        val req = ChooseCardFromWXCardPackage.Req()

        req.appId = appid
        req.cardType = "INVOICE"
        req.timeStamp = data.getInt("timeStamp").toString()
        req.nonceStr = data.getString("nonceStr")
        req.cardSign = data.getString("cardSign")
        req.signType = data.getString("signType")

        api?.sendReq(req)
        promise.resolve(null)
    }

    override fun customerService(data: ReadableMap, promise: Promise) {
        // open customer service logic
        val req = WXOpenCustomerServiceChat.Req()
        req.corpId = data.getString("corpId")
        req.url = data.getString("url")

        api?.sendReq(req)
        promise.resolve(null)
    }

    private fun bitmapResizeGetBytes(image: Bitmap, size: Int): ByteArray {
        // little-snow-fox 2019.10.20
        val baos = ByteArrayOutputStream()
        // 质量压缩方法，这里100表示第一次不压缩，把压缩后的数据缓存到 baos
        image.compress(Bitmap.CompressFormat.JPEG, 100, baos)
        var options = 100
        // 循环判断压缩后依然大于 32kb 则继续压缩
        while (baos.toByteArray().size / 1024 > size) {
            // 重置baos即清空baos
            baos.reset()
            if (options > 10) {
                options -= 8
            } else {
                return bitmapResizeGetBytes(Bitmap.createScaledBitmap(image, 280, image.height / image.width * 280, true), size)
            }
            // 这里压缩options%，把压缩后的数据存放到baos中
            image.compress(Bitmap.CompressFormat.JPEG, options, baos)
        }
        return baos.toByteArray()
    }

    @Throws(Exception::class)
    fun loadRawDataFromURL(u: String): ByteArray {
        val url = URL(u)
        val conn = url.openConnection() as HttpURLConnection

        val `is` = conn.inputStream
        val bis = BufferedInputStream(`is`)

        val baos = ByteArrayOutputStream()

        val BUFFER_SIZE = 2048
        val EOF = -1

        var c: Int
        val buf = ByteArray(BUFFER_SIZE)

        while (true) {
            c = bis.read(buf)
            if (c == EOF)
                break

            baos.write(buf, 0, c)
        }

        conn.disconnect()
        `is`.close()

        val data = baos.toByteArray()
        baos.flush()

        return data
    }

    fun getFileUri(context: Context, file: File?): String? {
        if (file == null || !file.exists()) {
            return null
        }

        val contentUri = FileProvider.getUriForFile(context,
                context.packageName + ".fileprovider",  // 要与`AndroidManifest.xml`里配置的`authorities`一致
                file)

        // 授权给微信访问路径
        context.grantUriPermission("com.tencent.mm",  // 这里填微信包名
                contentUri, Intent.FLAG_GRANT_READ_URI_PERMISSION)

        return contentUri.toString()   // contentUri.toString() 即是以"content://"开头的用于共享的路径
    }

    private fun _getImage(uri: Uri, resizeOptions: ResizeOptions?, imageCallback: ImageCallback) {
            val dataSubscriber: BaseBitmapDataSubscriber = object : BaseBitmapDataSubscriber() {
                override fun onNewResultImpl(bitmap: Bitmap?) {
                    var bitmap = bitmap
                    if (bitmap != null) {
                        if (bitmap.config != null) {
                            bitmap = bitmap.copy(bitmap.config!!, true)
                            imageCallback.invoke(bitmap)
                        } else {
                            bitmap = bitmap.copy(Bitmap.Config.ARGB_8888, true)
                            imageCallback.invoke(bitmap)
                        }
                    } else {
                        imageCallback.invoke(null)
                    }
                }

                override fun onFailureImpl(dataSource: DataSource<CloseableReference<CloseableImage?>>) {
                    imageCallback.invoke(null)
                }
            }

            var builder = ImageRequestBuilder.newBuilderWithSource(uri)
            if (resizeOptions != null) {
                builder = builder.setResizeOptions(resizeOptions)
            }
            val imageRequest = builder.build()

            val imagePipeline = Fresco.getImagePipeline()
            val dataSource = imagePipeline.fetchDecodedImage(imageRequest, null)
            dataSource.subscribe(dataSubscriber, UiThreadImmediateExecutorService.getInstance())
        }

    override fun onReq(baseReq: BaseReq) {

    }

    override fun onResp(baseResp: BaseResp) {
        Log.d("WechatOpensdkModule", "收到回调 " + baseResp.errCode)
        val map = Arguments.createMap()
        map.putInt("errCode", baseResp.errCode)
        map.putString("errStr", baseResp.errStr)
        map.putString("openId", baseResp.openId)
        map.putString("transaction", baseResp.transaction)
        when (baseResp) {
            is SendAuth.Resp -> {
                map.putString("type", "SendAuth.Resp")
                map.putString("code", baseResp.code)
                map.putString("state", baseResp.state)
                map.putString("url", baseResp.url)
                map.putString("lang", baseResp.lang)
                map.putString("country", baseResp.country)
            }
            is SendMessageToWX.Resp -> {
                map.putString("type", "SendMessageToWX.Resp")
            }
            is PayResp -> {
                map.putString("type", "PayReq.Resp")
                map.putString("returnKey", baseResp.returnKey)
            }
            else -> {
                when (baseResp.type) {
                    ConstantsAPI.COMMAND_LAUNCH_WX_MINIPROGRAM -> {
                        val resp = baseResp as WXLaunchMiniProgram.Resp
                        // 对应JsApi navigateBackApplication中的extraData字段数据
                        val extraData = resp.extMsg
                        map.putString("type", "WXLaunchMiniProgramReq.Resp")
                        map.putString("extraData", extraData)
                        map.putString("extMsg", extraData)
                    }
                }
                if (baseResp is ChooseCardFromWXCardPackage.Resp) {
                    map.putString("type", "WXChooseInvoiceResp.Resp")
                    map.putString("cardItemList", baseResp.cardItemList)
                }
            }
        }
        promiser?.resolve(map)
    }

    private interface ImageCallback {
        fun invoke(@Nullable bitmap: Bitmap?)
    }

    private interface MediaObjectCallback {
        fun invoke(@Nullable mediaObject: WXMediaMessage.IMediaObject?)
    }
}
