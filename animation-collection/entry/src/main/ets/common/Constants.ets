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

import { NavDestinationItem } from '../viewmodel/NavDestinationItem';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const context = AppStorage.get("context") as UIContext;

export default class Constants {
  /**
   * FontWeight.borderRadius
   */
  static readonly FONT_WEIGHT: number = 500;
  /**
   * BorderRadius.
   */
  static readonly BORDER_RADIUS: number = 24;
  /**
   * Detail height.
   */
  static readonly DETAIL_HEIGHT: number = 72;
  /**
   * List space.
   */
  static readonly LIST_SPACE: number = 12;
  /**
   * NavDestinationItem.
   */
  static readonly NavDestinationData: NavDestinationItem[] = [
    {
      name: 'PageTurningAnimation', detail: this.resourceToString($r('app.string.page_turning_animation'))
    },
    {
      name: 'PageExpandTitle', detail: this.resourceToString($r('app.string.page_expand_title'))
    },
    {
      name: 'PageStatusBarChange', detail: this.resourceToString($r('app.string.page_status_bar_change'))
    },
    {
      name: 'PageListSlideToHistory', detail: this.resourceToString($r('app.string.page_list_slide_to_history'))
    },
    {
      name: 'PageWaterRipples', detail: this.resourceToString($r('app.string.page_water_ripples'))
    },
    {
      name: 'PageWaterMarqueeView', detail: this.resourceToString($r('app.string.page_marquee_view'))
    },
    {
      name: 'SwiperSmoothVariation', detail: this.resourceToString($r('app.string.swiper_smooth_variation'))
    },
    {
      name: 'SideBarAnimation', detail: this.resourceToString($r('app.string.side_bar_animation'))
    },
    {
      name: 'PageVibrateEffect', detail: this.resourceToString($r('app.string.page_vibrate_effect'))
    },
    {
      name: 'PagePaintComponent', detail: this.resourceToString($r('app.string.page_paint_component'))
    },
    {
      name: 'DigitalScrollExample', detail: this.resourceToString($r('app.string.digital_scroll_example'))
    },
    {
      name: 'PageCardsSwiper', detail: this.resourceToString($r('app.string.page_cards_swiper'))
    },
    {
      name: 'VotingComponent', detail: this.resourceToString($r('app.string.voting_component'))
    },
    {
      name: 'VoiceRecordDynamic', detail: this.resourceToString($r('app.string.voice_record_dynamic'))
    }
  ];

  static resourceToString(resource: Resource): string {
    let result = '';
    try {
      result = context.getHostContext()!.resourceManager.getStringSync(resource.id);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'Constants', `getStringSync failed. error code=${error.code}, message=${error.message}`);
    }
    return result;
  }
}
