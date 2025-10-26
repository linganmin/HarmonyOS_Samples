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

import { PiPWindow } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { AvPlayerController } from '../controller/AvPlayerController';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConstants } from '../common/constants/CommonConstants';

const TAG = '[PiPWindowController]';

//picture in picture controller
export class PiPWindowController {
  pipController?: PiPWindow.PiPController;
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');
  public avPlayerController?: AvPlayerController;
  private xComponentController?: XComponentController;
  private curState: string = '';

  constructor(avPlayerController: AvPlayerController, xComponentController: XComponentController) {
    this.avPlayerController = avPlayerController;
    this.xComponentController = xComponentController;
  }

  // create PIPWindows
  async createPipController() {
    if (!this.pipController) {
      try {
        this.pipController = await PiPWindow.create({
          context: this.context,
          componentController: this.xComponentController,
          templateType: PiPWindow.PiPTemplateType.VIDEO_PLAY
        });
      } catch (error) {
        hilog.error(CommonConstants.LOG_DOMAIN,CommonConstants.LOG_TAG,
          `pipController init filed, error code is = ${error.code},error message is = ${error.message}`);
      }
    }
    this.pipController?.on('stateChange', (State: PiPWindow.PiPState, reason: string) => {
      this.onStateChange(State, reason);
    })

    this.pipController?.on('controlPanelActionEvent', (event: PiPWindow.PiPActionEventType, status?: number) => {
      this.onActionEvent(event, status);
    })
    this.pipController?.setAutoStartEnabled(true); // key point:  Set the animation to start when the application returns to the desktop
  }

  // destroy PIPWindows
  destroyPipController() {
    if (!this.pipController) {
      return;
    }
    this.pipController.setAutoStartEnabled(false);
    this.pipController.off('stateChange');
    this.pipController.off('controlPanelActionEvent');
    this.pipController = undefined;
  }

  onStateChange(state: PiPWindow.PiPState, reason: string) {
    switch (state) {
      case PiPWindow.PiPState.ABOUT_TO_START:
        this.curState = 'ABOUT_TO_START';
        break;
      case PiPWindow.PiPState.STARTED:
        this.curState = 'STARTED';
        let status: PiPWindow.PiPControlStatus =
          this.avPlayerController?.isPlaying ? PiPWindow.PiPControlStatus.PLAY : PiPWindow.PiPControlStatus.PAUSE;
        this.pipController?.updatePiPControlStatus(PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE, status);
        break;
      case PiPWindow.PiPState.ABOUT_TO_STOP:
        this.curState = 'ABOUT_TO_STOP';
        break;
      case PiPWindow.PiPState.STOPPED:
        this.curState = 'STOPPED';
        break;
      case PiPWindow.PiPState.ABOUT_TO_RESTORE:
        this.curState = 'ABOUT_TO_RESTORE';
        break;
      case PiPWindow.PiPState.ERROR:
        this.curState = 'ERROR';
        break;
      default:
        break;
    }
    hilog.info(CommonConstants.LOG_DOMAIN,CommonConstants.LOG_TAG, `onStateChange: ${this.curState}, reason: ${reason}`);
  }

  onActionEvent(event: PiPWindow.PiPActionEventType, status?: number) {
    switch (event) {
      case 'playbackStateChanged':
        if (status === 0) {
          this.avPlayerController?.videoPause();
        } else {
          this.avPlayerController?.videoPlay();
        }
        break;
      default:
        break;
    }
  }
}