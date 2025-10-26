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

import { arEngine, ARView, arViewController } from '@kit.AREngine';
import { Node, Scene } from '@kit.ArkGraphics3D';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../utils/Logger';
import { arrayBufferInt32ToNumber } from '../utils/Utils';

@Builder
export function ARDepthBuilder(): void {
  ARDepth();
}

let centerDistance: number;
let centerConfidence: number;

@Component
struct ARDepth {
  private delayInterval: number = 33;
  private intervalId: number = -1;
  @State arContext?: arViewController.ARViewContext = undefined;
  @State depthConfidence: number = 0;
  @State depthDistance: string = '0';

  build(): void {
    NavDestination() {
      RelativeContainer() {
        if (this.arContext) {
          ARView({ context: this.arContext })
            .height('100%')
            .width('100%')
            .alignRules({
              center: { anchor: '__container__', align: VerticalAlign.Center },
              middle: { anchor: '__container__', align: HorizontalAlign.Center }
            })
          Text('●')
            .fontSize(8)
            .fontColor(Color.Red)
            .alignRules({
              center: { anchor: '__container__', align: VerticalAlign.Center },
              middle: { anchor: '__container__', align: HorizontalAlign.Center }
            })

          Column() {
            Text(`${this.depthDistance} | ${this.depthConfidence}`)
              .fontColor(Color.Yellow)
              .fontSize(24)
              .textShadow({
                radius: 10,
                color: Color.Black,
                offsetX: 0,
                offsetY: 0
              })
          }
          .alignItems(HorizontalAlign.Center)
          .margin({ bottom: 10 })
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
        }
      }
    }
    .onAppear(() => {
      this.initARView();
      this.renderDepthMsg();
    })
    .onWillDisappear(() => {
      this.stopARView();
    })
    .onShown(() => {
      this.resumeARView();
    })
    .onHidden(() => {
      this.pauseARView();
    })
    .hideTitleBar(true)
    .hideBackButton(true)
    .hideToolBar(true)
  }

  private initARView(): void {
    Scene.load().then(async (scene: Scene) => {
      let viewContext: arViewController.ARViewContext = new arViewController.ARViewContext();
      viewContext.scene = scene;
      viewContext.callback = new ARViewCallbackImpl();
      viewContext.config = {
        type: arEngine.ARType.WORLD,
        planeFindingMode: arEngine.ARPlaneFindingMode.HORIZONTAL_AND_VERTICAL,
        powerMode: arEngine.ARPowerMode.NORMAL,
        semanticMode: arEngine.ARSemanticMode.NONE,
        poseMode: arEngine.ARPoseMode.GRAVITY,
        depthMode: arEngine.ARDepthMode.AUTOMATIC,
        meshMode: arEngine.ARMeshMode.DISABLED,
        focusMode: arEngine.ARFocusMode.AUTO
      }
      viewContext.init().then(() => {
        this.arContext = viewContext;
        Logger.info('Succeeded in initting ARView.');
      }).catch((err: BusinessError) => {
        Logger.error(`Failed to init ARView. Code is ${err.code}, message is ${err.message}`);
      })
    })
  }

  private renderDepthMsg(): void {
    this.intervalId = setInterval(() => {
      if (centerDistance === undefined || centerConfidence === undefined) {
        return;
      }
      this.depthDistance = centerDistance.toFixed(4);
      this.depthConfidence = centerConfidence;
    }, this.delayInterval)
  }

  private stopARView(): void {
    if (!this.arContext) {
      return;
    }
    try {
      clearInterval(this.intervalId);
      this.arContext.destroy();
      centerDistance = 0;
      centerConfidence = 0;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to stop context. Code is ${err.code}, message is ${err.message}`);
    }
  }

  private resumeARView(): void {
    if (!this.arContext) {
      return;
    }
    try {
      this.arContext.resume();
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to resume ARView. Code is ${err.code}, message is ${err.message}`);
    }
  }

  private pauseARView(): void {
    if (!this.arContext) {
      return;
    }
    try {
      this.arContext.pause();
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to pause ARView. Code is ${err.code}, message is ${err.message}`);
    }
  }
}

class ARViewCallbackImpl extends arViewController.ARViewCallback {
  onAnchorAdd(ctx: arViewController.ARViewContext, node: Node, anchor: arEngine.ARAnchor): void {
  }

  onAnchorUpdate(ctx: arViewController.ARViewContext, node: Node, anchor: arEngine.ARAnchor): void {
  }

  async onFrameUpdate(ctx: arViewController.ARViewContext, sysBootTs: number): Promise<void> {
    if (!ctx.session) {
      return;
    }

    let session: arEngine.ARSession | undefined = ctx.session;

    try {
      let frame: arEngine.ARFrame = session.getFrame();
      let depthImage: arEngine.ARImage = frame.acquireDepthImage16Bits();
      let confidenceImage: arEngine.ARImage = frame.acquireDepthConfidenceImage();
      let depthPlane: number[] = arrayBufferInt32ToNumber(depthImage.planes[0].buffer);
      let confidencePlane: number[] = arrayBufferInt32ToNumber(confidenceImage.planes[0].buffer);
      const index: number = depthImage.height * depthImage.width / 2 + depthImage.width / 2;

      centerDistance = depthPlane[index] / 1000;
      centerConfidence = confidencePlane[index];
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to acquire depth information. Code is ${err.code}, message is ${err.message}`);
    }
  }
}
