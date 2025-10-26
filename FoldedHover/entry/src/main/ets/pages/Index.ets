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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, window } from '@kit.ArkUI';
import { CommonConstants as Const } from '../common/CommonConstants';
import { HoveringUsingCustomComponent } from '../view/hoverview/HoverByCustom';
import { HoveringUsingFolderStack } from '../view/hoverview/HoverUseFolderStack';
import { HoveringUsingFoldSplitContainer } from '../view/hoverview/HoverUseFoldSplitContainer';
import { WindowUtil } from '../common/utils/WindowUtil';
import { DisplayUtil } from '../common/utils/DisplayUtil';

const TAG: string = 'INDEX';

@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @StorageLink('isHover') @Watch('onHalfFoldedChange') isHover: boolean = false;
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = Const.BREAKPOINT_LG;
  @StorageLink('currentHeightBreakpoint') currentHeightBreakpoint: string = Const.BREAKPOINT_LG;
  @StorageLink('pageID') @Watch('onPageIDChange') pageID: number = 0;
  @StorageLink('reOnFoldStatusChange') @Watch('onRegister') reOnFoldStatusChange: boolean = false;
  @StorageLink('operateSpace') operateSpace: string = '70vp';
  @State isFolded: boolean = true;
  private bottomHeight: string = '';
  private topHeight: string = '';
  private windowUtil?: WindowUtil;
  // [Start on_fold_status_change]
  private onFoldStatusChange: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
    try {
      // [StartExclude on_fold_status_change]
      if (this.windowUtil === undefined) {
        return;
      }
      // [EndExclude on_fold_status_change]
      let orientation: display.Orientation = display.getDefaultDisplaySync().orientation;

      if (this.pageID === 0 || this.pageID === 3) {
        if (data === display.FoldStatus.FOLD_STATUS_HALF_FOLDED && this.currentWidthBreakpoint === Const.BREAKPOINT_MD &&
          (orientation === display.Orientation.LANDSCAPE ||
            orientation === display.Orientation.LANDSCAPE_INVERTED)) {
          this.isHover = true;
          // [StartExclude on_fold_status_change]
          if (this.pageID === 0) {
            this.pageInfos.pushPathByName(Const.PAGE_NAMES[2], 0);
          }
          // [EndExclude on_fold_status_change]
        } else {
          this.isHover = false;
        }
      }
      // [StartExclude on_fold_status_change]
      if (data === display.FoldStatus.FOLD_STATUS_FOLDED) {
        this.isFolded = true;
      } else {
        this.isFolded = false;
      }
      // [EndExclude on_fold_status_change]
    } catch (error) {
      hilog.error(0x0000, TAG, `onFoldStatusChange catch error, code: ${error.code}, message: ${error.message}`);
    }
  };
  // [End on_fold_status_change]
  private onWindowSizeChange: () => void = () => {
    if (this.currentHeightBreakpoint === 'md' && this.currentWidthBreakpoint === 'md') {
      this.operateSpace = '70vp';
      if (this.isHover && this.pageID === 3) {
        this.windowUtil!.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED);
      } else if (this.pageID !== 2) {
        this.windowUtil!.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
      }
    } else {
      this.operateSpace = '50vp';
      if (this.pageID === 0) {
        this.windowUtil!.setMainWindowOrientation(window.Orientation.PORTRAIT);
      } else if (this.pageID !== 2) {
        this.windowUtil!.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED);
      }
    }
  }

  private onHalfFoldedChange(): void {
    if (this.isHover) {
      this.windowUtil!.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED);
    } else {
      if (this.currentHeightBreakpoint === 'md' && this.currentWidthBreakpoint === 'md') {
        this.windowUtil!.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
      }
    }
  }

  private onPageIDChange(): void {
    if (this.pageID !== 3) {
      this.isHover = false;
    }
  }

  private onRegister(): void {
    // [Start display_on_fold_status_change]
    try {
      display.on('foldStatusChange', this.onFoldStatusChange);
    } catch (exception) {
      hilog.error(0x0000, TAG, 'Failed to register onFoldStatusChange callback. Code: ' + JSON.stringify(exception));
    }
    // [End display_on_fold_status_change]
  }

  aboutToAppear(): void {
    AppStorage.setOrCreate<number>('pageID', 0);
    AppStorage.setOrCreate<Boolean>('reOnFoldStatusChange', false);
    this.windowUtil = WindowUtil.getInstance();
    if (this.windowUtil === undefined) {
      hilog.error(0x0000, TAG, `WindwoUtil is undefined`);
      return;
    }
    DisplayUtil.getFoldCreaseRegion();
    this.windowUtil.setFullScreen();
    this.windowUtil.getMainWindow()?.on('windowSizeChange', this.onWindowSizeChange);

    try {
      display.on('foldStatusChange', this.onFoldStatusChange);
    } catch (exception) {
      hilog.error(0x0000, TAG, 'Failed to register onFoldStatusChange callback. Code: ' + JSON.stringify(exception));
    }

    let top = this.windowUtil.getTopHeight(this.getUIContext());
    let bottom = this.windowUtil.getBottomHeight(this.getUIContext());
    if (top !== undefined) {
      this.topHeight = (top + 64).toString() + 'vp';
    }
    if (bottom !== undefined) {
      this.bottomHeight = (bottom + 16).toString() + 'vp';
    }

    if (this.currentHeightBreakpoint === 'md' && this.currentWidthBreakpoint === 'md') {
      this.isFolded = false;
      AppStorage.setOrCreate<string>('operateSpace', '70vp');
      this.windowUtil.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
    } else {
      this.isFolded = true;
      AppStorage.setOrCreate<string>('operateSpace', '50vp');
      this.windowUtil.setMainWindowOrientation(window.Orientation.PORTRAIT);
    }
  }

  aboutToDisappear(): void {
    try {
      display.off('foldStatusChange');
      this.windowUtil!.offWindowSizeChange();
    } catch (exception) {
      hilog.error(0x0000, TAG, 'Failed to unregister callback. Code: ' + JSON.stringify(exception));
    }
  }

  @Builder
  pagesMap(name: string) {
    if (name === Const.PAGE_NAMES[0]) {
      HoveringUsingFolderStack()
    } else if (name === Const.PAGE_NAMES[1]) {
      HoveringUsingFoldSplitContainer()
    } else if (name === Const.PAGE_NAMES[2]) {
      HoveringUsingCustomComponent()
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Column() {
          Text($r('app.string.EntryAbility_label'))
            .fontSize('30fp')
            .fontWeight(700)
        }
        .width('100%')
        .height('40%')
        .padding({ left: this.isFolded ? 0 : '24vp' })
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 12 }) {
          ForEach(Const.PAGE_TITLES, (item: Resource, index: number) => {
            Button(item)
              .width(this.isFolded ? '100%' : '448vp')
              .height('40vp')
              .onClick(() => {
                this.pageInfos.pushPathByName(Const.PAGE_NAMES[index], 0);
              })
          }, (item: Resource) => {
            return JSON.stringify(item);
          })
        }
        .width('100%')
        .height('60%')
        .justifyContent(FlexAlign.End)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding({
        left: '16vp',
        right: '16vp',
        top: this.topHeight,
        bottom: this.bottomHeight
      })
    }
    .width('100%')
    .height('100%')
    .hideToolBar(true)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.pagesMap)
    .backgroundColor(0XF1F3F5)
  }
}