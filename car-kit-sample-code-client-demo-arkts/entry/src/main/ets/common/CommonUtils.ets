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

import { navigationInfoMgr, smartMobilityCommon } from '@kit.CarKit';
import { display } from '@kit.ArkUI';
import { i18n } from '@kit.LocalizationKit';
import { Logger } from './Logger';

const TAG = 'CommonUtils';

export default class CommonUtils {
  private static FONT_SIZE_20VP: number = 70;
  private static FONT_SIZE_17VP: number = 60;
  private static FONT_SIZE_16VP: number = 56;
  private static FONT_SIZE_12VP: number = 42;
  private static FONT_SIZE_9VP: number = 31;

  private constructor() {
  }

  public static isChineseLanguage(): boolean {
    const sysLanguage: string = i18n.System.getSystemLanguage();
    return sysLanguage == 'zh-Hans';
  }

  /**
   * getFoldStatus
   * @returns -1 directScreen,0 FOLD_STATUS_UNKNOWN,1 FOLD_STATUS_EXPANDED,2 FOLD_STATUS_FOLDED,3 FOLD_STATUS_HALF_FOLDED.
   */
  public static getFoldStatus(): number {
    // isFoldAble: true foldingScreen, false directScreen.
    const isFoldAble: boolean = display.isFoldable();
    // foldStatus: 1 indicates full expansion, 2 indicates folding, and 3 indicates half folding.
    const foldStatus: number = display.getFoldStatus();
    Logger.info(TAG, `getFoldStatus: ${JSON.stringify(foldStatus)}`);
    return isFoldAble ? foldStatus : -1;
  }

  public static getCustomButtonFontSize(uiContext: UIContext | undefined): number {
    if (uiContext === undefined || uiContext === null) {
      return 0;
    }
    return CommonUtils.isChineseLanguage() ?
      uiContext.px2vp(CommonUtils.FONT_SIZE_16VP) : uiContext?.px2vp(CommonUtils.FONT_SIZE_12VP);
  }

  public static getCustomDialogTitleSize(uiContext: UIContext | undefined): number {
    if (uiContext === undefined || uiContext === null) {
      return 0;
    }
    if (!CommonUtils.isChineseLanguage() && CommonUtils.getFoldStatus() === display.FoldStatus.FOLD_STATUS_FOLDED) {
      return uiContext.px2vp(CommonUtils.FONT_SIZE_17VP);
    }
    return uiContext.px2vp(CommonUtils.FONT_SIZE_20VP);
  }

  public static getButtonFontSize(uiContext: UIContext | undefined): number {
    if (uiContext === undefined || uiContext === null) {
      return 0;
    }
    if (CommonUtils.isChineseLanguage()) {
      return uiContext.px2vp(CommonUtils.FONT_SIZE_16VP);
    }
    if (CommonUtils.getFoldStatus() === display.FoldStatus.FOLD_STATUS_HALF_FOLDED) {
      return uiContext.px2vp(CommonUtils.FONT_SIZE_9VP);
    }
    return uiContext.px2vp(CommonUtils.FONT_SIZE_12VP);
  }

  public static getNavStatusString(status: navigationInfoMgr.NavigationStatus): string {
    return `mapStatus: ${status.status}\n` +
      `navigationType: ${status.naviType}\n` +
      `destLocation: ${status.destLocation.name}\n` +
      `passPoint1: [${status.passPoint[0].name}, ${status.passPoint[1].name}]\n` +
      `routeIndex: ${status.routeIndex}\n` +
      `routePreference: [${status.routePreference[0]},${status.routePreference[1]}]\n` +
      `customData: ${status.customData}\n`;
  }

  public static getNavMetadataString(status: navigationInfoMgr.NavigationMetadata): string {
    return `naviTurnMode: ${status.naviTurnMode}\n` +
      `segmentLeftDis: ${status.segmentLeftDis}\n` +
      `currentRoadName: ${status.currentRoadName}\n` +
      `nextRoadName: ${status.nextRoadName}\n` +
      `intersectionView: ${status.intersectionView}\n` +
      `viewWidth: ${status.viewWidth}\n` +
      `viewHeight: ${status.viewHeight}\n` +
      `trafficLane: ${status.trafficLane}\n` +
      `cameraSpeedLimitValid: ${status.cameraSpeedLimitValid}\n` +
      `cameraSpeedLimit: ${status.cameraSpeedLimit}\n` +
      `naviSpeedLimitValid: ${status.naviSpeedLimitValid}\n` +
      `naviSpeedLimit: ${status.naviSpeedLimit}\n` +
      `currentSpeed: ${status.currentSpeed}\n` +
      `naviBearing: ${status.naviBearing}\n` +
      `totalLeftDis: ${status.totalLeftDis}\n` +
      `remainingTime: ${status.remainingTime}\n` +
      `customData: ${JSON.stringify(status.customData)}\n`;
  }

  public static getSmartMobilityEventString(event: smartMobilityCommon.SmartMobilityEvent): string {
    return `eventName: ${event.eventName}\n` +
      `serviceType: ${event.type}\n` +
      `additionalData: ${JSON.stringify(event.data)}\n`;
  }

  public static getSmartMobilityStatusString(info: smartMobilityCommon.SmartMobilityInfo): string {
    return `serviceConnectionStatus: ${info.status}\n` +
      `serviceType: ${info.type}\n` +
      `additionalData: ${JSON.stringify(info.data)}\n`;
  }

  public static handleCmdReceived(command: navigationInfoMgr.CommandType, args: Record<string, object>) {
    return `commandType: ${command}\n` +
      `args: ${JSON.stringify(args)}\n`;
  }

  public static resourceToString(resource: Resource, context: UIContext | undefined): string | undefined {
    let str: string | undefined = '';
    if (context !== undefined) {
      str = context.getHostContext()?.resourceManager.getStringSync(resource.id);
      if (str !== undefined) {
        return str;
      }
    }
    return str;
  }
}