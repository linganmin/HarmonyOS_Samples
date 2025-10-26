/**
 * 最佳实践：合理使用音频资源
 * 场景二：播音场景（AVPlayer）
 */
// [Start sound_pool]
import { fileIo as fs } from '@kit.CoreFileKit';
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';

// [End sound_pool]

// [Start av_player]
import { UIAbility } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

// [StartExclude av_player]
let avPlayer: media.AVPlayer

// [EndExclude av_player]

export default class EntryAbility extends UIAbility {
  // ...
  onForeground(): void {
    //Playing according to service requirements in the foreground
    avPlayer.play()
      .catch((err: BusinessError) => {
        hilog.error(0x000, 'testTag', `avPlayer play failed, code=${err.code}, message=${err.message}`)
      })
  }

  onBackground(): void {
    // Return to the background to stop playing or pause
    avPlayer.stop() // Or pause();
      .catch((err: BusinessError) => {
        hilog.error(0x000, 'testTag', `avPlayer stop failed, code=${err.code}, message=${err.message}`)
      })
  }
}

// [End av_player]

/**
 * 最佳实践：合理使用音频资源
 * 场景五：播音场景（SoundPool）
 */

let soundId: number;
let streamId: number;
let uri: string;
let soundPool: media.SoundPool;
// [Start sound_pool]
const SoundPool = async () => {

  //Construct the audio stream to play
  await fs.open('/test_01.mp3', fs.OpenMode.READ_ONLY).then((file: fs.File) => {
    console.info("filefd:" + file.fd);
    uri = 'fd://' + (file.fd).toString()
  }) // '/test_01.mp3' is used as an example. The path of the file needs to be transferred
    .catch((err: BusinessError) => {
      hilog.error(0x000, 'testTag', `avPlayer stop failed, code=${err.code}, message=${err.message}`);
    })
  await soundPool.load(uri)
    .then((soundId: number) => {
      //The foreground scene starts to play
      soundPool.play(soundId)
        .then((data: number) => {
          streamId = data;
          hilog.info(0x000, 'testTag', 'setPreferredOrientation success');
        })
        .catch((err: BusinessError) => {
          hilog.error(0x000, 'testTag', `soundPool play failed, code=${err.code}, message=${err.message}`);
        })
      //Stop playing in the background scenario: soundPool.stop (streamId);
    })
    .catch((err: BusinessError) => {
      hilog.error(0x000, 'testTag', `soundPool load failed, code=${err.code}, message=${err.message}`);
    })
}
// [End sound_pool]
