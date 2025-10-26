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
* FAQ:预览流黑屏但无报错信息该怎么解决
*/
import { camera } from '@kit.CameraKit';

const TAG = ''
const context = AppStorage.get("context") as Context;

const cameraFun = () => {
  let cameraManager = camera.getCameraManager(context)
  let cameraArray = []

  // [Start ResolvePreviewStreamBlackScreenIssue_Fun]
  // Obtain the output stream capability supported by the camera device
  let cameraOutputCap: camera.CameraOutputCapability =
    cameraManager.getSupportedOutputCapability(cameraArray[0], camera.SceneMode.NORMAL_PHOTO);
  if (!cameraOutputCap) {
    console.error(TAG, "cameraManager.getSupportedOutputCapability error");
    return;
  }
  console.info(TAG, "outputCapability: " +
  JSON.stringify(cameraOutputCap));  //The aspect ratio of the preview stream and the video output stream resolution should be consistent
  let previewProfilesArray: Array<camera.Profile> = cameraOutputCap.previewProfiles;
  let position: number = 0;
  if (previewProfilesArray != null) {
    previewProfilesArray.forEach((value: camera.Profile,
      index: number) => { // View supported preview sizes
      console.info(TAG,
        `Supported preview sizes: [${value.size.width},${value.size.height},${value.size.width / value.size.height}]`);
      if (value.size.width === 2592 && value.size.height === 1200) {
        position = index;
      }
    })
  } else {
    console.error(TAG, "createOutput photoProfilesArray == null || undefined");
  }
  // [End ResolvePreviewStreamBlackScreenIssue_Fun]
}