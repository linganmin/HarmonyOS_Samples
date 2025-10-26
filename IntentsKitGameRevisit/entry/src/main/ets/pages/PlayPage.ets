/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { IGameInfo } from '../model/DataModel';
import CommonConstants, { ShareStatus } from '../common/constants/CommonConstants';
import { FileReader } from '../common/utils/FileReader';
import { Logger } from '../common/utils/Logger';

@Builder
export function PlayPageBuilder() {
  PlayPage()
}

@Component
export struct PlayPage {
  @State shareStatus: ShareStatus = ShareStatus.SHARING;
  @State navParam: IGameInfo | undefined = undefined;
  private navPathStack: NavPathStack = new NavPathStack();
  private shareIntentList: insightIntent.InsightIntent[] = [];
  private intentItem: insightIntent.InsightIntent | undefined = undefined;
  private abilityContext: common.Context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  async aboutToAppear(): Promise<void> {
    // read shareIntent.json
    this.shareIntentList =
      await FileReader.readJson(this.abilityContext as common.UIAbilityContext,
        i18n.System.getSystemLanguage() === CommonConstants.ENG_LANGUAGE ?
        CommonConstants.INTENT_ENG_FILE_NAME : CommonConstants.INTENT_FILE_NAME) as insightIntent.InsightIntent[];
    // share intent
    this.shareIntent();
  }

  build() {
    NavDestination() {
      Column() {
        Image($r(this.navParam?.gamePoster))
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
    .title($r(`${this.navParam?.displayName}`))
    .systemTransition(NavigationSystemTransitionType.SLIDE_RIGHT)
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack;
      this.navParam = this.navPathStack.getParamByName(CommonConstants.PLAY_PATH_NAME)?.[0] as IGameInfo;
    })
  }

  shareIntent() {
    if (!this.intentItem && this.navParam?.id) {
      this.intentItem =
        this.shareIntentList.find((shareObject: insightIntent.InsightIntent) => shareObject.intentEntityInfo.entityId ===
          this.navParam?.id);
    }
    if (this.intentItem) {
      this.shareStatus = ShareStatus.SHARING
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