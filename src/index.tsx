import WechatOpensdk, {
  type AuthProps,
  type AuthResult,
  type ChooseInvoiceProps, type ChooseInvoiceResult,
  type CustomerServiceProps,
  type LaunchMiniProgramProps,
  type PayProps, type PayResult,
  type ShareFileProps,
  type ShareImageProps,
  type ShareLocalImageProps,
  type ShareMiniProgramProps,
  type ShareMusicProps, type ShareResult,
  type ShareTextProps,
  type ShareVideoProps,
  type ShareWebpageProps,
  type TransferProps, type TransferResult
} from './NativeWechatOpensdk';

export default {
  multiply: (a: number, b: number): number => {
    return WechatOpensdk.multiply(a, b);
  },
  isAppInstalled: (): Promise<boolean> => {
    return WechatOpensdk.isAppInstalled();
  },

  registerApp: (appid: string, universalLink: string): Promise<boolean> => {
    return WechatOpensdk.registerApp(appid, universalLink);
  },

  openApp: (): Promise<void> => {
    return WechatOpensdk.openApp();
  },

  auth: (data: AuthProps): Promise<AuthResult> => {
    return WechatOpensdk.auth(data);
  },

  shareFile: (data: ShareFileProps): Promise<ShareResult> => {
    return WechatOpensdk.shareFile(data);
  },

  shareLocalImage: (data: ShareLocalImageProps): Promise<ShareResult> => {
    return WechatOpensdk.shareLocalImage(data);
  },

  shareText: (data: ShareTextProps): Promise<ShareResult> => {
    return WechatOpensdk.shareText(data);
  },

  shareWebpage: (data: ShareWebpageProps): Promise<ShareResult> => {
    return WechatOpensdk.shareWebpage(data);
  },

  shareImage: (data: ShareImageProps): Promise<ShareResult> => {
    return WechatOpensdk.shareImage(data);
  },

  shareVideo: (data: ShareVideoProps): Promise<ShareResult> => {
    return WechatOpensdk.shareVideo(data);
  },

  shareMusic: (data: ShareMusicProps): Promise<ShareResult> => {
    return WechatOpensdk.shareMusic(data);
  },

  shareMiniProgram: (data: ShareMiniProgramProps): Promise<ShareResult> => {
    return WechatOpensdk.shareMiniProgram(data);
  },

  pay: (data: PayProps): Promise<PayResult> => {
    return WechatOpensdk.pay(data);
  },

  customerService: (data: CustomerServiceProps): Promise<void> => {
    return WechatOpensdk.customerService(data);
  },

  chooseInvoice: (data: ChooseInvoiceProps): Promise<ChooseInvoiceResult> => {
    return WechatOpensdk.chooseInvoice(data);
  },

  launchMiniProgram: (data: LaunchMiniProgramProps): Promise<void> => {
    return WechatOpensdk.launchMiniProgram(data);
  },

  transfer: async (data: TransferProps): Promise<TransferResult> => {
    const result = await WechatOpensdk.transfer(data);
    const extMsg = JSON.parse(result.extMsg);
    return {...result, extMsg};
  },

}
