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
import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { VideoPlayerController } from '../controller/VideoPlayerController';
import { VideoSessionController } from '../controller/VideoSessionController';
import Logger from '../common/utils/Logger';

const TAG = '[AvplayerView]';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');

@Component
export struct AvplayerView {
  @StorageLink('avPlayerController') @Watch('avPlayerStateChange') avPlayerController?: VideoPlayerController =
    undefined;
  @StorageLink('avSessionController') avSessionController ?: VideoSessionController = undefined;
  @State surfaceID: string = '';
  @State currentTime: number = 0;
  @State durationTime: number = 0;
  @Prop filePath: string;
  private xComponentController: XComponentController = new XComponentController();


  async aboutToDisappear() {
    try {
      await this.releaseAVPlayer();
      await this.releaseAVSession();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG,
        `Release video by aboutToDisappear failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  /**
   * Load XComponent.
   */
  async onDidBuild() {
    try {
      await this.releaseAVPlayer();
      await this.initAVPlayer();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Init video by onDidBuild failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  async releaseAVPlayer() {
    if (this.avPlayerController) {
      try {
        await this.avPlayerController.releasePlayer();
        this.avPlayerController = undefined;
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `Release Avplayer failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      }
    }
  }

  async releaseAVSession() {
    if (this.avSessionController) {
      try {
        await this.avSessionController.releaseAvSessionListener(uiContext?.getHostContext() as common.UIAbilityContext);
        this.avSessionController = undefined;
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `Release AVSession failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      }
    }
  }

  async initAVPlayer() {
    this.surfaceID = this.xComponentController.getXComponentSurfaceId();
    try {
      this.avPlayerController =
        await VideoPlayerController.create(this.surfaceID, this.filePath);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Init Avplayer failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  async initAVSession() {
    if (this.avPlayerController) {
      try {
        this.avSessionController =
          await VideoSessionController.create(uiContext?.getHostContext() as common.UIAbilityContext);
        await this.configSession();
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `Init Avsession failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      }
    }
  }

  /**
   * Configures AV session with player controller.
   * Sets up metadata, playback state, and event listeners.
   */
  async configSession() {
    if (!this.avSessionController || !this.avPlayerController) {
      return;
    }
    try {
      await this.avSessionController.setAVMetadata('1', this.durationTime);
      await this.avSessionController.setAvSessionListener(this.avPlayerController);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Config Avsession failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    this.avSessionController.initAvSessionPlayState(this.avPlayerController);
    this.avPlayerController.onStateChange(async (newState: string) => {
      this.avSessionController?.setAvSessionState(newState);
    });
    this.avPlayerController.onPositionChange(async (newPosition: number) => {
      this.avSessionController?.setAvSessionPosition(newPosition);
    });
    this.avPlayerController.onInterrupt(async (playState: avSession.AVPlaybackState) => {
      Logger.debug(TAG, `onInterrupt avPlayerController state = ${playState.state}.`);
      try {
        await this.avSessionController?.videoSession.setAVPlaybackState(playState);
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `setAVPlaybackState failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      }
    });
  }

  /**
   * Callback for changes in the live video playback status.
   */
  async avPlayerStateChange() {
    if (this.avPlayerController) {
      this.currentTime = this.avPlayerController.currentTime;
      this.durationTime = this.avPlayerController.durationTime;
      if (this.avPlayerController.state === 'prepared') {
        if (!this.avSessionController) {
          try {
            await this.initAVSession();
          } catch (error) {
            let err = error as BusinessError;
            Logger.error(TAG, `Init Avsession failed, errCode = ${err.code}, errMessage = ${err.message}.`);
          }
        } else {
          try {
            await this.configSession();
          } catch (error) {
            let err = error as BusinessError;
            Logger.error(TAG, `Config Avsession failed, errCode = ${err.code}, errMessage = ${err.message}.`);
          }
        }
      }
    }
  }

  build() {
    RelativeContainer() {
      XComponent({
        id: 'player',
        type: XComponentType.SURFACE,
        controller: this.xComponentController
      })
        .width('100%')
        .height('100%')
        .onClick(() => {
          Logger.debug(TAG, "begin click setAVPlayerPlaying");
          this.avPlayerController?.setAVPlayerPlaying();
        })
        .alignRules({
          'middle': { 'anchor': '__container__', 'align': HorizontalAlign.Center },
          'center': { 'anchor': '__container__', 'align': VerticalAlign.Center }
        })
        .expandSafeArea(
          [SafeAreaType.SYSTEM, SafeAreaType.CUTOUT],
          [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]
        )
    }
    .backgroundColor(Color.Black);
  }
}
