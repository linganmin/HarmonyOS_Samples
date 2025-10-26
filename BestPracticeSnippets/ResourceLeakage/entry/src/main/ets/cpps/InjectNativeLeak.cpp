// [Start inject_native_leak]
static bool InjectNativeLeak ()
{
    char* p = (char *) malloc(g_cmdLen + 1);
    if (!p) {
        return false;
    }
    int err = memset_s(p, g_cmdLen + 1, 'a', g_cmdLen);
    if (err) {
        free(p);
        return false;
    }
    free(p);
    return true;
}
// [End inject_native_leak]