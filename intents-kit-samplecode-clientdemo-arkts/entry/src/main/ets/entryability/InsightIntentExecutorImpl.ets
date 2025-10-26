import { Logger } from '../utils/Logger';

import { insightIntent, InsightIntentExecutor } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import type { BusinessError } from '@kit.BasicServicesKit';

/**
 * 最佳实践：意图框架习惯推荐场景开发实践
 */
const TAG: string = 'InsightIntentExecutorImpl';

/**
 * Intent execution example.
 */
export default class InsightIntentExecutorImpl extends InsightIntentExecutor {
  private static readonly PLAY_MUSIC = 'PlayMusic';
  private static readonly PLAY_MUSIC_LIST = 'PlayMusicList';

  // [Start fore_mode]
  /**
   * Override the method to execute the intent in the foreground UIAbility.
   *
   * @param name Intent name.
   * @param param Intent parameters.
   * @param pageLoader Window.
   * @returns Intent call result.
   */
  onExecuteInUIAbilityForegroundMode(name: string, param: Record<string, Object>, pageLoader: window.WindowStage):
    Promise<insightIntent.ExecuteResult> {
    Logger.info(TAG, `onExecuteInUIAbilityForegroundMode name: ${name}, param: ${JSON.stringify(param)}`);
    // Distribute the processing logic based on the intent name.
    switch (name) {
      case InsightIntentExecutorImpl.PLAY_MUSIC:
        return this.playMusic(param, pageLoader);
      case InsightIntentExecutorImpl.PLAY_MUSIC_LIST:
        return this.playMusicList(param, pageLoader);
      default:
        break;
    }

    return Promise.resolve({
      code: -1,
      result: {
        message: 'unknown intent'
      }
    } as insightIntent.ExecuteResult)
  }

  // [End fore_mode]
  // [Start play_music]
  /**
   * Implement the music playback function.
   *
   * @param param Intent parameters.
   * @param pageLoader Window.
   */
  private playMusic(param: Record<string, Object>,
    pageLoader: window.WindowStage): Promise<insightIntent.ExecuteResult> {
    return new Promise((resolve, reject) => {
      let para: Record<string, string> = {
        'result': `intent execute success, entityId: ${param.entityId}`
      };
      let localStorage: LocalStorage = new LocalStorage(para);
      // TODO Implement an intent call.
      pageLoader.loadContent('pages/Index', localStorage)
        .then(() => {
          // TODO The intent is called successfully.
          Logger.info(TAG, "Intent execute success");
          resolve({
            code: 0,
            result: {
              message: 'Intent execute success'
            }
          });
        })
        .catch((err: BusinessError) => {
          // TODO Handle the failure if the intent fails to be called.
          Logger.error(TAG, `Intent execute failed: ${JSON.stringify(err)}`);
          resolve({
            code: -1,
            result: {
              message: 'Intent execute failed'
            }
          })
        });
    })
  }

  // [End play_music]
  /**
   * Implement the playlist playback function.
   *
   * @param param Intent parameters.
   * @param pageLoader Window.
   */
  private playMusicList(param: Record<string, Object>,
    pageLoader: window.WindowStage): Promise<insightIntent.ExecuteResult> {
    return new Promise((resolve, reject) => {
      let para: Record<string, string> = {
        'result': JSON.stringify(param)
      };
      let localStorage: LocalStorage = new LocalStorage(para);
      // TODO Implement an intent call.
      pageLoader.loadContent('pages/Index', localStorage)
        .then(() => {
          // TODO The intent is called successfully.
          Logger.info(TAG, "Intent execute success");
          resolve({
            code: 0,
            result: {
              message: 'Intent execute success'
            }
          });
        })
        .catch((err: BusinessError) => {
          // TODO Handle the failure if the intent fails to be called.
          Logger.error(TAG, `Intent execute failed: ${JSON.stringify(err)}`);
          resolve({
            code: -1,
            result: {
              message: 'Intent execute failed'
            }
          })
        });
    })
  }
}
