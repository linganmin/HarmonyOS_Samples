@Entry
@Component
struct Hello {
  build() {
    Column({ space: 5 }) {
      Button('Demo Example')
        .onClick(() => {
          this.getUIContext().getRouter().pushUrl({
            url: 'pages/Demo'
          })
        })

      Button('Purchase Tickets scenario')
        .onClick(() => {
          this.getUIContext().getRouter().pushUrl({
            url: 'pages/PurchaseTicket'
          })
        })

      Button('Shipping Address scenario')
        .onClick(() => {
          this.getUIContext().getRouter().pushUrl({
            url: 'pages/ShipToAddress'
          })
        })
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}