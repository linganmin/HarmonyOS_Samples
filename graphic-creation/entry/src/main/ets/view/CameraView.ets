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
import { BreakpointType } from '../utils/BreakpointSystem';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import CameraService from '../model/CameraService';
import { camera } from '@kit.CameraKit';
import { display } from '@kit.ArkUI';
import { DataUtils } from '../utils/DataUtils';
import { image } from '@kit.ImageKit';
import { CommonConstants } from '../common/CommonConstants';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import Logger from '../utils/Logger';

@Component
export struct CameraView {
  @Link isMovingPhoto: boolean;
  @State currentImg: image.PixelMap | Resource = $r('app.media.preview_background');
  @Link @Watch('changeBreakpoint') currentBreakpoint: string;
  @Link cameraIndex: number;
  private readonly tag: string = 'CameraView';
  private mXComponentController: XComponentController = new XComponentController();
  // [Start ability_accessctrl]
  private permissions: Array<Permissions> = [
    'ohos.permission.CAMERA',
    'ohos.permission.MICROPHONE',
    'ohos.permission.MEDIA_LOCATION',
    'ohos.permission.READ_IMAGEVIDEO',
    'ohos.permission.WRITE_IMAGEVIDEO',
  ];
  // [End ability_accessctrl]
  private surfaceId: string = '';
  private supperCameraArr: Array<camera.CameraDevice> | undefined = undefined;
  private mRotate: number = display.getDefaultDisplaySync().rotation * camera.ImageRotation.ROTATION_90;

  aboutToAppear(): void {
    this.getThumbnail();
    CameraService.setTakePhotoCallback((photoAsset) => {
      this.takePhotoCallback(photoAsset);
    });
    display.on('change', () => {
      if (this.mRotate != display.getDefaultDisplaySync().rotation * camera.ImageRotation.ROTATION_90) {
        this.mRotate = display.getDefaultDisplaySync().rotation * camera.ImageRotation.ROTATION_90; // 获取屏幕旋转角度
        this.initCamera();
      }
    });
  }

  aboutToDisappear(): void {
    display.off('change');
    CameraService.releaseCamera();
    CameraService.setTakePhotoCallback();
  }

  build() {
    Flex({
      direction: new BreakpointType(
        {
          sm: FlexDirection.Column,
          md: FlexDirection.Row,
          lg: FlexDirection.Row,
        }
      ).getValue(this.currentBreakpoint),
      wrap: FlexWrap.NoWrap,
      justifyContent: FlexAlign.Start,
      alignItems: ItemAlign.Center,
      alignContent: FlexAlign.Center,
    }) {
      this.setCameraToolView();
      this.setXComponentView();
      this.setCameraActionsBtn();
    }
    .width($r('app.string.full_screen'))
    .height($r('app.string.full_screen'))
    .backgroundColor(Color.Black)
  }

  @Builder
  setCameraToolView() {
    Flex({
      direction: new BreakpointType(
        {
          sm: FlexDirection.Row,
          md: FlexDirection.Column,
          lg: FlexDirection.Column,
        }
      ).getValue(this.currentBreakpoint),
      wrap: FlexWrap.NoWrap,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center,
      alignContent: FlexAlign.Center,
    }) {
      this.setMovingPhotoBtn();
      this.setOtherBtn();
    }.padding({
      left: $r('sys.float.ohos_id_default_padding_bottom_fixed'),
      right: $r('sys.float.ohos_id_default_padding_bottom_fixed')
    })
    .width(new BreakpointType({
      sm: $r('app.string.full_screen'),
      md: $r('app.float.navigation_height_lg'),
      lg: $r('app.float.navigation_height_lg')
    }).getValue(this.currentBreakpoint))
    .height(new BreakpointType({
      sm: $r('app.float.navigation_height_sm'),
      md: $r('app.float.camera_tools_height_lg'),
      lg: $r('app.float.camera_tools_height_lg'),
    }).getValue(this.currentBreakpoint))
  }

  @Builder
  setMovingPhotoBtn() {
    Image(this.isMovingPhoto ? $r('app.media.ic_moving_photo_on') : $r('app.media.ic_moving_photo_off'))
      .width($r('app.float.icon_size_24'))
      .height($r('app.float.icon_size_24'))
      .objectFit(ImageFit.Fill)
      .onClick(() => {
        this.isMovingPhoto = !this.isMovingPhoto;
        CameraService.setEnableLivePhoto(this.isMovingPhoto);
      })
  }

