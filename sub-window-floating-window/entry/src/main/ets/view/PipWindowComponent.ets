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

import { BusinessError } from '@kit.BasicServicesKit';
import { PiPWindow, window } from '@kit.ArkUI';
import { AVPlayerDemo } from '../viewmodel/AVPlayerDemo';
import Logger from '../utils/Logger';
import CommonConstants from '../constants/CommonConstants';
import { common } from '@kit.AbilityKit';

@Component
export struct PipWindowComponent {
  @State windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;
  @State isPipWindow: boolean = false;
  @Consume('pageInfos') pageInfos: NavPathStack;
  private surfaceId: string = '';
  private mXComponentController: XComponentController = new XComponentController();
  private player?: AVPlayerDemo = undefined;
  private pipController?: PiPWindow.PiPController = undefined;
  private isPlay: boolean = false;
  navId: string = '';

  build() {
    NavDestination() {
      Column() {
        Row() {
          XComponent({ id: 'pipDemo', type: XComponentType.SURFACE, controller: this.mXComponentController })
            .onLoad(() => {
              this.surfaceId = this.mXComponentController.getXComponentSurfaceId();
              this.player = new AVPlayerDemo(this.surfaceId);
              this.player.avPlayerFdSrcDemo(this.getUIContext().getHostContext() as common.UIAbilityContext);
            })
            .onDestroy(() => {
              Logger.info(`XComponent onDestroy`);
            })
            .size({
              width: CommonConstants.FULL_PERCENT,
              height: this.getUIContext().px2vp(CommonConstants.DEFAULT_VIDEO_HEIGHT)
            })
        }
        .alignItems(VerticalAlign.Center)

        Row() {
          Button($r('app.string.enable_picture'))
            .width(CommonConstants.FULL_PERCENT)
            .visibility(this.isPipWindow ? Visibility.Hidden : Visibility.Visible)
            .onClick(() => {
              this.startPip();
              this.isPipWindow = true;
            })
        }
        .padding($r('app.float.common_lr_padding'))
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
    }
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onHidden(() => {
      if (!this.isPipWindow) {
        this.player?.pause();
      }
    })
  }

  startPip() {
    if (!PiPWindow.isPiPEnabled()) {
      Logger.error(`picture in picture disabled for current OS`);
      return;
    }
    let config: PiPWindow.PiPConfiguration = {
      context: this.getUIContext().getHostContext()!,
      componentController: this.mXComponentController,
      navigationId: this.navId,
      templateType: PiPWindow.PiPTemplateType.VIDEO_PLAY
    };
    PiPWindow.create(config).then((controller: PiPWindow.PiPController) => {
      this.pipController = controller;
      this.initPipController();
      this.pipController.startPiP().then(() => {
        this.player?.play();
        Logger.info(`Succeeded in starting pip.`);
      }).catch((err: BusinessError) => {
        Logger.error(`Failed to start pip. Cause:${err.code}, message:${err.message}`);
      });
    }).catch((err: BusinessError) => {
      Logger.error(`Failed to create pip controller. Cause:${err.code}, message:${err.message}`);
    });
  }

  initPipController() {
    if (!this.pipController) {
      return;
    }
    this.pipController.setAutoStartEnabled(true);
    this.pipController.on('stateChange', (state: PiPWindow.PiPState, reason: string) => {
      this.onStateChange(state, reason);
    });
    this.pipController.on('controlPanelActionEvent', (event: PiPWindow.PiPActionEventType, status?: number) => {
      this.onActionEvent(event, status);
    });
  }

  onStateChange(state: PiPWindow.PiPState, reason: string) {
    let curState: string = '';
    switch (state) {
      case PiPWindow.PiPState.ABOUT_TO_START:
        curState = 'ABOUT_TO_START';
        break;
      case PiPWindow.PiPState.STARTED:
        curState = 'STARTED';
        break;
      case PiPWindow.PiPState.ABOUT_TO_STOP:
        this.isPipWindow = false;
        if (!this.isPlay) {
          this.player?.pause();
        }
        this.isPlay = false;
        curState = 'ABOUT_TO_STOP';
        break;
      case PiPWindow.PiPState.STOPPED:
        this.isPipWindow = false;
        curState = 'STOPPED';
        break;
      case PiPWindow.PiPState.ABOUT_TO_RESTORE:
        this.isPlay = true;
        curState = 'ABOUT_TO_RESTORE';
        break;
      case PiPWindow.PiPState.ERROR:
        curState = 'ERROR';
        break;
      default:
        break;
    }
    Logger.info(`onStateChange: ${curState}, reason: ${reason}`);
  }

  onActionEvent(event: PiPWindow.PiPActionEventType, status?: number) {
    switch (event) {
      case 'playbackStateChanged':
        if (status === 1) {
          this.player?.play();
        } else {
          this.player?.pause();
        }
        break;
      case 'nextVideo':
        break;
      case 'previousVideo':
        break;
      default:
        break;
    }
  }

  updateContentSize(width: number, height: number) {
    if (this.pipController) {
      this.pipController.updateContentSize(width, height);
    }
  }

  stopPip() {
    if (this.pipController) {
      let promise: Promise<void> = this.pipController.stopPiP().catch((error: BusinessError) => {
        Logger.error(`stopPiP error, code is ${error.code}, message is ${error.message}`);
      });
      promise.then(() => {
        Logger.info(`Succeeded in stopping pip.`);
        this.pipController?.off('stateChange');
        this.pipController?.off('controlPanelActionEvent');
      }).catch((err: BusinessError) => {
        Logger.error(`Failed to stop pip. Cause:${err.code}, message:${err.message}`);
      });
    }
  }
}