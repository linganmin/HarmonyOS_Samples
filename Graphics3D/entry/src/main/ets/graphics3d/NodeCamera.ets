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
  SceneResourceFactory,
  EnvironmentBackgroundType,
  ToneMappingType,
  ToneMappingSettings
} from '@kit.ArkGraphics3D';
import { router } from '@kit.ArkUI';
import { Constants } from '../constants/Constants';
import Logger from '../utils/Logger';

let fovFlag: number = 0;
let TonemapTypeFlag: number = 0;
let clearColorFlag: number = 0;

@Extend(Text)
function textEffect() {
  .fontSize($r('app.float.text_font_size'))
  .fontWeight(Constants.FONT_WEIGHT_FIVE_HUNDRED)
  .margin({ left: $r('app.float.text_area_padding') })
}

@Entry
@Component
struct NodeCamera {
  @State sceneOpt: SceneOptions | null = null;
  @State nearPlaneValue: number = 0.1;
  @State farPlaneValue: number = 100;
  @State tonemapExposure: number = 1;
  @State enable: boolean = true;
  scene: Scene | null = null;
  cam: Camera | null = null;

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
          this.scene = result;
          this.sceneOpt = { scene: this.scene, modelType: ModelType.SURFACE } as SceneOptions;
          let rf: SceneResourceFactory = this.scene.getResourceFactory();
          this.cam = await rf.createCamera({ 'name': 'Camera1' });
          this.cam.position.z = Constants.CAMERA_POSITION_Z_INDEX;
          this.cam.enabled = true;
          this.cam.postProcess = {
            toneMapping: {
              type: ToneMappingType.ACES,
              exposure: 1.0
            } as ToneMappingSettings
          };
          this.scene.environment.backgroundType = EnvironmentBackgroundType.BACKGROUND_NONE;
        })
        .catch((reason: string) => {
          Logger.error(`init error: ${reason}`);
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
      .width(Constants.FULL_PERCENT)
      .backgroundColor(Color.White)
      .height(Constants.THIRTY_PERCENT)
      .borderRadius($r('app.float.board_radius_normal'))

      Column() {
        Text($r('app.string.near_plane', this.nearPlaneValue.toFixed(1).toString()))
          .textEffect()
        Slider({
          value: this.nearPlaneValue,
          min: 0.1,
          max: 10,
          step: 0.1,
          style: SliderStyle.OutSet
        })
          .showTips(false)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.nearPlaneValue = value;
            if (mode === SliderChangeMode.End) {
              if (!this.scene || !this.cam) {
                return;
              }
              this.cam.nearPlane = value;
            }
          })
          .width(Constants.FULL_PERCENT)
      }
      .alignItems(HorizontalAlign.Start)
      .width(Constants.FULL_PERCENT)

      Column() {
        Text($r('app.string.far_plane', this.farPlaneValue.toFixed(1).toString()))
          .textEffect()
        Slider({
          value: this.farPlaneValue,
          min: 0.1,
          max: 100,
          step: 1,
          style: SliderStyle.OutSet
        })
          .showTips(false)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.farPlaneValue = value;
            if (mode === SliderChangeMode.End) {
              if (!this.scene || !this.cam) {
                return;
              }
              this.cam.farPlane = this.farPlaneValue;
            }
          })
          .width(Constants.FULL_PERCENT)
      }
      .alignItems(HorizontalAlign.Start)
      .width(Constants.FULL_PERCENT)

      Column() {
        Text($r('app.string.tonemap_exposure', this.tonemapExposure.toFixed(1).toString()))
          .textEffect()
        Slider({
          value: this.tonemapExposure,
          min: 0,
          max: 10,
          step: 0.1,
          style: SliderStyle.OutSet
        })
          .showTips(false)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.tonemapExposure = value;
            if (mode === SliderChangeMode.End) {
              if (!this.scene || !this.cam || !this.cam.postProcess || !this.cam.postProcess.toneMapping) {
                return;
              }
              this.cam.postProcess = {
                toneMapping: {
                  exposure: this.tonemapExposure,
                  type: this.cam.postProcess.toneMapping.type
                }
              };
            }
          })
          .width(Constants.FULL_PERCENT)
      }
      .alignItems(HorizontalAlign.Start)
      .width(Constants.FULL_PERCENT)

      Column({ space: Constants.LIST_SPACE }) {
        Button(!this.enable ? $r('app.string.enabled') : $r('app.string.disabled'))
          .onClick(() => {
            if (!this.scene || !this.cam) {
              return;
            }
            this.enable = !this.enable;
            this.cam.enabled = this.enable;
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.change_fov'))
          .onClick(() => {
            if (!this.scene || !this.cam) {
              return;
            }
            const RADIAN: number = Math.PI / Constants.PI_RADIAN;
            const FOV_COUNT: number = 3;
            const FOV_0: number = 0;
            const FOV_1: number = 1;
            fovFlag = ++fovFlag % FOV_COUNT;
            if (fovFlag === FOV_0) {
              let degree = Constants.DEGREE_SIXTY;
              this.cam.fov = degree * RADIAN;
            } else if (fovFlag === FOV_1) {
              let degree = Constants.DEGREE_NINETY;
              this.cam.fov = degree * RADIAN;
            } else {
              let degree = Constants.DEGREE_FORTY_FIVE;
              this.cam.fov = degree * RADIAN;
            }
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.change_tonemap_type'))
          .onClick(() => {
            if (!this.scene || !this.cam || !this.cam.postProcess || !this.cam.postProcess.toneMapping) {
              return;
            }
            let type: ToneMappingType = ToneMappingType.ACES;
            const TONE_MAPPING_COUNT: number = 3;
            const TONE_MAPPING_0: number = 0;
            const TONE_MAPPING_1: number = 1;
            TonemapTypeFlag = ++TonemapTypeFlag % TONE_MAPPING_COUNT;
            if (TonemapTypeFlag === TONE_MAPPING_0) {
              type = ToneMappingType.ACES;
            } else if (TonemapTypeFlag === TONE_MAPPING_1) {
              type = ToneMappingType.ACES_2020;
            } else {
              type = ToneMappingType.FILMIC;
            }
            this.cam.postProcess = {
              toneMapping: {
                exposure: this.cam.postProcess.toneMapping.exposure,
                type: type
              }
            };
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.set_clear_color'))
          .onClick(() => {
            if (!this.scene || !this.cam) {
              return;
            }
            const CLEAR_COLOR_COUNT: number = 3;
            const CLEAR_COLOR_0: number = 0;
            const CLEAR_COLOR_1: number = 1;

            clearColorFlag = ++clearColorFlag % CLEAR_COLOR_COUNT;
            if (clearColorFlag === CLEAR_COLOR_0) {
              this.cam.clearColor = this.cam.clearColor = Constants.CLEAR_COLOR;
            } else if (clearColorFlag === CLEAR_COLOR_1) {
              this.cam.clearColor = Constants.CLEAR_COLOR_BLUE;
            } else {
              this.cam.clearColor = Constants.CLEAR_COLOR_RED;
            }
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