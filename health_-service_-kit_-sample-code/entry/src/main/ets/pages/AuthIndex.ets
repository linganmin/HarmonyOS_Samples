/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { AuthManagement } from '../common/bean/AuthManagement';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  @State log: string = '';

  build() {
    Column() {
      Text($r('app.string.Auth')).fontWeight(FontWeight.Bold).fontSize(30).height('20%');

      Row() {
        Button($r('app.string.RequestAuthorizations')).width('50%').onClick(async () => {
          this.log = await AuthManagement.auth(getContext(this) as common.UIAbilityContext);
        });
      }.height('10%').alignItems(VerticalAlign.Top);

      Row() {
        Button($r('app.string.CancelAuthorizations')).width('50%').onClick(async () => {
          this.log = await AuthManagement.cancelAuthAll();
        });
      }.height('10%').alignItems(VerticalAlign.Top);

      Row() {
        Button($r('app.string.GetAuthorizations')).width('50%').onClick(async () => {
          this.log = await AuthManagement.getAuth();
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