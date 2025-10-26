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

import Constants from '../../../common/Constants';
import { createMyNode, getMyNode, MyNodeController } from '../NodeController';

@Component
export struct VideoCardComponent {
  @Prop @Watch('onIsPlayingUpdated') isPlaying: boolean;
  @Prop index: number;
  @State myNodeController: MyNodeController | undefined = undefined;
  private xComponentId: string = `xComponent_${this.index}`;
  onColumnClicked: (func: () => void) => void = () => {
  };
  heightArray: number[] = [this.getUIContext().px2vp(350), this.getUIContext().px2vp(1020), this.getUIContext().px2vp(325), this.getUIContext().px2vp(1020), this.getUIContext().px2vp(1020), this.getUIContext().px2vp(1015)];
  heightArray1: number[] = [this.getUIContext().px2vp(420), this.getUIContext().px2vp(1250), this.getUIContext().px2vp(420), this.getUIContext().px2vp(1250), this.getUIContext().px2vp(1250), this.getUIContext().px2vp(1250)];

  onIsPlayingUpdated() {
    this.myNodeController?.update(this.isPlaying);
  }

  aboutToAppear(): void {
    let node = getMyNode(this.xComponentId);
    if (node === undefined) {
      createMyNode(this.getUIContext(), `video_${this.index}.mp4`, this.xComponentId, this.isPlaying ? true : false);
    }
    this.myNodeController = getMyNode(this.xComponentId);
  }

  build() {
    Column() {
      Column() {
        NodeContainer(this.myNodeController)
          .size({ width: '100%' })
          .backgroundColor(Constants.DEFAULT_BG_COLOR)
      }
      .height(AppStorage.get('currentBreakpoint') === 'md' ? this.heightArray1[this.index] :
      this.heightArray[this.index])

      Column() {
        Text($r('app.string.content'))
          .fontColor($r('sys.color.password_icon_focus_color'))
          .fontSize(14)
          .padding(12)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .backgroundColor(Color.White)
    .size({ width: '100%' })
    .onClick(() => {
      if (this.myNodeController) {
        this.onColumnClicked(() => {
          this.myNodeController = getMyNode(this.xComponentId);
          this.isPlaying ? this.myNodeController?.update(true) : this.myNodeController?.update(false);
        })
        this.myNodeController?.update(true);
        this.myNodeController = undefined;
      }
    })
  }
}