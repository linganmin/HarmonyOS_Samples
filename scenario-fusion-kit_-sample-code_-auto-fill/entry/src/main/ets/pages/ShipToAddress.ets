import { autoFillManager } from '@kit.AbilityKit';

@Entry
@Component
struct ShipToAddress {
  @State isClicked: boolean = false;

  build() {
    Column({ space: 16 }) {
      Row({ space: 8 }) {
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontSize('24vp')
            .fontColor([$r('sys.color.ohos_id_color_primary')])
        }
        .type(ButtonType.Normal)
        .borderRadius(20)
        .size({ width: 40, height: 40 })
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .onClick(() => {
          this.getUIContext().getRouter().back();
        })

        Text('Form')
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.ohos_id_text_size_headline8'))
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Start)
      .padding({ left: 16 })

      Column() {
        Column({ space: 5 }) {
          Row() {
            Text('Name:').textAlign(TextAlign.End).width('25%').padding({ right: 8 })
            TextInput().width('75%').contentType(ContentType.PERSON_FULL_NAME)
          }

          Row() {
            Text('Phone:').textAlign(TextAlign.End).width('25%').padding({ right: 8 })
            TextInput().width('75%')
              .contentType(ContentType.PHONE_NUMBER)
              .type(InputType.Normal)
          }

          Row() {
            Text('E-mail:').textAlign(TextAlign.End).width('25%').padding({ right: 8 })
            TextInput().width('75%')
              .contentType(ContentType.EMAIL_ADDRESS)
          }

          Row() {
            Text('Address:').textAlign(TextAlign.End).width('25%').padding({ right: 8 })
            TextInput().width('75%').contentType(ContentType.FULL_STREET_ADDRESS)
          }

        }
        .alignItems(HorizontalAlign.Center)
        .padding({ left: 16, right: 16 })
        .width('100%')

        Row() {
          Button('Save')
            .onClick(() => {
              if (!this.isClicked) {
                autoFillManager.requestAutoSave(this.getUIContext())
                this.isClicked = true;
              }
              setTimeout(() => {
                this.isClicked = false;
              }, 3000)
            })
            .width('50%')
        }
      }.layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ bottom: 16 })
    }.height('100%')
  }
}