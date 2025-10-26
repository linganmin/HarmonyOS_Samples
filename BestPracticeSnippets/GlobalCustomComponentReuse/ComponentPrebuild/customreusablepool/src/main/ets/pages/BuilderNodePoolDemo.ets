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

    Stack() {
      Column() {
        // [Start list_swiper]
        List() {
          ForEach(this.arrayTitle, (title: Title, index: number) => {
            ListItem() {
              TitleView({
                title: title, clickListener: () => {
                  if (title.isSelected) {
                    return;
                  }
                  // When clicking on the title, the Swiper component redirects to the corresponding page
                  this.swiperController.changeIndex(index, true);
                  // Set the title to selected status
                  this.arrayTitle[index].isSelected = true;
                  this.arrayTitle[this.selectIndex].isSelected = false;
                  this.selectIndex = index;
                }
              })
                // [StartExclude list_swiper]
                .padding({
                left: index === 0 ? 20 : 10,
                right: index === this.arrayTitle.length - 1 ? 20 : 10
              })
              // [EndExclude list_swiper]
            }
          })
        }
        .width('100%')
        .height(30)
        .listDirection(Axis.Horizontal)

        Swiper(this.swiperController) {
          //Use LazyForEach to load Swiper pages on demand instead of creating them all at once
          LazyForEach(this.array, (item: string, index: number) => {
            //Conventional reusable code, can be annotated as needed to run TabComp ({index: index})
            //Custom Component Reuse Pool Code
            // TabNode({ index: index })
            TabNode({ index: index })
          }, (title: string) => title)
        }
        .loop(false)
        .onChange((index: number) => {
          // When swiping to switch pages, change the selection status of the title bar
          if (this.selectIndex !== index) {
            this.arrayTitle[index].isSelected = true;
            this.arrayTitle[this.selectIndex].isSelected = false;
            this.selectIndex = index;
          }
        })
        .cachedCount(0) //Set the cached count to 0 here for performance comparison, and it can be set as needed in actual development
        // [End list_swiper]

      }
      .height('100%')
      .width('100%')

      Image($r('app.media.home_show'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)
    }
    .height('100%')
    .height('100%')
    .clip(true)
  }
}