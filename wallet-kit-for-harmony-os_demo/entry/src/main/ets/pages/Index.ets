import { router } from '@kit.ArkUI'

@Entry
@Component
struct Index {
  aboutToAppear() {
  }

  onPageShow(): void {
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
      Text('WalletKitDemo')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 30 })

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.End }) {
        CustomButton({ mText: 'TransitCard', mPageUrl: 'pages/wallet/TransitCard' })
      }
      .padding({ left: 24, right: 24 })
      .width('100%')
      .height(50)

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.End }) {
        CustomButton({ mText: 'Pass', mPageUrl: 'pages/wallet/Pass' })
      }
      .padding({ left: 24, right: 24 })
      .width('100%')
      .height(50)
    }
  }
}

@Component
export struct CustomButton {
  private mText: string = ''
  private mPageUrl: string = ''
  private mOnClick: ((event?: object) => void) | null = null

  build() {
    Button() {
      Text(this.mText)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
    }
    .id(this.mText)
    .type(ButtonType.Capsule)
    .margin({ top: 12 })
    .width('200vp')
    .height('50vp')
    .backgroundColor('#0D9FFB')
    .onClick((event) => {
      if (this.mOnClick) {
        this.mOnClick(event);
        return;
      }
      console.info(this.mPageUrl)
      router.pushUrl({
        url: this.mPageUrl
      })
    })
  }
}



