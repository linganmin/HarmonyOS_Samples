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
  Image,
  SceneResourceFactory,
  EnvironmentBackgroundType,
} from '@kit.ArkGraphics3D';
import { router } from '@kit.ArkUI';
import { Constants } from '../constants/Constants';
import { CalcUtils } from '../utils/CalcUtils';
import Logger from '../utils/Logger';

let typeFlag: number = 0;
let radianceImageFlag: boolean = true;
let factorIndex: number = 0;

@Entry
@Component
struct sceneEnvironment {
  @State sceneOpt: SceneOptions | null = null;
  scene: Scene | null = null;
  cam: Camera | null = null;
  env: Environment | null = null;
  envImg1: Image | null = null;
  envImg2: Image | null = null;
  envImg3: Image | null = null;
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
    if (this.scene === null) {
      Scene.load($rawfile('gltf/DamagedHelmet/glTF/DamagedHelmet.gltf'))
        .then(async (result: Scene) => {
          this.scene = result;
          this.sceneOpt = { scene: this.scene, modelType: ModelType.SURFACE } as SceneOptions;
          let rf: SceneResourceFactory = this.scene.getResourceFactory();
          this.cam = await rf.createCamera({ 'name': 'Camera1' });
          this.cam.enabled = true;
          this.cam.position.z = 5;
          this.env = await rf.createEnvironment({ 'name': 'Env' });
          this.scene.environment.backgroundType = EnvironmentBackgroundType.BACKGROUND_NONE;

          this.envImg1 = await rf.createImage({ name: 'envImg1', uri: $rawfile('gltf/Cube/glTF/Cube_BaseColor.png') });
          this.envImg2 = await rf.createImage({
            name: 'envImg2',
            uri: $rawfile('gltf/Environment/glTF/images/quarry_02_2k_skybox.ktx')
          });
          this.envImg3 = await rf.createImage({
            name: 'envImg3',
            uri: $rawfile('gltf/DamagedHelmet/glTF/Default_albedo.jpg')
          });
          this.radianceImg1 = await rf.createImage({
            name: 'radianceImg1',
            uri: $rawfile('gltf/Environment/glTF/images/quarry_02_2k_radiance.ktx')
          });
        })
        .catch((error: string) => {
          Logger.error(`init error: ${error}`);
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
            .backgroundColor(Color.Transparent)
            .width(Constants.NINETY_PERCENT)
            .height(Constants.FULL_PERCENT)
        } else {
          Text($r('app.string.loading'))
        }
      }
      .height(Constants.THIRTY_PERCENT)
      .width(Constants.FULL_PERCENT)
      .backgroundColor(Color.White)
      .borderRadius($r('app.float.board_radius_normal'))

      Column({ space: Constants.LIST_SPACE }) {
        Button($r('app.string.change_env_img_type'))
          .onClick(() => {
            if (!this.scene || !this.env || !this.cam) {
              return;
            }
            const ENV_TYPE_COUNT: number = 4;
            const ENV_TYPE_0: number = 0;
            const ENV_TYPE_1: number = 1;
            const ENV_TYPE_2: number = 2;
            typeFlag = ++typeFlag % ENV_TYPE_COUNT;
            if (typeFlag === ENV_TYPE_0) {
              this.scene.environment.backgroundType = EnvironmentBackgroundType.BACKGROUND_NONE;
              this.cam.clearColor = Constants.CLEAR_COLOR;
            } else if (this.envImg1 && typeFlag === ENV_TYPE_1) {
              this.scene.environment.backgroundType = EnvironmentBackgroundType.BACKGROUND_IMAGE;
              this.scene.environment.environmentImage = this.envImg1;
            } else if (this.envImg2 && typeFlag === ENV_TYPE_2) {
              this.scene.environment.backgroundType = EnvironmentBackgroundType.BACKGROUND_CUBEMAP;
              this.scene.environment.environmentImage = this.envImg2;
            } else {
              this.scene.environment.backgroundType = EnvironmentBackgroundType.BACKGROUND_EQUIRECTANGULAR;
              this.scene.environment.environmentImage = this.envImg3;
            }
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.change_environment_map_factor'))
          .onClick(() => {
            if (!this.scene || !this.env) {
              return;
            }
            this.scene.environment.environmentMapFactor =
              Constants.ENVIRONMENT_FACTOR[++factorIndex % Constants.ENVIRONMENT_FACTOR.length];
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.change_radiance_mg'))
          .onClick(() => {
            if (!this.scene || !this.env) {
              return;
            }
            radianceImageFlag = !radianceImageFlag;
            if (radianceImageFlag) {
              this.scene.environment.radianceImage = null;
            }
            if (this.radianceImg1 && !radianceImageFlag) {
              this.scene.environment.radianceImage = this.radianceImg1;
            }
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.change_indirect_diffuse_factor'))
          .onClick(() => {
            if (!this.scene || !this.env) {
              return;
            }
            this.scene.environment.indirectDiffuseFactor =
              Constants.ENVIRONMENT_FACTOR[++factorIndex % Constants.ENVIRONMENT_FACTOR.length];
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.change_indirect_specular_factor'))
          .onClick(() => {
            if (!this.scene || !this.env) {
              return;
            }
            this.scene.environment.indirectSpecularFactor =
              Constants.ENVIRONMENT_FACTOR[++factorIndex % Constants.ENVIRONMENT_FACTOR.length];
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.change_irradiance_coefficients'))
          .onClick(() => {
            if (!this.scene || !this.env) {
              return;
            }
            this.scene.environment.irradianceCoefficients = [
              { x: CalcUtils.genRandom(), y: CalcUtils.genRandom(), z: CalcUtils.genRandom() },
              { x: CalcUtils.genRandom(), y: CalcUtils.genRandom(), z: CalcUtils.genRandom() },
              { x: CalcUtils.genRandom(), y: CalcUtils.genRandom(), z: CalcUtils.genRandom() },
              { x: CalcUtils.genRandom(), y: CalcUtils.genRandom(), z: CalcUtils.genRandom() },
              { x: CalcUtils.genRandom(), y: CalcUtils.genRandom(), z: CalcUtils.genRandom() },
              { x: CalcUtils.genRandom(), y: CalcUtils.genRandom(), z: CalcUtils.genRandom() },
              { x: CalcUtils.genRandom(), y: CalcUtils.genRandom(), z: CalcUtils.genRandom() },
              { x: CalcUtils.genRandom(), y: CalcUtils.genRandom(), z: CalcUtils.genRandom() },
              { x: CalcUtils.genRandom(), y: CalcUtils.genRandom(), z: CalcUtils.genRandom() }
            ];
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.back'))
          .onClick(() => {
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