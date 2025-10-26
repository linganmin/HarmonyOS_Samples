/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Reverse camera_ Multiple workstations_ Take photos Video.
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { dataSharePredicates } from '@kit.ArkData';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { media } from '@kit.MediaKit';
import cameraDemo from 'libentry.so';
import Logger from '../common/utils/Logger';
import MediaUtils from '../common/utils/MediaUtils';
import { SettingDataObj } from '../common/Constants'
import { Constants } from '../common/Constants'

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context = uiContext?.getHostContext() as common.UIAbilityContext;

interface PhotoSettings {
  quality: number, // Photo quality
  rotation: number, // Photo direction
  mirror: boolean, // Mirror Enable
  latitude: number, // geographic location
  longitude: number, // geographic location
  altitude: number // geographic location
};

interface PhotoRotationMap {
  rotation0: number,
  rotation90: number,
  rotation180: number,
  rotation270: number,
};

@Component
export struct ModeSwitchPage {
  @State videoId: string = '';
  @State mSurfaceId: string = '';
  // Front and rear cameras
  @Link cameraDeviceIndex: number;
  // SurfaceID
  @Prop surfaceId: string;
  // Countdown value
  @Link countdownNum: number;
  // Countdown timer
  @State countTimerInt: number = -1;
  @State countTimerOut: number = -1;
  // Recording time
  @State videoRecodeTime: number = 0;
  // Recording time timer
  @State timer: number = -1;
  // Select mode
  @State modelBagCol: string = Constants.PHOTO;
  // Choose camera or capture
  @State @Watch('onChangeIsModeBol') isModeBol: boolean = true;
  @StorageLink('ratioXC') ratioXC: number = 0.0;
  // Thumbnails
  @StorageLink('thumbnail') thumbnail: image.PixelMap | undefined | string = '';
  private tag: string = 'sample modeSwitchPage:';
  private mediaUtil = MediaUtils.getInstance();
  private photoAsset?: string;
  private fd: number = -1;
  private cameraSize: image.Size = {
    width: 1280,
    height: 720
  };
  private photoSettings: PhotoSettings = {
    quality: 0,
    rotation: 0,
    mirror: false,
    latitude: Constants.LATITUDE,
    longitude: Constants.LONGITUDE,
    altitude: Constants.ALTITUDE
  };
  private mReceiver?: image.ImageReceiver;
  private videoRecorder?: media.AVRecorder;
  private videoConfig: media.AVRecorderConfig = {
    audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
    videoSourceType: media.VideoSourceType.VIDEO_SOURCE_TYPE_SURFACE_YUV,
    profile: {
      audioBitrate: Constants.AUDIO_BITRATE_SAMPLE_RATE,
      audioChannels: Constants.AUDIO_CHANNELS,
      audioCodec: media.CodecMimeType.AUDIO_AAC,
      audioSampleRate: Constants.AUDIO_BITRATE_SAMPLE_RATE,
      fileFormat: media.ContainerFormatType.CFT_MPEG_4,
      videoBitrate: Constants.VIDEO_BITRATE,
      videoCodec: media.CodecMimeType.VIDEO_AVC,
      videoFrameWidth: Constants.VIDEO_FRAME_WIDTH,
      videoFrameHeight: Constants.VIDEO_FRAME_HEIGHT,
      videoFrameRate: Constants.VIDEO_FRAME_RATE
    },
    url: '',
    metadata: {
      videoOrientation: ''
    }
  };
  private settingDataObj: SettingDataObj = {
    mirrorBol: false,
    videoStabilizationMode: 0,
    exposureMode: 1,
    focusMode: 2,
    photoQuality: 1,
    locationBol: false,
    photoFormat: 1,
    photoOrientation: 0,
    photoResolution: 0,
    videoResolution: 0,
    videoFrame: 0,
    referenceLineBol: false
  };

  // After pausing, click 'stop' to reset the pause to default.
  onChangeIsModeBol() {
  }

  // Countdown capture and video.
  countTakeVideoFn() {
    if (this.countdownNum) {
      // Clear Countdown.
      if (this.countTimerOut) {
        clearTimeout(this.countTimerOut);
      }
      if (this.countTimerInt) {
        clearInterval(this.countTimerInt);
      }
      // Turn on timer.
      this.countTimerOut = setTimeout(() => {
        // Determine whether it is in video or photo mode.
        this.isVideoPhotoFn();
      }, this.countdownNum * 1000)
      // Turn on timer.
      this.countTimerInt = setInterval(() => {
        this.countdownNum--;
        if (this.countdownNum === 0) {
          clearInterval(this.countTimerInt);
        }
      }, 1000)
    } else {
      this.isVideoPhotoFn();
    }
  }

