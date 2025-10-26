import { ShowDialogSuccessResponse } from '@kit.ArkUI';

@Entry
@Component
struct SideslipIntercept {
  controller: TextAreaController = new TextAreaController();
  @State text: string = '';
  @Provide pageStack: NavPathStack = new NavPathStack();

  build() {
    // Main page uses NavDestination as carrier to display Navigation content area
    Navigation(this.pageStack) {
    }
    .onAppear(() => {
      this.pageStack.pushPathByName('MainPage', null, false);
    })
    // Create NavDestination component, use its onBackPressed callback to intercept back event
    .navDestination(this.textArea)
  }

  @Builder
  textArea(name: string) {
    NavDestination() {
      Column() {
        TextArea({
          text: this.text,
          placeholder: 'input your word...',
          controller: this.controller
        })
          .onChange((value: string) => {
            this.text = value;
          })
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .height('100%')
    }
    .onBackPressed(() => {
      // Interception logic can be added here, then return true to proceed
      this.getUIContext().getPromptAction().showDialog({
        message: 'Save?',
        alignment: DialogAlignment.Center,
        buttons: [
          {
            text: "Don't Save",
            color: '#0000FF'
          },
          {
            text: 'Save',
            color: '#0000FF'
          }
        ]
      }).then((data: ShowDialogSuccessResponse) => {
        // When selecting button index in buttons array, starting from 0, second index is 1
        // Click Don't Save button
        if (data.index === 0) {
          console.info('Not saving')
        }
        // Click Save button
        if (data.index === 1) {
          console.info('Saving')
        }
      })
      return true ;
    })
  }
}