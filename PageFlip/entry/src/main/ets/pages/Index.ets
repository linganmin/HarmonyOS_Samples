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

import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants, PageFlipType } from '../common/Constants';
import { BottomView } from '../view/BottomView';
import { CoverFlipPage } from '../view/CoverFlipPage';
import { EmulationFlipPage } from '../view/EmulationFlipPage';
import { UpDownFlipPage } from '../view/UpDownFlipPage';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @StorageLink('pageHide') pageHide: boolean = false;
  @State @Watch('showSystemBar') isMenuViewVisible: boolean = false;
  @State buttonClickedIndex: number = PageFlipType.PFT_EMULATION;
  @State filledName: string = '';
  @State currentPageNum: number = 1;
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  onPageShow(): void {
    this.pageHide = false;
  }

  onPageHide(): void {
    this.pageHide = true;
  }

  /**
   * Display the status bar and navigation bar when the menu pops up..
   */
  showSystemBar() {
    try {
      window.getLastWindow(this.context).then((windowClass: window.Window) => {
        if (this.isMenuViewVisible) {
          windowClass.setWindowSystemBarEnable(['status', 'navigation']).catch((err: BusinessError) => {
            hilog.error(0x0000, 'Index',
              `setWindowSystemBarEnable(['status', 'navigation']) failed. Cause: code=${err.code}, message=${err.message}`);
          });
        } else {
          windowClass.setWindowSystemBarEnable([]).catch((err: BusinessError) => {
            hilog.error(0x0000, 'Index',
              `setWindowSystemBarEnable([]) failed. Cause: code=${err.code}, message=${err.message}`);
          });
        }
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'Index', `getLastWindow failed. Cause: code=${err.code}, message=${err.message}`);
      });
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'Index', `setWindowSystemBarEnable failed. Cause: code=${err.code}, message=${err.message}`);
    }
  }

  build() {
    Stack() {
      if (this.buttonClickedIndex === PageFlipType.PFT_EMULATION) {
        EmulationFlipPage({
          isMenuViewVisible: this.isMenuViewVisible,
          currentPageNum: this.currentPageNum
        })
      } else if (this.buttonClickedIndex === PageFlipType.PFT_UP_DOWN) {
        UpDownFlipPage({
          isMenuViewVisible: this.isMenuViewVisible,
          currentPageNum: this.currentPageNum
        })
      } else {
        CoverFlipPage({
          isMenuViewVisible: this.isMenuViewVisible,
          currentPageNum: this.currentPageNum
        })
      }
    }
    .padding({
      top: this.buttonClickedIndex === PageFlipType.PFT_UP_DOWN ? $r('app.integer.stack_padding_top') : 0
    })
    .backgroundColor($r('app.color.page_flip_background_color'))
    .bindSheet(
      $$this.isMenuViewVisible,
      this.sheetBuilder(),
      {
        height: SheetSize.FIT_CONTENT,
        showClose: true,
        title: { title: $r('app.string.setting') },
        maskColor: Color.Transparent,
        backgroundColor: Color.White,
        preferType: SheetType.CENTER
      }
    )
  }

  @Builder
  sheetBuilder() {
    Column({ space: 12 }) {
      Row() {
        Text($r('app.string.page_flip'))
          .fontSize('14fp')
          .fontWeight(500)
          .lineHeight(24)
          .fontColor($r('sys.color.mask_secondary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      BottomView({
        isMenuViewVisible: this.isMenuViewVisible,
        buttonClickedIndex: this.buttonClickedIndex,
        filledName: this.filledName
      })
        .zIndex(Constants.FLIP_PAGE_Z_INDEX)
    }
    .justifyContent(FlexAlign.Start)
    .onClick(() => {
      this.isMenuViewVisible = false;
      this.filledName = '';
    })
    .margin({ top: 8 })
    .padding({
      left: 16,
      right: 16
    })
    .height(128)
  }
}