  async getVideoSurfaceID() {
    try {
      Logger.info(this.tag, `getVideoSurfaceID`);
      this.videoRecorder = await media.createAVRecorder();
      Logger.info(this.tag, `getVideoSurfaceID videoRecorder: ${this.videoRecorder}`);

      this.photoAsset = await this.mediaUtil.createAndGetUri(photoAccessHelper.PhotoType.VIDEO);
      Logger.info(this.tag, `getVideoSurfaceID photoAsset: ${this.photoAsset}`);

      this.fd = await this.mediaUtil.getFdPath(this.photoAsset);
      Logger.info(this.tag, `getVideoSurfaceID fd: ${this.fd}`);

      this.videoConfig.url = `fd://${this.fd}`;
      Logger.info(this.tag, `getVideoSurfaceID videoConfig.url : ${this.videoConfig.url}`);

      if (deviceInfo.deviceType === Constants.DEFAULT) {
        Logger.info(this.tag, `deviceType = default`);
        this.videoConfig.videoSourceType = media.VideoSourceType.VIDEO_SOURCE_TYPE_SURFACE_ES;
      }
      if (deviceInfo.deviceType === Constants.PHONE) {
        Logger.info(this.tag, `deviceType = phone`)
        this.videoConfig.videoSourceType = media.VideoSourceType.VIDEO_SOURCE_TYPE_SURFACE_YUV;
        this.videoConfig.profile.videoCodec = media.CodecMimeType.VIDEO_AVC;
        if (this.cameraDeviceIndex === 1) {
          this.videoConfig.metadata = {
            videoOrientation: '270'
          };
        } else {
          this.videoConfig.metadata = {
            videoOrientation: '90'
          };
        }
      }
      if (deviceInfo.deviceType === 'tablet') {
        Logger.info(this.tag, `deviceType = tablet`);
        this.videoConfig.videoSourceType = media.VideoSourceType.VIDEO_SOURCE_TYPE_SURFACE_YUV;
      }

      this.videoConfig.profile.videoFrameWidth = cameraDemo.getVideoFrameWidth();
      this.videoConfig.profile.videoFrameHeight = cameraDemo.getVideoFrameHeight();
      this.videoConfig.profile.videoFrameRate = cameraDemo.getVideoFrameRate();

      await this.videoRecorder.prepare(this.videoConfig);
      this.videoId = await this.videoRecorder.getInputSurface();
      Logger.info(this.tag, `getVideoSurfaceID videoId: ${this.videoId}`);
    } catch (e) {
      Logger.error(this.tag, `getVideoSurfaceID error ${JSON.stringify(e)}`);
    }
  }

  createImageReceiver() {
    try {
      this.mReceiver = image.createImageReceiver(this.cameraSize, 2000, 8);
      Logger.info(this.tag, `createImageReceiver value: ${this.mReceiver} `);
      this.mReceiver.on('imageArrival', () => {
        Logger.info(this.tag, 'imageArrival start');
        if (this.mReceiver) {
          this.mReceiver.readNextImage((err, image) => {
            Logger.info(this.tag, 'readNextImage start');
            if (err || image === undefined) {
              Logger.error(this.tag, 'readNextImage failed ');
              return;
            }
            image.getComponent(4, (errMsg, img) => {
              Logger.info(this.tag, 'getComponent start');
              if (errMsg || img === undefined) {
                Logger.info(this.tag, 'getComponent failed ');
                return;
              }
              let buffer = new ArrayBuffer(2048);
              if (img.byteBuffer) {
                buffer = img.byteBuffer;
              } else {
                Logger.error(this.tag, 'img.byteBuffer is undefined');
              }
              this.savePicture(buffer, image);
            })
          })
        }
      })
    } catch {
      Logger.info(this.tag, 'savePicture err');
    }
  }

  // Read Image.
  async savePicture(buffer: ArrayBuffer, img: image.Image) {
    try {
      Logger.info(this.tag, 'savePicture start');
      let photoAssetUri: string = await this.mediaUtil.createAndGetUri(photoAccessHelper.PhotoType.IMAGE);
      let imgPhotoUri: string = photoAssetUri;
      Logger.info(this.tag, `photoUri = ${imgPhotoUri}`);
      let imgFd = await this.mediaUtil.getFdPath(imgPhotoUri);
      Logger.info(this.tag, `fd = ${imgFd}`);
      fileIo.writeSync(imgFd, buffer);
      fileIo.closeSync(imgFd);
      await img.release();
      Logger.info(this.tag, 'save image End');
      setTimeout(() => {
        if (this.handleTakePicture) {
          this.handleTakePicture(imgPhotoUri);
        }
      }, 10)
    } catch (err) {
      Logger.info(this.tag, 'savePicture err' + JSON.stringify(err.message));
    }
  }

