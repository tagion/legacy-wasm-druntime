module hello_wasm;
import core.stdc.stdio;

class A {
    int x;
    this(int x) {
        this.x=x;
    }
}


extern(C) @nogc {
    import core.sys.wasi.link;
    int dl_iterate_phdr(dl_iterate_phdr_cb __callback, void*__data) {
        char[128] __dummy;    
        // printf("%s %p callback=%p\n", &__FUNCTION__[0], __data, &__callback);
        /// wasmer does not run if we don't do this for some odd reason?
        sprintf(&__dummy[0], "%p\n",  __data);
        return __callback(null, 0, __data);
    }
void _Unwind_Resume(void* x) {
    printf("%s\n", &__FUNCTION__[0]);
}
int _error_code;
ref int _errno() {
    return _error_code;
}
int lockf(int x, int y, int z) {
    printf("%s\n", &__FUNCTION__[0]);
    assert(0, "Not implemented");
}
void __multi3(int, long, long, long, long) {
    printf("%s\n", &__FUNCTION__[0]);
    assert(0, "Not implemented");
}
    import rt.sections_wasm : tls_index;
extern(C) void* __tls_get_addr(tls_index* ti) nothrow @nogc {
    return null;
}
}

extern(C) int _Dmain(char[][] args);
extern(C) void _start() {
    printf("Hello _start\n");
    import rt.dmain2;
    const run_ptr=&_d_run_main;
    printf("%p\n", run_ptr);
    _d_run_main(0, null, &_Dmain);
    //   printf("main %s\n", &fullyQualifiedName!(_d_run_main)[0]);
//    import core.internal.entrypoint : main;
//    main(0, null);
    //        main();
}


void main() {
    printf("In main\n");
    int[] array;
    printf("Yes it works!\n");
    int i;
    array~=10;
    printf("array[%d]=%d\n", i, array[i]);

    auto a=new A(42);
    printf("a.x=%d\n", a.x);

}
//import std.traits;
//pragma(msg, fullyQualifiedName!main);
