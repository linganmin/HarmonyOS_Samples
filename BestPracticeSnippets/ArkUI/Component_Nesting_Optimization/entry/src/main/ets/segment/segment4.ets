// [Start Case4]
@Entry
@Component
struct OverlayExample {
  @Builder
  OverlayNode() {
    Text('fragmentary text')
      .fontSize(20)
      .fontColor(Color.Black)
  }

  build() {
    Column() {
      Image($r('app.media.startIcon'))
        .overlay(this.OverlayNode(), { align: Alignment.Center })
        .objectFit(ImageFit.Contain)
    }
  }
}

// [End Case4]