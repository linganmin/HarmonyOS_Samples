/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import CreateRecord from '../../utils/CreateRecord';

@Component
export default struct SharedRecord {
  @Link utdList: string[];
  @State utd: string = utd.UniformDataType.TEXT;

  @State SelectOption: SelectOption[] = CreateRecord.utdMap.map((item) => {
    return { value: item.utd } as SelectOption;
  })

  @Builder
  UTDBuilder() {
    Select(this.SelectOption)
      .value(this.utd)
      .onSelect(async (_: number, text?: string | undefined) => {
        if (text) {
          this.utd = text;
        }
      })
  }

  @Builder
  UTDItem() {
    Row() {
      Row() {
        Text('utd')
          .margin({ right: 12 })
        this.UTDBuilder();
      }

      Button($r('app.string.add_data'))
        .onClick(() => {
          if (this.utd) {
            this.utdList.push(this.utd);
          }
        })
    }
    .width('100%')
    .height(50)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  UTDRecordList() {
    Scroll() {
      List({ space: 6, initialIndex: 0 }) {
        ForEach(this.utdList, (utd: string, index: number) => {
          ListItem() {
            Row() {
              Text(`Record${index + 3}: ${utd}`)
              Button($r('app.string.delete'))
                .onClick(() => this.utdList.splice(index, 1))
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
        }, (utd: string) => utd)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .flexGrow(1)
    .margin({ top: 12 })
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      this.UTDItem();

      this.UTDRecordList()

      Row() {
        Button($r('app.string.clearing_data'))
          .onClick(() => this.utdList = [])
      }
      .width('100%')
      .height(60)
      .margin({ top: 12 })
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height('100%')
  }
}