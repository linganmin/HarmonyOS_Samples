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
// [Start dynamic_lyrics_menu_comp_add_form_menu]
import { AddFormMenuItem } from '@kit.ArkUI';
// [StartExclude dynamic_lyrics_menu_comp_add_form_menu]
import { formBindingData } from '@kit.FormKit';
import { FormControlData } from '../viewmodel/FormControlData';
import { hilog } from '@kit.PerformanceAnalysisKit';

class CardInfo {
  cardRealName: string = '';
  cardDimension: number = 0
  displayName: string = ''
  description: string = ''
  url: string = ''
}

class FormDataClass {
  imgBg: string = '';
  formImages: Record<string, number> = {};
  isLoaded: boolean = true;
  imageColorHex: string = '';
}

class MyDataSource implements IDataSource {
  private list: CardInfo[] = [];

  constructor(list: CardInfo[]) {
    this.list = list;
  }

  totalCount(): number {
    return this.list.length;
  }

  getData(index: number): CardInfo {
    return this.list[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
  }

  unregisterDataChangeListener() {
  }
}

const tag = 'AddFormMenuItem';

// src/main/ets/components/MenuComp.ets

// [Start dynamic_lyrics_menu_comp]
@Component
export struct MenuComp {
  // [StartExclude dynamic_lyrics_menu_comp]
  @State isShow: boolean = false;
  @State listData: number[] = [0]
  private compId: string = 'compIdExample';
  private swiperController: SwiperController = new SwiperController();
  @State swiperIndex: number = 0;
  @State formBindData: FormControlData | FormDataClass = new FormControlData();
  // [EndExclude dynamic_lyrics_menu_comp]
  @State card: CardInfo = new CardInfo();
  @State cardInfos: CardInfo[] = [{
    cardRealName: 'PlayControlCard2x2',
    cardDimension: 2,
    displayName: 'app.string.widget_display_name_control',
    description: 'app.string.widget_desc_control',
    url: 'app.media.PlayControlCard2x2'
  },
    // [StartExclude dynamic_lyrics_menu_comp]
    {
      cardRealName: 'PlayControlCard2x4',
      cardDimension: 3,
      displayName: 'app.string.widget_display_name_control',
      description: 'app.string.widget_desc_control',
      url: 'app.media.PlayControlCard2x4'
    }, {
      cardRealName: 'LyricsCard',
      cardDimension: 3,
      displayName: 'app.string.widget_display_name_lyrics',
      description: 'app.string.widget_desc_lyrics',
      url: 'app.media.LyricsCard2x4'
    }, {
      cardRealName: 'LyricsCard',
      cardDimension: 4,
      displayName: 'app.string.widget_display_name_lyrics',
      description: 'app.string.widget_desc_lyrics',
      url: 'app.media.LyricsCard4x4'
    }, {
      cardRealName: 'DynamicLyrics',
      cardDimension: 3,
      displayName: 'app.string.widget_dynamic_lyrics',
      description: 'app.string.widget_desc_dynamic_lyrics',
      url: 'app.media.DynamicLyrics2x4'
    }, {
      cardRealName: 'RecommendedMusic1x2',
      cardDimension: 1,
      displayName: 'app.string.recommended_playlists',
      description: 'app.string.widget_desc_recommended',
      url: 'app.media.RecommendedMusic1x2'
    }, {
      cardRealName: 'RecommendedMusic2x4',
      cardDimension: 3,
      displayName: 'app.string.recommended_playlists',
      description: 'app.string.widget_desc_recommended',
      url: 'app.media.RecommendedMusic2x4'
    }
  // [EndExclude dynamic_lyrics_menu_comp]
  ]
  // [StartExclude dynamic_lyrics_menu_comp]

  private data: MyDataSource = new MyDataSource(this.cardInfos);

  async createCardBindData(index: number) {
    this.card = this.cardInfos[index];
  }

  aboutToAppear(): void {
    this.createCardBindData(this.swiperIndex);
  }

