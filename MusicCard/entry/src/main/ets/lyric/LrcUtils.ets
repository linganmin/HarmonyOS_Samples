/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { util } from '@kit.ArkTS';
import { Logger } from '../utils/Logger';
import { LrcEntry, Word } from './LrcEntry';
import { LyricFile } from './LyricConst';
import { getSongListData } from '../viewmodel/SongListData';
import { SongItem } from '../viewmodel/SongItem';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * LRC format lyrics.
 */
const lrcLineRegex: RegExp = new RegExp('\\[\\d{2,}:\\d{2}((\\.|:)\\d{2,})\\]', 'g');
const lrcTimeRegex1: RegExp = new RegExp('\\[\\d{2,}', 'i');
const lrcTimeRegex2: RegExp = new RegExp('\\d{2}\\.\\d{2,}', 'i');

/**
 * KRC format lyrics.
 */
const krcLineRegex = new RegExp('\\[(\\d+),(\\d+)\\](.*)');
const krcWordRegex1 = new RegExp('<(\\d+),(\\d+),(\\d+)>([^<]*)', 'g');
const krcWordRegex2 = new RegExp('<(\\d+),(\\d+),(\\d+)>(.*)');

const TAG = 'LrcUtilsLogTag';

export async function getRawStringData(context: Context, rawFilePath: string): Promise<string> {
  let stringData = ''
  try {
    let value = await context.resourceManager.getRawFileContent(rawFilePath);
    let textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
    stringData = textDecoder.decodeToString(value, { stream: false });
  } catch (err) {
    let error = err as BusinessError;
    Logger.error(TAG, `onAddForm err, code: ${error.code}, mesage: ${error.message}`);
  }

  return stringData;
}

/**
 * Analysis of the lrc structure, similar to the following: [00:21.98] prime embryo outlines the blue and white pen dark to light.
 *
 * @param text
 * @returns
 * @param text
 * @returns
 */
export function parseLrcLyric(text: string): Array<LrcEntry> {
  if (!text) {
    return [];
  }
  let lyric: string[] = text.split('\n');
  let lrc: Array<LrcEntry> = [];
  for (let i = 0; i < lyric.length; i++) {
    let lineTime = lyric[i].match(lrcLineRegex);
    let lineText = lyric[i].replace(lrcLineRegex, '');
    if (lineTime && lineText) {
      for (let j = 0; j < lineTime.length; j++) {
        let min = Number(String(lineTime[j].match(lrcTimeRegex1)).slice(1));
        let sec = Number.parseFloat(String(lineTime[j].match(lrcTimeRegex2)));
        let timeInSeconds = (min * 60 + sec) * 1000;
        lrc.push({
          lineStartTime: timeInSeconds,
          lineDuration: 0,
          lineWords: lineText,
          words: [],
        });
      }
    }
  }
  if (lrc && lrc.length > 0) {
    lrc.sort((a, b) => {
      return a.lineStartTime - b.lineStartTime;
    });
    for (let i = 0; i < lrc.length; i++) {
      if (i === lrc.length - 1) {
        lrc[i].lineDuration = Number.MAX_VALUE;
      } else {
        lrc[i].lineDuration = lrc[i + 1].lineStartTime - lrc[i].lineStartTime;
      }
    }
  } else {
    Logger.error('Failed to parse the lyrics.');
  }
  return lrc;
}

/**
 * This function is used to parse KRC lyric files and convert lyric text into an array containing lyric information.
 * @param lyricText  KRC lyrics text that needs to be parsed.
 * @returns The parsed lyric information array, each element containing the starting time, duration, lyric text,
 * and detailed information of each word or phrase for a line of lyrics.
 */
export function parseKrcLyric(lyricText: string): LrcEntry[] {
  const lines: string[] = lyricText.split('\n');
  const lyricLines: LrcEntry[] = [];

  for (const line of lines) {
    const matches = line.match(krcLineRegex);
    if (matches) {
      const lineStartTime = Number.parseInt(matches[1]);
      const lineDuration = Number.parseInt(matches[2]);
      const lineWordsText = matches[3];
      const words: Word[] = [];
      const wordsMatches = lineWordsText.match(krcWordRegex1);
      let lineWords: string = '';
      if (wordsMatches) {
        for (const wordMatch of wordsMatches) {
          const wordMatches = wordMatch.match(krcWordRegex2);
          if (wordMatches) {
            const wordStartTime = Number.parseInt(wordMatches[1]);
            const wordDuration = Number.parseInt(wordMatches[2]);
            const wordText = wordMatches[4];
            lineWords += wordText;
            words.push({
              text: wordText,
              wordStartTime: wordStartTime,
              duration: wordDuration,
            });
          }
        }
      }
      lyricLines.push({
        lineStartTime: lineStartTime,
        lineDuration: lineDuration,
        lineWords: lineWords,
        words: words,
      });
    }
  }
  lyricLines.sort((a, b) => {
    return a.lineStartTime - b.lineStartTime;
  });
  return lyricLines;
}

