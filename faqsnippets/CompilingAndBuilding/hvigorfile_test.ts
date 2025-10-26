
//FAQ:如何快速关闭工程中所有字节码HAR配置
// [Start hvigorfile]
// Engineering-level hvigorfile.ts file
import { hvigor, HvigorNode, HvigorPlugin } from '@ohos/hvigor';
import { appTasks, OhosHarContext, OhosPluginId, Target } from '@ohos/hvigor-ohos-plugin';
// Implement custom plugins
export function customPlugin(): HvigorPlugin {
  return {
    pluginId: 'customPlugin',
    async apply(currentNode: HvigorNode): Promise<void> {
      hvigor.afterNodeEvaluate(async () => {
        // Register module-level tasks
        harTask(currentNode);
      });
    }
  };
}
function harTask(currentNode: HvigorNode) {
  currentNode.subNodes((node: HvigorNode) => {
    const context = node.getContext(OhosPluginId.OHOS_HAR_PLUGIN)
    context?.targets((target: Target) => {
      const targetName = target.getTargetName();
      node.registerTask({
        // Task name
        name: `HarTask`,
        // Main function of task execution logic
        run() {
          if (context.getBuildProfileOpt) {
            const buildProfile = context.getBuildProfileOpt();
            console.log(buildProfile)
            // Set the bytecode har config to false
            buildProfile["buildOption"] = { arkOptions: { byteCodeHar: false } };
            console.log(buildProfile)
            context.setBuildProfileOpt(buildProfile);
          }
        },
        // Configure the dependency of the pre-task
        dependencies: [`${targetName}@PackageHar`],
        // Post-task dependency for configuring tasks
        postDependencies: ['assembleHar']
      });
    });
  });
}
export default {
  system: appTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins:[customPlugin()]  /* Custom plugin to extend the functionality of Hvigor. */
}
// [End hvigorfile]