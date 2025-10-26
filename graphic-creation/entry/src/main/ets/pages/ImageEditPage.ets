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
import { CommonConstants } from '../common/CommonConstants';
import { UIUtils } from '../utils/UIUtils';
import { BreakpointType } from '../utils/BreakpointSystem';
import { SelectedEditeView } from '../view/SelectedEditeView';
import { TitleBackView } from '../view/TitleBackView';
import { CameraView } from '../view/CameraView';
import CameraService from '../model/CameraService';
import { DataUtils } from '../utils/DataUtils';

@Entry
@Component
struct ImageEditPage {
  @StorageLink(CommonConstants.BREAKPOINT_NAME) currentBreakpoint: string = CommonConstants.BREAKPOINT_SM;
  @State tabsIndex: number = 1;
  @State isEnterCamera: boolean = false;
  @State cameraIndex: number = 0;
  @State isMovingPhoto: boolean = true;
  private navToolTextArr: Resource[] =
    [$r('app.string.template'), $r('app.string.album'), $r('app.string.texts'), $r('app.string.take_photo')];
  private navToolIconArr: Resource[] =
    [$r('app.media.icon_model'), $r('app.media.icon_picture'),
      $r('app.media.icon_text'), $r('app.media.icon_camera')];

  aboutToAppear() {
    UIUtils.setWindowBackGroundColor(DataUtils.context, CommonConstants.WHITE_COLOR);
    CameraService.register();
  }

  aboutToDisappear(): void {
    CameraService.unRegister();
  }

  onPageShow(): void {
    UIUtils.setWindowBackGroundColor(DataUtils.context, CommonConstants.WHITE_COLOR);
    this.isEnterCamera = this.tabsIndex === 3;
  }

  onPageHide(): void {
    this.isEnterCamera = false;
  }

  build() {
    Row() {
      Tabs({
        barPosition: BarPosition.End,
        index: this.tabsIndex
      }) {
        this.setTemplateView(0);
        this.setSelectEditView(1);
        this.setTemplateView(2);
        this.setCameraView(3);
      }
      .systemBarEffect()
      .scrollable(false)
      .vertical(this.isEnterCamera && this.currentBreakpoint !== CommonConstants.BREAKPOINT_SM)
      .onTabBarClick((index: number) => {
        this.tabsIndex = index;
        this.isEnterCamera = index === 3;
        if (this.currentBreakpoint === CommonConstants.BREAKPOINT_SM) {
          if (this.isEnterCamera) {
            UIUtils.setWindowBackGroundColor(DataUtils.context, CommonConstants.BLACK_COLOR);
          } else {
            UIUtils.setWindowBackGroundColor(DataUtils.context, CommonConstants.WHITE_COLOR);
          }
        } else {
          if (this.isEnterCamera) {
            UIUtils.setWindowSystemBarVisible(DataUtils.context, []);
          } else {
            UIUtils.setWindowSystemBarVisible(DataUtils.context,
              [CommonConstants.WINDOW_STATUS, CommonConstants.WINDOW_NAVIGATION]);
          }
        }
      })
      .barBackgroundColor(this.isEnterCamera ? Color.Black : Color.White)
    }
    .width($r('app.string.full_screen'))
    .height($r('app.string.full_screen'))
    .padding({
      top: new BreakpointType({
        sm: $r('app.float.window_status_bar_height'),
        md: this.isEnterCamera ? $r('app.float.zero') : $r('app.float.window_status_bar_height'),
        lg: this.isEnterCamera ? $r('app.float.zero') : $r('app.float.window_status_bar_height'),
      }).getValue(this.currentBreakpoint),

      bottom: new BreakpointType({
        sm: $r('app.float.window_navigation_bar_height'),
        md: this.isEnterCamera ? $r('app.float.zero') : $r('app.float.window_navigation_bar_height'),
        lg: this.isEnterCamera ? $r('app.float.zero') : $r('app.float.window_navigation_bar_height'),
      }).getValue(this.currentBreakpoint)
    })
    .backgroundColor(this.isEnterCamera ? Color.Black : Color.White)
  }

  @Builder
  setTemplateView(index: number) {
    TabContent() {
      Column() {
        TitleBackView({ title: $r('app.string.edit_image') })
          .backgroundColor(this.isEnterCamera ? Color.Black : Color.White)
      }
      .width($r('app.string.full_screen'))
      .height($r('app.string.full_screen'))
    }
    .tabBar(BottomTabBarStyle.of(this.navToolIconArr[index], this.navToolTextArr[index]).iconStyle({
      selectedColor: this.getSelectedColor(index),
      unselectedColor: this.getSelectedColor(index),
    }).labelStyle({
      selectedColor: this.getSelectedColor(index),
      unselectedColor: this.getSelectedColor(index),
      font: {
        size: $r('sys.float.ohos_id_text_size_caption1'),
        family: $r('sys.string.ohos_id_text_font_family_medium'),
        weight: FontWeight.Medium,
      }
    }));
  }

  @Builder
  setSelectEditView(index: number) {
    TabContent() {
      Column() {
        TitleBackView({ title: $r('app.string.edit_image') })
          .backgroundColor(this.isEnterCamera ? Color.Black : Color.White)
        SelectedEditeView({ currentBreakpoint: this.currentBreakpoint });
      }
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .width($r('app.string.full_screen'))
      .height($r('app.string.full_screen'))
    }
    .tabBar(BottomTabBarStyle.of(this.navToolIconArr[index], this.navToolTextArr[index]).iconStyle({
      selectedColor: this.getSelectedColor(index),
      unselectedColor: this.getSelectedColor(index),
    }).labelStyle({
      selectedColor: this.getSelectedColor(index),
      unselectedColor: this.getSelectedColor(index),
      font: {
        size: $r('sys.float.ohos_id_text_size_caption1'),
        family: $r('sys.string.ohos_id_text_font_family_medium'),
        weight: FontWeight.Medium,
      }
    }));
  }

  @Builder
  setCameraView(index: number) {
    TabContent() {
      Column() {
        if (this.isEnterCamera) {
          CameraView({
            currentBreakpoint: this.currentBreakpoint,
            cameraIndex: this.cameraIndex,
            isMovingPhoto: this.isMovingPhoto,
          });
        }
      }
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .width($r('app.string.full_screen'))
      .height($r('app.string.full_screen'))
    }
    .tabBar(BottomTabBarStyle.of(this.navToolIconArr[index], this.navToolTextArr[index]).iconStyle({
      selectedColor: this.getSelectedColor(index),
      unselectedColor: this.getSelectedColor(index),
    }).labelStyle({
      selectedColor: this.getSelectedColor(index),
      unselectedColor: this.getSelectedColor(index),
      font: {
        size: $r('sys.float.ohos_id_text_size_caption1'),
        family: $r('sys.string.ohos_id_text_font_family_medium'),
        weight: FontWeight.Medium,
      }
    }));
  }

  private getSelectedColor(index: number) {
    if (index === this.tabsIndex) {
      return this.isEnterCamera ? $r('sys.color.ohos_id_color_activated_dark') :
      $r('sys.color.ohos_id_color_activated');
    } else {
      return this.isEnterCamera ? $r('sys.color.ohos_id_color_text_primary_contrary') :
      $r('sys.color.ohos_id_color_text_primary');
    }
  }
}