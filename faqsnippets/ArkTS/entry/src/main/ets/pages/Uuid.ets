/**
 * FAQ:如何生成UUID的字符串
 */
import { util } from '@kit.ArkTS';

// [Start get_uuid]
let uuid = util.generateRandomUUID(true);
console.info("RFC 4122 Version 4 UUID:" + uuid); // Output randomly generated UUID
// [End get_uuid]