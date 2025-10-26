@Component
struct ImagePage {
  build() {
    // [Start image_page]
    Column() {
      Image($r('app.media.startIcon'))
        .width("500px")
        .height("500px")
    }
    // [End image_page]
  }
}