/**
 * The angle is converted into radians.
 * Because the trigonometric function of Math needs to pass in the radian system instead of the angle value,
 * the angle needs to be converted into radians. Angle / 180 * π
 *
 * @param angle
 * @returns
 */
export function angleToRadian(angle: number): number {
  return (angle * Math.PI) / 180;
}

export function getRandomLyrics(context: Context): Record<string, object> {
  let songData: Record<string, object> = {};
  let songItem = getSongListData(context)[0];
  let randomLrcStr = getSongLyricsArray(context, songItem);
  songData.randomLrcStr = randomLrcStr;
  songData.songItem = songItem;
  return songData;
}

/**
 * This function is used to retrieve an array of lyrics for a specified song. If the song has lyrics files, the function will read and parse the lyrics files, and then return an array of parsed lyrics text. If the song does not have a lyrics file, the function will return an array containing prompt information.
 * @param context Context object, used to access the resource manager.
 * @param songItem Song object, containing detailed information about the song, including the path to the lyrics file
 * @returns
 */
// [Start dynamic_lyrics_get_song_lyrics_arr]
// [Start dynamic_lyrics_get_song_lyrics_arr_no_lyrics]
// src/main/ets/lyric/LrcUtils.ets
export function getSongLyricsArray(context: Context, songItem: SongItem): string[] | Resource[] {
  let lrcEntryList: LrcEntry[] = [];
  let value: Uint8Array = new Uint8Array();
  try {
    // [StartExclude dynamic_lyrics_get_song_lyrics_arr_no_lyrics]
    if (songItem.lyric) {
      value = context.resourceManager.getRawFileContentSync(songItem.lyric);
      let textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      let stringData = textDecoder.decodeToString(value, { stream: false });
      if (songItem.lyric.endsWith(LyricFile.KRC)) {
        lrcEntryList = parseKrcLyric(stringData);
      } else if (songItem.lyric.endsWith(LyricFile.LRC)) {
        lrcEntryList = parseLrcLyric(stringData);
      }
      // Return all lyrics
      let dynamicLrcStr: Array<string> = [];
      let randomLrc = lrcEntryList;
      randomLrc.forEach((lrc) => {
        dynamicLrcStr.push(lrc.lineWords);
      });
      return dynamicLrcStr;
      // [EndExclude dynamic_lyrics_get_song_lyrics_arr_no_lyrics]
    } else {
      return [$r('app.string.pure_music')];
    }
  } catch (err) {
    let error = err as BusinessError;
    Logger.error(TAG, `getSongLyricsArray err, code: ${error.code}, mesage: ${error.message}`);
  }
  return [];
}

// [End dynamic_lyrics_get_song_lyrics_arr]
// [End dynamic_lyrics_get_song_lyrics_arr_no_lyrics]

export function getSpecificLyrics(context: Context, lyrics: Array<LrcEntry>,
  lyricsIndex: number): Record<string, object> {
  let songData: Record<string, object> = {}; //  Define an empty object songData for storing song data
  let songItem: SongItem = AppStorage.get('currentSong') as SongItem;
  if (!songItem) {
    songItem = getSongListData(context)[0]; //  Retrieve the first song item from the song list data
  }
  let lrcLineLength = lyrics.length; //  Retrieve the number of lines in the lyrics
  let randomLrcStr: Array<string> = []; //  Define an empty array randomLrcStr to store lyrics
  randomLrcStr.push(lyrics[lyricsIndex].lineWords); //  Add the line of the current lyrics to the randomLrcStr array
  if (lyricsIndex + 1 < lrcLineLength) {
    AppStorage.setOrCreate('currentLyricIndex', lyricsIndex);
    //  If the next line of the current lyrics exists, add it to the randomLrcStr array
    randomLrcStr.push(lyrics[lyricsIndex + 1].lineWords);
  }
  songData.randomLrcStr = randomLrcStr;
  songData.songItem = songItem;
  return songData;
}

export function getInitialLyrics(context: Context): Record<string, object> {
  let songData: Record<string, object> = {};
  let lrcEntryList: LrcEntry[] = [];
  let songItem = getSongListData(context)[0];
  let value = new Uint8Array();
  try {
    value = context.resourceManager.getRawFileContentSync(songItem.lyric);
  } catch (err) {
    let error = err as BusinessError;
    Logger.error(TAG, `getInitialLyrics err, code: ${error.code}, mesage: ${error.message}`);
  }
  let textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
  let stringData = textDecoder.decodeToString(value, { stream: false });
  if (songItem.lyric.endsWith(LyricFile.KRC)) {
    lrcEntryList = parseKrcLyric(stringData);
  } else if (songItem.lyric.endsWith(LyricFile.LRC)) {
    lrcEntryList = parseLrcLyric(stringData);
  }
  let randomLrcStr: Array<string> = [];

  randomLrcStr.push(lrcEntryList[0].lineWords);
  randomLrcStr.push(lrcEntryList[1].lineWords);

  songData.randomLrcStr = randomLrcStr;
  songData.songItem = songItem;
  return songData;
}