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

import { Constants } from '../common/Constants';

@Builder
export function QuestionBuilder() {
  Question()
}

@Component
export struct Question {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State title: Resource|undefined = undefined;
  @State questionTag: number = 0;

  aboutToAppear(): void {
    let params: Array<number> = this.navPathStack.getParamByName('Question') as Array<number>
    if (params && params.length > 0) {
      this.questionTag = params[0];
      this.title = Constants.QUESTION_ARRAY[this.questionTag];
    }
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Button($r('app.string.before_optimization'))
          .height(40)
          .width('100%')
          .onClick(() => {
            this.navPathStack.pushPath({ name: `Question${this.questionTag + 1}Incorrect` });
          })
        Button($r('app.string.after_optimization'))
          .height(40)
          .width('100%')
          .onClick(() => {
            this.navPathStack.pushPath({ name: `Question${this.questionTag + 1}Correct` });
          })
      }
      .height('100%')
      .width('100%')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.End)
    }
    .title(this.title)
    .padding({
      top: AppStorage.get<number>('statusBarHeight') ?? 0,
      bottom: (AppStorage.get<number>('naviIndicatorHeight') ?? 0) + 16
    })
  }
}