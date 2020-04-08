Forest is a programming language. It has some cool properties, and a couple of surprising ones. It is not meant to be used directly to write programs, but rather other languages can be translated to it.

If you were ever programming and thinking that some aspects of the language (e.g. readable syntax) are good for the developer, but other ones (e.g. memory management, performance, ...) seem like something that could be handled better by some software than directly by a human being, then that's the exact kind of thinking that Forest was born from. The main goal is to separate the expression of comutation and low level operations that can be handled automatically depending on the platform and the computation itself.

Forest is an embedded language in the sense that it's embedded in another language. If you program in Forest, you focus on low-level operations (their performance, memory management, ...) when preparing an environment for the Forest code in the host language, and you focus on the computation itself (potentially with meta-data for the compiler) when writing the code in Forest.

There are 3 layers of the whole Forest environment:
1. `forest-runner-*` - has a function run(file_path, stages, options) that calls `forest-interpreter` and all the libraries
2. `forest-interpreter-*` (`forest-host-rb`, `forest-host-js`, ...) - it reads a text file and returns an AST (Abstract Syntax Tree) and a functioon that does exactly that. There are a couple of reasons why this function is returned. Forest libraries can use it to parse other files. Forest code can contain snippets in Forest as data and have it evaluated later. The text processed by this code has only 3 keywords: `code`, `block`, `data`. The AST that will be returned by this function has these keywords in internal nodes, and text in leafs.
2. Core library
  - `forest-essentials-*` - functions that can be found in almost every forest script
  - `forest-utils-*` - core library - useful funcntions that are worth learning
