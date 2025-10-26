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

import { MyDataSource } from '../common/MyDataSource';
import { Question } from '../model/Question';

// [Start QuestionSwiperItem_start]
@Reusable
@Component
struct QuestionSwiperItem {
  @State itemData: Question | null = null;

  aboutToReuse(params: Record<string, Object>): void {
    this.itemData = params.itemData as Question;
  }

  build() {
    Column() {
      Text(this.itemData?.title)
        // [StartExclude QuestionSwiperItem_start]
        .fontSize(18)
        .fontColor($r('sys.color.ohos_id_color_primary'))
        .alignSelf(ItemAlign.Start)
        .margin({
          top: 10,
          bottom: 16
        })
      // [EndExclude QuestionSwiperItem_start]
      Image(this.itemData?.image)
        // [StartExclude QuestionSwiperItem_start]
        .width('100%')
        .borderRadius(12)
        .objectFit(ImageFit.Contain)
        .margin({
          bottom: 16
        })
      // [EndExclude QuestionSwiperItem_start]

      Column({ space: 16 }) {
        // [StartExclude QuestionSwiperItem_start]
        ForEach(this.itemData?.answers, (item: Resource) => {
          Text(item)
            .fontSize(16)
            .fontColor($r('sys.color.ohos_id_color_primary'))
        }, (item: ResourceStr) => JSON.stringify(item))
        // [EndExclude QuestionSwiperItem_start]
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    // [StartExclude QuestionSwiperItem_start]
    .width('100%')
    .padding({
      left: 16,
      right: 16
    })
    // [EndExclude QuestionSwiperItem_start]
  }
}
// [End QuestionSwiperItem_start]

@Component
export struct LazyForEachSwiper {
  @State currentIndex: number = 0;
  private swiperController: SwiperController = new SwiperController();
  private dataSource = new MyDataSource<Question>();

  aboutToAppear(): void {
    for (let i = 0; i < 1000; i++) {
      let title = $r('app.string.question_title', i + 1);
      let answers = [$r('app.string.answer1'), $r('app.string.answer2'), $r('app.string.answer3'),
        $r('app.string.answer4')];
      this.dataSource.pushData(new Question(i.toString(), title, $r('app.media.answer_pic'), answers))
    }
  }

  build() {
    NavDestination() {
      Column() {
        // [Start LazyForEach_start]
        Swiper(this.swiperController) {
          LazyForEach(this.dataSource, (item: Question) => {
            QuestionSwiperItem({ itemData: item })
          }, (item: Question) => item.id)
        }
        // [End LazyForEach_start]
        .layoutWeight(1)
        .indicator(false)
        .onChange(index => {
          this.currentIndex = index;
        })

        Text($r('app.string.current_title_index', this.currentIndex + 1, this.dataSource.totalCount()))
          .fontSize(16)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.background_secondary'))
      .height('100%')
      .width('100%')
    }
    .title($r('app.string.title_question'))
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({
      top: AppStorage.get<number>('statusBarHeight') ?? 0,
      bottom: (AppStorage.get<number>('naviIndicatorHeight') ?? 0) + 16
    })
  }
}