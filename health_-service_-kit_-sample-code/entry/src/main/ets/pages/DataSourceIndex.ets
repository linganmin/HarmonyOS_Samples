/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */
import { DataSourceManagement } from '../common/bean/DataSourceManagement';

@Entry
@Component
struct Index {
  @State log: string = '';

  build() {
    Column() {
      Text($r('app.string.DataSource')).fontWeight(FontWeight.Bold).fontSize(30).height('20%');

      Row() {
        Button($r('app.string.InsertDataSource')).width('33%').onClick(async () => {
          this.log = await DataSourceManagement.insertDataSource();
        });
        Button($r('app.string.UpdateDataSource')).width('33%').onClick(async () => {
          this.log = await DataSourceManagement.updateDataSource();
        });
        Button($r('app.string.ReadDataSource')).width('33%').onClick(async () => {
          this.log = await DataSourceManagement.readDataSource();
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