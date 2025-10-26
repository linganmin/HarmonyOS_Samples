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
  Scene,
  Camera,
  DirectionalLight,
  Light,
  SpotLight,
  Image,
  LightType,
  SceneResourceFactory,
  EnvironmentBackgroundType
} from '@kit.ArkGraphics3D';
import { router } from '@kit.ArkUI';
import { Constants } from '../constants/Constants';
import Logger from '../utils/Logger';
import { CalcUtils } from '../utils/CalcUtils';

let colorFlag: number = 0;
let intensityFlag: number = 0;
let shadowFlag: boolean = true;

@Entry
@Component
struct NodeLight {
  @State sceneOpt: SceneOptions | null = null;
  @State lgt: Light | null = null;
  scene: Scene | null = null;
  cam: Camera | null = null;
  directionalLight: DirectionalLight | null | undefined = null;
  spotLight: SpotLight | null = null;
  radianceImg1: Image | null = null;

  onPageShow(): void {
    this.init();
  }

  onPageHide(): void {
    if (this.scene) {
      this.scene.destroy();
    }
    this.cam = null;
    this.scene = null;
  }

  init(): void {
    if (this.scene !== null) {
      return;
    }

    Scene.load($rawfile('gltf/CubeWithFloor/glTF/AnimatedCube.gltf'))
      .then(async (result: Scene) => {
        this.scene = result;
        this.sceneOpt = { scene: this.scene, modelType: ModelType.SURFACE } as SceneOptions;
        let rf: SceneResourceFactory = this.scene.getResourceFactory();
        this.cam = await rf.createCamera({ 'name': 'Camera1' });
        this.cam.position.z = Constants.CAMERA_POSITION_Z_INDEX;
        this.cam.enabled = true;
        // Camera look at direction.
        CalcUtils.lookAt(this.cam, { x: 10, y: 5, z: 15 }, { x: 0, y: 0.0, z: 0.0 }, { x: 0, y: 1, z: 0 });

        this.radianceImg1 = await rf.createImage({
          name: 'radianceImg1',
          uri: $rawfile('gltf/Environment/glTF/images/quarry_02_2k_radiance.ktx')
        });

        this.scene.environment.radianceImage = this.radianceImg1;
        this.scene.environment.backgroundType = EnvironmentBackgroundType.BACKGROUND_NONE;

        this.directionalLight = await this.scene?.getResourceFactory().createLight(
          { 'name': 'DirectionalLight1' }, LightType.DIRECTIONAL) as DirectionalLight;

        // Light look at direction.
        CalcUtils.lookAt(this.directionalLight, { x: 10.0, y: 10.0, z: 10.0 }, { x: 0.0, y: 0.0, z: 0.0 },
          { x: 0.0, y: 1.0, z: 0.0 });

        this.directionalLight.enabled = false;
        this.spotLight = await this.scene?.getResourceFactory().createLight(
          { 'name': 'SpotLight1' }, LightType.SPOT) as SpotLight;
        // Spot light look at direction.
        CalcUtils.lookAt(this.spotLight, { x: 6, y: 6, z: -6 }, { x: 0, y: 0.0, z: 0.0 }, { x: 0, y: 1, z: 0 });

        this.spotLight.enabled = true;
        this.lgt = this.spotLight;
        this.UpdateLights();
      })
      .catch((reason: string) => {
        Logger.error(`init error ${reason}`);
      })
  }

  UpdateLights(): void {
    if (this.lgt) {
      this.lgt.color = Constants.COLORS[colorFlag];
      this.lgt.intensity = Constants.INTENSITIES[intensityFlag];
      if (this.lgt.lightType === LightType.DIRECTIONAL) {
        // Just reduce some intensity when directional light.
        this.lgt.intensity = Constants.INTENSITIES[intensityFlag] / Constants.HALF_HUNDRED;
      }
      this.lgt.shadowEnabled = shadowFlag;
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
      .width(Constants.FULL_PERCENT)
      .backgroundColor(Color.White)
      .height(Constants.THIRTY_PERCENT)
      .borderRadius($r('app.float.board_radius_normal'))

      Blank()
        .layoutWeight(1)

      if (this.lgt) {
        if (this.lgt.enabled) {
          Button(`Shadows (${!this.lgt.shadowEnabled ? 'enabled' : 'disabled'})`)
            .onClick(() => {
              if (!this.scene || !this.lgt) {
                return;
              }
              shadowFlag = !shadowFlag;
              this.UpdateLights();
            })
            .width(Constants.FULL_PERCENT)

          Button($r('app.string.change_color'))
            .onClick(() => {
              if (!this.scene || !this.lgt) {
                return;
              }
              colorFlag = ++colorFlag % Constants.COLORS.length;
              this.UpdateLights();
            })
            .width(Constants.FULL_PERCENT)

          Button(`Change intensity (${this.lgt.intensity})`)
            .onClick(() => {
              if (!this.scene || !this.lgt) {
                return;
              }
              intensityFlag = (intensityFlag + 1) % Constants.INTENSITIES.length;
              this.UpdateLights();
            })
            .width(Constants.FULL_PERCENT)
        }

        Button(`Switch light type (${this.lgt.lightType === LightType.DIRECTIONAL ? 'DIRECTIONAL' : 'SPOT'})`)
          .onClick(() => {
            if (this.lgt) {
              this.lgt.enabled = false;

              if (this.lgt.lightType === LightType.DIRECTIONAL) {
                this.lgt = this.spotLight;
              } else if (this.directionalLight) {
                this.lgt = this.directionalLight;
              }
            }

            if (this.lgt) {
              this.lgt.enabled = true;
              this.UpdateLights();
            }
          })
          .width(Constants.FULL_PERCENT)

        Button(this.lgt.enabled ? $r('app.string.disabled') : $r('app.string.enabled'))
          .onClick(() => {
            if (!this.scene || !this.lgt) {
              return;
            }
            this.lgt.enabled = !this.lgt.enabled;
          })
          .width(Constants.FULL_PERCENT)
      }

      Button($r('app.string.back'))
        .onClick(() => {
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