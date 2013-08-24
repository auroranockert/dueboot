//
// zero.rs
//
// Minimal definitions of the core primitives in Rust. Include this file with
// your project to create a freestanding Rust program that can run on bare
// metal.
//

#[allow(ctypes)];

// Built-in traits

#[lang="copy"]
pub trait Copy {}

#[lang="owned"]
pub trait Owned {}

#[lang="const"]
pub trait Const {}

#[lang="drop"]
pub trait Drop {
    fn finalize(&self);
}

// Operator overloading

#[lang="eq"]
pub trait Eq {
    fn eq(&self, other: &Self) -> bool;
    fn ne(&self, other: &Self) -> bool;
}

#[lang="ord"]
pub trait Ord {
    fn lt(&self, other: &Self) -> bool;
    fn le(&self, other: &Self) -> bool;
    fn ge(&self, other: &Self) -> bool;
    fn gt(&self, other: &Self) -> bool;
}

#[lang="add"]
pub trait Add<Rhs,Result> {
    fn add(&self, rhs: &Rhs) -> Result;
}

#[lang="sub"]
pub trait Sub<Rhs,Result> {
    fn sub(&self, rhs: &Rhs) -> Result;
}

#[lang="mul"]
pub trait Mul<Rhs,Result> {
    fn mul(&self, rhs: &Rhs) -> Result;
}

#[lang="div"]
pub trait Div<Rhs,Result> {
    fn div(&self, rhs: &Rhs) -> Result;
}

#[lang="rem"]
pub trait Rem<Rhs,Result> {
    fn rem(&self, rhs: &Rhs) -> Result;
}

#[lang="neg"]
pub trait Neg<Rhs,Result> {
    fn neg(&self) -> Result;
}

#[lang="not"]
pub trait Not<Rhs,Result> {
    fn not(&self) -> Result;
}

#[lang="bitand"]
pub trait BitAnd<Rhs,Result> {
    fn bitand(&self, rhs: &Rhs) -> Result;
}

#[lang="bitor"]
pub trait BitOr<Rhs,Result> {
    fn bitor(&self, rhs: &Rhs) -> Result;
}

#[lang="bitxor"]
pub trait BitXor<Rhs,Result> {
    fn bitxor(&self, rhs: &Rhs) -> Result;
}

#[lang="shl"]
pub trait Shl<Rhs,Result> {
    fn shl(&self, rhs: &Rhs) -> Result;
}

#[lang="shr"]
pub trait Shr<Rhs,Result> {
    fn shr(&self, rhs: &Rhs) -> Result;
}

#[lang="index"]
pub trait Index<Index,Result> {
    fn index(&self, rhs: &Index) -> Result;
}

// String utilities

#[lang="str_eq"]
#[fixed_stack_segment]
pub fn str_eq(a: &str, b: &str) -> bool {
    unsafe {
        let (aptr, alen): (*u8, uint) = transmute(a);
        let (bptr, blen): (*u8, uint) = transmute(b);
        if alen != blen {
            return false
        }
        memcmp(aptr, bptr, alen - 1) == 0
    }
}

// FIXME(pcwalton): This function is legacy junk.
#[lang="uniq_str_eq"]
pub fn uniq_str_eq(a: &~str, b: &~str) -> bool {
    str_eq(*a, *b)
}

struct StringRepr {
    fill: uint,
    alloc: uint,
}

// FIXME(pcwalton): This function should not be necessary, I don't think.
#[lang="strdup_uniq"]
#[fixed_stack_segment]
pub unsafe fn strdup_uniq(ptr: *u8, len: uint) -> ~str {
    let size = size_of::<StringRepr>() + len + 1;
    let string: *mut StringRepr = transmute(exchange_malloc(transmute(0),
                                                            size));
    (*string).fill = len + 1;
    (*string).alloc = len + 1;

    let mut data_ptr: uint = transmute(string);
    data_ptr += size_of::<StringRepr>();
    let data_ptr: *mut u8 = transmute(data_ptr);
    memcpy(data_ptr, ptr, len + 1);

    transmute(string)
}

