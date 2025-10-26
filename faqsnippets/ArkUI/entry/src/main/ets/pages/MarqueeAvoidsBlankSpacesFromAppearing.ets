/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:Marquee组件的文字滚动，第一次滚动出现大量空白，如何避免空白出现
*/

// [Start marquee_avoids_blank_spaces_from_appearing]
@Entry
@Component
struct MarqueeScroll {
  @State textList: string[] = [
    'this is a test string1 this is a test string1',
    'this is a test string2 this is a test string2 this is a test string2',
    'this is a test string3 this is a test string3 this is a test string3 this is a test string3'
  ];
  @State count: number = 1;

  build() {
    Row() {
      Column() {
        myMarqueeCard({
          textList: $textList,
          updateList: () => {
            this.textList = [
              `This is test data${this.count++}This is test data${this.count++}`,
              `This is test data${this.count++}This is test data${this.count++}This is test data${this.count++}`,
              `This is test data${this.count++}This is test data${this.count++}This is test data${this.count++}This is test data${this.count++}`
            ];
          }
        })
      }
      .width('100%')
      .margin(20)
    }
    .height('100%')
  }
}

@Component
struct myMarqueeCard {
  @Link @Watch('handleNewList') textList: string[];
  @State list: string[] = [];
  scroller1: Scroller = new Scroller();
  scroller2: Scroller = new Scroller();
  scroller3: Scroller = new Scroller();
  updateList?: () => void;
  private intervalID?: number;

  handleNewList() {
    console.info(JSON.stringify(this.textList));
  }

  handleScroll(scroller: Scroller) {
    this.intervalID = setInterval(() => {
      const curOffset: OffsetResult = scroller.currentOffset();
      scroller.scrollTo({
        xOffset: curOffset.xOffset + 50, yOffset: curOffset.yOffset, animation: {
          duration: 1000,
          curve: Curve.Linear
        }
      });
      if (scroller.isAtEnd() && this.scroller1.isAtEnd() && this.scroller2.isAtEnd() && this.scroller3.isAtEnd() &&
      this.updateList) {
        this.scroller1.scrollTo({ xOffset: 0, yOffset: 0, animation: { duration: 0 } });
        this.scroller2.scrollTo({ xOffset: 0, yOffset: 0, animation: { duration: 0 } });
        this.scroller3.scrollTo({ xOffset: 0, yOffset: 0, animation: { duration: 0 } });
        this.updateList();
      }
    }, 500);
  }

  @Builder
  SingleText($$: SingleTextParams) {
    Scroll($$.scroller) {
      Row() {
        Text($$.text)
          .fontSize(30)
          .onAppear(() => {
            this.handleScroll($$.scroller);
          })
      }
    }
    .width(300)
    .scrollable(ScrollDirection.Horizontal)
    .enableScrollInteraction(false)
    .scrollBar(BarState.Off)
  }

  aboutToDisappear(): void {
    clearInterval(this.intervalID);
  }

  build() {
    Column() {
      this.SingleText({ text: this.textList[0], scroller: this.scroller1 })
      this.SingleText({ text: this.textList[1], scroller: this.scroller2 })
      this.SingleText({ text: this.textList[2], scroller: this.scroller3 })
    }
  }
}

class SingleTextParams {
  text: string = '';
  scroller: Scroller = new Scroller();
}

// [End marquee_avoids_blank_spaces_from_appearing]