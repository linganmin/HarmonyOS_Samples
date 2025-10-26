import { media } from '@kit.MediaKit';


@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  async play(){
    // [Start player]
    // Create avPlayer instance object
    let player = await media.createAVPlayer();
    let headers: Record<string, string> = {"User-Agent" : "User-Agent-Value"};
    let mediaSource : media.MediaSource = media.createMediaSourceWithUrl("http://xxx",  headers);
    // Set the preferredBufferDuration to the maximum value of 20MB；; PreferredWidth is the preferred width of the playback strategy; PreferredHeight is the preferred height of the playback strategy; PreferredHdr is the playback strategy. true is hdr, false is non-hdr.
    let playStrategy : media.PlaybackStrategy = {preferredWidth: 1, preferredHeight: 2, preferredBufferDuration: 20, preferredHdr: false};
    // Set the media source and playback strategy.
    player.setMediaSource(mediaSource, playStrategy);
    // [End player]
  }
  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.message = 'Welcome';
        })
    }
    .height('100%')
    .width('100%')
  }
}