/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Column() {
      Text($r('app.string.Kit')).fontWeight(FontWeight.Bold).fontSize(40);
      Button($r('app.string.DataSource')).width('50%').onClick(() => {
        router.pushUrl({
          url: "pages/DataSourceIndex"
        })
      });
      Button($r('app.string.SamplePoint')).width('50%').onClick(() => {
        router.pushUrl({
          url: "pages/SamplePointIndex"
        })
      });
      Button($r('app.string.ExerciseSequence')).width('50%').onClick(() => {
        router.pushUrl({
          url: "pages/ExerciseSequenceIndex"
        })
      });
      Button($r('app.string.HealthSequence')).width('50%').onClick(() => {
        router.pushUrl({
          url: "pages/HealthSequenceIndex"
        })
      });
      Button($r('app.string.Auth')).width('50%').onClick(() => {
        router.pushUrl({
          url: "pages/AuthIndex"
        })
      });
      Button($r('app.string.Workout')).width('50%').onClick(() => {
        router.pushUrl({
          url: "pages/WorkoutIndex"
        })
      });
    }.alignItems(HorizontalAlign.Center).height('100%').width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
  }
}