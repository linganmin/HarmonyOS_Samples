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

import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import CommonConstants from '../common/constants/CommonContants';
import { ArraybufferType } from './ArraybufferType';
import { ArrayType } from './ArrayType';
import { DateType } from './DateType';
import { NumberType } from './NumberType';
import { ObjectType } from './ObjectType';
import { StringBoolType } from './StringBoolType';

@Entry
@Component
struct Index {
  @Provide('pathStack') pathStack: NavPathStack = new NavPathStack();
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  getString(id: number): string {
    let result = '';
    try {
      result = this.context.resourceManager.getStringSync(id);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'Index', `getStringSync failed. error code=${err.code}, message=${err.message}`);
    }
    return result;
  }

  @Builder
  pathStackBuilder(name: string, param: string) {
    if (name === 'NumberType') {
      NavDestination() {
        NumberType()
      }
      .backgroundColor($r('app.color.back_ground_color'))
      .title(this.getString($r('app.string.NumberType').id))
    } else if (name === 'StringBoolType') {
      NavDestination() {
        StringBoolType()
      }
      .backgroundColor($r('app.color.back_ground_color'))
      .title(this.getString($r('app.string.StringBoolType').id))
    } else if (name === 'ArrayType') {
      NavDestination() {
        ArrayType()
      }
      .backgroundColor($r('app.color.back_ground_color'))
      .title(this.getString($r('app.string.ArrayType').id))
    } else if (name === 'ArraybufferType') {
      NavDestination() {
        ArraybufferType()
      }
      .backgroundColor($r('app.color.back_ground_color'))
      .title(this.getString($r('app.string.ArraybufferType').id))
    } else if (name === 'ObjectType') {
      NavDestination() {
        ObjectType()
      }
      .backgroundColor($r('app.color.back_ground_color'))
      .title(this.getString($r('app.string.ObjectType').id))
    } else {
      NavDestination() {
        DateType()
      }
      .backgroundColor($r('app.color.back_ground_color'))
      .title(this.getString($r('app.string.date_type').id))
    }
  }

  build() {
    Navigation(this.pathStack) {
      Row() {
        Column({ space: CommonConstants.SPACE }) {
          Row() {
            Text($r('app.string.NumberType'))
              .fontSize($r('app.float.title1_font_size'))
              .fontWeight(CommonConstants.FONT_WEIGHT)
              .height(CommonConstants.FULL_PARENT)
              .align(Alignment.Center)
              .maxLines(CommonConstants.MAX_LINES)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ left: $r('app.float.margin_left') })
          }
          .height($r('app.float.row_height'))
          .width(CommonConstants.FULL_PARENT)
          .backgroundColor($r('app.color.start_window_background'))
          .borderRadius($r('app.float.index_border_radius'))
          .onClick(() => {
            this.pathStack.pushPath({ name: 'NumberType' });
          })

          Row() {
            Text($r('app.string.StringBoolType'))
              .fontSize($r('app.float.title1_font_size'))
              .fontWeight(CommonConstants.FONT_WEIGHT)
              .height(CommonConstants.FULL_PARENT)
              .align(Alignment.Center)
              .maxLines(CommonConstants.MAX_LINES)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ left: $r('app.float.margin_left') })
          }
          .height($r('app.float.row_height'))
          .width(CommonConstants.FULL_PARENT)
          .backgroundColor($r('app.color.start_window_background'))
          .borderRadius($r('app.float.index_border_radius'))
          .onClick(() => {
            this.pathStack.pushPath({ name: 'StringBoolType' });
          })

          Row() {
            Text($r('app.string.ArrayType'))
              .fontSize($r('app.float.title1_font_size'))
              .fontWeight(CommonConstants.FONT_WEIGHT)
              .height(CommonConstants.FULL_PARENT)
              .align(Alignment.Center)
              .maxLines(CommonConstants.MAX_LINES)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ left: $r('app.float.margin_left') })
          }
          .height($r('app.float.row_height'))
          .width(CommonConstants.FULL_PARENT)
          .backgroundColor($r('app.color.start_window_background'))
          .borderRadius($r('app.float.index_border_radius'))
          .onClick(() => {
            this.pathStack.pushPath({ name: 'ArrayType' });
          })

          Row() {
            Text($r('app.string.ArraybufferType'))
              .fontSize($r('app.float.title1_font_size'))
              .fontWeight(CommonConstants.FONT_WEIGHT)
              .height(CommonConstants.FULL_PARENT)
              .align(Alignment.Center)
              .maxLines(CommonConstants.MAX_LINES)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ left: $r('app.float.margin_left') })
          }
          .height($r('app.float.row_height'))
          .width(CommonConstants.FULL_PARENT)
          .backgroundColor($r('app.color.start_window_background'))
          .borderRadius($r('app.float.index_border_radius'))
          .onClick(() => {
            this.pathStack.pushPath({ name: 'ArraybufferType' });
          })

          Row() {
            Text($r('app.string.ObjectType'))
              .fontSize($r('app.float.title1_font_size'))
              .fontWeight(CommonConstants.FONT_WEIGHT)
              .height(CommonConstants.FULL_PARENT)
              .align(Alignment.Center)
              .maxLines(CommonConstants.MAX_LINES)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ left: $r('app.float.margin_left') })
          }
          .height($r('app.float.row_height'))
          .width(CommonConstants.FULL_PARENT)
          .backgroundColor($r('app.color.start_window_background'))
          .borderRadius($r('app.float.index_border_radius'))
          .onClick(() => {
            this.pathStack.pushPath({ name: 'ObjectType' });
          })

          Row() {
            Text($r("app.string.date_type"))
              .fontSize($r('app.float.title1_font_size'))
              .fontWeight(CommonConstants.FONT_WEIGHT)
              .height(CommonConstants.FULL_PARENT)
              .align(Alignment.Center)
              .maxLines(CommonConstants.MAX_LINES)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ left: $r('app.float.margin_left') })
          }
          .height($r('app.float.row_height'))
          .width(CommonConstants.FULL_PARENT)
          .backgroundColor($r('app.color.start_window_background'))
          .borderRadius($r('app.float.index_border_radius'))
          .onClick(() => {
            this.pathStack.pushPath({ name: 'DateType' });
          })
        }
        .height(CommonConstants.FULL_PARENT)
        .alignItems(HorizontalAlign.Start)
      }
      .width(CommonConstants.FULL_PARENT)
      .height(CommonConstants.FULL_PARENT)
      .padding({
        left: $r('app.float.level1_padding_left'),
        right: $r('app.float.level1_padding_right'),
        top: $r('app.float.level1_padding_top')
      })
    }
    .navDestination(this.pathStackBuilder)
    .mode(NavigationMode.Stack)
    .title($r('app.string.Demo'))
    .backgroundColor($r('app.color.back_ground_color'))
  }
}