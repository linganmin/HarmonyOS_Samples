/**
 * FAQ:使用Router跳转导致闪退，可能是神马原因，如何排查
 */

@Entry
@Component
struct Index {
  build() {
    Column() {
      Button('click')
        .onClick(() => {
          // [Start use_router_jump_and_crash]
          this.getUIContext().getRouter().pushUrl({
            url: 'login/UserNameLoginPage'
          }, () => {
            this.getUIContext().getRouter().clear();
          })
          // [End use_router_jump_and_crash]
        })
    }
    .width('100%')
    .height('100%')
  }
}