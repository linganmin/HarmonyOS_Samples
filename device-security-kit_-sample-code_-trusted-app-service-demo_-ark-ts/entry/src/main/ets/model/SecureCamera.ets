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

import { camera } from '@kit.CameraKit'
import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { trustedAppService } from '@kit.DeviceSecurityKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { CertChain } from '../Common/CertChain';

class CameraService {
  private targetPhotoProfile: camera.Profile = {
    format: camera.CameraFormat.CAMERA_FORMAT_JPEG,
    size: {
      width: 640,
      height: 480
    }
  };
  private targetPreviewProfile: camera.Profile = {
    format: camera.CameraFormat.CAMERA_FORMAT_YUV_420_SP,
    size: {
      width: 640,
      height: 480
    }
  };
  private previewOutputObj: camera.PreviewOutput | undefined;
  private photoOutputObj: camera.PreviewOutput | undefined;
  private cameraInput: camera.CameraInput | undefined;
  private session: camera.SecureSession | undefined;
  private challenge: string;
  private certChainObj: CertChain | undefined;

  constructor(userData: string) {
    this.challenge = userData;
  }

  private getSecureCameraDevice(mgr: camera.CameraManager): camera.CameraDevice {
    // Obtain the list of supported cameras
    const cameraDevices = mgr.getSupportedCameras();
    if (cameraDevices.length < 1) {
      throw new Error('no camera devices');
    }
    // Obtain the front camera device object
    const frontCamera: camera.CameraDevice | undefined = cameraDevices.find((profile: camera.CameraDevice) => {
      return profile.cameraPosition === camera.CameraPosition.CAMERA_POSITION_FRONT;
    });
    if (frontCamera === undefined) {
      throw new Error('no front cameras');
    }
    // Check whether the security mode is supported on the front camera device
    const modes = mgr.getSupportedSceneModes(frontCamera);
    if (modes.indexOf(camera.SceneMode.SECURE_PHOTO) === -1) {
      throw new Error('not support secure mode');
    }
    return frontCamera;
  }

  private getSecureCameraOutputCapability(mgr: camera.CameraManager,
    device: camera.CameraDevice): camera.CameraOutputCapability {
    // Obtains the capability supported by the camera in security mode
    return mgr.getSupportedOutputCapability(device, camera.SceneMode.SECURE_PHOTO);
  }

  private getCameraProfile(profiles: Array<camera.Profile>, target: camera.Profile): camera.Profile | undefined {
    const profile = profiles.find((profile: camera.Profile) => {
      return profile.format === target.format && profile.size.width === target.size.width &&
        profile.size.height === target.size.height;
    });
    return profile;
  }

  private getPreviewProfile(capability: camera.CameraOutputCapability): camera.Profile {
    const previewProfiles = capability.previewProfiles;
    if (previewProfiles.length < 1) {
      throw new Error('no preview profiles');
    }
    const previewProfile = this.getCameraProfile(previewProfiles, this.targetPreviewProfile);
    if (previewProfile === undefined) {
      throw new Error('no target preview profile');
    }
    return previewProfile;
  }

  private async verifySecureImage(secureImageBuffer: ArrayBuffer): Promise<void> {
    try {
      const imageBufferLength = this.targetPhotoProfile.size.width * this.targetPhotoProfile.size.height * 3 / 2;
      const view = new DataView(secureImageBuffer);
      // Obtain the original data
      const userDataLength = view.getUint32(0, true);
      const originData = secureImageBuffer.slice(4, 4 + userDataLength + imageBufferLength);
      // Obtain the signature data
      const maxSignatureLength = 512;
      const signatureBuffer = secureImageBuffer.slice(4 + userDataLength + imageBufferLength,
        4 + userDataLength + imageBufferLength + maxSignatureLength);
      const signatureString = String.fromCharCode(...new Uint8Array(signatureBuffer).filter(code => code !== 0));
      const base64Helper = new util.Base64Helper();
      const signature = base64Helper.decodeSync(signatureString);
      // Verify the signature result
      const pubKey = await this.certChainObj?.getPubKey();
      const verifier = cryptoFramework.createVerify('ECC256|SHA256');
      verifier.initSync(pubKey);
      const inputData: cryptoFramework.DataBlob = {
        data: new Uint8Array(originData)
      };
      const signatureData: cryptoFramework.DataBlob = {
        data: new Uint8Array(signature)
      };
      if (!verifier.verifySync(inputData, signatureData)) {
        throw new Error('secure image validation failed');
      }
    } catch (err) {
      throw new Error((err as BusinessError).message);
    }
  }

