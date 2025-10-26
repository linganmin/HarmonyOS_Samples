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

let cubeVertexData: Array<number>;
let cubeConfidence: number;
let cubeLabel: arEngine.ARSemanticPlaneLabel;

@Builder
export function ARSemanticDenseBuilder(): void {
  ARSemanticDense();
}

@Component
struct ARSemanticDense {
  @State arContext?: arViewController.ARViewContext = undefined;
  // 平面类型
  private intervalId: number = -1;
  // 重复调用函数时间间隔为33ms，即设定为30fps
  private delayInterval: number = 33;

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
        }
      }
    }
    .onAppear(() => {
      this.initARView();
      // 设定在30fps下更新获取物体体积信息
      this.intervalId = setInterval(async () => {
      }, this.delayInterval);
    })
    .onWillDisappear(() => {
      // 退出setInterval函数
      clearInterval(this.intervalId);
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
        semanticDenseMode: arEngine.ARSemanticDenseMode.CUBE_VOLUME, // 开启体积测量
        poseMode: arEngine.ARPoseMode.GRAVITY,
        depthMode: arEngine.ARDepthMode.DISABLED,
        meshMode: arEngine.ARMeshMode.DISABLED,
        focusMode: arEngine.ARFocusMode.AUTO
      }
      viewContext.init().then(() => {
        this.arContext = viewContext;
        Logger.info('Succeeded in initting ARView.');
      }).catch((err: BusinessError) => {
        Logger.error(`Failed to init ARView. Code is ${err.code}, message is ${err.message}.`);
      })
    })
  }

  private stopARView(): void {
    if (!this.arContext) {
      return;
    }
    try {
      this.arContext.destroy();
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
      Logger.error(`Failed to resume context. Code is ${err.code}, message is ${err.message}.`);
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
      Logger.error(`Failed to pause context. Code is ${err.code}, message is ${err.message}.`);
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

    let arSession: arEngine.ARSession = ctx.session;

    try {
      let frame: arEngine.ARFrame = arSession.getFrame();
      if (frame) {
        let semanticData: arEngine.ARSemanticDenseData = frame.acquireSemanticDense();
        if (semanticData) {
          if (semanticData.cubeDataSize > 0) {
            // 获取第一个Cube的体积数据
            let semanticCubeData: arEngine.ARSemanticDenseCubeData = semanticData.acquireCubeData()[0];
            cubeVertexData = semanticCubeData.vertexData;
            cubeConfidence = semanticCubeData.confidence;
            cubeLabel = semanticCubeData.label;
          }
          semanticData.release();
        }
      }
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to update data. Code is ${err.code}, message is ${err.message}.`);
    }
  }
}