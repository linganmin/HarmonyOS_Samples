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
import { Dot } from '../model/Dot';
import { hilog } from '@kit.PerformanceAnalysisKit';

const PASSWORD: string = '123456';

@Builder
export function safeCodePageBuilder() {
  SafeCodePageView()
}

/**
 * SafeCode Page
 */
@Component
struct SafeCodePageView {
  @State isInput: boolean = false;
  @State services: Array<string> = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
  @State pwd: string = '';
  @State dots: Array<Dot> = [
    new Dot(0, '#000000'), new Dot(1, '#000000'), new Dot(2, '#000000'),
    new Dot(3, '#000000'), new Dot(4, '#000000'), new Dot(5, '#000000'),
  ];
  pathStack: NavPathStack = new NavPathStack();

  verifyPwd() {
    if (PASSWORD === this.pwd) {
      promptAction.openToast({
        message: $r('app.string.password_success'),
        duration: 1000
      }).catch((err: Error)=>{
        hilog.error(0x0000, 'testTag', 'Failed to open toast. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      });
      this.pathStack.pop();
    }
    if (this.pwd.length === 6 && PASSWORD !== this.pwd) {
      promptAction.openToast({
        message: $r('app.string.password_failed'),
        duration: 1000
      }).catch((err: Error)=>{
        hilog.error(0x0000, 'testTag', 'Failed to open toast. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      });
      for (let i = 0; i < this.pwd.length; i++) {
        this.dots[i].bgColor = '#000000';
      }
      this.pwd = '';
      this.isInput = false;
    }
  }

  build() {
    NavDestination() {
      Column() {
        Row({ space: 6 }) {
          if (this.isInput) {
            ForEach(this.dots, (item: Dot) => {
              DotView({ dot: item })
            }, (item: Dot) => JSON.stringify(item))
          } else {
            Text($r('app.string.password_input'))
              .fontSize(20)
              .fontWeight(700)
              .fontColor('#ffffffff')
          }
        }
        .height(23)
        .margin({ top: 15 })

        Grid() {
          ForEach(this.services, (service: string) => {
            GridItem() {
              Button(service, { type: ButtonType.Circle, stateEffect: true })
                .width(38)
                .height(38)
                .backgroundColor('#40ffffff')
                .onClick(() => {
                  this.isInput = true;
                  if (this.pwd.length < 6) {
                    this.pwd += service;
                    this.dots[this.pwd.length -1].bgColor = '#ffffff';
                  }
                  this.verifyPwd();
                })
            }
          }, (service: string) => service)
        }
        .width('60%')
        .height('59%')
        .rowsTemplate('1fr 1fr 1fr')
        .columnsTemplate('1fr 1fr 1fr')
        .margin({ top: 8 })

        Row() {
          Button('0', { type: ButtonType.Circle, stateEffect: true })
            .width(38)
            .height(38)
            .backgroundColor('#40ffffff')
            .onClick(() => {
              this.isInput = true;
              if (this.pwd.length < 6) {
                this.pwd += '0';
                this.dots[this.pwd.length -1].bgColor = '#ffffff';
              }
              this.verifyPwd();
            })
        }
        .margin({ top: 4 })
      }
      .width('100%')
      .height('100%')
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
    .borderRadius('50%')
    .backgroundColor(Color.Black)
  }
}

@Component
struct DotView {
  @ObjectLink dot: Dot;

  build() {
    Row() {
      Circle()
        .width(9)
        .height(9)
        .strokeWidth(1)
        .fill(this.dot.bgColor)
        .stroke(Color.White)
        .antiAlias(true)
    }
  }
}