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
import { BreakpointType } from '../utils/BreakpointSystem';
import { DataUtils } from '../utils/DataUtils';
import { UIUtils } from '../utils/UIUtils';
import { FileUtils } from '../utils/FileUtils';
import { ImageInfo } from '../model/ContentInfo';

@Component
export struct NavigationBarView {
  swiperController: SwiperController | undefined = undefined;
  @State selectIndex: number = 0;
  @StorageLink(CommonConstants.BREAKPOINT_NAME) currentBreakpoint: string = CommonConstants.BREAKPOINT_SM;
  private selectIconArr: Resource[] =
    [$r('app.media.icon_home_filled'), $r('app.media.ic_public_appstore'), $r('app.media.ic_public_comments'),
      $r('app.media.ic_public_contacts')];
  private labelArr: Resource[] =
    [$r('app.string.main_home'), $r('app.string.main_shopping'), $r('app.string.main_message'),
      $r('app.string.main_mine')];
  private readonly container: string = '__container__';

  build() {
    if (this.currentBreakpoint === CommonConstants.BREAKPOINT_SM) {
      Row() {
        this.setNavigationItem(0);
        this.setNavigationItem(1);
        this.setAddPictureItem();
        this.setNavigationItem(2);
        this.setNavigationItem(3);
      }
      .width($r('app.string.full_screen'))
      .height($r('app.float.navigation_height_sm'))
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: $r('app.float.window_navigation_bar_height') })
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    } else {
      RelativeContainer() {
        Column() {
          this.setNavigationItem(0);
          this.setNavigationItem(1);
          this.setNavigationItem(2);
          this.setNavigationItem(3);
        }
        .width($r('app.string.full_screen'))
        .alignRules({
          middle: { anchor: this.container, align: HorizontalAlign.Center },
          center: { anchor: this.container, align: VerticalAlign.Center }
        })

        Column() {
          this.setAddPictureItem();
        }
        .alignRules({
          bottom: { anchor: this.container, align: VerticalAlign.Bottom }
        })
      }
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .width($r('app.float.navigation_width'))
      .height($r('app.string.full_screen'))
      .padding({ top: $r('app.float.window_status_bar_height'), bottom: $r('app.float.window_status_bar_height') })
    }
  }

  @Builder
  setAddPictureItem() {
    Column() {
      Image($r('sys.media.ohos_ic_public_add_norm_filled'))
        .objectFit(ImageFit.Fill)
        .fillColor($r('sys.color.ohos_id_color_emphasize'))
        .width($r('app.float.navigation_icon_size_40'))
        .height($r('app.float.navigation_icon_size_40'))
    }
    .width(new BreakpointType(
      {
        sm: $r('app.string.full_screen_20'),
        md: $r('app.string.full_screen'),
        lg: $r('app.string.full_screen'),
      }
    ).getValue(this.currentBreakpoint))
    .onClick(() => {
      UIUtils.showPickerView(this.getUIContext(), 0, (uriArr: string[]) => {
        let imageInfoArr: ImageInfo[] = [];
        uriArr.forEach((uri: string) => {
          FileUtils.copyFileToDestination(uri, DataUtils.context.distributedFilesDir);
          let imageInfo: ImageInfo | undefined = FileUtils.createPixelMap(uri);
          if (imageInfo) {
            imageInfoArr.push(imageInfo);
          }
        });
        AppStorage.setOrCreate<Array<ImageInfo>>(CommonConstants.KEY_IMAGE_INFO, imageInfoArr);
        this.getUIContext().getRouter().pushUrl({
          url: 'pages/ImageEditPage'
        });
      });
    });
  }

  @Builder
  setNavigationItem(index: number) {
    Column({ space: DataUtils.fromResToNumber($r('app.float.space_4')) }) {
      Image(this.selectIconArr[index])
        .objectFit(ImageFit.Fill)
        .fillColor(this.selectIndex === index ? $r('sys.color.ohos_id_color_emphasize') :
        $r('sys.color.ohos_id_color_bottom_tab_text_off'))
        .width($r('app.float.navigation_icon_size'))
        .height($r('app.float.navigation_icon_size'))

      Text(this.labelArr[index])
        .fontSize($r('sys.float.ohos_id_text_size_caption1'))
        .fontWeight(FontWeight.Medium)
        .fontColor(this.selectIndex === index ? $r('sys.color.ohos_id_color_bottom_tab_text_on') :
        $r('sys.color.ohos_id_color_bottom_tab_text_off'))
    }
    .width(new BreakpointType(
      {
        sm: $r('app.string.full_screen_20'),
        md: $r('app.string.full_screen'),
        lg: $r('app.string.full_screen'),
      }
    ).getValue(this.currentBreakpoint))
    .height(new BreakpointType(
      {
        sm: $r('app.string.full_screen'),
        md: $r('app.float.navigation_height_lg'),
        lg: $r('app.float.navigation_height_lg'),
      }
    ).getValue(this.currentBreakpoint))
    .padding({
      top: new BreakpointType(
        {
          sm: $r('app.float.margin_4'),
          md: $r('app.float.zero'),
          lg: $r('app.float.zero'),
        }
      ).getValue(this.currentBreakpoint)
    })
    .onClick(() => {
    })
  }
}