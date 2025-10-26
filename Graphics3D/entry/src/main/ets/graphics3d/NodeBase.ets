/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { Scene, Camera, Node, Container, SceneResourceFactory, EnvironmentBackgroundType } from '@kit.ArkGraphics3D';
import { router } from '@kit.ArkUI';
import { Constants } from '../constants/Constants';
import Logger from '../utils/Logger';

const TAG: string = '[NodeBase]';

@Entry
@Component
struct NodeBase {
  @State sceneOpt: SceneOptions | null = null;
  @State xAxis: number = 0;
  @State layerMaskInfo: string = '';
  scene: Scene | null = null;
  cam: Camera | null = null;
  node: Node | null | undefined = null;
  scaled: boolean = false;
  step: number = 0;
  value: number = 0;
  layerMaskIndex: number = 0x1;

  traversalChild(node: Node | null): void {
    if (!node) {
      return;
    }

    let container: Container<Node> = node.children;
    let count: number = container.count();

    for (let i = 0; i < count; i++) {
      this.traversalChild(container.get(i));
    }
  }

  aboutToAppear(): void {
    this.init();
  }

  aboutToDisappear(): void {
    if (this.scene) {
      this.scene.destroy();
    }

    this.cam = null;
    this.scene = null;
  }

  init(): void {
    if (this.scene === null) {
      Scene.load($rawfile('gltf/DamagedHelmet/glTF/DamagedHelmet.gltf'))
        .then(async (result: Scene) => {
          if (!result) {
            return;
          }
          this.scene = result;
          this.sceneOpt = { scene: this.scene, modelType: ModelType.SURFACE } as SceneOptions;
          let rf: SceneResourceFactory = this.scene.getResourceFactory();
          this.cam = await rf.createCamera({ 'name': 'Camera1' });
          this.cam.enabled = true;
          this.cam.position.z = Constants.CAMERA_POSITION_Z_INDEX;

          this.scene.environment.backgroundType = EnvironmentBackgroundType.BACKGROUND_NONE;
          this.cam.clearColor = Constants.CLEAR_COLOR;
          this.node = this.scene.getNodeByPath(Constants.HELMET_NODE_PATH);
          if (this.node) {
            this.xAxis = this.node.position.x;
            this.value = this.xAxis;
          }
        }).catch((reason: string) => {
        Logger.error(TAG, `init error: ${reason}`);
      });
    }
  }

  build() {
    Column({ space: Constants.LIST_SPACE }) {
      Column() {
        if (this.sceneOpt) {
          Component3D(this.sceneOpt)
            .renderWidth($r('app.string.sixty_percent'))
            .renderHeight($r('app.string.sixty_percent'))
        } else {
          Text($r('app.string.loading'));
        }
      }
      .height(Constants.THIRTY_PERCENT)
      .width(Constants.FULL_PERCENT)
      .backgroundColor(Color.White)
      .borderRadius($r('app.float.board_radius_normal'))

      Column() {
        Text('layer mask info:')
          .fontWeight(FontWeight.Normal)

        Text(this.layerMaskInfo)
          .fontWeight(FontWeight.Normal)
      }
      .height(Constants.THIRTEEN_PERCENT)
      .width(Constants.FULL_PERCENT)
      .borderRadius($r('app.float.board_radius_normal'))
      .backgroundColor(Color.White)
      .alignItems(HorizontalAlign.Start)
      .padding($r('app.float.text_area_padding'))

      Column({ space: Constants.LIST_SPACE }) {
        Text($r('app.string.x_axis', this.xAxis?.toFixed(1).toString()))
          .fontSize($r('app.float.text_font_size'))
          .fontWeight(Constants.FONT_WEIGHT_FIVE_HUNDRED)
          .margin({ left: $r('app.float.text_area_padding') })

        Slider({
          value: this.value,
          min: this.value - Constants.XAXIS_VALUE,
          max: this.value + Constants.XAXIS_VALUE,
          step: Constants.XAXIS_STEP,
          style: SliderStyle.OutSet
        })
          .showTips(false)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.xAxis = value;
            if (mode === SliderChangeMode.End) {
              if (!this.node) {
                return;
              }
              this.node.position.x = this.xAxis;
            }
          })
          .width(Constants.FULL_PERCENT)
          .height($r('app.float.slider_height'))
      }
      .alignItems(HorizontalAlign.Start)
      .width(Constants.FULL_PERCENT)

      Column({ space: Constants.LIST_SPACE }) {
        Button($r('app.string.layer_mask'))
          .onClick(() => {
            if (!this.scene) {
              return;
            }
            let node: Node | null | undefined = this.scene.getNodeByPath(Constants.HELMET_NODE_PATH);
            if (!node) {
              return;
            }
            let enabled: boolean = node.layerMask.getEnabled(this.layerMaskIndex);
            node.layerMask.setEnabled(1, !enabled);
            this.layerMaskInfo = 'node name: ' + node.name + '\n' + 'layer mask index: ' + this.layerMaskIndex + '\n' +
              'layer mask enabled: ' + enabled;
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.scale_helmet'))
          .onClick(() => {
            if (!this.scene) {
              return;
            }
            let node: Node | null | undefined = this.scene.root?.children.get(0)?.getNodeByPath(Constants.HELMET_PATH);
            if (!node) {
              return;
            }

            if (this.scaled) {
              node.scale = { x: 1.0, y: 1.0, z: 1.0 };
              this.scaled = false;
            } else {
              node.scale = { x: 0.5, y: 0.5, z: 0.5 };
              this.scaled = true;
            }
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.rotate_helmet'))
          .onClick(() => {
            if (!this.scene) {
              return;
            }
            let node: Node | null | undefined = this.scene.getNodeByPath(Constants.HELMET_NODE_PATH);
            if (!node) {
              return;
            }
            let c = Math.cos(-this.step * 0.7 * 0.1);
            let s = Math.sin(-this.step * 0.7 * 0.1);
            node.rotation = {
              x: s,
              y: 0.0,
              z: 0.0,
              w: c
            };
            this.step++;
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.rotate_parent'))
          .onClick(() => {
            if (!this.scene) {
              return;
            }
            let child: Node | null | undefined = this.scene.root?.getNodeByPath(Constants.HELMET_PARENT_PATH);
            if (!child) {
              return;
            }
            let node: Node | null = child.parent;
            if (!node) {
              return;
            }
            let c = Math.cos(-this.step * 0.7 * 0.1);
            let s = Math.sin(-this.step * 0.7 * 0.1);
            node.rotation = {
              x: 0.0,
              y: s,
              z: 0.0,
              w: c
            };
            this.step++;
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.root_visible'))
          .onClick(() => {
            if (this.scene?.root) {
              this.scene.root.visible = !this.scene.root?.visible;
            }
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.back'))
          .onClick(() => {
            if (this.scene) {
              this.scene.destroy();
            }
            this.getUIContext().getRouter().back();
          })
          .width(Constants.FULL_PERCENT)
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .padding($r('app.float.page_padding_left'))
    .justifyContent(FlexAlign.SpaceBetween)
  }
}