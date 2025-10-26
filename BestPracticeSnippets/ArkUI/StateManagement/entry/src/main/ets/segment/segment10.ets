/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

@Builder
export function Segment10Builder() {
  NavDestination(){
    Index()
  }
}
// [Start Counter_example5]
@Component
struct Index {
  @State currentIndex: number = 0; // The subscript of the currently selected list item
  private listData: string[] = [];


  aboutToAppear(): void {
    for (let i = 0; i < 10; i++) {
      this.listData.push(`${i}`);
    }
  }


  build() {
    Row() {
      Column() {
        List() {
          ForEach(this.listData, (item: string, index: number) => {
            ListItem() {
              ListItemComponent({ item: item, index: index, currentIndex: this.currentIndex })
            }
          })
        }
        .alignListItem(ListItemAlign.Center)
      }
      .width('100%')
    }
    .height('100%')
  }
}


@Component
struct ListItemComponent {
  @Prop item: string;
  @Prop index: number; // The subscript of the list item
  @Link currentIndex: number;
  private sizeFont: number = 50;


  isRender(): number {
    console.info(`ListItemComponent ${this.index} Text is rendered`);
    return this.sizeFont;
  }


  build() {
    Column() {
      Text(this.item)
        .fontSize(this.isRender())// Dynamically set the color of the text according to the difference between the index and currentIndex of the current list item.
        .fontColor(Math.abs(this.index - this.currentIndex) <= 1 ? Color.Red : Color.Blue)
        .onClick(() => {
          this.currentIndex = this.index;
        })
    }
  }
}
// [End Counter_example5]