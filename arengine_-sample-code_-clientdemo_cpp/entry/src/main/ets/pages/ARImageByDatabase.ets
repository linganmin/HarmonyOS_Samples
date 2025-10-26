/*
 * Copyright (c) 2024-2025 Huawei Device Co., Ltd.
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

import { display } from '@kit.ArkUI';
import { resourceManager } from '@kit.LocalizationKit';
import { systemDateTime } from '@kit.BasicServicesKit';
import arEngineDemo from 'libentry.so';
import { Logger } from '../utils/Logger';

@Builder
export function ARImageByDatabaseBuilder() {
  ARImageByDatabase();
}

@Component
struct ARImageByDatabase {
  pageInfos: NavPathStack = new NavPathStack();
  private isSurfaceDestroy: boolean = false;
  private interval: number = -1;
  private isUpdate: boolean = false;
  private xComponentId: string = 'ARImage';
  @State context: Context = this.getUIContext().getHostContext() as Context;
  private resMgr: resourceManager.ResourceManager = this.context.resourceManager;
  @State rotation: number = display.getDefaultDisplaySync().rotation;
  @State showPage: boolean = true;
  private idStr: string = systemDateTime.getTime(false).toString() + this.xComponentId;

  build(): void {
    NavDestination() {
      RelativeContainer() {
        XComponent({ id: this.idStr, type: XComponentType.SURFACE, libraryname: 'entry' })
          .width('100%')
          .height('100%')
          .visibility(this.showPage ? Visibility.Visible : Visibility.None)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .onLoad(() => {
            Logger.info(`XComponent onLoad ${this.idStr}.`);
            this.interval = setInterval(() => {
              if (this.isUpdate) {
                arEngineDemo.update(this.idStr);
              }
            }, 33) // Set the frame rate to 30 fps (with the frame refreshed every 33 ms).
          })
          .onDestroy(() => {
            Logger.info(`XComponent onDestroy ${this.idStr}.`);
            this.isSurfaceDestroy = true;
            clearInterval(this.interval);
          })
      }
    }
    .onAppear(() => {
      arEngineDemo.init(this.resMgr);
      let config: Int32Array = new Int32Array([1, this.rotation]);
      arEngineDemo.start(this.idStr, config);

      arEngineDemo.setPath(this.idStr, this.context.filesDir);

      let imageCountInDatabase: number = arEngineDemo.getImageCount(this.idStr);
      Logger.info(`ImageCountInDatabase: ${imageCountInDatabase}.`);
      if (imageCountInDatabase <= 0) {
        this.ShowDialog(this.context.resourceManager.getStringByNameSync('invalid_image_added'));
      }
    })
    .onWillDisappear(() => {
      arEngineDemo.stop(this.idStr);
    })
    .onShown(() => {
      this.isUpdate = true;
      arEngineDemo.show(this.idStr);
    })
    .onHidden(() => {
      this.isUpdate = false;
      if (!this.isSurfaceDestroy) {
        arEngineDemo.hide(this.idStr);
      }
    })
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
    .hideTitleBar(true)
    .hideBackButton(true)
    .hideToolBar(true)
  }

  ShowDialog(msg: string): void {
    this.getUIContext().showAlertDialog({
      title: $r('app.string.warning'),
      message: msg,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      offset: { dx: 0, dy: -20 },
      gridCount: 3,
      transition: TransitionEffect
        .asymmetric(TransitionEffect.OPACITY
          .animation({ duration: 1000, curve: Curve.Sharp })
          .combine(TransitionEffect
            .scale({ x: 1.5, y: 1.5 })
            .animation({ duration: 1000, curve: Curve.Sharp })
          ),
          TransitionEffect.OPACITY.animation({ duration: 100, curve: Curve.Smooth })
          .combine(TransitionEffect.scale({ x: 0.5, y: 0.5 })
            .animation({ duration: 100, curve: Curve.Smooth })
          )
        ),
      buttons: [{
        enabled: true,
        defaultFocus: true,
        style: DialogButtonStyle.HIGHLIGHT,
        value: $r('app.string.back'),
        action: () => {
          Logger.info('Callback when the second button is clicked.');
          this.pageInfos.pop();
        }
      }]
    })
  }
}
