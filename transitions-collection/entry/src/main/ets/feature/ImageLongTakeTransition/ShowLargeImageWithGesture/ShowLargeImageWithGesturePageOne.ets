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

@Builder
export function ShowLargeImageWithGesturePageOneBuilder() {
  ShowLargeImageWithGesturePageOne()
}

@Component
struct ShowLargeImageWithGesturePageOne {
  @State clickedIndex: number = 0;
  @State isFirstPageShow: boolean = true;
  @State needFollow: boolean = false;
  private pageInfo: NavPathStack = new NavPathStack();
  private data: number[] = [];
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    for (let i = 0; i < 9; i++) {
      this.data[i] = i;
    }
  }

  // [Start onItemClick_start]
  onItemClick(index: number): void {
    let param: Record<string, Object> = {};
    this.needFollow = false;
    this.clickedIndex = index;
    param['selectedIndex'] = this.clickedIndex;
    param['onIndexChange'] = (index: number) => {
      this.onIndexChange(index);
    };
    param['onBackToFirstPage'] = () => {
      this.onBack();
    }

    this.getUIContext().animateTo({
      duration: 250,
      curve: Curve.EaseIn,
    }, () => {
      this.pageInfo.pushPath({ name: 'ShowLargeImageWithGesturePageTwo', param: param }, false);
      this.isFirstPageShow = false;
    })
  }

  // [End onItemClick_start]

  onIndexChange(index: number): void {
    this.clickedIndex = index;
  }

  onBack(): void {
    this.needFollow = true;
    this.isFirstPageShow = true;
  }

  build() {
    // [Start NavDestination1_start]
    NavDestination() {
      Column() {
        Grid(this.scroller) {
          ForEach(this.data, (item: number) => {
            GridItem() {
              if (this.clickedIndex !== item || (this.isFirstPageShow)) {
                Image($r(`app.media.img_${item % 9}`))
                  .width('100%')
                  .height('100%')
                  .objectFit(ImageFit.Cover)
                  .id('item2_' + item)
                  .onClick(() => {
                    this.onItemClick(item);
                  })
                  .geometryTransition(this.clickedIndex === item ? 'app.media.img_' + item.toString() : '')
                  .transition(TransitionEffect.opacity(0.99))
              }
            }
            .width(this.getUIContext().px2vp(381))
            .height(this.getUIContext().px2vp(381))
          }, (item: number) => item + '')
        }
        .rowsTemplate('1fr 1fr 1fr')
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(2)
        .rowsGap(2)
        .size({
          width: this.getUIContext().px2vp(1169),
          height: this.getUIContext().px2vp(1169)
        })
        .margin({ top: 16 })
      }
    }
    .title('View larger picture')
    .height('100%')
    .width('100%')
    .onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack;
    })

    // [End NavDestination1_start]
  }
}