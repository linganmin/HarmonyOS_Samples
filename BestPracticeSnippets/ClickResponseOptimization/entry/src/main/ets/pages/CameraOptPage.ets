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

/**
 *  最佳实践：点击响应优化
 */
import { camera } from '@kit.CameraKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

// [Start camera_output]
let cameraOutput: camera.PreviewOutput;
let cameraInput: camera.CameraInput;
let captureSession: camera.PhotoSession;
let previewOutput: camera.PhotoOutput;

// [End camera_output]

@Entry
@Component
struct CameraPage {
  @State message: string = 'Hello World';

  // [Start release_camera]
  // Trigger once every time the camera page is hidden.
  onPageHide() {
    setTimeout(this.releaseCamera, 200);
  }

  // release resources
  public async releaseCamera() {
    try {
      // Photo Mode Session Paused
      await captureSession?.stop();
      // Release of photo mode session class
      await captureSession?.release();
      // Turn off object class for photo input
      await cameraInput?.close();
      // Preview output object class release
      await previewOutput?.release();
      // Photo output object class release
      await cameraOutput?.release();
    } catch (e) {
      hilog.error(0x00, 'release input output error:', JSON.stringify(e));
    }
  }

  // [End release_camera]

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
  }
}