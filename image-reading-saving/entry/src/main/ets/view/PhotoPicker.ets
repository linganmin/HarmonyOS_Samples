/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


import { photoAccessHelper } from '@kit.MediaLibraryKit';
import {
  PhotoPickerComponent,
  PickerController,
  PickerOptions,
  DataType,
  BaseItemInfo,
  ItemInfo,
  PhotoBrowserInfo,
  ItemType,
  ClickType,
  MaxCountType,
  PhotoBrowserRange,
  ReminderMode,
} from '@kit.MediaLibraryKit';
import PermissionUtils from '../utils/AuthorizationTools';

@Builder
export function PagePhotoPicker() {
  PhotoPickerComp();
}

@Component
export struct PhotoPickerComp {
  @Consume('pageInfo') pageStack: NavPathStack;
  // Set parameter information during component initialization
  pickerOptions: PickerOptions = new PickerOptions();
  // After component initialization is completed, partial behavior of the component can be controlled
  @State pickerController: PickerController = new PickerController();
  // Selected images
  @State selectUris: Array<string> = new Array<string>();
  // The currently selected image
  @State currentUri: string = '';
  // Do you want to display a large image
  @State isBrowserShow: boolean = false;

  aboutToAppear() {
    // Set picker grid page data type
    this.pickerOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    // Maximum selection quantity
    this.pickerOptions.maxSelectNumber = 1;
    // When the maximum selection quantity is exceeded
    this.pickerOptions.maxSelectedReminderMode = ReminderMode.TOAST;
    // Display search box, default false
    this.pickerOptions.isSearchSupported = false;
    // Does it support taking photos? Default is false
    this.pickerOptions.isPhotoTakingSupported = true;
    this.pickerOptions.gridMargin = { top: 12 };
  };

  // Resource selection callback, returns information about the resource and the selection method
  private onItemClicked(itemInfo: ItemInfo, clickType: ClickType): boolean {
    if (!itemInfo) {
      return false;
    }
    let type: ItemType | undefined = itemInfo.itemType;
    let uri: string | undefined = itemInfo.uri;
    if (type === ItemType.CAMERA) {
      // Click on the camera item
      return true; // If true is returned, pull up the system camera. If self processing is required, return false
    } else {
      if (clickType === ClickType.SELECTED) {
        // Apply to do your own business processing
        if (uri) {
          this.selectUris.push(uri);
          this.pickerOptions.preselectedUris = [...this.selectUris];
        }
        return true; // If it returns true, check it; otherwise, it will not respond to the check
      } else {
        if (uri) {
          this.selectUris = this.selectUris.filter((item: string) => {
            return item != uri;
          })
          this.pickerOptions.preselectedUris = [...this.selectUris];
        }
      }
      return true;
    }
  };

  // Enter the callback of the large image
  private onEnterPhotoBrowser(_photoBrowserInfo: PhotoBrowserInfo): boolean {
    this.isBrowserShow = true;
    return true;
  };

  // The callback to exit the large image
  private onExitPhotoBrowser(_photoBrowserInfo: PhotoBrowserInfo): boolean {
    this.isBrowserShow = false;
    return true;
  };

  // After receiving the callback, sending data to the picker through the relevant interface of the picker controller
  // will not take effect until then
  private onPickerControllerReady(): void {
  };

  // The callback of sliding left and right in the big picture
  private onPhotoBrowserChanged(browserItemInfo: BaseItemInfo): boolean {
    this.currentUri = browserItemInfo.uri ?? '';
    return true;
  };

  // The callback when the selected image is deleted
  private onSelectedItemsDeleted(_baseItemInfos: Array<BaseItemInfo>): void {
  };

  // Callback when clicking again after exceeding the maximum selection quantity
  private onExceedMaxSelected(_exceedMaxCountType: MaxCountType): void {
  };

  // Callback when the current album is deleted
  private onCurrentAlbumDeleted(): void {
  };

  build() {
    NavDestination() {
      Flex({
        direction: FlexDirection.Column,
        alignItems: ItemAlign.Start
      }) {
        PhotoPickerComponent({
          pickerOptions: this.pickerOptions,
          onItemClicked: (itemInfo: ItemInfo, clickType: ClickType): boolean => this.onItemClicked(itemInfo, clickType),
          onEnterPhotoBrowser: (photoBrowserInfo: PhotoBrowserInfo): boolean => this.onEnterPhotoBrowser(photoBrowserInfo),
          onExitPhotoBrowser: (photoBrowserInfo: PhotoBrowserInfo): boolean => this.onExitPhotoBrowser(photoBrowserInfo),
          onPickerControllerReady: (): void => this.onPickerControllerReady(),
          onPhotoBrowserChanged: (browserItemInfo: BaseItemInfo): boolean => this.onPhotoBrowserChanged(browserItemInfo),
          onSelectedItemsDeleted: (BaseItemInfo: Array<BaseItemInfo>) => this.onSelectedItemsDeleted(BaseItemInfo),
          onExceedMaxSelected: (exceedMaxCountType: MaxCountType) => this.onExceedMaxSelected(exceedMaxCountType),
          onCurrentAlbumDeleted: () => this.onCurrentAlbumDeleted(),
          pickerController: this.pickerController,
        })

        // Simulate the selection bar at the bottom of the application side here
        if (this.isBrowserShow) {
          // Selected image thumbnail
          Row() {
            ForEach(this.selectUris, (uri: string) => {
              if (uri === this.currentUri) {
                Image(uri)
                  .height(50)
                  .width(50)
              } else {
                Image(uri).height(50).width(50).onClick(() => {
                  this.pickerController.setData(DataType.SET_SELECTED_URIS, this.selectUris);
                  this.pickerController.setPhotoBrowserItem(uri, PhotoBrowserRange.ALL);
                })
              }
            }, (uri: string) => JSON.stringify(uri))
          }
          .alignSelf(ItemAlign.Center)
          .margin(this.selectUris.length ? 10 : 0)
        } else {
          // Enter the large image and preview the selected image
          Button($r('app.string.preview'), { buttonStyle: ButtonStyleMode.NORMAL })
            .width('33%')
            .alignSelf(ItemAlign.Start)
            .height(40)
            .margin(16)
            .onClick(() => {
              if (this.selectUris.length > 0) {
                this.pickerController.setPhotoBrowserItem(this.selectUris[0], PhotoBrowserRange.SELECTED_ONLY);
                this.pageStack.replacePathByName('Preview', this.selectUris[0]);
              } else {
                PermissionUtils.showToast($r('app.string.please_select_an_image'), this.getUIContext());
              }
            });
        }
      }
    }
    .title($r('app.string.select_picture'))
  }
}