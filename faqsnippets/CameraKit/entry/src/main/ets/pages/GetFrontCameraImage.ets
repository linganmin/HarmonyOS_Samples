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

/*
* FAQ:如何获取前置摄像头的预览图像
*/

// [Start GetFrontCameraImage]
import { BusinessError } from '@kit.BasicServicesKit';
import { camera } from '@kit.CameraKit';
import { common } from '@kit.AbilityKit';

const context = AppStorage.get("context") as common.UIAbilityContext;

@Entry
@Component
struct GetFrontCameraImage {
  private xComponentController: XComponentController = new XComponentController();

  async getCameraImage() {
    // 1、Use the system camera framework camera module to obtain physical camera information.
    let cameraManager = camera.getCameraManager(context);
    let camerasInfo: Array<camera.CameraDevice> = cameraManager.getSupportedCameras();
    let cameraDevice: camera.CameraDevice = camerasInfo[0];
    // Detecting camera status
    cameraManager.on('cameraStatus', (err: BusinessError, cameraStatusInfo: camera.CameraStatusInfo) => {
      console.log(`camera : ${cameraStatusInfo.camera.cameraId}`);
      console.log(`status : : ${cameraStatusInfo.status}`);
    });
    // 2、Create and start a physical camera input stream channel
    // Set as front camera camera.CameraPosition.CAMERA_POSITION_FRONT
    let cameraInput = cameraManager.createCameraInput(camera.CameraPosition.CAMERA_POSITION_FRONT,
      camera.CameraType.CAMERA_TYPE_DEFAULT);
    await cameraInput.open();
    // 3、Retrieve the physical camera information and query the output formats supported by the preview stream of the camera. Create a preview output channel by combining it with the surfaceId provided by XComponent
    let outputCapability = cameraManager.getSupportedOutputCapability(cameraDevice, camera.SceneMode.NORMAL_PHOTO);
    let previewProfile = outputCapability.previewProfiles[0];
    let surfaceId = this.xComponentController.getXComponentSurfaceId();
    let previewOutput = cameraManager.createPreviewOutput(previewProfile, surfaceId);
    // 4、Create a camera session, add the camera input stream and preview output stream in the session, then start the session, and the preview image will be displayed on the XComponent component.
    let captureSession = cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO);
    captureSession.beginConfig();
    captureSession.addInput(cameraInput);
    captureSession.addOutput(previewOutput);
    captureSession.commitConfig()
    captureSession.start();
  }

  build() {
    Row() {
      Column({ space: 20 }) {
        XComponent({ id: 'xComponentId1', type: 'surface', controller: this.xComponentController })
          .height(300)
        Button('Turn on the camera')
          .onClick(() => {
            // Ensure that camera permissions have been obtained before calling
            this.getCameraImage();
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End GetFrontCameraImage]