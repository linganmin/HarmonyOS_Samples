// FAQ:构建报错"Cannot read properties of undefined(reading 'XXX')"
// [Start harTasks]
import { harTasks } from '@ohos/hvigor-ohos-plugin';

export default {
    system: harTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[]         /* Custom plugin to extend the functionality of Hvigor. */
}
// [End harTasks]