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
/**
 * 最佳实践：内存泄漏检测
 * 场景一：分析Snapshot数据
 */

// [Start check_snapshot]
class People {
  old: number;
  name: string;
  constructor(old: number, name: string) {
    this.old = old;
    this.name = name;
  }
  printOld() {
    console.log("old = ", this.old);
  }
  printName() {
    console.log("name = ", this.name);
  }
};
let p = new People(20, "Tom");
// [End check_snapshot]

/**
 * 最佳实践：资源泄漏类问题优化建议
 */

// [Start resource_leak_advise1_negative]
export default class test {
  private timer: number | null = null; // 正确声明类属性

  onInit() {
    this.timer = setInterval(() => {
      this.updateData(); // 通过this调用类方法
    }, 1000);
  }

  private updateData() {
    // 定时任务具体逻辑
  }
}
// [End resource_leak_advise1_negative]