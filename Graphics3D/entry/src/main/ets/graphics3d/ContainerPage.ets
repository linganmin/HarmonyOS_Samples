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

import { router } from '@kit.ArkUI';
import { Scene, Camera, Node, Container, SceneResourceFactory, EnvironmentBackgroundType } from '@kit.ArkGraphics3D';
import { Constants } from '../constants/Constants';
import Logger from '../utils/Logger';

const TAG: string = '[ContainerPage]';

@Entry
@Component
struct ContainerPage {
  @State sceneOpt: SceneOptions | null = null;
  @State hierarchy: string = '';
  scene: Scene | null = null;
  cam: Camera | null = null;
  node: Node | null | undefined = undefined;
  sceneNode: Node | null = null;

  traversal(node: Node | null): void {
    if (!node) {
      return;
    }

    this.hierarchy += node.path + node.name + '\n';
    let container: Container<Node> = node.children;
    let count: number = container.count();

    this.hierarchy += '  ';
    for (let i = 0; i < count; i++) {
      this.traversal(container.get(i));
    }
  }

  aboutToAppear(): void {
    this.init();
  }

  aboutToDisappear(): void {
    if (this.scene) {
      this.scene.destroy();
      this.scene = null;
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
          this.traversal(this.scene.root);
          this.sceneNode = this.scene.getNodeByPath(Constants.SCENE_NODE_PATH);
        })
        .catch((reason: string) => {
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
          Text($r('app.string.loading'))
            .fontSize($r('app.float.text_font_size'))
            .fontWeight(Constants.FONT_WEIGHT_FIVE_HUNDRED)
        }
      }
      .height(Constants.THIRTY_PERCENT)
      .width(Constants.FULL_PERCENT)
      .backgroundColor(Color.White)
      .borderRadius($r('app.float.board_radius_normal'))

      Column() {
        Text(this.hierarchy)
          .borderRadius($r('app.float.board_radius_normal'))
          .fontWeight(FontWeight.Normal)
      }
      .height(Constants.TWENTY_PERCENT)
      .width(Constants.FULL_PERCENT)
      .borderRadius($r('app.float.board_radius_normal'))
      .backgroundColor(Color.White)
      .alignItems(HorizontalAlign.Start)
      .padding($r('app.float.text_area_padding'))

      Blank()
        .layoutWeight(1)

      Button($r('app.string.remove_node'))
        .onClick(() => {
          if (this?.scene?.root) {
            this.scene.root.children.get(0)?.children.remove(this.node);
            this.hierarchy = '';
            this.traversal(this.scene.root);
          }
        })
        .width(Constants.FULL_PERCENT)

      Button($r('app.string.append_node'))
        .onClick(() => {
          if (this?.scene?.root) {
            this.scene.root.children.get(0)?.children.append(this.node);
            this.hierarchy = '';
            this.traversal(this.scene.root);
          }
        })
        .width(Constants.FULL_PERCENT)

      Button($r('app.string.insert_node'))
        .onClick(() => {
          if (this?.scene?.root) {
            this.scene.root.children.get(0)?.children.insertAfter(this.node, null);
            this.hierarchy = '';
            this.traversal(this.scene.root);
          }
        })
        .width(Constants.FULL_PERCENT)

      Button($r('app.string.clear'))
        .onClick(() => {
          if (this?.scene?.root) {
            this.scene.root.children.clear();
            this.hierarchy = '';
            this.traversal(this.scene.root);
          }
        })
        .width(Constants.FULL_PERCENT)

      Button($r('app.string.back'))
        .onClick(() => {
          this.getUIContext().getRouter().back();
        })
        .width(Constants.FULL_PERCENT)
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .padding($r('app.float.page_padding_left'))
  }
}