  @Builder
  setOtherBtn() {
    Image($r('app.media.ic_camera_public_flash_on'))
      .width($r('app.float.icon_size_24'))
      .height($r('app.float.icon_size_24'))
      .objectFit(ImageFit.Fill)
      .onClick(() => {
      })
    Image($r('app.media.ic_camera_public_flash_always_on'))
      .width($r('app.float.icon_size_24'))
      .height($r('app.float.icon_size_24'))
      .objectFit(ImageFit.Fill)
      .onClick(() => {
      })
    Image($r('app.media.ic_camera_filters'))
      .width($r('app.float.icon_size_24'))
      .height($r('app.float.icon_size_24'))
      .objectFit(ImageFit.Fill)
      .onClick(() => {
      })
    Image($r('app.media.stabilization_on'))
      .width($r('app.float.icon_size_24'))
      .height($r('app.float.icon_size_24'))
      .objectFit(ImageFit.Fill)
      .onClick(() => {
      })
  }

  @Builder
  setXComponentView() {
    XComponent({
      id: 'componentId',
      type: XComponentType.SURFACE,
      controller: this.mXComponentController
    })
      .renderFit(RenderFit.RESIZE_COVER)
      .onLoad(() => {
        this.mXComponentController.setXComponentSurfaceRect(
          {
            surfaceWidth: new BreakpointType({
              sm: CommonConstants.PREVIEW_HEIGHT,
              md: CommonConstants.PREVIEW_HEIGHT,
              lg: display.getDefaultDisplaySync().width,
            }).getValue(this.currentBreakpoint),
            surfaceHeight: new BreakpointType({
              sm: CommonConstants.PREVIEW_WIDTH,
              md: CommonConstants.PREVIEW_WIDTH,
              lg: display.getDefaultDisplaySync().height,
            }).getValue(this.currentBreakpoint)
          }
        );
        // [Start ability_accessctrl]
        abilityAccessCtrl.createAtManager().requestPermissionsFromUser(DataUtils.context, this.permissions).then(() => {
          this.surfaceId = this.mXComponentController.getXComponentSurfaceId();
          this.initCamera();
          this.getThumbnail();
        })
        // [End ability_accessctrl]
      })
      .width($r('app.string.full_screen'))
  }

  @Builder
  setCameraActionsBtn() {
    Flex({
      direction: new BreakpointType(
        {
          sm: FlexDirection.Row,
          md: FlexDirection.Column,
          lg: FlexDirection.Column,
        }
      ).getValue(this.currentBreakpoint),
      wrap: FlexWrap.NoWrap,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center,
      alignContent: FlexAlign.Center,
    }) {
      this.setActionsBtn();
    }
    .width(new BreakpointType({
      sm: $r('app.float.camera_actions_height_lg'),
      md: $r('app.float.navigation_height_lg'),
      lg: $r('app.float.navigation_height_lg'),
    }).getValue(this.currentBreakpoint))
    .height(new BreakpointType({
      sm: $r('app.float.size_74'),
      md: $r('app.float.camera_actions_height_lg'),
      lg: $r('app.float.camera_actions_height_lg')
    }).getValue(this.currentBreakpoint))
    .padding({
      left: new BreakpointType({
        sm: $r('app.float.margin_24'),
        md: $r('app.float.zero'),
        lg: $r('app.float.zero')
      }).getValue(this.currentBreakpoint),
      right: new BreakpointType({
        sm: $r('app.float.margin_24'),
        md: $r('app.float.zero'),
        lg: $r('app.float.zero')
      }).getValue(this.currentBreakpoint),
    })
    .margin({
      top: $r('app.float.margin_36'),
      bottom: $r('app.float.margin_36'),
      left: new BreakpointType({
        sm: $r('app.float.zero'),
        md: $r('app.float.margin_18'),
        lg: $r('app.float.margin_18')
      }).getValue(this.currentBreakpoint),
      right: new BreakpointType({
        sm: $r('app.float.zero'),
        md: $r('app.float.margin_18'),
        lg: $r('app.float.margin_18')
      }).getValue(this.currentBreakpoint),
    })
  }

