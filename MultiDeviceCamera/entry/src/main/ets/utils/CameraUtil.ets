/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { camera } from '@kit.CameraKit';
import { common, Context } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { colorSpaceManager } from '@kit.ArkGraphics2D';
import { sensor } from '@kit.SensorServiceKit';
import { display, window } from '@kit.ArkUI';
import { WindowUtil } from './WindowUtil';

export class CameraUtil {
  previewOutput?: camera.PreviewOutput;
  cameraInput?: camera.CameraInput;
  photoSession?: camera.PhotoSession;
  photoOutput?: camera.PhotoOutput;
  uri: string = '';
  currentContext?: Context;
  surfaceId: string = '';
  xComponentController?: XComponentController;
  uiContext?: UIContext;
  windowUtil?: WindowUtil;

  async cameraShooting(surfaceId: string, context: Context, cameraPosition: camera.CameraPosition): Promise<void> {
    this.surfaceId = surfaceId;
    this.currentContext = context;
    // Release camera session and streams, to avoid conflicts in camera resource usage.
    this.releaseCamera();
    try {
      let cameraManager: camera.CameraManager = camera.getCameraManager(context);
      if (!cameraManager) {
        return;
      }
      // Obtaining the camera list.
      let cameraArray: camera.CameraDevice[] = cameraManager.getSupportedCameras();
      if (cameraArray.length <= 0) {
        return;
      }
      // Select front and rear camera.
      let cameraIndex: number = this.getCamera(cameraArray, cameraPosition);
      // Create a camera input stream based on the camera.
      this.cameraInput = cameraManager.createCameraInput(cameraArray[cameraIndex]);
      // Open the camera.
      await this.cameraInput.open();
      // Get the supported modes of the camera and select the photo mode.
      let sceneModes: camera.SceneMode[] = cameraManager.getSupportedSceneModes(cameraArray[cameraIndex]);
      let cameraOutputCap: camera.CameraOutputCapability =
        cameraManager.getSupportedOutputCapability(cameraArray[cameraIndex], camera.SceneMode.NORMAL_PHOTO);
      let isSupportPhotoMode: boolean = sceneModes.indexOf(camera.SceneMode.NORMAL_PHOTO) >= 0;
      if (!isSupportPhotoMode) {
        return;
      }
      if (!cameraOutputCap) {
        return;
      }

      // Get camera preview and photo configuration.
      let previewProfileArray: camera.Profile[] = cameraOutputCap.previewProfiles;
      let previewProfile: camera.Profile = this.getProfile(previewProfileArray);
      let photoProfileArray: camera.Profile[] = cameraOutputCap.photoProfiles;
      let photoProfile: camera.Profile = this.getProfile(photoProfileArray);
      this.previewOutput = cameraManager.createPreviewOutput(previewProfile, surfaceId);
      if (this.previewOutput === undefined) {
        return;
      }

      this.photoOutput = cameraManager.createPhotoOutput(photoProfile);
      if (this.photoOutput === undefined) {
        return;
      }
      // Save photo.
      this.setPhotoOutputCb();
      // Configure the camera preview stream to match the aspect ratio of the surface, otherwise the preview page will be compressed or stretched.
      this.windowUtil = AppStorage.get('windowUtil');
      this.setXComponentRect(this.windowUtil!.getWindowSize());
      // Create the camera session and config.
      this.photoSession = cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO);
      if (this.photoSession === undefined) {
        return;
      }
      this.photoSession.beginConfig();
      this.photoSession.addInput(this.cameraInput);
      this.photoSession.addOutput(this.previewOutput);
      this.photoSession.addOutput(this.photoOutput);
      this.photoSession.setColorSpace(colorSpaceManager.ColorSpace.DISPLAY_P3);
      await this.photoSession.commitConfig();
      await this.photoSession.start();
      return;
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'MultiDeviceCamera', `Camera shooting failed. Code: ${err.code}, message: ${err.message}`);
    }
  }

  // [Start SelectCamera3]
  getCamera(cameras: Array<camera.CameraDevice>, cameraPosition: camera.CameraPosition): number {
    // Choose front or rear camera.
    for (let i: number = 0; i < cameras.length; ++i) {
      if (cameras[i].cameraPosition === cameraPosition) {
        if (cameraPosition === camera.CameraPosition.CAMERA_POSITION_BACK) {
          AppStorage.setOrCreate('isFront', false);
        }
        if (cameraPosition === camera.CameraPosition.CAMERA_POSITION_FRONT) {
          AppStorage.setOrCreate('isFront', true);
        }
        return i;
      }
    }
    hilog.error(0x0000, 'testLog', `Failed to find the camera with the corresponding position.`);
    if (cameras[0].cameraPosition === camera.CameraPosition.CAMERA_POSITION_BACK) {
      AppStorage.setOrCreate('isFront', false);
    }
    if (cameras[0].cameraPosition === camera.CameraPosition.CAMERA_POSITION_FRONT) {
      AppStorage.setOrCreate('isFront', true);
    }
    return 0;
  }
  // [End SelectCamera3]

  // [Start GetProfile]
  getProfile(profileArray: camera.Profile[]): camera.Profile {
    // Return profile based on breakpoint.
    let widthBp: WidthBreakpoint | undefined = AppStorage.get('widthBp');
    let heightBp: HeightBreakpoint | undefined = AppStorage.get('heightBp');
    // Choose a preview or camera configuration with an aspect ratio of 4:3, and select a 1:1 configuration on the Purax external screen.
    let aspectRatio: number = 4 / 3;
    if (widthBp === WidthBreakpoint.WIDTH_SM && heightBp === HeightBreakpoint.HEIGHT_MD) {
      aspectRatio = 1;
    }
    let maxWidth: number = 0;
    let maxHeight: number = 0;
    for (let i: number = 0; i < profileArray.length; ++i) {
      if (profileArray[i].size.width / profileArray[i].size.height === aspectRatio &&
        profileArray[i].size.width > maxWidth) {
        maxWidth = profileArray[i].size.width;
        maxHeight = profileArray[i].size.height;
      }
    }
    let resProfile: undefined | camera.Profile = profileArray.find((profile: camera.Profile) => {
      return profile.size.width === maxWidth && profile.size.height === maxHeight;
    })
    if (resProfile === undefined) {
      hilog.error(0x0000, 'testLog', `Failed to get the profile.`);
      return profileArray[0];
    }
    return resProfile;
  }
  // [End GetProfile]

  setPhotoOutputCb(): void {
    this.photoOutput!.on('photoAssetAvailable', async (err: BusinessError, photoAsset: photoAccessHelper.PhotoAsset):
      Promise<void> => {
      if (err) {
        hilog.error(0x0000, 'testLog', `Failed to save photo.`);
        return;
      }
      let accessHelper: photoAccessHelper.PhotoAccessHelper = photoAccessHelper.getPhotoAccessHelper(this.currentContext);
      let assetChangeRequest: photoAccessHelper.MediaAssetChangeRequest =
        new photoAccessHelper.MediaAssetChangeRequest(photoAsset);
      assetChangeRequest.saveCameraPhoto();
      await accessHelper.applyChanges(assetChangeRequest);
      // Save the address of the latest photo.
      this.uri = photoAsset.uri;
      AppStorage.setOrCreate('photoUri', await photoAsset.getThumbnail());
    })
  }

  // [Start Capture]
  capture(): void {
    let rotation: number = 0;
    try {
      // Obtain the angle of the gravity sensor during shooting and set the shooting rotation angle.
      sensor.once(sensor.SensorId.GRAVITY, (data: sensor.GravityResponse) => {
        let degree: number = this.getCalDegree(data.x, data.y, data.z);
        let isFront: boolean | undefined = AppStorage.get('isFront');
        if (degree >= 0 && (degree <= 30 || degree >= 300)) {
          rotation = camera.ImageRotation.ROTATION_0;
        } else if (degree > 30 && degree <= 120) {
          if (isFront) {
            // Use ROTATION_270 when degree range is (30, 120] for front camera.
            rotation = camera.ImageRotation.ROTATION_270;
          } else {
            // Use ROTATION_90 when degree range is (30, 120] for back camera.
            rotation = camera.ImageRotation.ROTATION_90;
          }
        } else if (degree > 120 && degree <= 210) {
          // Use ROTATION_180 when degree range is (120, 210].
          rotation = camera.ImageRotation.ROTATION_180;
        } else if (degree > 210 && degree <= 300) {
          if (isFront) {
            // Use ROTATION_90 when degree range is (210, 300] for front camera.
            rotation = camera.ImageRotation.ROTATION_90;
          } else {
            // Use ROTATION_270 when degree range is (210, 300] for back camera.
            rotation = camera.ImageRotation.ROTATION_270;
          }
        };

        let setting: camera.PhotoCaptureSetting = {
          quality: camera.QualityLevel.QUALITY_LEVEL_HIGH,
          rotation: rotation,
          mirror: isFront
        }
        this.photoOutput?.capture(setting);
      })
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'MultiDeviceCamera', `Capture failed. Code: ${err.code}, message: ${err.message}`);
    }
  }
  // [End Capture]

  releaseCamera(): void {
    try {
      if (this.photoSession) {
        this.photoSession.stop();
      }
      if (this.cameraInput) {
        this.cameraInput.close();
      }
      if (this.previewOutput) {
        this.previewOutput.release();
      }
      if (this.photoSession) {
        this.photoSession.stop();
      }
      if (this.photoOutput) {
        this.photoOutput.release();
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'MultiDeviceCamera', `Failed to release. Code: ${err.code}, message: ${err.message}`);
    }
  }

  fromBack(): void {
    let isFront: boolean | undefined = AppStorage.get('isFront');
    if (isFront) {
      this.cameraShooting(this.surfaceId, this.currentContext!, camera.CameraPosition.CAMERA_POSITION_FRONT);
      return;
    }
    this.cameraShooting(this.surfaceId, this.currentContext!, camera.CameraPosition.CAMERA_POSITION_BACK);
  }

  previewPhoto(): void {
    let photoContext: common.UIAbilityContext = this.currentContext as common.UIAbilityContext;
    // Start the gallery application to preview photo.
    photoContext.startAbility({
      parameters: { uri: this.uri },
      action: 'ohos.want.action.viewData',
      bundleName: 'com.huawei.hmos.photos',
      abilityName: 'com.huawei.hmos.photos.MainAbility'
    }).then(() => {
      hilog.info(0x0000, 'testLog', `Start ability successed.`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testLog', `Strat ability failed with err: ${err.code}, ${err.message}`);
    })
  }

  getCalDegree(x: number, y: number, z: number): number {
    let degree: number = 0;
    // three is Effective Delta Angle Threshold Coefficient.
    if ((x * x + y * y) * 3 < z * z) {
      return degree;
    }
    degree = 90 - (Number)(Math.round(Math.atan2(y, -x) / Math.PI * 180));
    return degree >= 0 ? degree % 360 : degree % 360 + 360;
  }

  setSurfaceProfile(xComponentController: XComponentController, uiContext: UIContext): void {
    this.xComponentController = xComponentController;
    this.uiContext = uiContext;
  }

  // [Start Preview1]
  // [Start SetXComponentRect]
  setXComponentRect(windowSize: window.Size): void {
    try {
      // Initialize the width and height of the surface to match the full screen of the window.
      let rect: SurfaceRect = {
        surfaceWidth: windowSize.width,
        surfaceHeight: windowSize.height
      };
      let widthBp: WidthBreakpoint = this.uiContext!.getWindowWidthBreakpoint();
      let heightBp: HeightBreakpoint = this.uiContext!.getWindowHeightBreakpoint();
      let displayRotation: number = display.getDefaultDisplaySync().rotation * 90;
      if (widthBp === WidthBreakpoint.WIDTH_SM && heightBp === HeightBreakpoint.HEIGHT_MD) {
        this.xComponentController!.setXComponentSurfaceRect(rect);
        return;
      }
      if (AppStorage.get('isHalfFolded')) {
        this.setHalfFoldedRect(windowSize);
        return;
      }
      if (displayRotation === 0 || displayRotation === 180) {
        if (windowSize.height * 3 / 4 > windowSize.width) {
          rect.surfaceHeight = windowSize.width / 3 * 4;
        } else {
          rect.surfaceWidth = windowSize.height / 4 * 3;
        }
        if (widthBp === WidthBreakpoint.WIDTH_MD && heightBp === HeightBreakpoint.HEIGHT_MD) {
          rect.offsetX = 0;
          rect.offsetY = 0;
        }
      }
      if (displayRotation === 90 || displayRotation === 270) {
        if (windowSize.width * 3 / 4 > windowSize.height) {
          rect.surfaceWidth = windowSize.height / 3 * 4;
        } else {
          rect.surfaceHeight = windowSize.width / 4 * 3;
        }
      }
      this.xComponentController!.setXComponentSurfaceRect(rect);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'MultiDeviceCamera', `Failed to set XComponent rect. Code: ${err.code}, message: ${err.message}`);
    }
  }
  // [End SetXComponentRect]
  // [End Preview1]

  setHalfFoldedRect(windowSize: window.Size): void {
    let creaseRegion: number[] | undefined = AppStorage.get('creaseRegion');
    // Initialize the width and height of the surface to match the full screen of the window.
    let rect: SurfaceRect = {
      surfaceWidth: windowSize.width,
      surfaceHeight: windowSize.height
    };
    // Set the width and height of the half folded page surface.
    rect.surfaceHeight = this.uiContext!.vp2px(creaseRegion![0]);
    rect.surfaceWidth = this.uiContext!.vp2px(creaseRegion![0]) / 3 * 4;
    this.xComponentController!.setXComponentSurfaceRect(rect);
  }
}