  async getPhotoSurfaceID() {
    if (this.mReceiver) {
      Logger.info(this.tag, 'imageReceiver has been created');
    } else {
      this.createImageReceiver();
    }
    if (this.mReceiver) {
      this.mSurfaceId = await this.mReceiver.getReceivingSurfaceId();
    }
    if (this.mSurfaceId) {
      Logger.info(this.tag, `createImageReceiver mSurfaceId: ${this.mSurfaceId} `);
    } else {
      Logger.info(this.tag, `Get mSurfaceId failed `);
    }
  }

  // Determine the video or photo mode.
  async isVideoPhotoFn() {
    await this.getPhotoSurfaceID();

    if (this.modelBagCol === Constants.PHOTO) {
      cameraDemo.startPhotoOrVideo(this.modelBagCol, this.videoId, this.mSurfaceId);
    } else if (this.modelBagCol === Constants.VIDEO) {
      this.isModeBol = false;
      if (this.timer) {
        clearInterval(this.timer);
      }
      // Start record.
      await this.getVideoSurfaceID();
      cameraDemo.startPhotoOrVideo(this.modelBagCol, this.videoId, this.mSurfaceId);
      cameraDemo.videoOutputStart();
      if (this.videoRecorder) {
        try {
          this.videoRecorder.start();
        } catch (e) {
          Logger.error(this.tag, `videoRecorder.start error ${JSON.stringify(e)}`);
        }
      }
    }
  }

  async handleTakePicture(thumbnail: string) {
    this.thumbnail = thumbnail
    Logger.info(this.tag, `takePicture end , thumbnail: ${this.thumbnail}`);
  }

  aboutToDisappear() {
    if (this.mReceiver) {
      this.mReceiver.release().then(() => {
        Logger.info(this.tag, 'release succeeded.');
      }).catch((error: BusinessError) => {
        Logger.error(this.tag, `release failed, error: ${error}`);
      })
    }
  }

