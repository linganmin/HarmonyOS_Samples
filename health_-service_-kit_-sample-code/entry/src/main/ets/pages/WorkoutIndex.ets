/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { WorkoutManagement } from '../common/bean/WorkoutManagement';

@Entry
@Component
struct Index {
  @State log: string = '';

  build() {
    Column() {
      Text($r('app.string.Workout')).fontWeight(FontWeight.Bold).fontSize(30).height('20%');

      Row() {
        Button($r('app.string.ReadActivityReport')).width('50%').onClick(async () => {
          this.log = await WorkoutManagement.readActivityReport();
        });
      }.height('10%').alignItems(VerticalAlign.Top);

      Column() {
        Column() {
          Text($r('app.string.Print_log')).fontSize(15).textAlign(TextAlign.Start).fontWeight(FontWeight.Bold);
        }.alignItems(HorizontalAlign.Start).width('90%');

        Column() {
          Text(this.log).fontSize(10).textAlign(TextAlign.Start);
        }.alignItems(HorizontalAlign.Start).width('90%');
      }.alignItems(HorizontalAlign.Start)
    }.alignItems(HorizontalAlign.Center).height('100%').width('100%')
    .justifyContent(FlexAlign.Start)
  }
}
