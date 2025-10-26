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
* FAQ:如何查看触摸热区范围
*/

// [Start view_range_of_touch_hotspots]
@Entry
@Component
struct TouchTargetExample {
  @State text: string = '';
  @State x: number = 0;
  @State y: number = 0;
  @State regWidth: string = '50%';
  @State regHeight: string = '100%';

  build() {
    Column({ space: 20 }) {
      Text(`{x:0,y:0,width:'50%',height:'100%'}`)
      // The width of the hot zone is half of the button, and there is no response when clicking on the right side
      Button('button1')
        .responseRegion({
          x: this.x,
          y: this.y,
          width: this.regWidth,
          height: this.regHeight
        })
        .onClick(() => {
          this.text = 'button1 clicked';
          console.info('button1 clicked: ' + this.x + ' ' + this.y + ' ' + this.regWidth + ' ' + this.regHeight);
        })

      Text(this.text)
        .margin({ top: 10 })
    }
    .width('100%')
    .margin({ top: 100 })
  }
}

// [End view_range_of_touch_hotspots]