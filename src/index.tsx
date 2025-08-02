import WechatOpensdk from './NativeWechatOpensdk';

// export function multiply(a: number, b: number): number {
//   return WechatOpensdk.multiply(a, b);
// }

export async function isAppInstalled(): Promise<boolean> {
  return WechatOpensdk.isAppInstalled();
}
