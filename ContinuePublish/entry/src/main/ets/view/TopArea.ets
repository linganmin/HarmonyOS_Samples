/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { CommonConstants } from '../constants/CommonConstants';
import { BreakpointType } from '../utils/BreakpointSystem';

const DOMAIN = 0x0000;
const TAG = 'TopArea';
const FORMAT = '%{public}s';

/*
 *  Top area.
 */
@Component
export struct TopArea {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = 'sm';

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontSize($r('sys.float.Title_M'))
            .fontColor([$r('sys.color.font_primary')])
            .onClick(() => {
              let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
              context.terminateSelf().catch((err: BusinessError) => {
                hilog.info(DOMAIN, TAG, FORMAT,
                  `TerminateSelf failed. Cause code: ${err.code}, message: ${err.message}`);
              });
            })
        }
        .justifyContent(FlexAlign.Center)
        .margin({ right: $r('app.integer.cancel_icon_right') })
        .width($r('app.integer.top_area_size'))
        .height($r('app.integer.top_area_size'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius($r('app.integer.top_area_radius'))

        Text($r('app.string.text_posts'))
          .fontSize($r('app.integer.text_size_headline8'))
          .fontWeight(FontWeight.Bold)
          .width(CommonConstants.PUBLISH_TITLE_WIDTH)
          .maxLines(CommonConstants.PUBLISH_TITLE_MAX_LINES)
      }
      .backgroundColor($r('sys.color.background_primary'))

      Row() {
        SymbolGlyph($r('sys.symbol.square_and_pencil'))
          .fontSize($r('sys.float.Title_M'))
          .fontColor([$r('sys.color.font_primary')])
          .onClick(() => {
            try {
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.trigger_event') });
            } catch (err) {
              hilog.error(DOMAIN, TAG, FORMAT, `ShowToast failed. Cause code: ${err.code}, message: ${err.message}`);
            }
          })
      }
      .justifyContent(FlexAlign.Center)
      .width($r('app.integer.top_area_size'))
      .height($r('app.integer.top_area_size'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius($r('app.integer.top_area_radius'))
    }
    .backgroundColor($r('sys.color.background_primary'))
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.integer.top_area_height'))
    .padding({
      left: new BreakpointType($r('sys.float.padding_level8'), $r('sys.float.padding_level8'),
        $r('sys.float.padding_level12'), $r('sys.float.padding_level16')).GetValue(this.currentBreakpoint),
      right: new BreakpointType($r('sys.float.padding_level8'), $r('sys.float.padding_level8'),
        $r('sys.float.padding_level12'), $r('sys.float.padding_level16')).GetValue(this.currentBreakpoint)
    })
    .margin({
      top: $r('app.integer.comm_padding_margin'),
      bottom: $r('app.integer.comm_padding_margin')
    })
  }
}