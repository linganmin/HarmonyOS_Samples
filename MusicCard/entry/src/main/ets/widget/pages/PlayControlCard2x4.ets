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

import ActionUtils from '../model/ActionUtils';
import { CollectAction, PlayActionType } from '../model/FormCardConstant';

const CollectAlignRules: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
  'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
  'right': { 'anchor': '__container__', 'align': HorizontalAlign.End }
};

const TitleAlignRules: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
  'left': { 'anchor': 'musicCover', 'align': HorizontalAlign.End }
};

const SingerAlignRules: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
  'top': { 'anchor': 'musicTitle', 'align': VerticalAlign.Bottom },
  'left': { 'anchor': 'musicCover', 'align': HorizontalAlign.End }
};

const ControlAlignRules: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
  'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
  'left': { 'anchor': 'musicCover', 'align': HorizontalAlign.End }
};
// [Start storage_update_call1]
// [Start is_need_request_update_call]
// [Start music_control_card_achieve]
// [Start music_control_card_collect]
// [Start music_control_card_color_card]
// [Start music_control_card_router_to_pages]
// [Start music_control_card_onclick]
// src/main/ets/widget/pages/PlayControlCard2x4.ets
let storageUpdateCall = new LocalStorage();

@Entry(storageUpdateCall)
@Component
struct PlayControlCard2x4 {
  // [StartExclude music_control_card_router_to_pages]
  // [StartExclude music_control_card_color_card]
  @LocalStorageProp('formId') formId: string = '';
  // [StartExclude music_control_card_collect]
  // [StartExclude music_control_card_onclick]
  @LocalStorageProp('isNeedRequestUpdate') @Watch('requestData') isNeedRequestUpdate: boolean = false;
  // [EndExclude music_control_card_collect]
  // [EndExclude music_control_card_onclick]
  // [StartExclude is_need_request_update_call]
  @LocalStorageProp('isPlay') isPlay: boolean = false;
  // [StartExclude music_control_card_achieve]
  // [StartExclude music_control_card_collect]
  // [StartExclude music_control_card_onclick]
  @LocalStorageProp('title') title: string = 'SongName';
  // [EndExclude music_control_card_collect]
  @LocalStorageProp('isCollected') isCollected: boolean = false;
  @LocalStorageProp('musicCover') musicCover: Resource = $r('app.media.ic_dream');
  @LocalStorageProp('singer') singer: string = 'Singer';
  // [EndExclude music_control_card_router_to_pages]
  @LocalStorageProp('songId') songId: string = '';
  // [StartExclude music_control_card_router_to_pages]
  // [StartExclude music_control_card_collect]
  @LocalStorageProp('imageColor') imageColor: string = 'rgba(76, 72, 68, 1)';
  // [EndExclude music_control_card_color_card]
  @LocalStorageProp('imageColorHex') imageColorHex: string = '18191d';

  // [EndExclude is_need_request_update_call]
  // [EndExclude music_control_card_collect]
  // [StartExclude music_control_card_collect]
  // [StartExclude music_control_card_color_card]
  requestData() {
    ActionUtils.updateControlCardAction(this, this.formId);
  }

