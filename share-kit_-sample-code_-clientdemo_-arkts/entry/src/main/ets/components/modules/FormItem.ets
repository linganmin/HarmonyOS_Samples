/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

@Component
export default struct FormItem {
  @Prop label: string = '';
  @Builder customBuilder() {}
  @BuilderParam labelExtra: () => void = this.customBuilder;
  @BuilderParam content: () => void = this.customBuilder;

  build() {
    Row() {
      Row() {
        Text(this.label)
      }

      Row() {
        this.content();
      }
      .width('60%')
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height(50)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}