import core from 'libentry.so';

@Entry
@Component
struct Index {
  static readonly ON_LABEL: ResourceStr = $r("app.string.OpenGtx_enabled")
  static readonly ON_COLOR: string = "rgba(24, 36, 49, 1.0)"
  static readonly OFF_LABEL: ResourceStr = $r("app.string.OpenGtx_disabled")
  static readonly OFF_COLOR: string = "rgba(255, 255, 255, 1.0)"
  @State label: ResourceStr = Index.ON_LABEL
  @State color: string = Index.ON_COLOR

  build() {
    Stack({
      alignContent: Alignment.TopStart
    }) {
      XComponent({
        id: "entry-ui-surface",
        type: XComponentType.SURFACE,
        libraryname: "entry"
      })
        .margin({
          top: 0,
          left: 0,
          right: 0,
          bottom: 0
        })
        .padding({
          top: 0,
          left: 0,
          right: 0,
          bottom: 0
        })
        .height("100%")
        .width("100%")

      Toggle({
        type: ToggleType.Button,
        isOn: true
      }) {
        Text(this.label)
          .fontColor(this.color)
          .fontSize(12)
      }
      .width("150vp")
      .selectedColor("rgba(0, 125, 255, 0.95)")
      .offset({
        x: "30vp",
        y: "30vp"
      })
      .onChange(
        (isOn: boolean) => {
          if (isOn) {
            core.EnablePrediction()
            this.label = Index.ON_LABEL
            this.color = Index.ON_COLOR
            return
          }

          core.DisablePrediction()
          this.label = Index.OFF_LABEL
          this.color = Index.OFF_COLOR
        }
      )
    }
    .width("100%")
    .height("100%")
  }
}
