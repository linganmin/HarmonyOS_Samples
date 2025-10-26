/*
* FAQ:使用video组件播放视频时，如何刷新重新加载视频?比如网络异常导致播放失败等情况
 */

// [Start VideoErrorReload]
@Component
export struct VideoErrorReload {
  @State url: string = 'https://******';

  build() {
    Column({ space: 20 }) {
      Video({ src: this.url })
        .height(300)

      Button('重新url')
        .onClick(() => {
          let temp = this.url;
          this.url = '';
          setTimeout(() => {
            this.url = temp;
          }, 100);
        })
    }
  }
}
// [End VideoErrorReload]




