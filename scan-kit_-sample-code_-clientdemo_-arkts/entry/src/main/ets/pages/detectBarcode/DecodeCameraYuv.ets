import { camera } from '@kit.CameraKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, PermissionRequestResult } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { display, LengthMetrics } from '@kit.ArkUI';
import { detectBarcode, scanBarcode, scanCore } from '@kit.ScanKit';
import Logger from '../../common/Logger';
import { BreakpointType } from '../customScan/model/BreakpointType';
import { WindowService } from '../customScan/model/WindowService';
import { UIContextSelf } from '../customScan/model/UIContextSelf';
import { ScanLayout } from '../customScan/model/ScanLayout';

const TAG: string = 'DecodeCameraYuv';
const CAMERA_1080: number = 1080;
const CAMERA_1920: number = 1920;

@Entry
@Component
struct DecodeCameraYuv {
  mXComponentController: XComponentController = new XComponentController();
  @State scanLayout: ScanLayout = ScanLayout.getInstance();
  @State windowService: WindowService = WindowService.getInstance();
  @State isUserGrant: boolean = false;
  @State xComponentHeight: number = 1;
  @State xComponentWidth: number = 1;
  @State previewScreenOffsetX: number = 0;
  @State previewScreenOffsetY: number = 0;
  @State scanResultPoints: Array<scanBarcode.ScanCodeRect> = [];
  @State cornerPoints: Array<Array<scanBarcode.Point>> = [];
  // CameraKit
  private cameraManager: camera.CameraManager | undefined = undefined;
  private photoSession: camera.PhotoSession | undefined = undefined;
  private cameraInput: camera.CameraInput | undefined = undefined;
  private previewOutput: camera.PreviewOutput | undefined = undefined;
  private previewOutput2: camera.PreviewOutput | undefined = undefined;
  private isDecoding: boolean = false;
  private adaptRatio: number = 1.0;

  async reqPermissionsFromUser(): Promise<void> {
    let permission: boolean = await this.requestPermissionsFromUserFn();
    if (permission) {
      this.isUserGrant = true;
    }
  }

  requestPermissionsFromUserFn(): Promise<boolean> {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    return new Promise((resolve, reject) => {
      atManager.requestPermissionsFromUser(UIContextSelf.uiContext.getHostContext(), ['ohos.permission.CAMERA'])
        .then((data: PermissionRequestResult) => {
          const grantStatus: Array<number> = data.authResults;
          const PERMISSION_GRANTED: number = 0;
          if (grantStatus.length > 0 && grantStatus[0] === PERMISSION_GRANTED) {
            // The user has granted the permission.
            resolve(true);
          } else {
            // If the user refuses to grant the permission, display a message indicating that user authorization is required, and direct the user to set the permission in system settings.
            reject(false);
          }
        }).catch((error: BusinessError) => {
        Logger.error(TAG, `Failed to requestPermissionsFromUser by atManager. Code: ${error.code}.`);
        reject(false);
      })
    });
  }

  async aboutToAppear() {
    this.setDisplay();
    this.setCameraManager();
  }

  setDisplay() {
    try {
      let displayClass = display.getDefaultDisplaySync();
      if (displayClass) {
        let widthVp: number = UIContextSelf.uiContext.px2vp(displayClass.width);
        let heightVp: number = UIContextSelf.uiContext.px2vp(displayClass.height);
        let ratio: number = CAMERA_1080 / CAMERA_1920;
        this.xComponentHeight = heightVp;
        this.xComponentWidth = heightVp * ratio;
        this.previewScreenOffsetX = (widthVp - this.xComponentWidth) / 2;
        this.previewScreenOffsetY = 0;
        this.adaptRatio = this.xComponentWidth / CAMERA_1080;
      }
    } catch (error) {
      Logger.error(TAG, `Failed to getDefaultDisplaySync. Code: ${error?.code}.`);
    }
  }

  aboutToDisappear(): void {
    this.stopCamera();
  }

  async onPageShow(): Promise<void> {
    if (!this.isUserGrant) {
      await this.reqPermissionsFromUser();
    } else {
      this.xComponentInit();
    }
  }

