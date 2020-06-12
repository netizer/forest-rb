# Forest

## Description

Forest is a programming language. It has some cool properties, and a couple of surprising ones. It is not meant to be used directly to write programs, but rather other languages can be translated to it.

If you were ever programming and thinking that some aspects of the language (e.g. readable syntax) are good for the developer, but other ones (e.g. memory management, performance, ...) seem like something that could be handled better by some software than directly by a human being, then that's the exact kind of thinking that Forest was born from. The main goal is to separate the low level operations that can be handled and optimised automatically depending on the platform and the computation itself.

Forest is an embedded language in the sense that it's embedded in another language. If you program in Forest, you focus on low-level operations (their performance, memory management, ...) when preparing an environment for the Forest code in the host language, and you focus on the computation itself (potentially with meta-data for the compiler) when writing the code in Forest.

There are 3 layers of the whole Forest environment:
1. `forest-runner-*` - has a function `run_forest(file_path, stages, options)` that calls `forest-interpreter` and all the libraries. This module is the interface for any script written in forest or any language that translates to forest. Currently the only other language is `lamb`, and you can call the script written in it in the following way: `run(lang, file_path, stages, options)`. In the future it will be possible to pass `compile: true` as `options` and cause a compilation of the script in `forest` (or lany language that translates to `forest`) to the host language. This could potentially significantly improve the performence as the compilation process will run optimisations on the code and as `forest` is so simple, static analysis of the code should enable significant performance improvements.
2. `forest-interpreter-*` (`forest-host-rb`, `forest-host-js`, ...) - it provides one function that gets a stream of code and returns an AST (Abstract Syntax Tree) with leafs being text and internal nodes being one of 3 keywords (`code`, `block`, `data`). This function can be used in several ways:
- to process the main file of a package (by `forest-runner-*`)
- `forest` libraries can use it to parse other files
- `forest` code can contain snippets in `forest` as data and have it evaluated later.
3. `forest-subcore-*` - functions for `forest-runner-*` and `forest-interpreter-*`, for example to iterate over characters from the forest-file. s
4. `forest-core-*` - core library; functions that can be found in almost every forest script. `forest-runner-*` and `forest-interpreter-*` often call these functions directly, for example to iterate over characters from the forest-file.

To run the code written in forest, use the following code:
```
runner = Runner.new(
  file: 'path-to-main.forest`
  dependencies: {
    core: Core.new
  }
)
runner.run([:macro, :type, :eval])
```

## Installation

You can use this library as a gem (just add `gem forest-rb` to your `Gemfile` and run `bundle install`), or you can install a `forest` command. To do that, you could for example (instructions are for MacOS):
1. Clone this repository (e.g. to `~/xyz/forest-rb`)
2. Go to `/usr/local/bin`
3. Run `ln -s ~/xyz/forest-rb/lib/command.rb forest`
4. Done. From now on you can just use `forest` command (e.g. `forest help`)
