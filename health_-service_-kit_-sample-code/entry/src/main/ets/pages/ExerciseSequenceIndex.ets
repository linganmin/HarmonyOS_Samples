/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { ExerciseSequenceManagement } from '../common/bean/ExerciseSequenceManagement';

@Entry
@Component
struct Index {
  @State log: string = '';

  build() {
    Column() {
      Text($r('app.string.ExerciseSequence')).fontWeight(FontWeight.Bold).fontSize(28).height('20%');

      Row() {
        Button($r('app.string.SaveData')).width('50%').onClick(async () => {
          this.log = await ExerciseSequenceManagement.saveData();
        });
        Button($r('app.string.ReadData')).width('50%').onClick(async () => {
          this.log = await ExerciseSequenceManagement.readData();
        });
      }.height('10%').alignItems(VerticalAlign.Top);

      Row() {
        Button($r('app.string.DeleteByRequest')).width('50%').onClick(async () => {
          this.log = await ExerciseSequenceManagement.deleteByRequest();
        });
        Button($r('app.string.DeleteByExerciseSequence')).width('50%').onClick(async () => {
          this.log = await ExerciseSequenceManagement.deleteByExerciseSequence();
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