  onPageHide(): void {
    this.stopCamera();
  }

  stopCamera() {
    if (this.photoSession) {
      // Stop the current camera session.
      try {
        this.photoSession.stop().catch((error: BusinessError) => {
          Logger.error(TAG, `Failed to stop photoSession. Code: ${error.code}.`);
        });
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `Failed to stop photoSession. Code: ${err.code}.`);
      }

      // close CameraInput.
      if (this.cameraInput) {
        try {
          this.cameraInput.close().catch((error: BusinessError) => {
            Logger.error(TAG, `Failed to close cameraInput. Code: ${error.code}.`);
          });
        } catch (error) {
          let err = error as BusinessError;
          Logger.error(TAG, `Failed to close cameraInput. Code: ${err.code}.`);
        }
      }

      // Release the camera preview stream.
      if (this.previewOutput) {
        try {
          this.previewOutput.release().catch((error: BusinessError) => {
            Logger.error(TAG, `Failed to release previewOutput. Code: ${error.code}.`);
          });
        } catch (error) {
          let err = error as BusinessError;
          Logger.error(TAG, `Failed to release previewOutput. Code: ${err.code}.`);
        }
      }
      // Release the second camera preview stream.
      if (this.previewOutput2) {
        try {
          this.previewOutput2.release().catch((error: BusinessError) => {
            Logger.error(TAG, `Failed to release previewOutput2. Code: ${error.code}.`);
          });
        } catch (error) {
          let err = error as BusinessError;
          Logger.error(TAG, `Failed to release previewOutput2. Code: ${err.code}.`);
        }
      }
      // Release the camera session.
      try {
        this.photoSession.release().catch((error: BusinessError) => {
          Logger.error(TAG, `Failed to release photoSession. Code: ${error.code}.`);
        });
      } catch (error) {
        Logger.error(TAG, `Failed to release photoSession. Code: ${error?.code}.`);
      }
      this.photoSession = undefined;
    }
  }

  @Builder
  goBack() {
    Column() {
      Image($rawfile('scan_back.svg'))
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
        .responseRegion({
          x: '-50%',
          y: '-50%',
          width: '200%',
          height: '200%'
        })
        .draggable(false)
        .fillColor(Color.Black)
        .id('decode_camera_yuv_goBack')
        .margin({
          top: LengthMetrics.vp(this.windowService.topAvoidHeight + 8),
          start: LengthMetrics.vp(new BreakpointType(16,
            24,
            32).getValue(this.scanLayout.widthBreakpoint))
        })
        .onClick(async () => {
          UIContextSelf.getRouter().back();
        })
    }
    .position({
      x: 0,
      y: 0
    })
  }

  @Builder
  cameraXComponent() {
    // Create XComponent.
    if (this.isUserGrant) {
      Column() {
        XComponent({
          id: 'componentId',
          type: XComponentType.SURFACE,
          controller: this.mXComponentController
        })
          .onLoad(() => {
            this.xComponentInit();
          })
          .width(this.xComponentWidth)
          .height(this.xComponentHeight)
          .position({
            x: this.previewScreenOffsetX,
            y: this.previewScreenOffsetY
          })
      }
      .width('100%')
      .height('100%')
    }
  }

  build() {
    Stack() {
      this.cameraXComponent()

      // Draw the central point.
      Column() {
        if (this.scanResultPoints && this.scanResultPoints.length > 0) {
          ForEach(this.scanResultPoints, (rect: scanBarcode.ScanCodeRect) => {
            Image($rawfile('scan_selected.svg'))
              .position({
                x: (CAMERA_1080 - rect.bottom + CAMERA_1080 - rect.top) / 2 * this.adaptRatio,
                y: (rect.left + rect.right) / 2 * this.adaptRatio
              })
              .width(40).height(40)
              .markAnchor({ x: 20, y: 20 })
          }, (rect: scanBarcode.ScanCodeRect) => rect.left + rect.right + 'rect')
        }
      }
      .width(this.xComponentWidth)
      .height(this.xComponentHeight)
      .position({
        x: this.previewScreenOffsetX,
        y: 0
      })

      // Draw QR code corners.
      Column() {
        if (this.cornerPoints && this.cornerPoints.length > 0) {
          ForEach(this.cornerPoints, (points: Array<scanBarcode.Point>) => {
            ForEach(points, (point: scanBarcode.Point) => {
              Row() {
              }
              .width(8)
              .height(8)
              .backgroundColor(Color.Red)
              .position({ x: (CAMERA_1080 - point.y) * this.adaptRatio, y: point.x * this.adaptRatio })
            }, (point: scanBarcode.Point) => point.x + point.y + 'point')
          }, (cornerPoint: scanBarcode.Point) => cornerPoint.x + cornerPoint.y + 'cornerPoint')
        }
      }
      .width(this.xComponentWidth)
      .height(this.xComponentHeight)
      .position({
        x: this.previewScreenOffsetX,
        y: 0
      })

      this.goBack()
    }
  }

  setCameraManager(): void {
    try {
      this.cameraManager = camera.getCameraManager(UIContextSelf.uiContext.getHostContext());
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to get cameraManager. Code: ${err.code}.`);
    }
  }

  xComponentInit() {
    this.mXComponentController.setXComponentSurfaceRect({
      surfaceWidth: UIContextSelf.uiContext.vp2px(this.xComponentWidth),
      surfaceHeight: UIContextSelf.uiContext.vp2px(this.xComponentHeight)
    });
    let surfaceId: string = this.mXComponentController.getXComponentSurfaceId();
    try {
      // Create the ImageReceiver object.
      let size: image.Size = {
        width: CAMERA_1080,
        height: CAMERA_1920
      }
      let receiver: image.ImageReceiver = image.createImageReceiver(size, image.ImageFormat.JPEG, 8);

      if (this.cameraManager) {
        this.startPreviewOutput(this.cameraManager, surfaceId, receiver);
      }
    } catch (error) {
      Logger.error(TAG, `Failed to create the previewOutput instance. Code: ${error?.code}`);
    }
  }

  async startPreviewOutput(
    cameraManager: camera.CameraManager, xComponentSurfaceId: string, receiver: image.ImageReceiver): Promise<void> {
    try {
      // Call Camera Kit to obtain supported camera devices.
      let camerasDevices: Array<camera.CameraDevice> = cameraManager.getSupportedCameras();

      // Obtain supported modes.
      let sceneModes: Array<camera.SceneMode> = cameraManager.getSupportedSceneModes(camerasDevices[0]);
      let isSupportPhotoMode: boolean = sceneModes.indexOf(camera.SceneMode.NORMAL_PHOTO) >= 0;
      if (!isSupportPhotoMode) {
        return;
      }

      let cameraProfile: camera.Profile = {
        format: camera.CameraFormat.CAMERA_FORMAT_YUV_420_SP,
        size: {
          "width": CAMERA_1920,
          "height": CAMERA_1080
        },
      }

      this.previewOutput = cameraManager.createPreviewOutput(cameraProfile, xComponentSurfaceId);

      let imageReceiverSurfaceId: string = await receiver.getReceivingSurfaceId();
      this.previewOutput2 = cameraManager.createPreviewOutput(cameraProfile, imageReceiverSurfaceId);

      this.cameraInput = cameraManager.createCameraInput(camerasDevices[0]);

      await this.cameraInput.open();

      this.photoSession =
        cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO) as camera.PhotoSession;

      this.photoSession.beginConfig();
      this.photoSession.addInput(this.cameraInput);
      this.photoSession.addOutput(this.previewOutput);
      this.photoSession.addOutput(this.previewOutput2);
      await this.photoSession.commitConfig();

      await this.photoSession.start();

      // Obtain the camera preview stream buffer.
      this.onImageArrival(receiver);
    } catch (error) {
      Logger.error(TAG, `Failed to startPreviewOutput. Code: ${error?.code}.`);
    }
  }

  onImageArrival(receiver: image.ImageReceiver): void {
    receiver.on('imageArrival', () => {
      receiver.readNextImage((err: BusinessError, nextImage: image.Image) => {
        Logger.info(TAG, 'Receiver.readNextImage success');
        if (err || nextImage === undefined) {
          Logger.error(TAG, `receiver.readNextImage failed. Code: ${err.code}`);
          return;
        }
        nextImage.getComponent(image.ComponentType.JPEG, (err: BusinessError, imgComponent: image.Component) => {
          if (err || nextImage === undefined) {
            Logger.error(TAG, 'Failed to getComponent by nextImage.');
            return;
          }
          let width = CAMERA_1920;
          let height = CAMERA_1080;
          if (!this.isDecoding && imgComponent && imgComponent.byteBuffer as ArrayBuffer) {
            // Image decoding preview buffer.
            // Note: The camera and camera preview are not always in the same orientation.
            let stride = imgComponent.rowStride;
            Logger.info(TAG, `getComponent stride:${stride}, width: ${width}`);
            if (stride == width) {
              this.decodeImageBuffer(nextImage, imgComponent.byteBuffer, CAMERA_1920, CAMERA_1080);
            } else {
              // NV21（YUV_420_SP）
              const dstBufferSize = width * height * 1.5;
              const dstArr = new Uint8Array(dstBufferSize);
              Logger.error(TAG, 'dstBufferSize: ' + dstBufferSize);
              for (let j = 0; j < height * 1.5; j++) {
                const srcBuf = new Uint8Array(imgComponent.byteBuffer, j * stride, width);
                dstArr.set(srcBuf, j * width);
              }
              this.decodeImageBuffer(nextImage, dstArr.buffer as ArrayBuffer, CAMERA_1920, CAMERA_1080);
            }
          }
        })
      })
    })
  }

  decodeImageBuffer(nextImage: image.Image, buffer: ArrayBuffer, width: number, height: number) {
    try {
      let byteImg: detectBarcode.ByteImage = {
        byteBuffer: buffer,
        width: width,
        height: height,
        format: detectBarcode.ImageFormat.NV21
      }

      let options: scanBarcode.ScanOptions = {
        scanTypes: [scanCore.ScanType.ALL],
        enableMultiMode: true,
        enableAlbum: false
      }

      this.scanResultPoints = [];
      this.cornerPoints = [];
      this.isDecoding = true;
      // Image decoding buffer.
      detectBarcode.decodeImage(byteImg, options).then((res: detectBarcode.DetectResult) => {
        let results: Array<scanBarcode.ScanResult> = res.scanResults;

        results.forEach((result) => {
          // Code value.
          let codeType: scanCore.ScanType = result.scanType;
          Logger.info(TAG, `Scan result: type: ${codeType}`);

          // Code position.
          let rect: scanBarcode.ScanCodeRect | undefined = result.scanCodeRect;
          if (rect) {
            this.scanResultPoints.push({
              left: rect.left,
              top: rect.top,
              right: rect.right,
              bottom: rect.bottom
            });
          }

          // QR code corners.
          let points: Array<scanBarcode.Point> | undefined = result.cornerPoints;
          if (result.scanType == scanCore.ScanType.QR_CODE && points) {
            this.cornerPoints.push([]);
            points.forEach((point) => {
              this.cornerPoints[this.cornerPoints.length - 1].push(point);
            });
          }
        });

        // Zoom in or out.
        if (res && res.zoomValue > 1.0) {
          this.setCameraZoom(res.zoomValue);
        }

        this.isDecoding = false;
        // Release image data after decoding.
        nextImage.release();
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `Failed to decodeImage. Code: ${error.code}, message: ${error.message}.`);
        this.isDecoding = false;
        nextImage.release();
      })
    } catch (error) {
      this.isDecoding = false;
      nextImage.release();
    }
  }

  setCameraZoom(zoomValue: number) {
    // Set the zoom ratio.
    if (this.photoSession) {
      try {
        let zoomRatio: number = this.photoSession.getZoomRatio() * zoomValue;
        if (zoomRatio < 10.0) {
          this.photoSession.setZoomRatio(zoomRatio);
        }
      } catch (error) {
        Logger.error(TAG, `Failed to setCameraZoom. Code: ${error?.code}.`);
      }
    }
  }
}
