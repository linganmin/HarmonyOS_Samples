/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { SelectListItem } from '../common/ConstUtil'
import { CustomButton } from './CustomButton'


@Component
export struct CommonCompAddPass {
  private mText: string = ''
  private selectList: Array<SelectListItem> = [{ value: '0' }]
  handleClick?: () => void
  @Link code: string
  @Link text: string
  @Link jwe: string

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
        TextInput({ text: this.jwe, placeholder: $r('app.string.Enter_JWE'), })
          .width('50%')
          .height(30)
          .placeholderFont({ size: 13 })
          .fontSize(13)
          .onChange((value: string) => {
            this.jwe = value
          })
      }
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 5 })

      CustomButton({ mText: this.mText }).onClick(() => {
        this.handleClick && this.handleClick()
      }).width('50%')
        .alignSelf(ItemAlign.End)
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
