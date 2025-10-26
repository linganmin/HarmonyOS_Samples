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

import { Animation, Scene, Camera, EnvironmentBackgroundType, SceneResourceFactory, Color } from '@kit.ArkGraphics3D';
import { Animator, router, AnimatorResult } from '@kit.ArkUI';
import Logger from '../utils/Logger';
import { Constants } from '../constants/Constants';

@Entry
@Component
struct SceneAnimation {
  @State sceneOpt: SceneOptions | null = null;
  @State progressValue: number = 0;
  @State animationEnabled: Boolean = false;
  @State animationDuration: number = 0;
  @State animationIsRunning: Boolean = false;
  @State animationCallbackInvoked: string = Constants.STRING_NO;
  @State enable: boolean = true;
  scene: Scene | null = null;
  cam: Camera | null = null;
  backAnimator: AnimatorResult | undefined = undefined;
  anim: Animation | null = null;

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
    this.backAnimator = this.getUIContext().createAnimator(Constants.ANIMATION_OPTION);
    this.backAnimator.onFrame = () => {
      if (this.scene?.animations[0]) {
        this.animationEnabled = this.scene.animations[0].enabled;
        this.animationDuration = this.scene.animations[0].duration;
        this.animationIsRunning = this.scene.animations[0].running;
        this.progressValue = this.scene.animations[0].progress;
      }
    }
    if (this.scene === null) {
      Scene.load($rawfile('gltf/BrainStem/glTF/BrainStem.gltf'))
      .then(async (result: Scene) => {
        this.scene = result;
        let rf: SceneResourceFactory = this.scene.getResourceFactory();
        this.scene.environment.backgroundType = EnvironmentBackgroundType.BACKGROUND_NONE;

        // Get animation resources
        this.anim = this.scene.animations[0];
        if (this.anim) {
          this.anim.enabled = true;
          // Register callback function
          this.anim.onStarted(() => {
            Logger.info('onStarted');
            this.animationCallbackInvoked = 'animation on start';
          });

          this.anim.onFinished(() => {
            Logger.info('onFinished');
            this.animationCallbackInvoked = 'animation on finish';
          });

          Logger.info('ready to create a new animation.');
        } else {
          Logger.error('No animation found in scene.');
        }

        // create a new camera.
        this.cam = await rf.createCamera({ 'name': 'Camera' });
        // set the camera.
        this.cam.enabled = true;
        this.cam.position.z = 5;
        this.cam.clearColor  = {r: 1, g: 1, b: 1, a: 1} as Color;

        this.sceneOpt = { scene: this.scene, modelType: ModelType.SURFACE } as SceneOptions;
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
            .onAppear(() => {
              if (!this.scene || !this.scene.animations[0]) {
                return;
              }
              let anim: Animation = this.scene.animations[0];
              anim.onStarted(() => {
                this.animationCallbackInvoked = Constants.STRING_START;
              });
              anim.onFinished(() => {
                this.animationCallbackInvoked = Constants.STRING_FINISH;
              });
              this.backAnimator?.play();
            })
        } else {
          Text($r('app.string.loading'))
        }
      }
      .width(Constants.FULL_PERCENT)
      .backgroundColor(Color.White)
      .height(Constants.TWENTY_FIVE_PERCENT)
      .borderRadius($r('app.float.board_radius_normal'))

      Column() {
        Text($r('app.string.progress', (this.progressValue * 100).toFixed(2).toString()))
          .fontSize($r('app.float.text_font_size'))
        Text($r('app.string.duration', this.animationDuration.toFixed(2).toString()))
          .fontSize($r('app.float.text_font_size'))
        Text($r('app.string.running', this.animationIsRunning))
          .fontSize($r('app.float.text_font_size'))
        Text($r('app.string.animation_enabled', this.animationEnabled))
          .fontSize($r('app.float.text_font_size'))
        Text($r('app.string.animation_invoked_callback', this.animationCallbackInvoked))
          .fontSize($r('app.float.text_font_size'))
      }
      .alignItems(HorizontalAlign.Start)
      .width(Constants.FULL_PERCENT)
      .backgroundColor(Color.White)
      .borderRadius($r('app.float.board_radius_normal'))
      .padding($r('app.float.text_area_padding'))

      Column({ space: Constants.LIST_SPACE }) {
        Button(this.enable ? 'disable animation' : 'enable animation')
          .onClick(() => {
            if (!this.scene || !this.scene.animations[0]) {
              return;
            }
            this.enable = !this.enable;
            this.scene.animations[0].enabled = this.enable;
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.start'))
          .onClick(async () => {
            if (!this.scene || !this.scene.animations[0]) {
              return;
            }
            let anim: Animation = this.scene.animations[0];
            anim.start();
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.pause'))
          .onClick(async () => {
            if (!this.scene || !this.scene.animations[0]) {
              return;
            }
            let anim: Animation = this.scene.animations[0];
            anim.pause();
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.stop'))
          .onClick(async () => {
            if (!this.scene || !this.scene.animations[0]) {
              return;
            }
            let anim: Animation = this.scene.animations[0];
            anim.stop();
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.finish'))
          .onClick(async () => {
            if (!this.scene || !this.scene.animations[0]) {
              return;
            }
            let anim: Animation = this.scene.animations[0];
            anim.finish();
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.restart'))
          .onClick(async () => {
            if (!this.scene || !this.scene.animations[0]) {
              return;
            }
            let anim: Animation = this.scene.animations[0];
            anim.restart();
          })
          .width(Constants.FULL_PERCENT)

        Button($r('app.string.seek'))
          .onClick(async () => {
            if (!this.scene || !this.scene.animations[0]) {
              return;
            }
            let anim: Animation = this.scene.animations[0];
            // Seek to 30%.
            anim.seek(0.3);
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