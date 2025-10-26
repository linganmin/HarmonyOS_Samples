/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * Public constants.
 */
export class CommonConstants {
  /**
   * IP Address.
   */
  static readonly IP_ADDRESS: string = '127.0.0.1';
  /**
   *  IP Port.
   */
  static readonly IP_PORT: number = 1234;
  /**
   *  CLIENT IP Port.
   */
  static readonly CLIENT_IP_PORT: number = 4321;
  /**
   *  Video Source.
   */
  static readonly VIDEO_SRC: string = 'https://mos-vod-drcn.dbankcdn.cn/P_VT/video_injection/28B76491E5988CFD48CA33EDDAF5D3D8B7407CF11958A53CFCC3CBC6DC31E270134D8ED/v3/M2000139681609568769/MP4Mix_H.264_1920x1080_6000_HEAAC1_PVC_NoCut.mp4?accountinfo=LB1z4gNHXSUGUQwjknSFIwYJ6USHbz%2F3Mz5YkLmsBr8ikWk4PoTAd6WSY%2FWeOFhuvT0S7KOLpM8DBW0E0pT8FQ%3D%3D%3A20240621081001%3AUTC%2C%2C%2C20240621081001%2C%2C%2C-1%2C1%2C0%2C%2C%2C1%2C%2C%2C%2C1%2C%2C0%2C%2C%2C%2C%2C1%2CEND&GuardEncType=2&contentCode=M202406211662000139676022755842&spVolumeId=MP202406211662000139675603325440&server=mosplay-drcn.himovie.dbankcloud.cn&protocolType=1&formatPriority=504*%2C204*%2C2';
  /**
   *  HTTP Download.
   */
  static readonly HTTP_DOWNLOAD: string = 'HTTP Download';
  /**
   *  RCP Download.
   */
  static readonly RCP_DOWNLOAD: string = 'RCP Download';
  /**
   *  Socket Download.
   */
  static readonly Socket_DOWNLOAD: string = 'Socket Download';
  /**
   *  Download Video.
   */
  static readonly DOWNLOAD_VIDEO: string = 'Download Video';
}