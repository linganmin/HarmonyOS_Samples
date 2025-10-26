/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { trustedAppService } from '@kit.DeviceSecurityKit';
import CameraService from '../model/SecureCamera';
import LocationService from '../model/SecureLocation';
import Permission from '../Common/Permission';
import createOptions from '../Common/TrustedServiceOption';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  // UI
  private xComponentController: XComponentController = new XComponentController();
  private scroller: Scroller = new Scroller();

  async createAttestKey(): Promise<void> {
    trustedAppService.createAttestKey(createOptions)
      .then(() => {
        this.message += '\n\napp.string.CreateKeySucc_desc';
      })
      .catch(() => {
        this.message += '\n\napp.string.CreateKeyFail_desc';
      });
  }

  aboutToAppear(): void {
    this.createAttestKey();
  }

  aboutToDisappear(): void {
    trustedAppService.destroyAttestKey();
  }

  build() {
    Column({ space: 20 }) {
      Row() {
        Flex() {
          XComponent({
            type: XComponentType.SURFACE,
            controller: this.xComponentController
          }).onLoad(() => {
            this.xComponentController.setXComponentSurfaceRect({ offsetX: 0, offsetY: 0, surfaceWidth: 640, surfaceHeight: 480 });
          }).renderFit(RenderFit.RESIZE_COVER)
        }
      }
      .width('250vp')
      .height('250vp')
      .backgroundColor($r('sys.color.black'))
      .borderRadius('125vp')
      .clip(true)
      .justifyContent(FlexAlign.Center);

      Row() {
        Button($r('app.string.CameraOn_button')).onClick(() => {
          const UIContext  = this.getUIContext().getHostContext()
          if (UIContext == undefined) {
            this.message += `\n\napp.string.GetUIContextFail_desc`;
            return;
          }
          Permission.checkCameraPermission()
            .then((hasPermission: boolean) => {
              if (!hasPermission) {
                return Permission.requestCameraPermission(UIContext);
              }
              return Promise.resolve();
            })
            .then(() => {
              CameraService.initCamera(this.xComponentController.getXComponentSurfaceId(), UIContext, (err, msg) => {
                this.message += `\n\n${msg}`;
              });
            })
            .catch(() => {
              this.message += '\n\napp.string.OpenCameraFail_desc';
              this.createAttestKey();
            });
        }).fontSize(14);

        Button($r('app.string.CameraOff_button')).onClick(() => {
          const UIContext  = this.getUIContext().getHostContext()
          if (UIContext == undefined) {
            this.message += `\n\napp.string.GetUIContextFail_desc`;
            return;
          }
          Permission.checkCameraPermission()
            .then((hasPermission: boolean) => {
              if (!hasPermission) {
                return Permission.requestCameraPermission(UIContext);
              }
              return Promise.resolve();
            })
            .then(() => {
              CameraService.closeCamera();
            });
        }).fontSize(14);
      }

      Column({ space: 12 }) {
        Scroll(this.scroller) {
          Text(this.message).width('100%').textAlign(TextAlign.Start);
        }
        .width('80%')
        .height('40%')
        .backgroundColor('#f0f0f0')
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.On);

        Button($r('app.string.GetLocationSpeedFirst_button')).onClick(() => {
          const UIContext  = this.getUIContext().getHostContext()
          if (UIContext == undefined) {
            this.message += `\n\napp.string.GetUIContextFail_desc`;
            return;
          }
          Permission.checkLocationPermission()
            .then((hasPermission: boolean) => {
              if (!hasPermission) {
                return Permission.requestLocationPermission(UIContext);
              }
              return Promise.resolve();
            })
            .then(() => {
              const priority = trustedAppService.LocatingPriority.PRIORITY_LOCATING_SPEED;
              return LocationService.getVerifiedSecureLocation(priority);
            })
            .then((locationString: string) => {
              this.message += `\n\n${locationString}`;
            })
            .catch(() => {
              this.message += '\n\napp.string.GetLocationFail_desc';
              this.createAttestKey();
            });
        });
        Button($r('app.string.GetLocationAccuracyFirst_button')).onClick(() => {
          const UIContext  = this.getUIContext().getHostContext()
          if (UIContext == undefined) {
            this.message += `\n\napp.string.GetUIContextFail_desc`;
            return;
          }
          Permission.checkLocationPermission()
            .then((hasPermission: boolean) => {
              if (!hasPermission) {
                return Permission.requestLocationPermission(UIContext);
              }
              return Promise.resolve();
            })
            .then(() => {
              const priority = trustedAppService.LocatingPriority.PRIORITY_ACCURACY;
              return LocationService.getVerifiedSecureLocation(priority);
            })
            .then((locationString: string) => {
              this.message += `\n\n${locationString}`;
            })
            .catch(() => {
              this.message += '\n\napp.string.GetLocationFail_desc';
              this.createAttestKey();
            });
        });
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
