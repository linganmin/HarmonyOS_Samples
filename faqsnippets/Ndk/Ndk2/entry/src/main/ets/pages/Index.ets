import { MessageEvents, worker } from '@kit.ArkTS';
import { Prompt } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State progress: number = 0;
  @State message: string = '0'
  state: number = 0

  build() {
    Column() {
      Row() {
        Button("开始")
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            if (this.state == 1) {
              Prompt.showToast({ message: "Please do not click again" })
              return
            }
            this.state = 1
            let worker1: worker.ThreadWorker =
              new worker.ThreadWorker('entry/ets/workers/Worker.ets', { name: "worker1" });
            worker1.postMessage('this is a msg to start worker1');
            worker1.onmessage = (e: MessageEvents) => {
              this.progress = e.data.data as number
              this.message = String(this.progress)
              console.log('=====js main, process is:' + this.message)

              if (this.progress == 100) {
                worker1.terminate()
                this.state = 0
              }
            }
          });
      }
      .margin({
        top: 10,
        bottom: 10,
        left: 5,
        right: 5
      })

      Row() {
        Text(this.message)
          .fontSize(50)
      }
      .margin({
        top: 10,
        bottom: 5,
        left: 5,
        right: 5
      })
    }
  }
}

