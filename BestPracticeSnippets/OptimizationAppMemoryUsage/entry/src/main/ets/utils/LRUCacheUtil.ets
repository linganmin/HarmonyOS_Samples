// [Start lru_cache_util]
import { util } from '@kit.ArkTS';

export class LRUCacheUtil {
  private static instance: LRUCacheUtil;
  private lruCache: util.LRUCache<string, Object>;

  private constructor() {
    this.lruCache = new util.LRUCache(64);
  }

  // Get the singleton of LRUCacheUtil
  public static getInstance(): LRUCacheUtil {
    if (!LRUCacheUtil.instance) {
      LRUCacheUtil.instance = new LRUCacheUtil();
    }
    return LRUCacheUtil.instance;
  }

  // Determine whether the lruCache cache is empty
  public isEmpty(): boolean {
    return this.lruCache.isEmpty();
  }

  // Get the capacity of lruCache
  public getCapacity(): number {
    return this.lruCache.getCapacity();
  }

  // Reset the capacity of lruCache
  public updateCapacity(newCapacity: number): void {
    this.lruCache.updateCapacity(newCapacity);
  }

  // Add cache to lruCache
  public putCache(key: string, value: Object): void {
    this.lruCache.put(key, value);
  }

  // Delete the cache corresponding to the key
  public remove(key: string): void {
    this.lruCache.remove(key);
  }

  // Get the cache corresponding to the key
  public getCache(key: string): Object | undefined {
    return this.lruCache.get(key);
  }

  // Determine whether the cache corresponding to the key is included.
  public contains(key: string): boolean {
    return this.lruCache.contains(key);
  }

  // Clear the cached data and reset the size of lruCache
  public clearCache(): void {
    this.lruCache.clear();
    this.lruCache.updateCapacity(64);
  }
}
// [End lru_cache_util]