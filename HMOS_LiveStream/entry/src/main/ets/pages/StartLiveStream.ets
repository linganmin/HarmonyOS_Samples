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

import { ApplicationStateChangeCallback, common } from '@kit.AbilityKit';
import Logger from '../common/utils/Logger';
import { BackgroundTaskManager } from '../common/utils/BackgroundTaskManager';
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager';
import { CameraController } from '../controller/CameraController';
import { StartLiveDecorationView } from '../view/StartLiveDecorationView';
import { StartLiveRenderView } from '../view/StartLiveRenderView';
import { BgmController } from '../controller/BgmController';
import { DistributeFileManager } from '../controller/DistributeFileManager';


const TAG: string = '[StartLiveStream]';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');

@Builder
export function StartLiveStreamBuilder() {
  StartLiveStream();
}

@Component
struct StartLiveStream {
  @Consume('pageStack') pageStack: NavPathStack;
  @Consume('cameraController') cameraController: CameraController;
  @Consume('bgmController') bgmController: BgmController;
  @Consume('fileNameSandbox') fileNameSandbox: string;

  async aboutToAppear(): Promise<void> {
    this.cameraController?.updateImageRotation();
    this.cameraController?.onDisplayCallback();

    let appContext = uiContext?.getHostContext()!!.getApplicationContext();
    if (appContext) {
      appContext.on('applicationStateChange', this.thisApplicationStateChangeCallback);
    }
  }

  aboutToDisappear(): void {
    this.cameraController?.offDisplayCallback();
    let appContext = uiContext?.getHostContext()!!.getApplicationContext();
    if (appContext) {
      appContext.off('applicationStateChange', this.thisApplicationStateChangeCallback);
    }
  }

  build() {
    NavDestination() {
      Stack() {
        StartLiveRenderView();
        StartLiveDecorationView();
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
      .expandSafeArea()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      BackgroundTaskManager.stopContinuousTask(uiContext?.getHostContext() as common.UIAbilityContext);
      this.cameraController.release();
      this.bgmController.release();
      this.pageStack.pop()
      return true;
    })
    .onAppear(() => {
      BackgroundTaskManager.startContinuousTask(backgroundTaskManager.BackgroundMode.AUDIO_RECORDING,
        uiContext?.getHostContext() as common.UIAbilityContext);
    })
    .onDisAppear(async () => {
      // copy file from sandbox to distribute file
      const distributeFileManager = new DistributeFileManager();
      await distributeFileManager.copyFileToDistribute(uiContext?.getHostContext() as common.UIAbilityContext,
        this.fileNameSandbox);
    })
    .hideTitleBar(true)
    .expandSafeArea()
  }

  private thisApplicationStateChangeCallback: ApplicationStateChangeCallback = {
    onApplicationForeground: () => {
      Logger.info(TAG, `onApplicationForeground.`);
      this.cameraController?.createRecorder();
    },
    onApplicationBackground: () => {
      Logger.info(TAG, `onApplicationBackground.`);
      this.cameraController?.releaseCamera();
    }
  }
}