  private createSecurePhotoReceiver(callback: AsyncCallback<string>): image.ImageReceiver {
    try {
      const receiver = image.createImageReceiver({
        width: this.targetPhotoProfile.size.width,
        height: this.targetPhotoProfile.size.height
      },
        image.ImageFormat.JPEG, 8);
      receiver.on('imageArrival', () => {
        if (!receiver) {
          return;
        }
        receiver.readNextImage((err, nextImage) => {
          if (err || nextImage === undefined) {
            return;
          }
          nextImage.getComponent(image.ComponentType.JPEG, (err, component) => {
            if (err || component === undefined) {
              nextImage.release();
              return;
            }
            const buffer = component.byteBuffer;
            if (buffer) {
              /**
               * The best practice is to complete the secure image verification on the server.
               * The reference code is provided here.
               */
              this.verifySecureImage(buffer)
                .catch((err: BusinessError) => {
                  callback(err, '图像签名验证失败');
                });
            }
            nextImage.release();
          });
        });
      });
      return receiver;
    } catch (err) {
      throw new Error('failed to create receiver');
    }
  }

  private async initSecureCameraAttestContext(cameraInput: camera.CameraInput): Promise<void> {
    try {
      const seqId = await cameraInput.open(true);
      const initProperties: Array<trustedAppService.AttestParam> = [
        {
          tag: trustedAppService.AttestTag.ATTEST_TAG_DEVICE_TYPE,
          value: trustedAppService.AttestType.ATTEST_TYPE_CAMERA
        },
        {
          tag: trustedAppService.AttestTag.ATTEST_TAG_DEVICE_ID,
          value: BigInt(seqId)
        }
      ];
      const initOptions: trustedAppService.AttestOptions = {
        properties: initProperties
      };
      const certChainResult = await trustedAppService.initializeAttestContext(this.challenge, initOptions);
      if (certChainResult.certChains.length < 1) {
        throw new Error('empty returned cert chain');
      }
      this.certChainObj = new CertChain(certChainResult.certChains[0]);
      await this.certChainObj.validate();
    } catch (err) {
      throw new Error((err as BusinessError).message);
    }
  }

  private async finalizeSecureCameraAttestContext(): Promise<void> {
    const finalProperties: Array<trustedAppService.AttestParam> = [
      {
        tag: trustedAppService.AttestTag.ATTEST_TAG_DEVICE_TYPE,
        value: trustedAppService.AttestType.ATTEST_TYPE_CAMERA
      }
    ];
    const finalOptions: trustedAppService.AttestOptions = {
      properties: finalProperties,
    };
    return trustedAppService.finalizeAttestContext(finalOptions);
  }

  private async openSessionFlow(mgr: camera.CameraManager): Promise<void> {
    try {
      this.session = mgr.createSession(camera.SceneMode.SECURE_PHOTO) as camera.SecureSession;
      if (this.session === undefined) {
        throw new Error('undefined session');
      }
      this.session.beginConfig();
      this.session.addInput(this.cameraInput);
      this.session.addOutput(this.previewOutputObj);
      this.session.addOutput(this.photoOutputObj);
      this.session.addSecureOutput(this.photoOutputObj);
      await this.session.commitConfig();
      await this.session.start();
    } catch (err) {
      throw new Error((err as BusinessError).message);
    }
  }

  async initCamera(surfaceId: string, UIContext: common.BaseContext, callback: AsyncCallback<string>): Promise<void> {
    try {
      const cameraMgr = camera.getCameraManager(UIContext as common.UIAbilityContext);

      // Obtain the front camera
      const frontCamera = this.getSecureCameraDevice(cameraMgr);

      // Obtains the capabilities supported by the front camera in security mode
      const capability = this.getSecureCameraOutputCapability(cameraMgr, frontCamera);

      // Obtains the preview stream configuration information
      const previewProfile = this.getPreviewProfile(capability);

      // Obtains the configuration information about secure stream
      const photoProfile = this.getPreviewProfile(capability);

      // Create a preview stream output object
      this.previewOutputObj = cameraMgr.createPreviewOutput(previewProfile, surfaceId);

      // Create a secure stream output object.
      const receiver = this.createSecurePhotoReceiver(callback);
      const secureSurfaceId = await receiver.getReceivingSurfaceId();
      this.photoOutputObj = cameraMgr.createPreviewOutput(photoProfile, secureSurfaceId);

      // Create a camera input object
      this.cameraInput = cameraMgr.createCameraInput(frontCamera);

      // Initiate the security camera attestation session
      await this.initSecureCameraAttestContext(this.cameraInput);

      // Open the session
      await this.openSessionFlow(cameraMgr);
    } catch (err) {
      throw new Error((err as BusinessError).message);
    }
  }

  async closeCamera(): Promise<void> {
    try {
      if (this.previewOutputObj) {
        await this.previewOutputObj.release();
        this.previewOutputObj = undefined;
      }
      if (this.photoOutputObj) {
        await this.photoOutputObj.release();
        this.photoOutputObj = undefined;
      }
      if (this.session) {
        await this.session.release();
        this.session = undefined;
      }
      if (this.cameraInput) {
        await this.cameraInput.close();
        await this.finalizeSecureCameraAttestContext();
      }
    } catch (err) {
      throw new Error((err as BusinessError).message);
    }
  }
}

export default new CameraService('trusted_app_service_default_userdata');
