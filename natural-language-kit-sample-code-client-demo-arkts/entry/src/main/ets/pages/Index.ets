import { hilog } from '@kit.PerformanceAnalysisKit';
import { textProcessing } from '@kit.NaturalLanguageKit';

@Entry
@Component
struct Index {
  private inputText: string = '';
  @State outputText: string = '';

  build() {
    Column() {
      TextInput({ placeholder: 'Please enter text' })
        .height(40)
        .fontSize(16)
        .width('90%')
        .margin(10)
        .onChange((value: string) => {
          this.inputText = value;
        })

      Scroll() {
        Text(this.outputText)
          .fontSize(16)
          .width('90%')
          .margin(10)
      }
      .height('40%')

      Row() {
        Button('Get Word Segmentation Result')
          .type(ButtonType.Capsule)
          .fontColor(Color.White)
          .width('45%')
          .margin(10)
          .onClick(async () => {
            try {
              let result: textProcessing.WordSegment[] = await textProcessing.getWordSegment(this.inputText);
              this.outputText = this.formatWordSegmentResult(result);
            } catch (err) {
              hilog.error(0x0000, 'testTag', `getWordSegment error: code: ${err.code}, message: ${err.message}`);
            }
          })

        Button('Get Entity Results')
          .type(ButtonType.Capsule)
          .fontColor(Color.White)
          .width('45%')
          .margin(10)
          .onClick(async () => {
            try {
              let result: textProcessing.Entity[] = await textProcessing.getEntity(this.inputText);
              this.outputText = this.formatEntityResult(result);
            } catch (err) {
              hilog.error(0x0000, 'testTag', `getEntity error: code: ${err.code}, message: ${err.message}`);
            }
          })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  private formatWordSegmentResult(segments: textProcessing.WordSegment[]): string {
    let output = 'Word Segments:\n';
    segments.forEach((segment, index) => {
      output += `Word[${index}]: ${segment.word}, Tag: ${segment.wordTag}\n`;
    });
    return output;
  }

  private formatEntityResult(entities: textProcessing.Entity[]): string {
    if (!entities || !entities.length) {
      return 'No entities found.';
    }

    let output = 'Entities:\n';
    for (let i = 0; i < entities.length; i++) {
      let entity = entities[i];
      output += `Entity[${i}]:\n`;
      output += `  oriText: ${entity.text}\n`;
      output += `  charOffset: ${entity.charOffset}\n`;
      output += `  entityType: ${entity.type}\n`;
      output += `  jsonObject: ${entity.jsonObject}\n\n`;
    }
    return output;
  }
}