  build() {
    if (this.isModeBol) {
      Column() {
        Text($r('app.string.photo'))
          .size({ width: $r('app.float.model_size_width'), height: $r('app.float.model_size_height') })
          .borderRadius($r('app.float.border_radius'))
          .fontSize($r('app.float.photo_video_font_size'))
          .fontColor(Color.White)
          .onClick(() => {
            cameraDemo.releaseSession()
            cameraDemo.initCamera(this.surfaceId, this.settingDataObj.focusMode, this.cameraDeviceIndex, this.ratioXC)
            this.modelBagCol = Constants.PHOTO
          })
      }.position({ x: Constants.PHOTO_X_POSITION, y: Constants.Y_POSITION })

      Column() {
        Text($r('app.string.video'))
          .size({ width: $r('app.float.model_size_width'), height: $r('app.float.model_size_height') })
          .borderRadius($r('app.float.border_radius'))
          .fontSize($r('app.float.photo_video_font_size'))
          .fontColor(Color.White)
          .onClick(() => {
            cameraDemo.releaseSession()
            cameraDemo.initCamera(this.surfaceId, this.settingDataObj.focusMode, this.cameraDeviceIndex, this.ratioXC)
            this.modelBagCol = Constants.VIDEO
          })
      }.position({ x: Constants.VIDEO_X_POSITION, y: Constants.Y_POSITION })

      // Album.
      Column() {
        Row() {
          if (this.modelBagCol === Constants.PHOTO) {
            Image(this.thumbnail || $r('app.media.camera_thumbnail_4x'))
              .borderRadius(this.getUIContext().px2vp(Constants.ICON_SIZE / 2))
              .syncLoad(true)
              .objectFit(ImageFit.Fill)
              .width(this.getUIContext().px2vp(Constants.ICON_SIZE))
              .height(this.getUIContext().px2vp(Constants.ICON_SIZE))
          } else {
            Image(this.thumbnail || $r('app.media.camera_thumbnail_4x'))
              .borderRadius(this.getUIContext().px2vp(Constants.ICON_SIZE / 2))
              .objectFit(ImageFit.Fill)
              .width(this.getUIContext().px2vp(Constants.ICON_SIZE))
              .height(this.getUIContext().px2vp(Constants.ICON_SIZE))
          }
        }
        .onClick(() => {
          if (deviceInfo.deviceType === Constants.DEFAULT) {
            context.startAbility({
              bundleName: 'com.ohos.photos',
              abilityName: 'com.ohos.photos.MainAbility'
            })
          } else if (deviceInfo.deviceType === Constants.PHONE) {
            context.startAbility({
              bundleName: 'com.huawei.hmos.photos',
              abilityName: 'com.huawei.hmos.photos.MainAbility'
            })
          }
        })
      }
      .position({ x: Constants.ALBUM_X_POSITION, y: Constants.ICON_Y_POSITION })
      .id('Thumbnail')

      // Capture video icon.
      Column() {
        Row() {
          if (this.modelBagCol === Constants.PHOTO) {
            Image($r('app.media.camera_take_photo_4x'))
              .width(this.getUIContext().px2vp(Constants.ICON_SIZE))
              .height(this.getUIContext().px2vp(Constants.ICON_SIZE))
              .onClick(() => {
                // Countdown camera recording - default camera recording.
                this.countTakeVideoFn();
              })
          } else {
            Image($r('app.media.camera_take_video_4x'))
              .width(this.getUIContext().px2vp(Constants.ICON_SIZE))
              .height(this.getUIContext().px2vp(Constants.ICON_SIZE))
              .onClick(() => {
                // Countdown camera recording - default camera recording.
                this.countTakeVideoFn();
              })
          }
        }
      }.position({ x: Constants.CAPTURE_X_POSITION, y: Constants.ICON_Y_POSITION })
      .id('CaptureOrVideoButton')

      // Front and rear camera switching.
      Column() {
        Row() {
          Image($r('app.media.camera_switch_4x'))
            .width(this.getUIContext().px2vp(Constants.ICON_SIZE))
            .height(this.getUIContext().px2vp(Constants.ICON_SIZE))
            .onClick(async () => {
              // Switching cameras.
              this.cameraDeviceIndex ? this.cameraDeviceIndex = 0 : this.cameraDeviceIndex = 1;
              // Clear configuration.
              cameraDemo.releaseSession();
              // Start preview.
              cameraDemo.initCamera(this.surfaceId, this.settingDataObj.focusMode, this.cameraDeviceIndex,
                this.ratioXC);
            })
        }
      }.position({ x: Constants.SWITCH_X_POSITION, y: Constants.ICON_Y_POSITION })
      .id('SwitchCameraButton')
    } else {
      Column() {
        // Video capture button.
        Image($r('app.media.camera_take_photo_4x'))
          .width(this.getUIContext().px2vp(Constants.ICON_SIZE))
          .height(this.getUIContext().px2vp(Constants.ICON_SIZE))
          .onClick(() => {
            cameraDemo.takePictureWithSettings(this.photoSettings);
          })
      }.position({ x: Constants.ALBUM_X_POSITION, y: Constants.ICON_Y_POSITION })
      .id('VideoCaptureButton')

      Column() {
        Row() {
          Column() {
            // video stop button.
            Image($r('app.media.camera_pause_video_4x'))
              .size({ width: $r('app.float.video_stop_size'), height: $r('app.float.video_stop_size') })
              .width(this.getUIContext().px2vp(Constants.ICON_SIZE))
              .height(this.getUIContext().px2vp(Constants.ICON_SIZE))
              .id('StopVideo')
              .onClick(() => {
                if (this.timer) {
                  clearInterval(this.timer);
                }
                // Stop video.
                this.stopVideo().then(() => {
                  this.videoRecodeTime = 0;
                  this.isModeBol = true;
                  // Clear configuration.
                  cameraDemo.releaseSession();
                  // Start preview.
                  cameraDemo.initCamera(this.surfaceId, this.settingDataObj.focusMode, this.cameraDeviceIndex,
                    this.ratioXC);
                })
              })
          }
        }
        .width(this.getUIContext().px2vp(Constants.ICON_SIZE))
        .height(this.getUIContext().px2vp(Constants.ICON_SIZE))
      }.position({ x: Constants.CAPTURE_X_POSITION, y: Constants.ICON_Y_POSITION })
    }
  }

  async stopVideo() {
    try {
      if (this.videoRecorder) {
        await this.videoRecorder.stop();
        await this.videoRecorder.release();
      }
      cameraDemo.videoOutputStopAndRelease();
      let result: photoAccessHelper.PhotoAsset | undefined = undefined;
      if (this.photoAsset) {
        await fileIo.close(this.fd);
        setTimeout(async () => {
          let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
          let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
          let fetchOptions: photoAccessHelper.FetchOptions = {
            fetchColumns: [],
            predicates: predicates
          };
          let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
            await phAccessHelper.getAssets(fetchOptions);
          let photoAssetList: Array<photoAccessHelper.PhotoAsset> = await fetchResult.getAllObjects();
          photoAssetList.forEach((item: photoAccessHelper.PhotoAsset) => {
            if (item.uri === this.photoAsset) {
              Logger.info(this.tag, `item.uri = ${item.uri}`)
              result = item
            }
          })
          try {
            // Get video thumbnail.
            this.thumbnail = await result?.getThumbnail();
            Logger.info(this.tag, 'videoThumbnail = ' + JSON.stringify(this.thumbnail));
          } catch (err) {
            Logger.error(this.tag, 'videoThumbnail err----------:' + JSON.stringify(err.message));
          }
        }, 1000)
      }
      Logger.info(this.tag, 'stopVideo end');
    } catch (err) {
      Logger.error(this.tag, 'stopVideo err: ' + JSON.stringify(err));
    }
    return;
  }
}