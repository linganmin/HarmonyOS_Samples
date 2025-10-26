/*
* FAQ:AudioRenderer是否有跳转到某一帧的接口
 */
import { media } from '@kit.MediaKit'
import { BusinessError } from '@kit.BasicServicesKit';

let avPlayer: media.AVPlayer;
media.createAVPlayer((error: BusinessError, video: media.AVPlayer) => {
  if (video != null) {
    avPlayer = video;

    // [Start AvSeek]
    let seekTime: number = 1000
    avPlayer.seek(seekTime,media.SeekMode.SEEK_PREV_SYNC)
    // [End AvSeek]

    console.info('Succeeded in creating AVPlayer');
  } else {
    console.error(`Failed to create AVPlayer, error message:${error.message}`);
  }
});



