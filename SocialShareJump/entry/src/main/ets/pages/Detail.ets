/*
* Copyright (C) 2025 Huawei Device Co., Ltd.
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

// [Start access_share_panel]
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor } from '@kit.ArkData';
import { Logger } from '../common/Logger';
// [StartExclude access_share_panel]
import { Article, getArticleById } from '../model/Article';

const TAG = 'Detail';

// [EndExclude access_share_panel]
// [Start load_detail_data]
// entry/src/main/ets/pages/Detail.ets
@Entry
@Component
struct Detail {
  // [StartExclude access_share_panel]
  // [StartExclude load_detail_data]
  @StorageProp('naviIndicatorHeight') naviIndicatorHeight: number = 0;
  @StorageProp('statusBarHeight') statusBarHeight: number = 0;
  @StorageProp('aid') aid: string = '';
  // [EndExclude load_detail_data]
  private article: Article | undefined;

  aboutToAppear(): void {
    if (this.aid && this.aid !== '') {
      this.article = getArticleById(this.aid);
    } else {
      let params = this.getUIContext().getRouter().getParams() as Record<string, string>;
      this.article = getArticleById(params.aid);
    }
  }

  // [EndExclude access_share_panel]
  // [StartExclude load_detail_data]
  private async share() {
    try {
      let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      // [StartExclude access_share_panel]
      let iconData = context.resourceManager.getMediaContentSync($r('app.media.startIcon').id);
      let descriptionStr = context.resourceManager.getStringSync($r('app.string.shared_from_friend').id);
      // [EndExclude access_share_panel]
      // To construct ShareData, you need to configure a valid data message
      let shareData: systemShare.SharedData = new systemShare.SharedData({
        // The type of data shared is a link
        utd: uniformTypeDescriptor.UniformDataType.HYPERLINK,
        // The shared App Linking link is replaced with the real address here
        content: `https://hello.dra.agchosting.link?aid=${this.article?.aId}`,
        // [StartExclude access_share_panel]
        // When the title is not passed, the link is displayed
        title: context.resourceManager.getStringSync(this.article?.title.id),
        // If you don't pass it, you won't see the description
        description: descriptionStr,
        // Recommended incoming app icon If not, the default HTML icon will be displayed
        thumbnail: iconData
        // [EndExclude access_share_panel]
      });
      // The sharing panel is displayed
      let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
      controller.show(context, {
        previewMode: systemShare.SharePreviewMode.DEFAULT,
        selectionMode: systemShare.SelectionMode.SINGLE
      })
      // [EndExclude access_share_panel]
        .then(() => {
          Logger.info(TAG, 'ShareController show success.');
        })
        .catch((error: BusinessError) => {
          Logger.error(TAG, `ShareController show error. code: ${error.code}, message: ${error.message}`);
        });
      // [EndExclude access_share_panel]
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `share err, code: ${error.code}, mesage: ${error.message}`);
    }
  }

  // [StartExclude access_share_panel]
  build() {
    Stack() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontSize($r('sys.float.Title_M'))
            .fontColor([$r('sys.color.icon_primary')])
        }
        .height(40)
        .aspectRatio(1)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.getUIContext().getRouter().back();
        })

        Image(this.article?.avatar)
          .height(40)
          .width(40)
          .borderRadius(20)
          .margin({
            left: 8,
            right: 8
          })

        Text(this.article?.author)
          .fontSize(18)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)

        Blank()

        Button($r('app.string.follow'))
          .width(64)
          .height(40)
          .fontColor($r('sys.color.white'))
          .margin({ right: 8 })

        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.share'))
            .fontSize($r('sys.float.Title_M'))
            .fontColor([$r('sys.color.icon_primary')])
        }
        .height(40)
        .aspectRatio(1)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.share();
        })
      }
      .width('100%')
      .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
      .height(56 + this.statusBarHeight)
      .zIndex(3)
      .position({
        x: 0,
        y: 0
      })
      .padding({
        left: 16,
        right: 16,
        top: this.statusBarHeight
      })

      Scroll() {
        Column() {
          Image($r('app.media.detail'))
            .width('100%')
            .objectFit(ImageFit.Fill)
          Text(this.article?.title)
            .fontColor($r('sys.color.font_primary'))
            .fontSize(18)
            .lineHeight(24)
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
            .padding({
              left: 16,
              right: 16,
              top: 16
            })
          Blank()
          Text($r('app.string.article_detail'))
            .fontColor($r('sys.color.font_primary'))
            .lineHeight(19)
            .fontSize(14)
            .padding({
              left: 16,
              right: 16,
              top: 12
            })
        }
        .alignSelf(ItemAlign.Start)
        .padding({
          top: 56 + this.statusBarHeight,
          bottom: 48 + this.naviIndicatorHeight
        })
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .zIndex(1)

      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.square_and_pencil'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
          Text($r('app.string.edit_comment'))
            .margin({ left: 2 })
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .lineHeight(16)
        }

        Row() {
          SymbolGlyph($r('sys.symbol.heart'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
          Text('999+')
            .margin({ left: 2 })
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .lineHeight(16)
        }

        Row() {
          SymbolGlyph($r('sys.symbol.star'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
          Text('390')
            .margin({ left: 2 })
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .lineHeight(16)
        }

        Row() {
          SymbolGlyph($r('sys.symbol.ellipsis_message'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
          Text('2880')
            .margin({ left: 2 })
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .lineHeight(16)
        }
      }
      .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
      .width('100%')
      .height(48 + this.naviIndicatorHeight)
      .justifyContent(FlexAlign.SpaceBetween)
      .zIndex(2)
      .padding({
        left: 26,
        right: 26,
        bottom: this.naviIndicatorHeight
      })

    }
    .alignContent(Alignment.Bottom)
    .backgroundColor($r('sys.color.background_secondary'))
  }
  // [EndExclude access_share_panel]
  // [EndExclude load_detail_data]
}
// [End access_share_panel]
// [End load_detail_data]