// FAQ：编译命令行中如何传递参数并且在Hvigor编译阶段扩展插件中获取到
// [Start hvigor_key]
// hvigorfile.ts
import { harTasks } from '@ohos/hvigor-ohos-plugin';
import { hvigor } from '@ohos/hvigor';

export default {
    system: harTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[]         /* Custom plugin to extend the functionality of Hvigor. */
}
console.log('value===', hvigor.getParameter().getExtParam('key1'));
// [End hvigor_key]