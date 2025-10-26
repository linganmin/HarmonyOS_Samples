import { hilog } from '@kit.PerformanceAnalysisKit';
import { TextReader, TextReaderIcon, ReadStateCode } from '@kit.SpeechKit';

const TAG = 'AI_SPEECH_KIT_DEMO'

@Entry
@Component
struct Index {
  @State message: string = '';

  /**
   * Articles to be loaded.
   */
  @State readInfoList: TextReader.ReadInfo[] = [];
  @State selectedReadInfo: TextReader.ReadInfo = this.readInfoList[0];

  /**
   * Playback status.
   */
  @State readState: ReadStateCode = ReadStateCode.WAITING;

  /**
   * Used to display the status of the button on the current page.
   */
  @State isInit: boolean = false;
  @State isListening: boolean = false;

  async aboutToAppear(){
    /**
     * Loading data.
     */
    console.info('ReadStateCode', JSON.stringify(this.readState))
    let readInfoList: TextReader.ReadInfo[] = [{
      id: '001',
      title: {
        text:'水调歌头.明月几时有',
        isClickable:true
      },
      author:{
        text:'宋.苏轼',
        isClickable:true
      },
      date: {
        text:'2024/01/01',
        isClickable:false
      },
      bodyInfo: '明月几时有？把酒问青天。'
    }];
    this.readInfoList = readInfoList;
    this.selectedReadInfo = readInfoList[0];
    this.init();
  }

  /**
   * Initialize
   */
  async init() {
    const readerParam: TextReader.ReaderParam = {
      isVoiceBrandVisible: true,
      businessBrandInfo: {
        panelName: '小艺朗读',
        panelIcon: $r('app.media.startIcon')
      }
    }

    let context: Context | undefined = this.getUIContext().getHostContext();
    if (context) {
      try {
        await TextReader.init(context, readerParam);
        this.isInit = true;
      } catch (err) {
        hilog.error(0x0001, TAG, 'init error: %{public}s', JSON.stringify(err))
      }
    }
  }

  // Setting the Operation Listener
  setActionListener() {
    TextReader.on('setArticle',  (id: string) => {});
    TextReader.on('clickArticle',  (id: string) => {});
    TextReader.on('clickAuthor',  (id: string) => {});
    TextReader.on('clickNotification',  (id: string) => { hilog.info(0x0001, TAG, `onClickNotification ${id}`) });
    TextReader.on('showPanel', () => { hilog.info(0x0001, TAG, `onShowPanel`) });
    TextReader.on('hidePanel', () => { hilog.info(0x0001, TAG, `onHidePanel`) });
    TextReader.on('stop', () => { hilog.info(0x0001, TAG, `onStop`) });
    TextReader.on('release', () => { hilog.info(0x0001, TAG, `onRelease`) });
    TextReader.on('stateChange', (state: TextReader.ReadState) => {
      hilog.info(0x1, TAG, `ReadState: %{public}s`, JSON.stringify(state));
      this.onStateChanged(state)
    });
    TextReader.on('requestMore', () => this.onStateChanged);
  }

  onStateChanged = (state: TextReader.ReadState) => {
    hilog.info(0x1, TAG, `selectedReadInfo.id: %{public}s`, this.selectedReadInfo?.id);
    if (this.selectedReadInfo?.id === state.id) {
      hilog.warn(0x1, TAG, `match, changeState to %{public}s`, JSON.stringify(state))
      this.readState = state.state;
    } else {
      this.readState = ReadStateCode.WAITING;
    }
  }

  // Setting Event Listening
  setEventListener(){
    TextReader.on('eventNotification',  (event: TextReader.NotificationEvent) => {
      hilog.info(0x0001, TAG, `Notification event: ${JSON.stringify(event)}`)
    })
    TextReader.on('eventPanel',  (event: TextReader.PanelEvent) => {
      hilog.info(0x0001, TAG, `Panel event: ${JSON.stringify(event)}`)
    })
    TextReader.on('eventReadList',  (event: Array<TextReader.ListEventState>) => {
      hilog.info(0x0001, TAG, `ReadList event: ${JSON.stringify(event)}`)
      TextReader.loadMore([], true);
    })
  }

  build() {
    Column() {
      TextReaderIcon({ readState: this.readState })
        .width(32)
        .height(32)
        .onClick(async () => {
          // The playback is already in progress. Pull up the playback panel.
          if (this.readState === ReadStateCode.PLAYING) {
            TextReader.showPanel();
            return;
          }
          // If it is not initialized, initialize it and start it.
          try {
            this.setActionListener();
            this.setEventListener();
            await TextReader.start(this.readInfoList, this.selectedReadInfo?.id);
          } catch (err) {
            hilog.error(0x0001, TAG, 'init message: %{public}s', JSON.stringify(err))
          }
        })

      Text(this.readState === ReadStateCode.PLAYING? 'playing' : 'click icon to play').fontSize(10)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
