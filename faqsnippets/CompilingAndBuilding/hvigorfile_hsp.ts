/*
* FAQ:构建HSP模块时报错“Ohos BundleTool [Error]: hsp has home ability;Ohos BundleTool [Error]: CompressEntrance::main exit, verify failed.”
 */

// [Start custom_plugin]
// HSP module hvigorfile.ts
import { hspTasks,OhosPluginId, Target } from '@ohos/hvigor-ohos-plugin';
import { hvigor, HvigorNode, HvigorPlugin,FileUtil } from '@ohos/hvigor';
export function customPlugin():HvigorPlugin {
    return {
        pluginId: 'customPlugin',
        context() {
            return {
                data: 'customPlugin xxx'
            };
        },
        apply(currentNode:HvigorNode): Promise<void> {
            hvigor.nodesEvaluated(async () => {
                hspTask(currentNode);
            });
        }
    }
}
function hspTask(currentNode: HvigorNode) {
    // Obtain contextual information of the HSP module
    const hspContext = currentNode.getContext(OhosPluginId.OHOS_HSP_PLUGIN) as OhosHspContext;
    hspContext?.targets((target: Target) => {
        const targetName = target.getTargetName();
        const outputPath = target.getBuildTargetOutputPath();
        const task = currentNode.getTaskByName(`${targetName}@GeneratePkgModuleJson`);
        currentNode.registerTask({
            // TASK
            name: `${targetName}@changeModuleJson`,
            // Task execution logic entity function
            run() {
                const moduleJson = FileUtil.readJson5(outputPath+"/../../intermediates/package/"+targetName+"/module.json");
                const abilities = moduleJson['module']['abilities'];
                abilities.forEach((ability)=>{
                    delete ability['skills'];
                })
                console.log('begin to rewrite module.json file.');
                moduleJson['module']['abilities'] = abilities
                FileUtil.writeFileSync(outputPath+"/../../intermediates/package/"+targetName+"/module.json",JSON.stringify(moduleJson));
            },
            // Configure prerequisite task dependencies
            dependencies: [`${targetName}@GeneratePkgModuleJson`],
            // Post task dependencies for configuring tasks
            postDependencies: [`${targetName}@PackageSharedHar`]
        });
    });
}
export default {
    system: hspTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[customPlugin()]         /* Custom plugin to extend the functionality of Hvigor. */
}
// [End custom_plugin]