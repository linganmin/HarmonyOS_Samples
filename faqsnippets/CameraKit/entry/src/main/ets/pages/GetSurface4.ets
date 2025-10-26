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
* FAQ:如何读取相机的预览图
*/

// [Start GetSurface4]
import { camera } from '@kit.CameraKit';
import { image } from '@kit.ImageKit';

async function createDualChannelPreview(cameraManager: camera.CameraManager, XComponentSurfaceId: string, receiver: image.ImageReceiver): Promise<void> {
  let camerasDevices: Array<camera.CameraDevice> = cameraManager.getSupportedCameras(); // 获取支持的相机设备对象

  // Get profile object
  let profiles: camera.CameraOutputCapability = cameraManager.getSupportedOutputCapability(camerasDevices[0], camera.SceneMode.NORMAL_PHOTO); // 获取对应相机设备profiles
  let previewProfiles: Array<camera.Profile> = profiles.previewProfiles;

  // Preview Stream 1
  let previewProfilesObj: camera.Profile = previewProfiles[0];

  // Preview Stream 2
  let previewProfilesObj2: camera.Profile = previewProfiles[0];

  // Create preview stream 1 output object
  let previewOutput: camera.PreviewOutput = cameraManager.createPreviewOutput(previewProfilesObj, XComponentSurfaceId);

  // Create preview stream 2 output object
  let imageReceiverSurfaceId: string = await receiver.getReceivingSurfaceId();
  let previewOutput2: camera.PreviewOutput = cameraManager.createPreviewOutput(previewProfilesObj2, imageReceiverSurfaceId);

  // Create cameraInput object
  let cameraInput: camera.CameraInput = cameraManager.createCameraInput(camerasDevices[0]);

  // Turn on the camera
  await cameraInput.open();

  // session flow
  let captureSession = cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO);

  // Start configuring session
  captureSession.beginConfig();

  // Add CameraInput to the conversation
  captureSession.addInput(cameraInput);

  // Add preview stream 1 to the session
  captureSession.addOutput(previewOutput);

  // Add preview stream 2 to the session
  captureSession.addOutput(previewOutput2);

  // Submit configuration information
  await captureSession.commitConfig();

  // session start
  await captureSession.start();
}
// [End GetSurface4]