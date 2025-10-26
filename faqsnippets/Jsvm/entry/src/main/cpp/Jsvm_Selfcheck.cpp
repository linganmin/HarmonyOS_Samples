/*
* FAQ:如何自排查OOM(v8::FatalProcessOutOfMemory)错误
*/

// [Start Jsvm_Selfcheck]
// ...
JSVM_InitOptions init_options;
init_options.argc = (int*)malloc(sizeof(int));
*init_options.argc = 3;
init_options.argv = (char**)malloc(3 * sizeof(char*));
init_options.argv[1] = "--max-semi-space-size=1024";
init_options.argv[2] = "--max-old-space-size=1024";
init_options.removeFlags = true;
init_options.externalReferences = nullptr;
      
JSVM_Status status = OH_JSVM_Init(&init_options);

if (status != JSVM_OK)  {
  // If the status is not JSVM-OK, it indicates that OH_JSVM_Init execution failed and init_options was not successfully set.
}
// ...
// [End Jsvm_Selfcheck]