  // [Start dynamic_lyrics_menu_comp_bind_context_menu]
  @Builder
  SheetModal() {
    Column() {
      // [StartExclude dynamic_lyrics_menu_comp_bind_context_menu]
      Column() {
        Swiper(this.swiperController) {
          LazyForEach(this.data, (item: CardInfo) => {
            Flex({
              direction: FlexDirection.Column
            }) {
              Column() {
                Text($r(item.displayName))
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .margin({
                    bottom: 5
                  })
                Text($r(item.description))
                  .fontSize(16)
                  .fontColor('#8d8d8d')
              }
              .width('100%')
              .margin({
                top: 20,
                bottom: 50
              })

              Row() {
                Image($r(item.url))
                  .objectFit(ImageFit.ScaleDown)
                  .id(this.compId)
                  .borderRadius(10)
                  .bindContextMenu(this.MyMenu(), ResponseType.LongPress, {
                    placement: Placement.TopLeft
                  })
                  .width(264)
                  .borderRadius(20)
                  .margin({
                    bottom: 40
                  })
              }
              .width('100%')
              .flexGrow(1)
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Center)
            }
            .width(264)
            .height('100%')
          }, (item: string) => item)
        }
        .width('100%')
        .height('100%')
        .cachedCount(2)
        .index($$this.swiperIndex)
        .autoPlay(false)
        .indicatorInteractive(true)
        .itemSpace(15)
        .prevMargin(25)
        .nextMargin(25)
        .curve(Curve.Linear)
        .onChange((index: number) => {
          this.createCardBindData(index);
        })
        .onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
          this.swiperIndex = index;
        })
      }
      .width('100%')
      .height('calc(100% - 68vp)')

      // [EndExclude dynamic_lyrics_menu_comp_bind_context_menu]

      Button($r('app.string.long_pressc_btn'))
        .fontSize(16)
        .width(328)
        .height(40)
        .bindContextMenu(this.MyMenu(), ResponseType.LongPress, {
          placement: Placement.TopLeft
        })
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }

  // [End dynamic_lyrics_menu_comp_bind_context_menu]
  // [EndExclude dynamic_lyrics_menu_comp_add_form_menu]

  @Builder
  MyMenu() {
    Menu() {
      AddFormMenuItem(
        {
          bundleName: 'com.huawei.music.card', // Package Name
          abilityName: 'PhoneFormAbility', // Module Capability Name
          parameters: {
            'ohos.extra.param.key.form_dimension': this.card.cardDimension, // Card size, 1 represents 1*2 card, 2 represents 2*2 card, 3 represents 2*4 card, 4 represents 4*4 card, 7 represents 6*4 card, 6 represents 1*1 card
            'ohos.extra.param.key.form_name': this.card.cardRealName, // Card Name
            'ohos.extra.param.key.module_name': 'entry' // Module name to which the card belongs
          },
        },
        this.compId,
        {
          formBindingData: formBindingData.createFormBindingData({}),
          callback: (error, formId) => {
            hilog.info(0x3900, tag, `callback info：error = ${JSON.stringify(error)}, formId = ${formId}`);
            if (error?.code === 0) {
              this.getUIContext().getPromptAction().showToast({
                message: $r('app.string.successfully_added_to_desktop'),
                duration: 1000
              });
              this.isShow = false
            } else {
              this.getUIContext().getPromptAction().showToast({
                message: $r('app.string.error_added_to_desktop'),
                duration: 1000
              });
            }
          },
          style: {}
        }
      )
    }
  }

  // [End dynamic_lyrics_menu_comp_add_form_menu]

  @Builder
  MenuBuilder() {
    Column() {
      Row() {
        Text($r('app.string.add_desktop_widget'))
          .fontSize(16)
          .width('100%')
          .height('100%')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .align(Alignment.Center)
      .onClick(() => {
        this.isShow = true
      })
    }.padding({
      left: 5
    })
    .height(56)
    .width(224)
    .borderRadius(20)
  }

  // [Start dynamic_lyrics_menu_comp_bind_sheet]
  build() {
    Column() {
      Text('+')
        .height(40)
        .fontSize(30)
        .textAlign(TextAlign.Center)
        .lineHeight(40)
        .fontWeight(300)
        .bindSheet($$this.isShow, this.SheetModal(), {
          detents: [600, SheetSize.MEDIUM, SheetSize.LARGE],
          backgroundColor: '#ededeb',
          dragBar: true,
          title: { title: $r('app.string.add_desktop_widget'), subtitle: "" },
          onDisappear: () => {
            this.isShow = false
          }
        })
    }
    // [End dynamic_lyrics_menu_comp_bind_sheet]
    .bindMenu(this.MenuBuilder)
    .height(40)
    .width(40)
    .margin({
      right: 16
    })
    .backgroundColor('#e3e5e4')
    .borderRadius('50%')
  }

  // [EndExclude dynamic_lyrics_menu_comp]
}

// [End dynamic_lyrics_menu_comp]