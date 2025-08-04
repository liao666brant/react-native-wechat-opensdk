import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  multiply(a: number, b: number): number;
  isAppInstalled: () => Promise<boolean>;
  registerApp: (appid: string, universalLink: string) => Promise<boolean>;
  openApp: () => Promise<void>;
  auth: (data: AuthProps) => Promise<AuthResult>;
  shareFile: (data: ShareFileProps) => Promise<ShareResult>;
  shareText: (data: ShareTextProps) => Promise<ShareResult>;
  shareWebpage: (data: ShareWebpageProps) => Promise<ShareResult>;
  shareImage: (data: ShareImageProps) => Promise<ShareResult>;
  shareLocalImage: (data: ShareLocalImageProps) => Promise<ShareResult>;
  shareVideo: (data: ShareVideoProps) => Promise<ShareResult>;
  shareMusic: (data: ShareMusicProps) => Promise<ShareResult>;
  shareMiniProgram: (data: ShareMiniProgramProps) => Promise<ShareResult>;
  launchMiniProgram: (data: LaunchMiniProgramProps) => Promise<void>;
  pay: (data: PayProps) => Promise<PayResult>;
  customerService: (data: CustomerServiceProps) => Promise<void>;
  chooseInvoice: (data: ChooseInvoiceProps) => Promise<ChooseInvoiceResult>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('WechatOpensdk');

export interface AuthProps {
  state: string;
  scope?: string;
}

export interface ShareFileProps {
  url: string;
  title?: string;
  ext?: string;
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
  signType: string;
  nonceStr: string;
  timeStamp: number;
  cardSign: string;
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










export interface BasicResult {
  errCode: number;
  errStr?: string;
}

export interface AuthResult extends BasicResult {
  code: string;
  lang: string;
  country: string;
  appid: string;
  state?: string;
}

export interface ShareResult extends BasicResult {
  lang?: string;
  country?: string;
}

export interface PayResult extends BasicResult {
  /**
   * 响应类型
   */
  type: string;
  /**
   * 财付通返回给商家的信息
   */
  returnKey: string;
}

export interface ChooseInvoiceResult extends BasicResult {
  cards: {
    cardId: string;
    encryptCode: string;
    appID: string;
  }[];
}