  // [EndExclude music_control_card_achieve]
  // [EndExclude music_control_card_collect]
  // [EndExclude music_control_card_color_card]
  // [EndExclude music_control_card_router_to_pages]
  // [EndExclude music_control_card_onclick]
  // [StartExclude is_need_request_update_call]
  build() {
    RelativeContainer() {
      // [StartExclude music_control_card_router_to_pages]
      // [StartExclude music_control_card_color_card]
      // [StartExclude music_control_card_achieve]
      // [StartExclude music_control_card_onclick]
      Image(this.musicCover)
        // [StartExclude storage_update_call1]
        // [StartExclude music_control_card_collect]
        .height('100%')
        .borderRadius(10)
        .aspectRatio(1)
        .id('musicCover')
        .onClick(() => {
          ActionUtils.jumpPlayPage(this);
        })
      // [EndExclude storage_update_call1]
      // [EndExclude music_control_card_collect]
      SymbolGlyph(this.isCollected ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
        // [StartExclude storage_update_call1]
        // [StartExclude music_control_card_collect]
        .fontSize(24)
        .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), true)
        .fontColor(['#E5FFFFFF'])
        .alignRules(CollectAlignRules)
          // [EndExclude music_control_card_collect]
        .onClick(() => {
          if (this.isCollected) {
            ActionUtils.collectAction(this, CollectAction.UNCOLLECTED, this.formId, this.songId);
          } else {
            ActionUtils.collectAction(this, CollectAction.COLLECTED, this.formId, this.songId);
          }
        })
      // [StartExclude music_control_card_collect]
      // [EndExclude symbolglyph]
      Text($r(this.title))
        // [StartExclude text]
        .fontSize(16)
        .fontWeight(700)
        .fontColor(Color.White)
        .maxLines(1)
        .margin({
          top: 30,
          left: 24
        })
        .alignRules(TitleAlignRules)
        .id('musicTitle')
      // [EndExclude text]
      Text($r(this.singer))
        // [StartExclude text1]
        .fontSize(14)
        .fontColor(Color.White)
        .fontWeight(500)
        .opacity(0.6)
        .maxLines(1)
        .alignSelf(ItemAlign.Start)
        .margin({
          top: 5,
          left: 24
        })
        .alignRules(SingerAlignRules)
      // [EndExclude storage_update_call1]
      // [EndExclude music_control_card_achieve]
      // [EndExclude music_control_card_collect]
      // [EndExclude music_control_card_onclick]
      Row() {
        // [StartExclude music_control_card_collect]
        // [StartExclude music_control_card_achieve]
        SymbolGlyph($r('sys.symbol.backward_end_fill'))
          // [StartExclude storage_update_call1]
          .fontSize(24)
          .fontColor(['#E5FFFFFF'])
          .onClick(() => {
            ActionUtils.playByAction(this, PlayActionType.PREVIOUS, this.formId);
          })
        // [EndExclude storage_update_call1]
        SymbolGlyph(this.isPlay ? $r('sys.symbol.pause') : $r('sys.symbol.play_fill'))
          // [StartExclude storage_update_call1]
          // [StartExclude music_control_card_onclick]
          .fontSize(24)
          .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), true)
          .fontColor(['#E5FFFFFF'])
          .margin({
            left: 25,
            right: 25
          })
          // [EndExclude music_control_card_onclick]
          .onClick(() => {
            if (this.isPlay) {
              ActionUtils.playByAction(this, PlayActionType.PAUSE, this.formId);
            } else {
              ActionUtils.playByAction(this, PlayActionType.PLAY, this.formId);
            }
          })
        // [EndExclude storage_update_call1]
        SymbolGlyph($r('sys.symbol.forward_end_fill'))
          // [StartExclude storage_update_call1]
          // [StartExclude music_control_card_onclick]
          .fontSize(24)
          .fontColor(['#E5FFFFFF'])
          // [EndExclude music_control_card_onclick]
          .onClick(() => {
            ActionUtils.playByAction(this, PlayActionType.NEXT, this.formId);
          })
        // [EndExclude storage_update_call1]
        // [EndExclude music_control_card_achieve]
        // [EndExclude music_control_card_collect]
      }
      // [StartExclude music_control_card_collect]
      // [StartExclude storage_update_call1]
      // [StartExclude music_control_card_achieve]
      // [StartExclude music_control_card_onclick]
      .height(30)
      .margin({ left: 24 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignRules(ControlAlignRules)
      // [EndExclude music_control_card_onclick]
      // [EndExclude music_control_card_collect]

      // [EndExclude storage_update_call1]
      // [EndExclude music_control_card_achieve]
      // [EndExclude music_control_card_color_card]
      // [EndExclude music_control_card_router_to_pages]
    }
    // [StartExclude storage_update_call1]
    // [StartExclude music_control_card_achieve]
    // [StartExclude music_control_card_collect]
    // [StartExclude music_control_card_onclick]
    .height('100%')
    .width('100%')
    .padding(12)
    .onClick(() => {
      ActionUtils.jumpPlayPage(this);
    })
    // [StartExclude music_control_card_router_to_pages]
    // [StartExclude music_control_card_color_card]
    .linearGradient({
      direction: GradientDirection.Bottom,
      repeating: false,
      colors: [[`#ff${this.imageColorHex}`, 0.0], [`#cc${this.imageColorHex}`, 0.5], [`#ff${this.imageColorHex}`, 1.0]]
    })
    // [EndExclude music_control_card_color_card]
    // [EndExclude storage_update_call1]
    // [EndExclude music_control_card_achieve]
    // [EndExclude music_control_card_collect]
    // [EndExclude music_control_card_router_to_pages]
    // [EndExclude music_control_card_onclick]
  }
  // [EndExclude is_need_request_update_call]
}
// [End storage_update_call1]
// [End is_need_request_update_call]
// [End music_control_card_achieve]
// [End music_control_card_collect]
// [End music_control_card_color_card]
// [End music_control_card_router_to_pages]
// [End music_control_card_onclick]