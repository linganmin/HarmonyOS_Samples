/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { Constants, ChildRoute, Route } from '../common/Constants';
import { BreakpointType } from '../common/Utils';
import { SplitScreen } from '../view/SplitScreenButton';
import { UserButton } from '../view/UserButton';

@Entry
@Component
struct Index {
  @StorageLink('currentBreakpoint') curBp: string = Constants.BREAK_POINT_SM;
  private routes: Route = Constants.ROUTES;
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack();
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  aboutToAppear(): void {
    if (this.curBp === Constants.BREAK_POINT_LG || this.curBp === Constants.BREAK_POINT_MD) {
      this.pageStack.pushPath({ name: 'ImageDrag' });
    }
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        Text($r('app.string.index_title'))
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.Title_L'))
          .height(40)
          .width(Constants.FULL_WIDTH)
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: $r('sys.float.padding_level32'), bottom: $r('sys.float.padding_level6') })
        Column() {
          List() {
            ListItemGroup() {
              ForEach(this.routes.child, (item: ChildRoute) => {
                ListItem() {
                  UserButton({ name: item.name, page: item.route })
                }
              }, (item: string, index: number) => item + index.toString())
              SplitScreen()
            }
            .backgroundColor($r('sys.color.comp_background_primary'))
            .padding({
              top: $r('sys.float.padding_level2'),
              bottom: $r('sys.float.padding_level2')
            })
            .divider({
              strokeWidth: Constants.BORDER_WIDTH,
              color: $r('sys.color.comp_divider'),
              startMargin: $r('sys.float.padding_level6'),
              endMargin: $r('sys.float.padding_level6'),
            })
            .borderRadius($r('sys.float.padding_level8'))
            ListItem() {
              Row() {
                Blank()
                  .width('100%')
                  .height(50)
              }
            }
          }
          .height('auto')
          .width('auto')
          .borderRadius($r('sys.float.padding_level8'))
          .backgroundColor($r('sys.color.background_secondary'))
          .width(Constants.FULL_WIDTH)
          .scrollBar(BarState.Off)
        }
        .layoutWeight(1)
        .borderRadius($r('sys.float.padding_level8'))
        .backgroundColor($r('sys.color.background_secondary'))
      }
      .justifyContent(FlexAlign.Start)
      .height('100%')
      .padding({
        top: 'sys.float.padding_level32',
        left: new BreakpointType($r('sys.float.padding_level8'), $r('sys.float.padding_level12'),
          $r('sys.float.padding_level16')).getValue(this.curBp),
        right: new BreakpointType($r('sys.float.padding_level8'), $r('sys.float.padding_level12'),
          $r('sys.float.padding_level16')).getValue(this.curBp)
      })
    }
    .mode(new BreakpointType(NavigationMode.Stack, NavigationMode.Split, NavigationMode.Split).getValue(this.curBp))
    .navBarWidth(new BreakpointType('360vp', '300vp', '450vp').getValue(this.curBp))
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
  }
}