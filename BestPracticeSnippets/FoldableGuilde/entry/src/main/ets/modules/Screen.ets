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

import { display, window } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct Movie {
  @State isFoldable: Boolean = false
  @State foldStatus: display.FoldStatus = 1
  private mainWindow: window.Window | undefined;
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private onDetailFoldStatusChange: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
    if (data === display.FoldStatus.FOLD_STATUS_FOLDED) {
      // 当前折叠状态为折叠态，设置窗口横屏显示
      this.mainWindow?.setPreferredOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE);
    } else if (data === display.FoldStatus.FOLD_STATUS_EXPANDED) {
      // 如果折叠状态为展开态，设置窗口跟随传感器自动旋转，且受控制中心的旋转开关控制
      this.mainWindow?.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
    }
  };

  // 如果使用Navigation路由跳转，需要在NavDestination的onShown()和onHidden()事件中注册监听
  onPageShow(): void {
    // 获取应用主窗口
    window.getLastWindow(this.context).then((data: window.Window) => {
      this.mainWindow = data;
      console.info('Succeeded in obtaining the top window. Data: ' + JSON.stringify(data));
      try {
        let foldStatus: display.FoldStatus = display.getFoldStatus();
        if (foldStatus === display.FoldStatus.FOLD_STATUS_FOLDED) {
          // 当前折叠状态为折叠态，设置窗口横屏显示
          this.mainWindow?.setPreferredOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE).catch((err: BusinessError) => {
            console.error(`Failed to set AUTO_ROTATION_LANDSCAPE. Cause code: ${err.code}, message: ${err.message}`);
          });
        } else if (foldStatus === display.FoldStatus.FOLD_STATUS_EXPANDED) {
          // 如果折叠状态为展开态，设置窗口跟随传感器自动旋转，且受控制中心的旋转开关控制
          this.mainWindow?.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED).catch((err: BusinessError) => {
            console.error(`Failed to set AUTO_ROTATION_RESTRICTED. Cause code: ${err.code}, message: ${err.message}`);
          });
        }
        // 监听折叠屏折叠状态
        display.on('foldStatusChange', this.onDetailFoldStatusChange);
      } catch (err) {
        console.error(`Failed to obtain the fold status. Cause code: ${err.code}, message: ${err.message}`);
      }
    }).catch((err: BusinessError) => {
      console.error(`Failed to obtain the top window. Cause code: ${err.code}, message: ${err.message}`);
    });
  }

  onPageHide(): void {
    try {
      display.off('foldStatusChange');
    } catch (err) {
      console.error(`Failed to cancel monitoring the fold status. Cause code: ${err.code}, message: ${err.message}`);
    }
  }

  build() {
    Column() {
      Text('demo')
    }
    .margin({ top: 100 })
  }
}