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

import { PiPWindow } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';
import { Constants } from '../constants/Constants';
import { AVPlayer } from './AVPlayer';
import Logger from '../utils/Logger';

const TAG = Constants.NAV_DESTINATION_NAME;
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let UIContext = uiContext!.getHostContext()!;

@Extend(Text)
function textType() {
  .padding({ left: $r('app.integer.other_padding') })
  .fontWeight(FontWeight.Bold)
  .fontSize($r('app.integer.text_size'))
  .alignSelf(ItemAlign.Start)
}

@Extend(Text)
function msgType() {
  .padding({ left: $r('app.integer.other_padding') })
  .fontSize($r('app.integer.text_size'))
  .fontColor($r('app.color.Message_color'))
  .alignSelf(ItemAlign.Start)
}

@Component
export struct PlayVideo {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State curState: string = '';
  @State curError: ResourceStr = '';
  @State buttonAction: string = '';
  @State isAutoPull: boolean = false;
  @State isLightBackground: boolean = false;
  @State hintMsgVisibility: boolean = false;
  @State pipTypeString: string = '';
  mXComponentController = new XComponentController();
  surfaceId = '';
  navigationId: string = '';
  player?: AVPlayer;
  pipController?: PiPWindow.PiPController;
  eventHub = UIContext.eventHub;
  private scrollerForScroll: Scroller = new Scroller()

  aboutToAppear(): void {
    this.eventHub.on('onStateChange', (fg: boolean) => {
      if (fg && this.curState === 'STARTED') {
        this.stopPip();
      }
    });
  }

  async startPip() {
    if (!this.pipController) {
      await this.createPipController();
    }
    if (!this.pipController) {
      Logger.info(`[${TAG}] pipController create error`);
      return;
    }
    try {
      await this.pipController.startPiP();
    } catch (err) {
      Logger.error(`StartPiP failed. Cause code: ${err.code}, message: ${err.message}`);
    }
  }

  async stopPip() {
    if (!this.pipController) {
      Logger.info(`[${TAG}] pipController is not exist`);
      return;
    }
    try {
      await this.pipController.stopPiP();
    } catch (err) {
      Logger.error(`StopPiP failed. Cause code: ${err.code}, message: ${err.message}`);
    }
  }

  async createPipController() {
    try {
      this.pipController = await PiPWindow.create({
        context: UIContext,
        componentController: this.mXComponentController,
        navigationId: this.navigationId,
        templateType: PiPWindow.PiPTemplateType.VIDEO_PLAY
      });
      this.pipController.on('stateChange', (state: PiPWindow.PiPState, reason: string) => {
        this.onStateChange(state, reason);
      });
      this.pipController.on('controlPanelActionEvent', (event: PiPWindow.PiPActionEventType, status?: number) => {
        this.onActionEvent(event, status);
      });
    } catch (e) {
      Logger.error(`Failed to create pip controller. Cause:${e.code}, message:${e.message}`);
    }
  }

  destroyPipController() {
    if (!this.pipController) {
      return;
    }
    this.pipController.off('stateChange');
    this.pipController.off('controlPanelActionEvent');
    this.pipController = undefined;
  }

  onStateChange(state: PiPWindow.PiPState, reason: string) {
    switch (state) {
      case PiPWindow.PiPState.ABOUT_TO_START:
        this.curState = 'ABOUT_TO_START';
        this.curError = $r('app.string.current_error_hint');
        break;
      case PiPWindow.PiPState.STARTED:
        this.curState = 'STARTED';
        this.curError = $r('app.string.current_error_hint');
        break;
      case PiPWindow.PiPState.ABOUT_TO_STOP:
        this.curState = 'ABOUT_TO_STOP';
        this.curError = $r('app.string.current_error_hint');
        break;
      case PiPWindow.PiPState.STOPPED:
        this.player?.updatePlayStatus(true);
        this.player?.play();
        this.curState = 'STOPPED';
        this.curError = $r('app.string.current_error_hint');
        break;
      case PiPWindow.PiPState.ABOUT_TO_RESTORE:
        this.curState = 'ABOUT_TO_RESTORE';
        this.curError = $r('app.string.current_error_hint');
        break;
      case PiPWindow.PiPState.ERROR:
        this.curState = 'ERROR';
        this.curError = reason;
        break;
      default:
        break;
    }
    Logger.info(`[${TAG}] onStateChange: ${this.curState}, reason: ${reason}`);
  }

  onActionEvent(event: PiPWindow.PiPActionEventType, status: number | undefined) {
    switch (event) {
      case 'playbackStateChanged':
        if (status === 0) {
          this.player?.updatePlayStatus(false);
          this.player?.pause();
        } else {
          this.player?.updatePlayStatus(true);
          this.player?.play();
        }
        break;
      default:
        break;
    }
    this.buttonAction = event + `-status:${status}`;
    Logger.info(`[${TAG}] onActionEvent: ${this.buttonAction} status:${status}}`);
  }

