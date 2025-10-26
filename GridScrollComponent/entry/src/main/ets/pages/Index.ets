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

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack();
  pages: PageInfo[] = [
    new PageInfo($r('app.string.photoGrid'), 'PhotoGridPage', $r('app.string.photoGrid_scenario')),
    new PageInfo($r('app.string.workGrid'), 'WorkGridPage', $r('app.string.workGrid_scenario')),
    new PageInfo($r('app.string.cardGrid'), 'CardGridPage', $r('app.string.cardGrid_scenario')),
    new PageInfo($r('app.string.numberGrid'), 'NumberGridPage', $r('app.string.numberGrid_scenario')),
    new PageInfo($r('app.string.wordGrid'), 'WordGridPage', $r('app.string.wordGrid_scenario')),]

  @Styles
  btnStyle() {
    .height(56)
    .borderRadius(16)
    .backgroundColor(Color.White)
    .padding({
      left: 10,
      right: 10
    })
  }

  @Builder
  buildTitle() {
    Text($r('app.string.scenario_grid'))
      .fontWeight(FontWeight.Bold)
      .fontSize(30)
      .width('100%')
      .fontColor($r('app.color.text_color'))
      .padding({
        top: 8,
        left: 16,
        right: 16,
        bottom: 8
      })
      .margin({
        bottom: 8
      })
  }

  build() {
    Navigation(this.pathStack) {
      List({ space: 12 }) {
        ForEach(this.pages, (page: PageInfo) => {
          ListItem() {
            Row() {
              Text(page.pageName)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.index_text_color'))
            }
            .width('100%')
            .margin({
              top: 15,
              bottom: 5
            })
          }

          ListItem() {
            Column() {
              Row() {
                Text(page.routePath)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)

                Text('')
                  .width('100%')
                  .layoutWeight(1)

                Text(page.description)
                  .fontColor($r('app.color.index_text_color'))
                  .fontSize(16)

                Text() {
                  Span(' ')
                  SymbolSpan($r('sys.symbol.chevron_right'))
                    .fontSize(24)
                }
                .fontColor($r('app.color.index_text_color'))
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .btnStyle()
              .onClick(() => {
                this.pathStack.pushPathByName(page.routePath, null);
              })
            }
          }
        }, (page: PageInfo) => page.routePath)
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16
      })
      .margin({
        top: 12
      })
    }
    .backgroundColor($r('app.color.home_background_color'))
    .title(this.buildTitle())
    .mode(NavigationMode.Stack)
    .width("100%")
    .height("100%")
  }
}

class PageInfo {
  pageName: Resource | string = '';
  routePath: string = '';
  description: Resource | string = '';

  constructor(pageName: Resource | string, routePath: string, description: Resource | string) {
    this.pageName = pageName;
    this.routePath = routePath;
    this.description = description;
  }
}