  @Builder
  setActionsBtn() {
    Image(this.currentImg)
      .height($r('app.float.size_44'))
      .width($r('app.float.size_44'))
      .objectFit(ImageFit.Cover)
      .clipShape(new Circle({
        width: DataUtils.fromResToNumber($r('app.float.size_44')),
        height: DataUtils.fromResToNumber($r('app.float.size_44'))
      }))
      .onClick(() => {
        const photoAsset = AppStorage.get(CommonConstants.KEY_PHOTO_ASSET) as photoAccessHelper.PhotoAsset;
        if (photoAsset === undefined) {
          return;
        }
        this.pushPreviewPage(photoAsset);
      });

    //take photo
    Image($r('app.media.capture'))
      .objectFit(ImageFit.Contain)
      .width($r('app.float.size_74'))
      .height($r('app.float.size_74'))
      .onClick(async () => {
        CameraService.takePhoto();
      });

    //camera selected
    Image($r('app.media.switch_camera'))
      .objectFit(ImageFit.Contain)
      .width($r('app.float.size_44'))
      .height($r('app.float.size_44'))
      .bindMenu(this.setLocalCameraMenu);

  }

  /**
   * get take photo to show
   * @returns
   */
  // [Start getthumbnail]
  async getThumbnail(): Promise<void> {
    let photoAsset: photoAccessHelper.PhotoAsset =
      AppStorage.get(CommonConstants.KEY_PHOTO_ASSET) as photoAccessHelper.PhotoAsset;
    if (photoAsset === undefined) {
      return;
    }
    this.currentImg = await photoAsset.getThumbnail();
  }

  // [End getthumbnail]

  @Builder
  setLocalCameraMenu() {
    Menu() {
      ForEach(this.supperCameraArr, (item: camera.CameraDevice, index: number) => {
        MenuItem({ content: this.getMenuText(item) }).onChange((selected: boolean) => {
          if (selected) {
            this.cameraIndex = index;
            this.initCamera();
          }
        }).contentFontColor(Color.White)
      }, (item: string) => item)
    }.backgroundColor($r('sys.color.ohos_id_blur_style_component_ultra_thick_color_dark'))
  }

  private getMenuText(item: camera.CameraDevice) {
    let res = $r('app.string.local_back')
    if (item.cameraPosition === camera.CameraPosition.CAMERA_POSITION_FRONT) {
      res = item.connectionType === camera.ConnectionType.CAMERA_CONNECTION_REMOTE ? $r('app.string.remote_front') :
      $r('app.string.local_front')
    } else if (item.cameraPosition === camera.CameraPosition.CAMERA_POSITION_BACK) {
      res = item.connectionType === camera.ConnectionType.CAMERA_CONNECTION_REMOTE ? $r('app.string.remote_back') :
      $r('app.string.local_back')
    }
    return res;
  }

  private initCamera() {
    CameraService.initCamera(DataUtils.context, this.cameraIndex, this.surfaceId);
    this.supperCameraArr = CameraService.supperCameraArr;
    CameraService.setEnableLivePhoto(this.isMovingPhoto);
  }

  // Push photo preview
  private async pushPreviewPage(photoAsset: photoAccessHelper.PhotoAsset) {
    const uri = photoAsset.uri;
    if (uri === '') {
      Logger.error(this.tag, `pushPreviewPage uri is null`);
      return;
    }
    let isMovingPhoto =
      photoAsset.get(photoAccessHelper.PhotoKeys.PHOTO_SUBTYPE) === photoAccessHelper.PhotoSubtype.MOVING_PHOTO;
    Logger.info(this.tag, `pushPreviewPage isMovingPhoto: ${isMovingPhoto}`);
    let pageName = isMovingPhoto ? 'pages/PreviewMovingPhotoPage' : 'pages/PreviewPhotoPage';
    this.currentImg = await photoAsset.getThumbnail();
    this.getUIContext().getRouter().pushUrl({
      url: pageName,
      params: {
        uri: uri,
      }
    });
  }

  private takePhotoCallback(photoAsset: photoAccessHelper.PhotoAsset) {
    AppStorage.setOrCreate<photoAccessHelper.PhotoAsset>(CommonConstants.KEY_PHOTO_ASSET, photoAsset);
    let isMovingPhoto =
      photoAsset.get(photoAccessHelper.PhotoKeys.PHOTO_SUBTYPE) === photoAccessHelper.PhotoSubtype.MOVING_PHOTO;
    setTimeout(() => {
      this.pushPreviewPage(photoAsset);
    }, isMovingPhoto ? DataUtils.fromResToNumber($r('app.float.living_delay_time')) :
    DataUtils.fromResToNumber($r('app.float.normal_delay_time')))
  }

  changeBreakpoint(changedPropertyName: string) {
    this.initCamera();
  }
}