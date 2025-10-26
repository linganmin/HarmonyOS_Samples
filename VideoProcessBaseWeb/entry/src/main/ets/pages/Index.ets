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

import { webview } from '@kit.ArkWeb';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AlertDialog, ComponentContent, promptAction, window } from '@kit.ArkUI';
import { Constants } from '../common/Constants';
import { WebDownloadManager } from '../utils/WebDownloadManager';
import { downloadControlBuilder } from '../view/DownloadControlView';
import { customPopupMenuBuilder, getOffset } from '../view/CustomPopupMenu';

@Entry
@Component
struct Index {
  @State isShow: boolean = false;
  @State pressPosY: number = 0;
  @State pressPosX: number = 0;
  @StorageProp(Constants.SYSTEM_LANGUAGE_KEY) language: string = '';
  private handler: FullScreenExitHandler | null = null;
  private result: WebContextMenuResult | null = null;
  private webController: webview.WebviewController = new webview.WebviewController();
  private isFullScreen: boolean = false;
  private linkUrl: string = '';
  private webWidth: number = 0;
  private webHeight: number = 0;
  private windowClass: window.Window | null = null;
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private manager: WebDownloadManager = WebDownloadManager.getInstance();
  private ctx: UIContext = this.getUIContext();
  private options: promptAction.BaseDialogOptions = {
    alignment: DialogAlignment.Center,
    isModal: true,
    autoCancel: false,
    onWillDismiss: () => {
      WebDownloadManager.getInstance().pause();
      this.dialogControllerConfirm.open();
    }
  };
  private contentNode: ComponentContent<Object> = new ComponentContent(this.ctx, wrapBuilder(downloadControlBuilder));
  private dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.confirm_cancel'),
      content: $r('app.string.confirm_task_cancel'),
      primaryButton: {
        value: $r('app.string.cancel_download'),
        fontColor: Color.Red,
        action: () => {
          this.manager.cancel();
          this.closeDownloadDialog();
        }
      },
      secondaryButton: {
        value: $r('app.string.resume_download'),
        action: () => {
          this.manager.unpause();
        }
      }
    })
  });
  private openDownloadDialog = () => {
    this.ctx.getPromptAction().openCustomDialog(this.contentNode, this.options).catch((error: BusinessError<void>) => {
      hilog.error(0x0000, 'testTag', 'Execution failed, code = %{public}d, message = %{public}s',
        error.code, error.message);
    });
  };
  private closeDownloadDialog = () => {
    this.ctx.getPromptAction().closeCustomDialog(this.contentNode).catch((error: BusinessError<void>) => {
      hilog.error(0x0000, 'testTag', 'Execution failed, code = %{public}d, message = %{public}s',
        error.code, error.message);
    });
  };
  private changeIsShow = () => {
    this.isShow = !this.isShow;
  };

  aboutToAppear(): void {
    window.getLastWindow(this.context)
      .then((windowClass) => this.windowClass = windowClass)
      .catch((error: BusinessError<void>) => {
        hilog.error(0x0000, 'testTag', 'Execution failed, code = %{public}d, message = %{public}s',
          error.code, error.message);
      });
    this.manager.registerController(Constants.INDEX_WEB_CONTROLLER, this.webController);
    AppStorage.setOrCreate<ComponentContent<Object>>('contentNode', this.contentNode);
    hilog.info(0x000, Constants.TAG, 'language: ' + this.language);
  }

  /**
   * Changes the preferred orientation of the window.
   *
   * @param orientation - The preferred orientation to set. This should be a value from the `window.Orientation` enum.
   * @returns void - This function does not return any value.
   */
  changeOrientation(orientation: window.Orientation) {
    this.windowClass?.setPreferredOrientation(orientation).catch((error: BusinessError<void>) => {
      hilog.error(0x0000, 'testTag', 'Execution failed, code = %{public}d, message = %{public}s',
        error.code, error.message);
    });
  }

  onBackPress(): boolean | void {
    if (this.isFullScreen && this.handler) {
      this.handler.exitFullScreen();
      return true;
    }
    return false;
  }

  build() {
    Column() {
      Web({
        src: $rawfile(/zh/.test(this.language) ? 'index_cn.html' : 'index_en.html'),
        controller: this.webController
      })
        .zoomAccess(false)
        .width('100%')
        .height('100%')
        .onAreaChange((oldArea, newArea) => {
          this.webWidth = newArea.width as number;
          this.webHeight = newArea.height as number;
        })
        .onContextMenuShow((event) => {
          if (!event) {
            return false;
          }
          this.result = event.result;
          this.pressPosX = this.getUIContext().px2vp(event.param.x());
          this.pressPosY = this.getUIContext().px2vp(event.param.y());
          this.linkUrl = event.param.getSourceUrl();
          this.isShow = true;
          return true;
        })
        .bindPopup(this.isShow, {
          builder: customPopupMenuBuilder(
            this.linkUrl,
            this.context,
            this.openDownloadDialog,
            this.closeDownloadDialog,
            this.changeIsShow,
          ),
          enableArrow: false,
          placement: Placement.TopLeft,
          offset: getOffset(this.webWidth, this.webHeight,
            this.pressPosX, this.pressPosY),
          onStateChange: (event) => {
            if (!event.isVisible) {
              this.isShow = false;
              this.result?.closeContextMenu();
            }
          }
        })
        .onFullScreenEnter((event) => {
          this.handler = event.handler;
          this.changeOrientation(window.Orientation.LANDSCAPE);
          this.isFullScreen = true;
        })
        .onFullScreenExit(() => {
          this.changeOrientation(window.Orientation.PORTRAIT);
          this.isFullScreen = false;
        })
    }
  }
}