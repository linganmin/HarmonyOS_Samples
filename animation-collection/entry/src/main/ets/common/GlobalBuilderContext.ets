/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { wrappedBuilderTurningAnimation } from '../feature/pageturninganimation/view/PageTurningAnimation';
import { wrappedBuilderExpandTitle } from '../feature/pageExpandTitle/view/PageExpandTitle';
import { wrappedBuilderPageListSlideToHistory } from '../feature/pagelistslidetohistory/view/PageListSlideToHistory';
import { wrappedBuilderStatusBarChange } from '../feature/pageStatusBarChange/view/PageStatusBarChange';
import { wrappedBuilderWaterRipples } from '../feature/pageWaterRipples/view/PageWaterRipples';
import { wrappedBuilderMarqueeView } from '../feature/pageMarqueeView/view/Marquee';
import { wrappedBuilderSwiperSmooth } from '../feature/swipersmoothvariation/view/SwiperSmoothVariation';
import { sideBarAnimationViewWrappedBuilder } from '../feature/sidebarAnimation/view/SideBarAnimation';
import { wrappedBuilderVibrateEffect } from '../feature/pageVibrateEffect/view/PageVibrateEffect';
import { wrappedBuilderPaintComponent } from '../feature/pagePaintComponent/view/PagePaintComponent';
import { wrappedBuilderDigitalScroll } from '../feature/digitalscrollanimation/view/DigitalScrollExample';
import { wrappedBuilderCardsSwiper } from '../feature/pageCardsSwiper/view/CardSwiper';
import { wrappedBuilderVotingComponent } from '../feature/votingcomponent/pages/VotingComponent';
import { wrappedBuilderVoiceRecordDynamic } from '../feature/voiceRecordDynamicEffect/view/VoiceRecordDynamic';

export class GlobalBuilderContext {
  private static instance: GlobalBuilderContext;
  private _objects = new Map<string, Object>();

  public static getContext(): GlobalBuilderContext {
    if (!GlobalBuilderContext.instance) {
      GlobalBuilderContext.instance = new GlobalBuilderContext();
      GlobalBuilderContext.instance.setObject('PageTurningAnimation', wrappedBuilderTurningAnimation);
      GlobalBuilderContext.instance.setObject('PageExpandTitle', wrappedBuilderExpandTitle);
      GlobalBuilderContext.instance.setObject('PageListSlideToHistory', wrappedBuilderPageListSlideToHistory);
      GlobalBuilderContext.instance.setObject('PageStatusBarChange', wrappedBuilderStatusBarChange);
      GlobalBuilderContext.instance.setObject('PageWaterRipples', wrappedBuilderWaterRipples);
      GlobalBuilderContext.instance.setObject('PageWaterMarqueeView', wrappedBuilderMarqueeView);
      GlobalBuilderContext.instance.setObject('SwiperSmoothVariation', wrappedBuilderSwiperSmooth);
      GlobalBuilderContext.instance.setObject('SideBarAnimation', sideBarAnimationViewWrappedBuilder);
      GlobalBuilderContext.instance.setObject('PageVibrateEffect', wrappedBuilderVibrateEffect);
      GlobalBuilderContext.instance.setObject('PagePaintComponent', wrappedBuilderPaintComponent);
      GlobalBuilderContext.instance.setObject('DigitalScrollExample', wrappedBuilderDigitalScroll);
      GlobalBuilderContext.instance.setObject('PageCardsSwiper', wrappedBuilderCardsSwiper);
      GlobalBuilderContext.instance.setObject('VotingComponent', wrappedBuilderVotingComponent);
      GlobalBuilderContext.instance.setObject('VoiceRecordDynamic', wrappedBuilderVoiceRecordDynamic);
    }
    return GlobalBuilderContext.instance;
  }

  getObject(value: string): Object | undefined {
    return this._objects.get(value);
  }

  setObject(key: string, objectClass: Object): void {
    this._objects.set(key, objectClass);
  }
}