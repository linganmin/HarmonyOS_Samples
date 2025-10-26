// [Start song_info]
import { SongInfoItem } from './song';
import { HashMap } from '@kit.ArkTS';
import { fileIo } from '@kit.CoreFileKit';
import { IDataSourcePrefetching } from '@kit.ArkUI';
import { rcp } from '@kit.RemoteCommunicationKit';
let PREFETCH_ENABLED: boolean = false;
const CANCEL_CODE: number = 1007900992;
const IMADE_UNAVAILABLE = $r('app.media.startIcon');
export default class DataSourcePrefetching implements IDataSourcePrefetching {
  private dataArray: Array<SongInfoItem>;
  private listeners: DataChangeListener[] = [];
  private readonly requestsInFlight: HashMap<number, rcp.Request> = new HashMap();
  private readonly session: rcp.Session = rcp.createSession();
  cache(ID:number,body: ESObject){}
  constructor(dataArray: Array<SongInfoItem>) {
    this.dataArray = dataArray;
  }
  totalCount(): number {
    throw new Error('Method not implemented.');
  }
  getData(index: number): ESObject {
    throw new Error('Method not implemented.');
  }
  registerDataChangeListener(listener: DataChangeListener): void {
    throw new Error('Method not implemented.');
  }
  unregisterDataChangeListener(listener: DataChangeListener): void {
    throw new Error('Method not implemented.');
  }
  async prefetch(index: number): Promise<void> {
    PREFETCH_ENABLED = true;
    if (this.requestsInFlight.hasKey(index)) {
      throw new Error('Already being prefetched')
    }
    const item = this.dataArray[index];
    if (item.cachedImage) {
      return;
    }
    // Data request
    const request = new rcp.Request(item.albumUrl, 'GET');
    // Cache the network request object, which is convenient for handling when the request needs to be cancelled.
    this.requestsInFlight.set(index, request);
    try {
      // Send an http request to get a response.
      const response = await this.session.fetch(request);
      if (response.statusCode !== 200 || !response.body) {
        throw new Error('Bad response');
      }
      // Storing the loaded data information into a cache file.
      item.cachedImage = await this.cache(item.songId, response.body);
      // Delete the specified element
      this.requestsInFlight.remove(index);
    } catch (err) {
      if (err.code !== CANCEL_CODE) {
        item.cachedImage = IMADE_UNAVAILABLE;
        // Remove abnormal network request tasks.
        this.requestsInFlight.remove(index);
      }
      throw err as Error;
    }
  }
  cancel(index: number) {
    if (this.requestsInFlight.hasKey(index)) {
      // Returns the specified element of a MAP object.
      const request = this.requestsInFlight.get(index);
      // Cancel data request
      this.session.cancel(request);
      // Remove the canceled network request object
      this.requestsInFlight.remove(index);
    }
  }
  // ...
}
// [End song_info]