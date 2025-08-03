import WechatOpensdk, {
  type AuthProps,
  type AuthResult, type BasicResult,
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
  type ShareWebpageProps
} from './NativeWechatOpensdk';

export function multiply(a: number, b: number): number {
  return WechatOpensdk.multiply(a, b);
}

export function isAppInstalled(): Promise<boolean> {
  return WechatOpensdk.isAppInstalled();
}

export async function registerApp(appid: string, universalLink: string): Promise<boolean> {
  return WechatOpensdk.registerApp(appid, universalLink);
}

export async function openApp(): Promise<void> {
  return WechatOpensdk.openApp();
}

export async function auth(data: AuthProps): Promise<AuthResult> {
  return WechatOpensdk.auth(data);
}

export async function shareFile(data: ShareFileProps): Promise<ShareResult> {
  return WechatOpensdk.shareFile(data);
}

export async function shareLocalImage(data: ShareLocalImageProps): Promise<ShareResult> {
  return WechatOpensdk.shareLocalImage(data);
}

export async function shareText(data: ShareTextProps): Promise<ShareResult> {
  return WechatOpensdk.shareText(data);
}

export async function shareWebpage(data: ShareWebpageProps): Promise<ShareResult> {
  return WechatOpensdk.shareWebpage(data);
}

export async function shareImage(data: ShareImageProps): Promise<ShareResult> {
  return WechatOpensdk.shareImage(data);
}

export async function shareVideo(data: ShareVideoProps): Promise<ShareResult> {
  return WechatOpensdk.shareVideo(data);
}

export async function shareMusic(data: ShareMusicProps): Promise<ShareResult> {
  return WechatOpensdk.shareMusic(data);
}

export async function shareMiniProgram(data: ShareMiniProgramProps): Promise<ShareResult> {
  return WechatOpensdk.shareMiniProgram(data);
}

export async function pay(data: PayProps): Promise<PayResult> {
  return WechatOpensdk.pay(data);
}

export async function customerService(data: CustomerServiceProps): Promise<void> {
  return WechatOpensdk.customerService(data);
}

export async function chooseInvoice(data: ChooseInvoiceProps): Promise<ChooseInvoiceResult> {
  return WechatOpensdk.chooseInvoice(data);
}

export async function launchMiniProgram(data: LaunchMiniProgramProps): Promise<void> {
  return WechatOpensdk.launchMiniProgram(data);
}
