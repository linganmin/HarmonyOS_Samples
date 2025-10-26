/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { SamplePointManagement } from '../common/bean/SamplePointManagement';

@Entry
@Component
struct Index {
  @State log: string = '';

  build() {
    Column() {
      Text($r('app.string.SamplePoint')).fontWeight(FontWeight.Bold).fontSize(30).height('20%');

      Row() {
        Button($r('app.string.SaveData')).width('33%').onClick(async () => {
          this.log = await SamplePointManagement.saveData();
        });
        Button($r('app.string.ReadData')).width('33%').onClick(async () => {
          this.log = await SamplePointManagement.readData();
        });
        Button($r('app.string.AggregateData')).width('33%').onClick(async () => {
          this.log = await SamplePointManagement.aggregateData();
        });
      }.height('10%').alignItems(VerticalAlign.Top);

      Row() {
        Button($r('app.string.DeleteByRequest')).width('50%').onClick(async () => {
          this.log = await SamplePointManagement.deleteByRequest();
        });
        Button($r('app.string.DeleteBySamplePoint')).width('50%').onClick(async () => {
          this.log = await SamplePointManagement.deleteBySamplePoint();
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