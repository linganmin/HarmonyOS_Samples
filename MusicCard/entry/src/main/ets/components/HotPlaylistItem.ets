/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@Component
export struct HotPlaylistItem {
  private title: string = '';

  build() {
    Stack() {
      Image($r('app.media.cover3'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .borderRadius(16)

      Row() {
        Column() {
          Text(this.title)
            .fontWeight(700)
            .fontSize(20)
            .fontColor('#DBFFFFFF')
          Text($r('app.string.card_playlists_desc'))
            .fontColor('#99FFFFFF')
            .height(12)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 5 })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        SymbolGlyph($r('sys.symbol.play_round_triangle_fill'))
          .fontSize(36)
          .fontColor(['#99FFFFFF'])
      }
      .backgroundColor('#26000000')
      .height(72)
      .width('100%')
      .borderRadius({
        bottomLeft: 16,
        bottomRight: 16
      })
      .padding({
        left: 12,
        right: 12
      })
    }
    .align(Alignment.Bottom)
    .width(224)
    .height(280)
  }
}

