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

import { insightIntent } from '@kit.IntentsKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { i18n } from '@kit.LocalizationKit';
import { preferences } from '@kit.ArkData';
import { IVideoInfo } from '../model/DataModel';
import CommonConstants, { ShareStatus } from '../common/constants/CommonConstants';
import { FileReader } from '../common/utils/FileReader';
import { Logger } from '../common/utils/Logger';

@Builder
export function PlayPageBuilder() {
  PlayPage();
}

interface ProgressUpdateObject {
  time: number;
}

@Component
export struct PlayPage {
  @State shareStatus: ShareStatus = ShareStatus.SHARING;
  @State navParam: IVideoInfo | undefined = undefined;
  private navPathStack: NavPathStack = new NavPathStack();
  private shareIntentList: insightIntent.InsightIntent[] = [];
  private intentItem: insightIntent.InsightIntent | undefined = undefined;
  private controller: VideoController = new VideoController();
  private abilityContext: common.Context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private videoPreference: preferences.Preferences | undefined = undefined;

  async aboutToAppear(): Promise<void> {
    // read video progress
    preferences.getPreferences(this.abilityContext, 'video.data',
      (err: BusinessError, data: preferences.Preferences) => {
        if (err) {
          Logger.error('preference', `getPreferences error. code: ${err.code}, message: ${err.message}`);
          return;
        }
        this.videoPreference = data;
      })
    // read shareIntent.json
    this.shareIntentList =
      await FileReader.readJson(this.abilityContext as common.UIAbilityContext,
        i18n.System.getSystemLanguage() === CommonConstants.ENG_LANGUAGE ?
        CommonConstants.INTENT_ENG_FILE_NAME : CommonConstants.INTENT_FILE_NAME) as insightIntent.InsightIntent[];
  }

  aboutToDisappear(): void {
    // save video progress
    this.videoPreference?.flush().then(() => {
      Logger.info('preference', 'Succeeded in flushing.');
    }).catch((err: BusinessError) => {
      Logger.error('preference', `Failed to flush. code: ${err.code}, message: ${err.message}`);
    })
  }

  build() {
    NavDestination() {
      Column() {
        Video({
          src: $rawfile(this.navParam?.fileName),
          controller: this.controller
        })
          .autoPlay(true)
          .onPrepared(() => {
            this.controller.setCurrentTime(this.getProgress(), SeekMode.Accurate);
          })
          .onUpdate((e: ProgressUpdateObject) => {
            this.updatePreference(e.time);
          })
          .onStart(() => {
            this.shareIntent();
          })
          .onFinish(() => {
            this.controller.stop();
          })
          .height('90%')
        Row() {
          Row({ space: 8 }) {
            if (this.shareStatus === ShareStatus.SUCCEEDED) {
              SymbolGlyph($r('sys.symbol.checkmark_circle'))
                .fontSize(22)
                .fontColor(['#64bb5c'])
            } else {
              SymbolGlyph($r('sys.symbol.exclamationmark_circle'))
                .fontSize(22)
                .fontColor(['#E84026'])
            }
            Text(CommonConstants.SHARE_STATUS_TEXT + this.shareStatus)
              .font({ weight: FontWeight.Normal, size: 14 })
          }
          .width('100%')
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgb(241,243,245)')
          .borderRadius(12)
        }
        .height('10%')
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .height('100%')
      .width('100%')
    }
    .title($r(this.navParam?.displayName))
    .systemTransition(NavigationSystemTransitionType.SLIDE_RIGHT)
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack;
      this.navParam = this.navPathStack.getParamByName(CommonConstants.PLAY_PATH_NAME)?.[0] as IVideoInfo;
    })
  }

  /**
   * get specify video progress
   * @returns progress
   */
  getProgress(): number {
    try {
      return this.videoPreference?.getSync(this.navParam?.id, 0) as number;
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(`getProgress`, `getSync failed, error.code is ${error.code}, error.message is ${error.message}`);
      return 0;
    }
  }

  /**
   * update video progress
   * @param time
   */
  updatePreference(time: number) {
    if (this.videoPreference && this.navParam?.id) {
      this.videoPreference.put(this.navParam.id, time || 0).then(() => {
        Logger.info('preference', 'put succeeded');
      }).catch((err: BusinessError) => {
        Logger.error('preference', `put failed. code: ${err.code}, message: ${err.message}`);
      })
    }
  }

  /**
   * share intent to system
   */
  shareIntent() {
    if (!this.intentItem && this.navParam?.id) {
      this.intentItem =
        this.shareIntentList.find((shareObject: insightIntent.InsightIntent) => shareObject.intentEntityInfo.entityId ===
          this.navParam?.id);
    }
    if (this.intentItem) {
      this.shareStatus = ShareStatus.SHARING;
      insightIntent.shareIntent(this.abilityContext, [this.intentItem]).then(() => {
        this.shareStatus = ShareStatus.SUCCEEDED;
        Logger.info('shareIntent', 'succeeded');
      }).catch((err: BusinessError) => {
        this.shareStatus = ShareStatus.FAILED;
        Logger.error('shareIntent', `failed code: ${err.code}, message: ${err.message}`);
      })
    }
  }
}