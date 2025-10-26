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
* FAQ: 如何对手势事件进行限流？例如500ms内不允许点击事件重复触发？
*/

// [Start throttle]
// Debouncing: When a function is triggered multiple times within a certain period, debouncing ensures that the function is ultimately executed only once after a specified delay
export function debounce(func: (event: ClickEvent) => void, delay?: number) {
  let timer: number;
  return (event: ClickEvent) => {
    clearTimeout(timer);
    timer = setTimeout(() => {
      func(event);
    }, delay ? delay : 1000);
  };
}

// Throttling: Execute only once within the specified time frame
export function throttle(func: (event: ClickEvent) => void, delay?: number) {
  let inThrottle: boolean;
  return (event: ClickEvent) => {
    if (!inThrottle) {
      func(event);
      inThrottle = true;
      setTimeout(() => inThrottle = false, delay ? delay : 1000);
    }
  };
}

@Entry
@Component
struct Index {
  @State num: number = 0

  build() {
    Row() {
      Column() {
        Text(this.num.toString())
        Button("click")
          .onClick(
            debounce(() => {
              this.num++
            }, 500))
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End throttle]