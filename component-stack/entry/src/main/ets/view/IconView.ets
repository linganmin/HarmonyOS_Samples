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

import { promptAction } from '@kit.ArkUI';
import { ICON_DATA1, ICON_DATA2 } from '../model/IconModel';
import { IconDataModel } from '../viewmodel/IconViewModel';
import { StackConstant } from '../constant/StackConstant';

// White background style of the lower text in the preceding figure.
@Component
struct IconView1 {
  icon: ResourceStr = '';
  title: ResourceStr = '';

  build() {
    Column({ space: StackConstant.ICON_VIEW_SPACE }) {
      Image(this.icon)
        .width($r('app.integer.icon_view_width'))
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)

      Text(this.title)
        .fontSize($r('app.integer.icon_view_title_font_size'))
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
    }
    .width(StackConstant.FULL_PERCENT)
    .height($r('app.integer.icon_view_height'))
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius($r('app.integer.icon_view_border_radius'))
    .onClick(() => {
      try {
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.component_stack_other_function') });
      } catch (error) {
        console.error(`showToast args error code is ${error.code}, message is ${error.message}`);
      }
    })
  }
}

// White background style of the left text and right image.
@Component
struct IconView2 {
  icon: ResourceStr = '';
  title: ResourceStr = '';

  build() {
    Row() {
      Text(this.title)
        .fontSize($r('app.integer.icon_view_title_font_size2'))
        .fontColor(Color.Black)

      Image(this.icon)
        .width($r('app.integer.icon_view_width2'))
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)
        .margin({ left: $r('app.integer.icon_view_image_margin_left') })
    }
    .width(StackConstant.FULL_PERCENT)
    .height($r('app.integer.icon_view_height2'))
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius($r('app.integer.icon_view_border_radius'))
    .onClick(() => {
      try {
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.component_stack_other_function') });
      } catch (error) {
        console.error(`showToast args error code is ${error.code}, message is ${error.message}`);
      }
    })
  }
}

// Transparent background style of the text above.
@Component
struct IconView3 {
  icon: ResourceStr = '';
  title: ResourceStr = '';

  build() {
    Column({ space: StackConstant.ICON_VIEW_SPACE }) {
      Image(this.icon)
        .width($r('app.integer.icon_view_width'))
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)

      Text(this.title)
        .fontSize($r('app.integer.icon_view_title_font_size'))
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
    }
    .width(StackConstant.FULL_PERCENT)
    .height($r('app.integer.icon_view_height3'))
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      try {
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.component_stack_other_function') });
      } catch (error) {
        console.error(`showToast args error code is ${error.code}, message is ${error.message}`);
      }
    })
  }
}

@Component
export struct IconList1 {
  build() {
    GridRow({
      columns: StackConstant.ICON_LIST_COLUMNS_1,
      gutter: {
        x: StackConstant.ICON_VIEW_SPACE,
        y: StackConstant.ICON_VIEW_SPACE
      }
    }) {
      ForEach(ICON_DATA1, (item: IconDataModel) => {
        GridCol({ span: item.span }) {
          if (item.span === 1) {
            IconView1({ icon: item.icon, title: item.title })
          } else {
            IconView2({ icon: item.icon, title: item.title })
          }
        }
      }, (item: IconDataModel) => item.id.toString())
    }
  }
}

@Component
export struct IconList2 {
  @Prop ratio: number;

  build() {
    GridRow({
      columns: StackConstant.ICON_LIST_COLUMNS_2,
      gutter: {
        x: StackConstant.ICON_VIEW_SPACE,
        y: StackConstant.ICON_VIEW_SPACE
      }
    }) {
      ForEach(ICON_DATA2, (item: IconDataModel) => {
        GridCol({ span: item.span }) {
          IconView3({ icon: item.icon, title: item.title })
        }
        .scale({ x: this.ratio, y: this.ratio })
      }, (item: IconDataModel) => item.id.toString())
    }
  }
}

@Component
export struct IconList3 {
  scroller: Scroller = new Scroller();
  @Prop marginSpace: number;

  build() {
    List({ space: this.marginSpace }) {
      ForEach(ICON_DATA1, (item: IconDataModel) => {
        ListItem() {
          IconView1({ icon: item.icon, title: item.title })
            .width($r('app.integer.icon_view_height'))
        }
      }, (item: IconDataModel) => item.id.toString())
    }
    .height($r('app.integer.icon_view_height'))
    .width(StackConstant.FULL_PERCENT)
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
  }
}