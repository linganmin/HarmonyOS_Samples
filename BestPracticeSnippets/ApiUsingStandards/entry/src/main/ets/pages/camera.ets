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

/**
 * 易错API的使用规范
 */
import { camera } from '@kit.CameraKit';


class cameraClass {
  cameraManager: camera.CameraManager | undefined = undefined;

  getCameraManager(context: Context): void {
    this.cameraManager = camera.getCameraManager(context);
  }

  async addInput(cameraManager: camera.CameraManager, camera: camera.CameraDevice,
    session: camera.Session): Promise<void> {
    let cameraInput: camera.CameraInput | undefined = undefined;
    // [Start add_input]
    cameraInput = cameraManager.createCameraInput(camera);
    await cameraInput.open();
    session.beginConfig();
    session.addInput(cameraInput);
    // [End add_input]
  }

  async addOutput(cameraManager: camera.CameraManager, camera: camera.CameraDevice, session: camera.Session,
    cameraOutputCapability: camera.CameraOutputCapability): Promise<void> {
    let previewOutput: camera.CameraOutput | undefined = undefined;
    let cameraInput: camera.CameraInput | undefined = undefined;
    let profile: camera.Profile = cameraOutputCapability.previewProfiles[0];
    let surfaceId: string = 'xxx';
    // [Start add_output]
    previewOutput = cameraManager.createPreviewOutput(profile, surfaceId);
    cameraInput = cameraManager.createCameraInput(camera);
    await cameraInput.open();
    session.beginConfig();
    session.addInput(cameraInput);
    session.addOutput(previewOutput);
    // [End add_output]
  }

  async addOutput1(cameraManager: camera.CameraManager, camera: camera.CameraDevice, session: camera.Session,
    cameraOutputCapability: camera.CameraOutputCapability): Promise<void> {
    let previewOutput: camera.CameraOutput | undefined = undefined;
    let cameraInput: camera.CameraInput | undefined = undefined;
    let profile: camera.Profile = cameraOutputCapability.previewProfiles[0];
    let surfaceId: string = 'xxx';
    // [Start add_output1]
    previewOutput = cameraManager.createPreviewOutput(profile, surfaceId);
    cameraInput = cameraManager.createCameraInput(camera);
    await cameraInput.open();
    session.beginConfig();
    session.addInput(cameraInput);
    session.addOutput(previewOutput);
    session.commitConfig();
    // [End add_output1]
  }
}

let cameraInput: camera.CameraInput;
let cameraSession: camera.Session;

// [Start close_release]
async function onBackground(): Promise<void> {
  await cameraInput.close();
  await cameraSession.release();
}

// [End close_release]