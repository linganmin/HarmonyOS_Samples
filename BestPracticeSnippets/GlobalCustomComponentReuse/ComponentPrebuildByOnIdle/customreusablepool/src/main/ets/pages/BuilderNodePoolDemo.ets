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

import { flowItemWrapper, TabNode } from '../view/TabNode';
import { Title } from '../data/TitleBean';
import { TitleDataSource } from '../data/TitleDataSource';
import { TitleView } from '../view/TitleView';
import { Constants } from '../constants/Constants';
import { FrameCallback } from '@kit.ArkUI';
import { systemDateTime } from '@kit.BasicServicesKit';
import { NodePool } from '../utils/BuilderNodePool';
import { ViewItem } from '../data/ViewItem';
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';

// [Start builder_node_pool]
export class IdleCallback extends FrameCallback {
  private uiContext: UIContext;
  // Number of sub components already created
  private todoCount: number = 0;
  private viewItems: ViewItem[] = [];

  /**
   * @param context Context object, used to pass frame callbacks to the next frame
   * @param preBuildData A data list for pre created components, used to confirm the quantity and related information of pre created components, which can be modified or set to a fixed value according to business needs
   */
  constructor(context: UIContext, preBuildData: ViewItem[]) {
    super();
    this.uiContext = context;
    this.viewItems = preBuildData;
  }

  // [End builder_node_pool]
  // [Start on_idle]
  // The onIdle callback returns the idle time idleTimeInNano at the end of the frame.
  onIdle(idleTimeInNano: number): void {

    // Stop pre creation when the number of pre created components exceeds the number of simulated data
    if (this.todoCount >= this.viewItems.length) {
      return;
    }
    // The current time will be used to calculate the remaining idle time of this frame in the future.
    let cur: number = systemDateTime.getTime(true);
    // The idle time at the end of the frame is used to calculate the remaining idle time of the current frame.
    let timeLeft = idleTimeInNano;
    // When the idle time at the end of the frame is greater than 1ms, perform pre creation.
    // The idle time limit here is set to 1ms, which means that when the idle time is less than 1ms, the component will no longer be pre created in this frame, but the frame callback will be passed to the next frame. Developers can set it according to their own business and component complexity, and reserve sufficient idle time.
    while (timeLeft >= 1000000) {
      // [End on_idle]
      // [Start start_trace]
      hiTraceMeter.startTrace('onIdle_prebuild', 1);
      // Perform component pre creation
      NodePool.getInstance()
        .preBuild('reuse_type_', this.viewItems[this.todoCount], flowItemWrapper, this.uiContext);
      hiTraceMeter.finishTrace('onIdle_prebuild', 1);
      // After the pre creation is completed, update the remaining idle time of this frame.
      let now = systemDateTime.getTime(true);
      timeLeft = timeLeft - (now - cur);
      cur = now;
      this.todoCount++;
      // Stop pre creation when the number of pre created components exceeds the number of simulated data
      if (this.todoCount >= this.viewItems.length) {
        return;
      }
      // [End start_trace]
    }
    // [Start pre_create]
    // If the pre creation of the component is not completed, the frame callback is passed to the next frame and the pre creation of the component continues in the next frame.
    if (this.todoCount < this.viewItems.length) {
      this.uiContext.postFrameCallback(this);
    }
    // [End pre_create]
  }
}

// 全局自定义组件复用池页面，可以实现跨页面、跨父组件复用子组件，减少组件创建耗时，提高应用性能
@Component
export struct BuilderNodePoolDemo {
  @State arrayTitle: Title[] = [];
  arrayStr: string[] = [Constants.HOME, Constants.FILM, Constants.TELEPLAY, Constants.ANIMATION, Constants.SPORT];
  @State array: TitleDataSource = new TitleDataSource();
  swiperController: SwiperController = new SwiperController();
  @State selectIndex: number = 0;

  aboutToAppear(): void {
    // 添加标题模拟数据
    for (let i = 0; i < this.arrayStr.length; i++) {
      let title: Title = new Title();
      if (i === 0) {
        title.isSelected = true;
      }
      title.name = this.arrayStr[i];
      this.arrayTitle.push(title);
      this.array.addItem(this.arrayStr[i]);
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          List() {
            ForEach(this.arrayTitle, (title: Title, index: number) => {
              ListItem() {
                TitleView({
                  title: title, clickListener: () => {
                    if (title.isSelected) {
                      return;
                    }
                    // 点击标题时，Swiper组件跳转到对应的页面
                    this.swiperController.changeIndex(index, true);
                    // 设置标题为选中状态
                    this.arrayTitle[index].isSelected = true;
                    this.arrayTitle[this.selectIndex].isSelected = false;
                    this.selectIndex = index;
                  }
                }).padding({
                  left: index === 0 ? 20 : 10,
                  right: index === this.arrayTitle.length - 1 ? 20 : 10
                })
              }
            })
          }
          .width('100%')
          .height(30)
          .listDirection(Axis.Horizontal)

          Swiper(this.swiperController) {
            LazyForEach(this.array, (item: string, index: number) => {
              TabNode({ index: index })
            }, (title: string) => title)
          }
          .loop(false)
          .onChange((index: number) => {
            // Swiper滑动切换页面时，改变标题栏的选中状态
            if (this.selectIndex !== index) {
              this.arrayTitle[index].isSelected = true;
              this.arrayTitle[this.selectIndex].isSelected = false;
              this.selectIndex = index;
            }
          })
          .cachedCount(0)
        }
        .width('100%')
        .height('100%')

        Image($r('app.media.home_show'))
          .width('100%')
          .height('100%')
          .backgroundColor(Color.White)
      }.width('100%')
      .height('100%')
      .clip(true)

    }
  }
}