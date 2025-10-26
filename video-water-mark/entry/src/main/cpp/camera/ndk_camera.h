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

#ifndef CAMERA_NDK_CAMERA_H
#define CAMERA_NDK_CAMERA_H

#include <unistd.h>
#include <string>
#include <thread>
#include <cstdio>
#include <fcntl.h>
#include <map>
#include <string>
#include <vector>
#include <native_buffer/native_buffer.h>
#include "iostream"
#include "napi/native_api.h"
#include "hilog/log.h"
#include "ohcamera/camera.h"
#include "ohcamera/camera_input.h"
#include "ohcamera/capture_session.h"
#include "ohcamera/photo_output.h"
#include "ohcamera/preview_output.h"
#include "ohcamera/video_output.h"
#include "ohcamera/camera_manager.h"

namespace OHOS_CAMERA_SAMPLE {
class NDKCamera {
public:
    ~NDKCamera();
    NDKCamera(const char *surfaceId, uint32_t focusMode, uint32_t cameraDeviceIndex);
    
    Camera_ErrorCode CreateCameraInput(void);
    Camera_ErrorCode CameraInputOpen(void);
    Camera_ErrorCode CameraInputClose(void);
    Camera_ErrorCode CameraInputRelease(void);
    Camera_ErrorCode GetSupportedCameras(void);
    Camera_ErrorCode GetSupportedOutputCapability(void);
    Camera_ErrorCode CreatePreviewOutput(void);
    Camera_ErrorCode PreviewOutputStop(void);
    Camera_ErrorCode PreviewOutputRelease(void);
    Camera_ErrorCode SessionFlowFn(void);
    Camera_ErrorCode IsFocusMode(uint32_t mode);
    Camera_ErrorCode ReleaseCamera(void);
    Camera_ErrorCode SessionRealese(void);
    Camera_ErrorCode PreviewOutputSetFrameRate(uint32_t minFps, uint32_t maxFps);
    
    // callback
    Camera_ErrorCode CameraManagerRegisterCallback(void);
    Camera_ErrorCode CameraInputRegisterCallback(void);
    Camera_ErrorCode PreviewOutputRegisterCallback(void);
    Camera_ErrorCode CaptureSessionRegisterCallback(void);

    // Get callback
    CameraManager_Callbacks *GetCameraManagerListener(void);
    CameraInput_Callbacks *GetCameraInputListener(void);
    PreviewOutput_Callbacks *GetPreviewOutputListener(void);
    CaptureSession_Callbacks *GetCaptureSessionRegister(void);

private:
    NDKCamera(const NDKCamera &) = delete;
    NDKCamera &operator=(const NDKCamera &) = delete;
    uint32_t cameraDeviceIndex_;
    uint32_t focusMode_;
    const char *previewSurfaceId_;
    Camera_Manager *cameraManager_ {nullptr};
    Camera_CaptureSession *captureSession_ {nullptr};
    Camera_Device *cameras_ {nullptr};
    uint32_t size_ {0};
    Camera_OutputCapability *cameraOutputCapability_ {nullptr};
    const Camera_Profile *profile_ {nullptr};
    Camera_PreviewOutput *previewOutput_ {nullptr};
    Camera_Input *cameraInput_ {nullptr};
    bool isFocusModeSupported_ {false};
    Camera_ErrorCode ret_ {CAMERA_OK};
    
    static NDKCamera *ndkCamera_;
    static std::mutex mtx_;
    volatile bool valid_;
};
}  // namespace OHOS_CAMERA_SAMPLE
#endif  // CAMERA_NDK_CAMERA_H
