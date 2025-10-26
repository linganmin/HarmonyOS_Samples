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
import { SelectedDataSource } from '../model/SelectedDataSource';
import { BreakpointType } from '../utils/BreakpointSystem';
import { ListAddPictureView } from './ListAddPictureView';
import { ImageInfo } from '../model/ContentInfo';

@Component
export struct SelectedEditeView {
  @StorageLink(CommonConstants.KEY_IMAGE_INFO) imageInfoArr: Array<ImageInfo> = [];
  @Link currentBreakpoint: string;
  @State currentIndex: number = 0;
  @State selectedData: SelectedDataSource = new SelectedDataSource();
  private swiperController: SwiperController = new SwiperController();
  private listScroller: ListScroller = new ListScroller();

  aboutToAppear() {
    this.currentIndex = 0;
    this.imageInfoArr.forEach((imageInfo: ImageInfo) => {
      this.selectedData.addData(imageInfo.imagePixelMap);
    });
  }

  build() {
    Flex({
      direction: FlexDirection.Column,
      wrap: FlexWrap.NoWrap,
      justifyContent: FlexAlign.Start,
      alignItems: ItemAlign.Center,
      alignContent: FlexAlign.Center
    }) {
      this.setSwiperView();
      this.setSelectToolView();
    }
    .width($r('app.string.full_screen'))
    .height($r('app.string.full_screen'))
    .backgroundColor(CommonConstants.GRAY_COLOR)
  }

  @Builder
  setSwiperView() {
    Swiper(this.swiperController) {
      LazyForEach(this.selectedData, (item: PixelMap) => {
        this.setSwiperImage(item);
      })
    }
    .cachedCount(2)
    .indicator(false)
    .loop(false)
    .onAnimationStart((index: number, targetIndex: number) => {
      if (index === targetIndex) {
        return;
      }
      this.currentIndex = targetIndex;
      if (targetIndex > 2) {
        this.listScroller.scrollToIndex(targetIndex);
      } else {
        this.listScroller.scrollToIndex(0);
      }
    })
    .width(new BreakpointType({
      sm: $r('app.string.full_screen')
    }).getValue(this.currentBreakpoint))
    .height($r('app.string.full_screen'))
  }

  @Builder
  setSwiperImage(item: PixelMap) {
    // [Start image]
    Image(item)
      .objectFit(ImageFit.Contain)
      .enableAnalyzer(true)
      .dynamicRangeMode(DynamicRangeMode.HIGH)
      // [End image]
      .height($r('app.string.full_screen'))
  }

  @Builder
  setSelectToolView() {
    Column() {
      ListAddPictureView({
        swiperController: this.swiperController,
        listScroller: this.listScroller,
        currentIndex: this.currentIndex,
        selectedData: this.selectedData,
        itemSize: new BreakpointType({
          sm: $r('app.float.size_80'),
          md: $r('app.float.size_80'),
          lg: $r('app.float.size_114'),
        }).getValue(this.currentBreakpoint)
      })
        .width($r('app.string.full_screen'))
        .margin({ top: $r('app.float.margin_14') })
      this.setTextAndBtn();
    }
    .width($r('app.string.full_screen'))
    .padding({
      left: new BreakpointType({
        sm: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
        md: $r('app.float.margin_32'),
        lg: $r('app.float.margin_32'),
      }).getValue(this.currentBreakpoint),
      right: new BreakpointType({
        sm: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
        md: $r('app.float.margin_32'),
        lg: $r('app.float.margin_32'),
      }).getValue(this.currentBreakpoint),
    })
    .backgroundColor(Color.White)
  }

  @Builder
  setTextAndBtn() {
    Row() {
      Text($r('app.string.select_num', `${this.imageInfoArr.length}/${CommonConstants.LIMIT_PICKER_NUM}`))
        .fontColor($r('sys.color.ohos_id_color_emphasize'))
        .fontSize($r('sys.float.ohos_id_text_size_body1'))

      Button($r('app.string.finish'), { type: ButtonType.Normal, stateEffect: true })
        .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .fontSize($r('sys.float.ohos_id_text_size_button3'))
        .borderRadius($r('sys.float.ohos_id_corner_radius_small_button'))
        .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
        .height($r('app.float.finish_btn_height'))
        .width($r('app.float.size_80'))
        .onClick(() => {
          this.getUIContext().getRouter().pushUrl({
            url: 'pages/GraphicCreationPage',
          })
        })
    }
    .width($r('app.string.full_screen'))
    .height($r('app.float.navigation_height_sm'))
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({
      bottom: new BreakpointType({
        sm: $r('app.float.margin_130'),
        md: $r('app.float.margin_130'),
        lg: $r('app.float.margin_190'),
      }).getValue(this.currentBreakpoint)
    })
  }
}