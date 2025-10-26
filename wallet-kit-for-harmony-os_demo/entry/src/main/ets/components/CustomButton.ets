/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

@Component
export struct CustomButton {
  private mText: string = ''

  build() {
    Button() {
      Text(this.mText)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
    }
    .id(this.mText)
    .type(ButtonType.Capsule)
    .width('100%')
    .height(30)
    .backgroundColor('#0D9FFB')
  }
}