  build() {
    Stack() {
      NavDestination() {
        Column({ space: Constants.SPACE }) {
          Stack() {
            Text($r('app.string.current_video_pip_play'))
              .fontColor($r('app.color.XComponent_text_color'))
              .margin({ bottom: $r('app.integer.x_component_marg_bottom') })
              .visibility(this.hintMsgVisibility ? Visibility.Visible : Visibility.Hidden)
            XComponent({ id: 'video', type: XComponentType.SURFACE, controller: this.mXComponentController })
              .onLoad(() => {
                Logger.info(`[${TAG}] XComponent onLoad`);
                this.surfaceId = this.mXComponentController.getXComponentSurfaceId();
                this.player = new AVPlayer(this.surfaceId, Constants.AVPLAYER_TYPE);
                this.player.avPlayerFdSrc();
              })
              .onDestroy(() => {
                this.player?.stopAvPlayer();
                Logger.info(`[${TAG}] XComponent onDestroy`);
              })
              .size({ width: Constants.X_COMPONENT_WIDTH, height: $r('app.float.x_component_height') })
              .margin({ top: $r('app.integer.x_component_marg_top') })
              .backgroundColor(Color.Transparent)
              .align(Alignment.Bottom)
              .id('x_component')
          }
          .size({ width: Constants.X_COMPONENT_WIDTH, height: $r('app.float.x_component_height') })
          .alignContent(Alignment.Bottom)
          .backgroundColor($r('app.color.XComponent_backgroundColor'))

          Scroll(this.scrollerForScroll) {
            Column({ space: Constants.SPACE }) {
              this.ControlPip()
              this.AutoPip()
              this.CallbackMessage()
            }
            .width(Constants.NAV_DESTINATION_WIDTH)
          }
          .layoutWeight(Constants.SCROLL_LAY_OUT_WEIGHT)
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
        .width(Constants.NAV_DESTINATION_WIDTH)
        .height(Constants.NAV_DESTINATION_HEIGHT)
      }
      .hideTitleBar(true)
      .backgroundColor($r('app.color.Play_backgroundColor'))
      .onBackPressed(() => {
        // Eject the top-of-the-stack element of the routing stack.
        const popDestinationInfo = this.pageInfos.pop();
        Logger.info('pop' + 'return value' + JSON.stringify(popDestinationInfo));
        return true;
      })
    }
  }

  @Builder
  ControlPip() {
    Row({ space: Constants.SPACE }) {
      Button($r('app.string.start'))
        .width($r('app.integer.control_button_width'))
        .onClick(() => {
          this.startPip();
          this.hintMsgVisibility = true;
        })
      Button($r('app.string.stop'))
        .width($r('app.integer.control_button_width'))
        .onClick(() => {
          this.stopPip();
          this.hintMsgVisibility = false;
        })
    }
    .size({ width: Constants.CONTROL_WIDTH, height: $r('app.integer.control_height') })
    .justifyContent(FlexAlign.SpaceAround)
    .id('pip_control')
  }

  @Builder
  AutoPip() {
    Row() {
      Text($r('app.string.auto'))
        .width($r('app.integer.auto_text_width'))
        .fontSize($r('app.integer.text_size'))
        .fontWeight(FontWeight.Bold)
        .padding({ left: $r('app.integer.other_padding') })

      Toggle({ type: ToggleType.Switch, isOn: this.isAutoPull })
        .width($r('app.integer.auto_button_width'))
        .height($r('app.integer.auto_button_height'))
        .selectedColor($r('app.color.Toggle_selectedColor'))
        .padding({ right: $r('app.float.toggle_padding') })
        .onChange(async (isOn: boolean) => {
          this.isAutoPull = isOn;
          if (!this.pipController) {
            await this.createPipController();
          }
          this.pipController?.setAutoStartEnabled(this.isAutoPull);
          this.hintMsgVisibility = true;
        })
    }
    .width(Constants.AUTO_PIP_WIDTH)
    .height($r('app.integer.auto_pip_height'))
    .borderRadius($r('app.integer.auto_button_board_radius'))
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('app.color.start_window_background'))
  }

  @Builder
  CallbackMessage() {
    Column({ space: Constants.SPACE }) {
      Text($r('app.string.callback_message'))
        .width(Constants.CONTROL_WIDTH)
        .fontColor($r('app.color.Text_color'))
        .padding({ left: $r('app.integer.other_padding') })
      Column() {
        Text($r('app.string.current_status'))
          .textType()
        Text(this.curState)
          .msgType()
      }
      .size({
        width: Constants.CONTROL_WIDTH,
        height: $r('app.integer.control_height')
      })
      .backgroundColor($r('app.color.Callback_message_backgroundColor'))
      .borderRadius($r('app.integer.auto_button_board_radius'))
      .justifyContent(FlexAlign.SpaceAround)
      .id('current_state')

      Column() {
        Text($r('app.string.current_error'))
          .textType()
        Text(this.curError)
          .msgType()
      }
      .size({
        width: Constants.CONTROL_WIDTH,
        height: $r('app.integer.control_height')
      })
      .backgroundColor($r('app.color.Callback_message_backgroundColor'))
      .borderRadius($r('app.integer.auto_button_board_radius'))
      .justifyContent(FlexAlign.SpaceAround)
      .id('current_error')

      Column() {
        Text($r('app.string.current_action'))
          .textType()
        Text(this.buttonAction)
          .msgType()
      }
      .size({
        width: Constants.CONTROL_WIDTH,
        height: $r('app.integer.control_height')
      })
      .backgroundColor($r('app.color.Callback_message_backgroundColor'))
      .borderRadius($r('app.integer.auto_button_board_radius'))
      .justifyContent(FlexAlign.SpaceAround)
      .id('current_action')
    }
  }
}