// Legacy junk

#[lang="log_type"]
pub fn log_type<T>(_: u32, _: &T) {
    // FIXME: This function should not be a lang item.
}

#[lang="annihilate"]
pub unsafe fn annihilate() {}

// Failure

#[lang="fail_"]
#[fixed_stack_segment]
pub fn fail(_: *i8, _: *i8, _: uint) -> ! {
    unsafe {
        abort()
    }
}

#[lang="fail_bounds_check"]
#[fixed_stack_segment]
pub fn fail_bounds_check(_: *i8, _: uint, _: uint, _: uint) {
    unsafe {
        abort()
    }
}

// Memory allocation

// FIXME: So grotesquely inefficient.
struct Header {
    minus_one: uint,    // Must be -1.
    type_desc: *i8,
    null_0: uint,       // Must be null.
    null_1: uint,       // Must be null.
}

// FIXME: This is horrendously inefficient.
#[lang="exchange_malloc"]
#[fixed_stack_segment]
pub unsafe fn exchange_malloc(type_desc: *i8, size: uint) -> *i8 {
    let alloc: *mut Header = transmute(malloc(size_of::<Header>() + size));
    (*alloc).minus_one = -1;
    (*alloc).type_desc = type_desc;
    (*alloc).null_0 = 0;
    (*alloc).null_1 = 0;
    transmute(alloc)
}

#[lang="exchange_free"]
#[fixed_stack_segment]
pub unsafe fn exchange_free(alloc: *i8) {
    free(transmute(alloc))
}

// Entry point

// TODO(pcwalton): Stash argc and argv somewhere. Probably needs to wait on
// global variables.
#[lang="start"]
pub fn start(main: *u8, _: int, _: **i8, _: *u8) -> int {
    unsafe {
        let main: extern "Rust" fn() = transmute(main);
        main();
        0
    }
}

// The nonexistent garbage collector

#[lang="malloc"]
#[fixed_stack_segment]
pub unsafe fn gc_malloc(_: *i8, _: uint) -> *i8 {
    abort()
}

#[lang="free"]
#[fixed_stack_segment]
pub unsafe fn gc_free(_: *i8) {
    abort()
}

#[lang="borrow_as_imm"]
#[fixed_stack_segment]
pub unsafe fn borrow_as_imm(_: *u8, _: *i8, _: uint) -> uint {
    abort()
}

#[lang="borrow_as_mut"]
#[fixed_stack_segment]
pub unsafe fn borrow_as_mut(_: *u8, _: *i8, _: uint) -> uint {
    abort()
}

#[lang="record_borrow"]
#[fixed_stack_segment]
pub unsafe fn record_borrow(_: *u8, _: uint, _: *i8, _: uint) {
    abort()
}

#[lang="unrecord_borrow"]
#[fixed_stack_segment]
pub unsafe fn unrecord_borrow(_: *u8, _: uint, _: *i8, _: uint) {
    abort()
}

#[lang="return_to_mut"]
#[fixed_stack_segment]
pub unsafe fn return_to_mut(_: *u8, _: uint, _: *i8, _: uint) {
    abort()
}

#[lang="check_not_borrowed"]
#[fixed_stack_segment]
pub unsafe fn check_not_borrowed(_: *u8, _: *i8, _: uint) {
    abort()
}

// libc dependencies

extern {
    #[fast_ffi]
    pub fn malloc(size: uint) -> *u8;
    #[fast_ffi]
    pub fn free(ptr: *u8);
    #[fast_ffi]
    pub fn abort() -> !;
    #[fast_ffi]
    pub fn memcpy(dest: *mut u8, src: *u8, size: uint) -> *u8;
    #[fast_ffi]
    pub fn memcmp(a: *u8, b: *u8, size: uint) -> i32;
}

// Rust intrinsic dependencies

extern "rust-intrinsic" {
    pub fn transmute<T,U>(val: T) -> U;
    pub fn size_of<T>() -> uint;
}
