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

@Component
export struct EpisodeChoose {
  @Prop numberTest: number[];
  @Link videoIndex: number;

  aboutToAppear(): void {
    console.info('videoIndex EpisodeChoose ' + this.videoIndex)
  }

  build() {
    Flex() {
      ForEach(this.numberTest, (item: number, index) => {
        RelativeContainer() {
          Text(item.toString())
            .width(46)
            .height(46)
            .fontSize(16)
            .textAlign(TextAlign.Center)
          if (this.videoIndex === index) {
            SymbolGlyph($r('sys.symbol.rhythm'))
              .fontSize(16)
              .alignRules({
                bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
                left: { anchor: '__container__', align: HorizontalAlign.Start },
              })
              .fontColor([$r('sys.color.background_emphasize')])
              .offset({
                x: 2,
                y: 2
              })
          }
        }
        .width(46)
        .height(46)
        .borderWidth('1')
        .backgroundColor(this.videoIndex === index ? $r('sys.color.comp_emphasize_tertiary') : $r('sys.color.background_primary'))
        .borderColor(this.videoIndex === index ? $r('sys.color.background_emphasize') : $r('sys.color.font_fourth'))
        .borderRadius(8)
        .margin({
          right: 12
        })
        .onClick(() => {
          this.videoIndex = item - 1;
        })
      })
    }
  }
}