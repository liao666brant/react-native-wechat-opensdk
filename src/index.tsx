import WechatOpensdk, {
  type AuthProps,
  type ShareFileProps,
  type ShareLocalImageProps,
  type ShareTextProps
} from './NativeWechatOpensdk';

// export function multiply(a: number, b: number): number {
//   return WechatOpensdk.multiply(a, b);
// }

export async function isAppInstalled(): Promise<boolean> {
  return WechatOpensdk.isAppInstalled();
}

export async function registerApp(appid: string, universalLink: string): Promise<boolean> {
  return WechatOpensdk.registerApp(appid, universalLink);
}

export async function openApp(): Promise<void> {
  return WechatOpensdk.openApp();
}

export async function auth(data: AuthProps): Promise<any> {
  return WechatOpensdk.auth(data);
}

export async function shareFile(data: ShareFileProps): Promise<any> {
  return WechatOpensdk.shareFile(data);
}

export async function shareLocalImage(data: ShareLocalImageProps): Promise<any> {
  return WechatOpensdk.shareLocalImage(data);
}

export async function shareText(data: ShareTextProps): Promise<any> {
  return WechatOpensdk.shareText(data);
}
