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

@Builder
export function ARSemanticDenseRenderBuilder() {
  ARSemanticDenseRender();
}

@Component
struct ARSemanticDenseRender {
  pageInfos: NavPathStack = new NavPathStack();
  @State context: Context = this.getUIContext().getHostContext() as Context;
  private xComponentId: string = 'ARSemanticDense';
  private resMgr: resourceManager.ResourceManager = this.context.resourceManager;
  private interval: number = -1;
  private inputInterval: number = -1;
  private getCubeInfoInterval: number = -1;
  private isUpdate: boolean = false;
  private semanticDenseMode: number = 0;
  @State showPage: boolean = true;
  @State rotation: number = display.getDefaultDisplaySync().rotation;
  @State volume: string = '';
  private idStr: string = systemDateTime.getTime(false).toString() + this.xComponentId;

  build(): void {
    NavDestination() {
      RelativeContainer() {

        XComponent({ id: this.idStr, type: XComponentType.SURFACE, libraryname: 'entry' })
          .opacity(0.2)
          .width('100%')
          .height('100%')
          .zIndex(0.1)
          .visibility(this.showPage ? Visibility.Visible : Visibility.None)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .onLoad(() => {
            this.interval = setInterval(() => {
              if (this.isUpdate) {
                arEngineDemo.update(this.idStr);
                if (this.semanticDenseMode != 0) {
                  this.volume = arEngineDemo.getVolume(this.idStr);
                }
              }
            }, 33) // Set the frame rate to 30 fps (with the frame refreshed every 33 ms).
          })
          .onDestroy(() => {
            if (this.interval !== -1) {
              clearInterval(this.interval);
              this.interval = -1;
            }

            if (this.inputInterval !== -1) {
              clearInterval(this.inputInterval);
              this.inputInterval = -1;
            }

            if (this.getCubeInfoInterval !== -1) {
              clearInterval(this.getCubeInfoInterval);
              this.getCubeInfoInterval = -1;
            }
          })

        Text(this.volume)
          .fontColor(Color.Red)
          .fontSize(14)
          .textAlign(TextAlign.Center)
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
      }
    }
    .onAppear(() => {
      arEngineDemo.init(this.resMgr);
      let config: Int32Array = new Int32Array([1, this.rotation, 2, this.semanticDenseMode]);
      arEngineDemo.start(this.idStr, config);
    })
    .onWillDisappear(async () => {
      arEngineDemo.stop(this.idStr);
    })
    .onShown(() => {
      this.isUpdate = true;
      arEngineDemo.show(this.idStr);
    })
    .onHidden(() => {
      this.isUpdate = false;
      arEngineDemo.hide(this.idStr);
    })
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      this.semanticDenseMode = context.pathInfo.param as number;
    })
    .hideTitleBar(true)
    .hideBackButton(true)
    .hideToolBar(true)
  }
}
