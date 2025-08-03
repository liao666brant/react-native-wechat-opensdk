import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  // multiply(a: number, b: number): number;
  isAppInstalled: () => Promise<boolean>;
  registerApp: (appid: string, universalLink: string) => Promise<boolean>;
  openApp: () => Promise<void>;
  auth: (data: AuthProps) => Promise<AuthResponse>;
  shareFile: (data: ShareFileProps) => Promise<any>;
  shareLocalImage: (data: ShareLocalImageProps) => Promise<any>;
  shareText: (data: ShareTextProps) => Promise<any>;
  shareWebpage: (data: ShareWebpageProps) => Promise<any>;
  shareImage: (data: ShareImageProps) => Promise<any>;
  shareVideo: (data: ShareVideoProps) => Promise<any>;
  shareMusic: (data: ShareMusicProps) => Promise<any>;
  pay: (data: PayProps) => Promise<any>;
  customerService: (data: CustomerServiceProps) => Promise<any>;
  chooseInvoice: (data: ChooseInvoiceProps) => Promise<any>;
  shareMiniProgram: (data: ShareMiniProgramProps) => Promise<any>;
  launchMiniProgram: (data: LaunchMiniProgramProps) => Promise<any>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('WechatOpensdk');

export interface AuthProps {
  state: string;
  scope: string;
}
export interface AuthResponse {
  type: string;
  code: string;
  state: string;
  lang: string;
  country: string;
  url?: string;
}

export interface ShareFileProps {
  url: string;
  title: string;
  scene?: WXScene;
}

export interface ShareTextProps {
  text: string;
  scene?: WXScene;
}

export interface ShareLocalImageProps {
  imageUrl: string;
  scene?: WXScene;
}

export interface ShareMusicProps {
  musicUrl: string;
  musicLowBandUrl?: string;
  musicDataUrl?: string;
  musicLowBandDataUrl?: string;
  title?: string;
  description?: string;
  thumbImageUrl?: string;
  scene?: WXScene;
}

export interface ShareWebpageProps {
  webpageUrl: string;
  title?: string;
  description?: string;
  thumbImageUrl?: string;
  scene?: WXScene;
}

export interface ShareImageProps {
  imageUrl: string;
  scene?: WXScene;
}

export interface ShareVideoProps {
  videoUrl: string;
  videoLowBandUrl?: string;
  title?: string;
  description?: string;
  thumbImageUrl?: string;
  scene?: WXScene;
}

export interface PayProps {
  partnerId: string;
  prepayId: string;
  nonceStr: string;
  timeStamp: string;
  package: string;
  sign: string;
}

export interface CustomerServiceProps {
  corpId: string;
  url: string;
}

export interface ChooseInvoiceProps {
  signType?: string;
  nonceStr?: string;
  timeStamp?: number;
  cardSign?: string;
}

export interface ShareMiniProgramProps {
  userName: string;
  path?: string;
  title?: string;
  description?: string;
  thumbImageUrl?: string;
  hdImageUrl?: string;
  miniProgramType?: number;
  webpageUrl: string;
  withShareTicket?: string;
  scene?: WXScene;
}

export interface LaunchMiniProgramProps {
  userName: string;
  miniProgramType?: number;
  path?: string;
}

export enum WXScene {
  /* 聊天界面    */
  WXSceneSession = 0,
  /* 朋友圈     */
  WXSceneTimeline = 1,
  /* 收藏       */
  WXSceneFavorite = 2,
  /* 指定联系人  */
  WXSceneSpecifiedSession = 3,
  /* 状态   */
  WXSceneState = 4,
}
