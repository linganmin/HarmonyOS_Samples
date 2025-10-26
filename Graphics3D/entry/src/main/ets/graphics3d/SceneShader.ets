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

import {
  Aabb,
  Vec4,
  Scene,
  Camera,
  Shader,
  ShaderMaterial,
  Geometry,
  Material,
  Node,
  Image,
  Container,
  SceneResourceFactory,
  EnvironmentBackgroundType,
  MaterialType
} from '@kit.ArkGraphics3D';
import { Animator, AnimatorResult, router } from '@kit.ArkUI';
import Logger from '../utils/Logger';
import { Constants } from '../constants/Constants';

@Entry
@Component
struct sceneShader {
  @State sceneOpt: SceneOptions | null = null;
  @State hierarchy: string = '';
  @State meshInfo: string = '';
  scene: Scene | null = null;
  rf: SceneResourceFactory | null = null;
  cam: Camera | null = null;
  shader: Shader | null = null;
  material: ShaderMaterial | null = null;
  geom: Geometry | null = null;
  image: Image | null = null;
  materialOrg: Material | null = null;
  backAnimator: AnimatorResult | undefined = undefined;
  step: number = 0;

  traversal(node: Node | null): void {
    if (!node) {
      return;
    }
    this.hierarchy += node.path + '/' + node.name + '\n';
    let container: Container<Node> = node.children;
    let count: number = container.count();
    this.hierarchy += '  ';
    for (let i = 0; i < count; i++) {
      this.traversal(container.get(i));
    }
  }

  onPageShow(): void {
    this.init();
  }

  printAabb(aabb: Aabb, append: string): string {
    let info: string = '';
    info += append + ' max aabb [ ' + aabb.aabbMax.x + ' ' + aabb.aabbMax.y + ' ' + aabb.aabbMax.z + ' ]';
    info += '\n' + append + ' min aabb [ ' + aabb.aabbMin.x + ' ' + aabb.aabbMin.y + ' ' + aabb.aabbMin.z + ' ]';
    return info;
  }

  onPageHide(): void {
    if (this.scene) {
      this.scene.destroy();
    }

    this.cam = null;
    this.scene = null;
  }

  init(): void {
    this.backAnimator = this.getUIContext().createAnimator(Constants.ANIMATION_OPTION);
    this.backAnimator.onFrame = () => {
      this.step++;
      if (this.material && this.material.colorShader) {
        // Just give a random effect.
        (this.material.colorShader.inputs['vec_1'] as Vec4) = {
          x: Math.abs(Math.sin(this.step) + 0.5),
          y: Math.abs(Math.sin(this.step * 0.86) + 0.5),
          z: Math.abs(Math.sin(this.step * 0.91) + 0.5),
          w: 1.0
        };
        (this.material.colorShader.inputs['time'] as number) = this.step;
      }
    };
    if (this.scene === null) {
      Scene.load($rawfile('gltf/Cube/glTF/Cube.gltf'))
        .then(async (result: Scene) => {
          this.scene = result;
          this.sceneOpt = { scene: this.scene, modelType: ModelType.SURFACE } as SceneOptions;
          this.rf = this.scene.getResourceFactory();
          this.cam = await this.rf.createCamera({ 'name': 'Camera1' });
          this.cam.enabled = true;
          this.cam.position.z = Constants.CAMERA_POSITION_Z_INDEX;
          this.scene.environment.backgroundType = EnvironmentBackgroundType.BACKGROUND_NONE;

          this.image =
            await this.rf.createImage({ name: 'envImg3', uri: $rawfile('gltf/DamagedHelmet/glTF/Default_AO.jpg') });
          this.traversal(this.scene?.root);
          if (!this.geom) {
            this.geom = this.scene.getNodeByPath(Constants.CUBE_PATH) as Geometry;
            this.meshInfo += this.printAabb(this.geom.mesh.aabb, 'Mesh ');

            for (let i = 0; i < this.geom.mesh.subMeshes.length; i++) {
              this.meshInfo += '\n';
              this.meshInfo += this.printAabb(this.geom.mesh.aabb, 'Submesh[' + i + ']');
            }
          }
          this.materialOrg = this.geom.mesh.subMeshes[0].material;
        })
        .catch((error: string) => {
          Logger.error(`init error: ${error}`);
        });
    }
  }

  async createShader(): Promise<void> {
    if (!this.scene || !this.rf) {
      return;
    }
    if (!this.material) {
      this.material = await this.rf.createMaterial({ name: 'CustomMaterial' }, MaterialType.SHADER);
    }
    if (!this.shader) {
      this.shader = await this.rf.createShader({
        name: 'CustomShader',
        uri: $rawfile('shaders/custom_shader/custom_material_sample.shader')
      });
    }

    if (this.material) {
      this.material.colorShader = this.shader;
    }

    if (!this.geom) {
      this.geom = this.scene.getNodeByPath(Constants.CUBE_PATH) as Geometry;
    }

    this.geom.mesh.materialOverride = undefined;
    this.geom.mesh.subMeshes[0].material = this.material;

    if (this.material && this.material.colorShader && this.image) {
      (this.material.colorShader.inputs['BASE_COLOR_Image'] as Image) = this.image;
    }
  }

  build() {
    Column({ space: Constants.LIST_SPACE }) {
      Column() {
        if (this.sceneOpt) {
          Component3D(this.sceneOpt)
            .renderWidth($r('app.string.sixty_percent'))
            .renderHeight($r('app.string.sixty_percent'))
            .onAppear(() => {
              this.backAnimator?.play()
            })
        } else {
          Text($r('app.string.loading'))
        }
      }
      .height(Constants.THIRTY_PERCENT)
      .width(Constants.FULL_PERCENT)
      .backgroundColor(Color.White)
      .borderRadius($r('app.float.board_radius_normal'))

      Column() {
        Text(this.meshInfo)
          .fontSize($r('app.float.text_font_size'))
        Text(this.hierarchy)
          .fontSize($r('app.float.text_font_size'))
      }
      .borderRadius($r('app.float.board_radius_normal'))
      .backgroundColor(Color.White)
      .width(Constants.FULL_PERCENT)
      .padding($r('app.float.text_area_padding'))
      .alignItems(HorizontalAlign.Start)

      Blank()
        .layoutWeight(1)

      Button($r('app.string.create_shader'))
        .onClick(() => {
          this.createShader();
        })
        .width(Constants.FULL_PERCENT)

      Button($r('app.string.recovery_original_material'))
        .onClick(async () => {
          if (this.geom) {
            this.geom.mesh.materialOverride = undefined;
            this.geom.mesh.subMeshes[0].material = this.materialOrg as ShaderMaterial;
          }
        })
        .width(Constants.FULL_PERCENT)

      Button($r('app.string.material_override'))
        .onClick(async () => {
          if (this.geom) {
            this.geom.mesh.subMeshes[0].material = this.materialOrg as ShaderMaterial;
          }
          if (this.geom && this.material) {
            this.geom.mesh.materialOverride = this.material as ShaderMaterial;
          }
        })
        .width(Constants.FULL_PERCENT)

      Button($r('app.string.back'))
        .onClick(() => {
          this.backAnimator?.cancel();
          this.getUIContext().getRouter().back();
        })
        .width(Constants.FULL_PERCENT)
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .padding($r('app.float.page_padding_left'))
    .justifyContent(FlexAlign.SpaceBetween)
  }
}