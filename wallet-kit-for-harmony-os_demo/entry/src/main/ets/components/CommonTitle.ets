/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
@Component
export struct CommonTitle {
  private title: ResourceStr = ''

  build() {
    Row() {
      Text(this.title)
        .fontWeight(FontWeight.Bold).fontSize(20)
    }.width('100%').margin({ top: 10 })
  }
}
