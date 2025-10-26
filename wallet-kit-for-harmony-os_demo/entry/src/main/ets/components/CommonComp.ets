/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { SelectListItem } from '../common/ConstUtil'
import { CustomButton } from './CustomButton'


@Component
export struct CommonComp {
  private mText: string = ''
  private isEnabled?: boolean = true
  private selectList: Array<SelectListItem> = [{ value: '0' }]
  handleClick?: () => void
  @Link code: string
  @Link text: string

  build() {
    Column() {
      Row() {
        Select(this.selectList)
          .selected(0)
          .value(this.code)
          .onSelect((index: number, text?: string | undefined) => {
            console.info('Select:' + index)
            if (text) {
              this.code = text;
            }
          })
          .width('50%')
          .height(30)
          .enabled(this.isEnabled)
        CustomButton({ mText: this.mText }).onClick(() => {
          this.handleClick && this.handleClick()
        }).width('50%')
      }
      .alignItems(VerticalAlign.Center)

      Row() {
        Text($r('app.string.Result')).fontSize(14)
        Text(this.text).fontSize(14).textOverflow({ overflow: TextOverflow.MARQUEE })
      }
      .alignSelf(ItemAlign.Start)
      .margin({ top: 5 })
    }
    .width('100%')
    .margin({ bottom: 5 })
    .backgroundColor('#eee')
    .padding({ top: 5, bottom: 5, left: 5, right: 5 })
    .borderRadius(10)
  }
}