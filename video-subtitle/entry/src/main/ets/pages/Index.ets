/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { VideoPage } from './VideoPage';
import { Logger } from '../utils/Logger';

const LOG_TAG = 'INDEX';
const orientation = window.Orientation.LANDSCAPE;

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack();
  private currentWindow: window.Window | null = null;

  aboutToAppear(): void {
    try {
      window.getLastWindow(this.getUIContext().getHostContext())
        .then(async (topWindow) => {
          this.currentWindow = topWindow;
          topWindow.setPreferredOrientation(orientation, (err: BusinessError) => {
            const errCode: number = err.code;
            if (errCode) {
              Logger.error(LOG_TAG,
                `Failed to set window orientation. Cause code: ${err.code}, message: ${err.message}`);
              return;
            }
            topWindow.setWindowSystemBarEnable(['status', 'navigation']);
          });
        }).catch((err: BusinessError) => {
        Logger.error(LOG_TAG, `Failed to obtain the top window. Cause code: ${err.code}, message: ${err.message}`);
      });
    } catch (exception) {
      Logger.error(LOG_TAG, 'Failed to enter immersive. Cause:', JSON.stringify(exception));
    }
  }

  @Builder
  buttonBuilder(text: ResourceStr, isVideo: boolean) {
    Button(text)
      .fontWeight(500)
      .fontSize(16)
      .width('50%')
      .fontColor('rgb(10,89,247)')
      .backgroundColor('rgba(0,0,0,0.05)')
      .onClick(async () => {
        await this.currentWindow?.setWindowSystemBarEnable([]);
        this.pageStack.pushPathByName('videoPage', isVideo);
      })
  }

  @Builder
  PagesMap(name: string, isVideo: boolean) {
    if (name === 'videoPage') {
      VideoPage({ isVideo, currentWindow: this.currentWindow });
    }
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        Text($r('app.string.demo_title'))
          .fontSize(30)
          .fontWeight(700)
      }
      .padding({ left: 36, top: 8 })
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Column({ space: 12 }) {
        this.buttonBuilder($r('app.string.av_caption'), false)
        this.buttonBuilder($r('app.string.video_caption'), true)
      }
      .width('100%')
      .position({ bottom: 16 })
    }
    .mode(NavigationMode.Stack)
    .navDestination(this.PagesMap)
    .hideToolBar(true)
    .hideTitleBar(true)
    .titleMode(NavigationTitleMode.Full)
    .onNavBarStateChange((isVisible) => {
      if (isVisible && this.currentWindow) {
        this.currentWindow.setWindowSystemBarEnable(['status', 'navigation']);
      }
    })
  }
}