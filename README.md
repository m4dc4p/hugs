# Hugs 98 for MacOS (x86)

This flake defines how to build and run the Hugs Haskell interpreter on 
MacOS machines with the x86 chipset. Its quite likely that this source can
build on M1, etc. but someone else will have to test that.

This flake builds from the last [public source release of Hugs (September 2006)](https://www.haskell.org/hugs/downloads/2006-09/hugs98-plus-Sep2006.tar.gz). No
updates were made to the source, except those necessary to get it to compile.

# Building Hugs

With nix installed and flakes enabled, you can build hugs quite easily. From the root
of this repo:


```bash
$ nix build
```

The `result` symlink will point to a directory containing `bin`, `hugsdir` and some
other directories:

* `bin` - Hugs interpreter and other executables (`hugs`, `runhugs`, `ffihugs`, `cpphs-hugs` and `hsc2hs-hugs`)
* `hugsdir` - This contains all the libraries that shipped with the last release of Hugs.

# Running Hugs

Hugs and friends can be run directly from this flake:

* `nix run` (that is, the default app) will execute `runhugs`, which expects a Haskell source file to execute.
* `#hugs` - Starts the Hugs interpreter.
* `#runhugs` - Executes `runhugs` (same as the default)
* `#ffihugs` - Executes the `ffihugs` program.
* `#cpphs-hugs` - Executes the `cpphs-hugs` program.
* `#hsc2hs-hugs` - Executes the `hsc2hs-hugs` program.

## HUGSDIR

`HUGSDIR` is a compile time value that is used when resolving path names while searching for modules. By default,
it will be set to the absolute path to the `hugsdir` directory in derivation's output (that is, the directory pointed to
by `result` above).

`man hugs` explains how to override HUGSDIR and how to use it in conjunction with the search path (`-P` option) in
order to find modules.

# Notes on Buildin Hugs with Nix

Ironically, the hardest part in getting hugs to build under Nix was due to whitespace handling. In the far
past, someone mixed tabs and spaces throughout the hugs source code (Haskell files, specifically). `gcc` must
have originally preserved whitespace, but `clang` (now the standard compiler provided by nix) did not. The
file `patches/sources.patch` mostly updates indentation so hugs can compile its own source files.

I tried very hard to use `cpphs` (provided externally by nixpkgs) rather than patching all these source files, but
there were just enough special defines and includes that `clang` already knew about that I couldn't quite get it working. 

The C preprocessor provided by `gcc` also behaved slightly differently than `clang`. In particular, Haskell
pragrams such as `{-# INLINE #-}` could not be split across multiple lines, such as:

    {-# INLINE 
     #-}

As the preprocess would think the final line was a preprocess directive, and halt.

Some of the scripts in the source distribution seem plain bugged, as they were missing source files
or preprocessor defines. 

`hsc2hs` (built during bootstrapping) was hardcoded to use `gcc`; not surprising, `clang` didn't even exist
when this was last released! `gcc` is provided by nix so the build can complete, and is also provided to the `hsc2hs-hugs`
binary (though I'm not sure what that acutally does).


