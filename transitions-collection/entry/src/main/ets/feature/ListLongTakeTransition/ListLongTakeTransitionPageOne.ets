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

import { curves } from '@kit.ArkUI'
import { ListDetailPageExtraInfo } from '../../utils/commonutils/ExtraInfo'
import Constants from '../../common/Constants'
import { getResourceString } from '../../utils/commonutils/ResourceString';

@Builder
export function ListLongTakeTransitionPageOneBuilder() {
  ListLongTakeTransitionPageOne()
}

interface ListContent {
  title: string | Resource;
  content: Resource;
}

@Component
export default struct ListLongTakeTransitionPageOne {
  @State transitionEffect: TransitionEffect = TransitionEffect.IDENTITY;
  private pageInfos: NavPathStack = new NavPathStack();
  private listContent: ListContent[] =
    [
      {
        title: getResourceString(this.getUIContext(), $r('app.string.memorandum'), this) + 1,
        content: $r('app.string.DetailPage_text')
      },
      {
        title: getResourceString(this.getUIContext(), $r('app.string.memorandum'), this) + 2,
        content: $r('app.string.DetailPage_text')
      },
      {
        title: getResourceString(this.getUIContext(), $r('app.string.memorandum'), this) + 3,
        content: $r('app.string.DetailPage_text')
      },
      {
        title: getResourceString(this.getUIContext(), $r('app.string.memorandum'), this) + 4,
        content: $r('app.string.DetailPage_text')
      },
      {
        title: getResourceString(this.getUIContext(), $r('app.string.memorandum'), this) + 5,
        content: $r('app.string.DetailPage_text')
      },
      {
        title: getResourceString(this.getUIContext(), $r('app.string.memorandum'), this) + 6,
        content: $r('app.string.DetailPage_text')
      },
      {
        title: getResourceString(this.getUIContext(), $r('app.string.memorandum'), this) + 7,
        content: $r('app.string.DetailPage_text')
      },
      {
        title: getResourceString(this.getUIContext(), $r('app.string.memorandum'), this) + 8,
        content: $r('app.string.DetailPage_text')
      },
    ];

  build() {
    NavDestination() {
      Scroll() {
        List({ space: 12 }) {
          ForEach(this.listContent, (item: ListContent, index: number) => {
            ListItem() {
              MyButton({
                listContent: item,
                indexValue: index.toString(),
                onButtonClicked: (indexValue: string) => {
                  this.onButtonClicked(indexValue, item.title, item.content);
                }
              })
            }
          }, (name: string) => name)
        }
        .height('100%')
        .width('100%')
        .alignListItem(ListItemAlign.Center)
        .padding({ top: 16 })
      }
      .scrollBarWidth(0)
      .size({
        width: '100%',
        height: '100%'
      })
      .edgeEffect(EdgeEffect.Spring)
    }
    .transition(this.transitionEffect)
    .backgroundColor(Constants.DEFAULT_BG_COLOR)
    .title(getResourceString(this.getUIContext(), $r('app.string.list_title'), this))
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
    .onBackPressed(() => {
      this.transitionEffect = TransitionEffect.IDENTITY;
      this.pageInfos.pop(true);
      return true;
    })
  }

  private onButtonClicked(indexValue: string, title: string | Resource, content: Resource): void {
    this.transitionEffect = TransitionEffect.OPACITY
      .combine(TransitionEffect.scale({ x: 0.9, y: 0.9 }))
      .animation({ curve: curves.interpolatingSpring(0, 1, 195, 23) })

    let param = new ListDetailPageExtraInfo(indexValue, title, content);
    this.getUIContext().animateTo({ curve: curves.interpolatingSpring(0, 1, 328, 36) }, () => {
      this.pageInfos.pushPath({ name: 'ListLongTakeTransitionPageTwo', param }, false);
    })
  }
}

// [Start MyButton_start]
@Component
export struct MyButton {
  @Prop listContent: ListContent;
  @Prop indexValue: string;
  @State scaleValue: number = 1;

  build() {
    Column({ space: 10 }) {
      Row({ space: 5 }) {
        Line()
          .startPoint([0, 0])
          .endPoint([0, 20])
          .strokeWidth(5)
          .stroke(Color.Yellow)
          .strokeLineCap(LineCapStyle.Round)
        Text(this.listContent.title)
          .fontWeight(FontWeight.Medium)
          .fontSize(16)
      }

      Text(this.listContent.content)
        .fontColor(Color.Grey)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontSize(14)
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: 20,
      right: 20,
      top: 20,
      bottom: 20
    })
    .width('91%')
    .backgroundColor(Color.White)
    .clip(true)
    .borderRadius(20)
    .scale({
      x: this.scaleValue,
      y: this.scaleValue
    })
    .geometryTransition(this.indexValue, { follow: true })
    .onTouch((event?: TouchEvent) => {
      this.onTouchProcess(event);
    })
    .onClick(() => {
      this.onButtonClicked?.(this.indexValue);
    })
  }

  onButtonClicked: (index: string) => void = (_index: string) => {
  };

  private onTouchProcess(event?: TouchEvent): void {
    if (!event) {
      return;
    }
    if (event.type === TouchType.Down) {
      this.getUIContext().animateTo({ curve: curves.interpolatingSpring(0, 1, 350, 35) }, () => {
        this.scaleValue = 0.95;
      })
    } else if (event.type === TouchType.Up) {
      this.getUIContext().animateTo({ curve: curves.interpolatingSpring(0, 1, 350, 35) }, () => {
        this.scaleValue = 1;
      })
    } else if (event.type === TouchType.Cancel) {
      this.getUIContext().animateTo({ curve: curves.interpolatingSpring(0, 1, 350, 35) }, () => {
        this.scaleValue = 1;
      })
    }
  }
}

// [End MyButton_start]