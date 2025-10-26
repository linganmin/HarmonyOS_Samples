// [Start not_recommend_demo]
// library/src/main/ets/components/mainpage/SubPage.ets
// Global time-consuming functions in SubPage
const LARGE_NUMBER: number = 10000000;

function computeTask(): number {
  let count: number = 0;
  while (count < LARGE_NUMBER) {
    count++;
  }
  return count;
}

computeTask();
// ...
// [End not_recommend_demo]
@Component
export struct SubPage {
  @Consume pathStack: NavPathStack;
  @State message: string = 'HAR SubPage';

  build() {
    Row() {
      Text(this.message)
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
    }.onClick(() => {
      this.pathStack.pushPath({ name: 'SecondPage' });
    })
  }
}