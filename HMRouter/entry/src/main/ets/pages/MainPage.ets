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

import { HMLifecycleState, HMPopInfo, HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { BreakpointConstants } from '../component/common/constants/BreakpointConstants';
import { JumpInfoInterceptor } from '../interceptor/JumpInfoInterceptor';
import { PageDurationLifecycle } from '../lifecycle/PageDurationLifecycle';
import { FooterTab, FooterTabViewModel } from '../component/viewmodel/FooterTabViewModel';
import { ResourceUtil } from '../component/common/utils/ResourceUtil';
import { CommonConstants } from '../component/common/constants/CommonConstants';
import { HomeConstants } from '../component/common/constants/HomeConstants';
import { ShoppingBagContent } from '../component/shoppingBag/ShoppingBagContent';
import { MineContent } from '../component/mine/MineContent';
import { HomeContent } from '../component/home/HomeContent';

@HMRouter({ pageUrl: 'MainPage', lifecycle: 'ExitAppLifecycle' })
@Component
export default struct MainPage {
  @State currentTabIndex: number = 0;
  private controller: TabsController = new TabsController()

  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  private tabList: FooterTab[] = new FooterTabViewModel().getTabList();

  aboutToAppear(): void {
    let targetName = HMRouterMgr.getCurrentParam() as number;
    if(targetName){
      this.currentTabIndex = targetName
    }
    HMRouterMgr.registerGlobalInterceptor({
      interceptor: new JumpInfoInterceptor(),
      interceptorName: 'JumpInfo',
      priority: 5
    });

    HMRouterMgr.registerGlobalLifecycle({
      lifecycle: new PageDurationLifecycle(),
      lifecycleName: 'PageDuration',
      priority: 5
    });
  }

  aboutToDisappear(): void {
  }

  @Builder
  TabBarBuilder(item: FooterTab) {
    Column() {
      Image(HomeConstants.FOOTER_TOPIC_LIST[this.currentTabIndex] === item.getName() ? item.getIconSelected() :
      item.getIcon())
        .width(ResourceUtil.getCommonImgSize()[0])
        .height(ResourceUtil.getCommonImgSize()[0]);
      Text(item.getName())
        .fontSize($r('app.float.tab_font_size'))
        .fontWeight(CommonConstants.FONT_WEIGHT_500)
        .fontColor(HomeConstants.FOOTER_TOPIC_LIST[this.currentTabIndex] === item.getName() ?
        $r('app.color.button_tabs_font_color_selected') : $r('app.color.button_tabs_font_color'))
        .margin({top: $r('app.float.tab_top_margin')})
        .opacity(CommonConstants.TEXT_OPACITY[1]);
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(()=>{
      let selectIndex = HomeConstants.FOOTER_TOPIC_LIST.indexOf(item.getName())
      if (this.currentTabIndex === selectIndex) {
        return; // 如果点击的是当前Tab，不进行任何操作,
      }

      if(selectIndex !== 3){
        // 切换到新Tab
        this.currentTabIndex = selectIndex
        this.controller.changeIndex(selectIndex)
      }else {
        if (!!AppStorage.get('isLogin')) {
          this.currentTabIndex = selectIndex
          this.controller.changeIndex(selectIndex)
        } else {
          this.getUIContext().getPromptAction().showToast({ message: '请先登录' });
          HMRouterMgr.push({
            pageUrl: 'loginPage',
            param:3,
            skipAllInterceptor: true
          });
        }
      }
    })
  }

  @Builder
  TabContentBuilder(index: number) {
      if (index === 3) {
        ShoppingBagContent()
      } else if (index === 4) {
        MineContent()
      } else if (index === 0) {
        HomeContent()
      }
  }

  build() {
    Column() {
      Tabs({
        controller:this.controller,
        index: this.currentTabIndex,
        barPosition: BarPosition.End
      }) {
        TabContent() {
          this.TabContentBuilder(0)
        }
        .tabBar(this.TabBarBuilder(this.tabList[0]))
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);

        TabContent() {
          this.TabContentBuilder(1)
        }
        .tabBar(this.TabBarBuilder(this.tabList[1]));

        TabContent() {
          this.TabContentBuilder(2)
        }
        .tabBar(this.TabBarBuilder(this.tabList[2]));

        TabContent(){
          this.TabContentBuilder(3)
        }
        .tabBar(this.TabBarBuilder(this.tabList[3]))

        TabContent(){
          this.TabContentBuilder(4)
        }
        .tabBar(this.TabBarBuilder(this.tabList[4]))
      }
      .width('100%')
      .height('100%')
      .barOverlap(true)
      .barBackgroundColor('rgba(241, 243, 245, 0.1)')
      .barBackgroundBlurStyle(BlurStyle.Thin)
      .scrollable(false) // 禁用滑动切换，提升性能
      .animationDuration(0)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .onChange((index: number) => {
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.home_content_background_color'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}
