/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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

/*
* FAQ: 如何实现马赛克效果
*/

// [Start mosaic_effect]
import { DrawPathType, DrawViewModel } from '../viewmodel/DrawViewModel';

@Component
export struct DrawView {
  @ObjectLink viewModel: DrawViewModel;

  build() {
    Column({ space: 8 }) {
      Text('Please select the brush type')
        .fontColor(Color.Red)
        .textAlign(TextAlign.Center)
        .fontSize(30)
        .width('80%')
        .margin('10%')

      Canvas(this.viewModel.context)
        .width('100%')
        .height('75%')
        .onAreaChange((oldValue: Area, newValue: Area) => {
          this.viewModel.canvasAreaChange(newValue);
        })
        .gesture(
          GestureGroup(GestureMode.Exclusive,
            PanGesture()
              .onActionStart((event: GestureEvent) => {
                let finger: FingerInfo = event.fingerList[0];
                if (finger == undefined) {
                  return;
                }
                let x = finger.localX;
                let y = finger.localY;
                this.viewModel.moveStart(x, y);
              })
              .onActionUpdate((event: GestureEvent) => {
                let finger: FingerInfo = event.fingerList[0];
                if (finger == undefined) {
                  return;
                }
                let x = finger.localX;
                let y = finger.localY;
                this.viewModel.moveUpdate(x, y);
              })
              .onActionEnd((event: GestureEvent) => {
                let finger: FingerInfo = event.fingerList[0];
                if (finger == undefined) {
                  return;
                }
                this.viewModel.moveEnd();
              })
          )
        )

      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
        Button('Ordinary paintbrush')
          .onClick(() => {
            this.viewModel.drawModel.pathType = DrawPathType.pen;
          })
        Button('Mosaic brush')
          .onClick(() => {
            this.viewModel.drawModel.pathType = DrawPathType.pattern;
          })
        Button('Clear the content')
          .onClick(() => {
            this.viewModel.clearPath();
          })
      }
    }
  }
}
// [End mosaic_effect]