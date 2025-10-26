/**
 * FAQ: ArkTS侧与Native侧如何进行map数据交互
 */
import { HashMap } from '@kit.ArkTS'
import testNapi from 'libentry.so';

const fun = ()=>{
  // [Start native_map_ets]
  let hashmap: HashMap<string, number> = new HashMap()
  hashmap.set("Abc", 123)
  hashmap.set("Bcd", 234)
  hashmap.set("Cde", 345)
  for (let key of hashmap.keys()) {
    testNapi.mapDemo(key, hashmap.get(key))
    console.info(`key is ${key}, value is ${hashmap.get(key)}`)
  }
  // [End native_map_ets]
}