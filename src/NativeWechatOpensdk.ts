import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  // multiply(a: number, b: number): number;
  isAppInstalled: () => Promise<boolean>;
  registerApp: (appid: string, universalLink: string) => Promise<boolean>;
  openApp: () => Promise<null>;
  auth: (data: AuthProps) => Promise<AuthResponse>;
  shareText: (data: ShareTextProps) => Promise<any>;
  shareWebpage: (data: ShareWebpageProps) => Promise<any>;
  shareImage: (data: ShareImageProps) => Promise<any>;
  shareVideo: (data: ShareVideoProps) => Promise<any>;
  pay: (data: PayProps) => Promise<any>;
  customerService: (data: CustomerServiceProps) => Promise<any>;
  chooseInvoice: (data: ChooseInvoiceProps) => Promise<any>;
  shareMiniProgram: (data: ShareMiniProgramProps) => Promise<any>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('WechatOpensdk');

interface AuthProps {
  state: string;
  scope: string;
}
interface AuthResponse {
  type: string;
  code: string;
  state: string;
  lang: string;
  country: string;
  url?: string;
}

interface ShareTextProps {
  text: string;
  scene?: WXScene;
}

interface ShareWebpageProps {
  webpageUrl: string;
  title?: string;
  description?: string;
  thumbImageUrl?: string;
  scene?: WXScene;
}

interface ShareImageProps {
  imageUrl: string;
  scene?: WXScene;
}

interface ShareVideoProps {
  videoUrl: string;
  videoLowBandUrl?: string;
  title?: string;
  description?: string;
  thumbImageUrl?: string;
  scene?: WXScene;
}

interface PayProps {
  partnerId: string;
  prepayId: string;
  nonceStr: string;
  timeStamp: string;
  package: string;
  sign: string;
}

interface CustomerServiceProps {
  corpId: string;
  url: string;
}

interface ChooseInvoiceProps {
  signType?: string;
  nonceStr?: string;
  timeStamp?: number;
  cardSign?: string;
}

interface ShareMiniProgramProps {
  userName: string;
  path: string;
  title?: string;
  description?: string;
  thumbImageUrl?: string;
  hdImageUrl?: string;
  miniProgramType?: number;
  webpageUrl: string;
  scene?: WXScene;
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
