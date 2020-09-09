# Forest

Forest is a programming language. The main goal for it is to make static analysis as easy as possible.

Simplicity for static analysis goes against language readability and terseness. That's why Forest is a backend of a couple of other languages. One of them is Lamb (another is Groudcover). You can write the code in Lamb which has a goal of making programming a pure pleasure. Then the Lamb compiler produces Forest code, and you can use it for static analysis.

If you want to write a new porgramming language, and its syntax is what matters to you the most, it might be a good call to implement it as a front-end of Forest.

The following repositories are closely related to tthis one:
- https://github.com/netizer/lamb-rb
- https://github.com/netizer/groundcover-rb
- https://github.com/netizer/core-lib-forest
- https://github.com/netizer/forest-utils

## Features that you might like

Forest environment (so Forest + Lamb + Groundcover) has some nice properties. The following list covers general ideas. Some of them might not be 100% ready yet. I'll mention when that's the case.

1. Multi-stage evaluation - Macro resolution is just a stage, another is runtime. We will have type inference stage pretty soon, and optimisation stage after that. As Forest is easy to staticly analise, creating code that takes Forest code and produces Forest code is easy. Every stage apart from the last one (runtime) does exactly that.
2. Security - Imagine being absolutely sure that the tests you're running won't try to reach the production server. But I mean, not just knowing  because you know the code, but knowing that it's absolutely impossible, because the code doesn't even have access to functions that could do that. As analysing Forest code is so easy, the function than lists all features that the given code depends on takes less than 50 lines of code (`check_tree` function in `lib/forest/dependenncies/stages.rb`). You can list all features that you feel comfortable passing to certain code, and if that code depends on something else, you can stub it.
3. Developer productivity - The split between frontend and backend languages as a first-class citizen means that the frontend language (e.g. Lamb) can be focused on developer productivity without compromise. We don't need 2 different ways to express something because in different circumstances one or the other is more performant. We can just build the code that recognises these circumstances and optimises the code as part of a performance stage of compilation (as mentioned in the point 1, the features for the performance stage will arrive shortly).

## Core properties of Forest

### Great for static analysis

Easy static analysis means that the language has to be simple. Forest is simple. The lexer and parser together (`lib/forest/dependencies/interpreter.rb`) have less than 200 lines of code. It has only 3 low-level keywords: `call`, `block`, and `data`. Calling them keywords might be a bit of a stretch in the same sense as adding the word `keyword` in front of every keyword in some language wouldn't really make it a one-keyword language, but these 3 words and strings are the only things you'll see in the Forest code.

### Embedded

It is an embedded language, so you can use Forest from another languages. Currently only Ruby is supported. There are 2 or 3 milestones ahead before it will make sense to support other languages (mostly I need to move as much of the Ruby code to Forest itself).

### Frontend languages

There are 3 layers of software written with Forest.
1. Language frontend - the code the developer writes (e.g. in Lamb).
2. Language backend - the code the frontend produces (Forest).
3. Host lanugage - the code (in Ruby, JS, Python, C, ... but, currently only Ruby) that passes host-language features (IO, threads, Iternet access) to Forest environment.

## How does it look and what does it mean?

The following Forest code creates a function `first_function` that prints "defined first" text.

```forest
call
  data
    cgs.context
  block
    call
      data
        cgs.set
      block
        data
          first_function
        call
          data
            ln.later
          call
            data
              testing.log
            block
              data
                defined first
```      

Now, what does it mean?  

- `call`, `data`, and `block` are low-level keywords (or internal nodes). If you look at the Forest code, that's all there is. We call them internal nodes, because that's what they are in the tree tructure of the program.
  - `call` is for describing calls to high-level keywords. It has always 2 children - data representing the name of the keyword, and the node that will be passed to it.
  - `data` represents some data. It might be a function name, or a name of a variable, or anything else.
  - `block` is just for grouping several nodes together. Some high-level keywords need a block as the second child, because they operate on sequences of calls (e.g. `cgs.context`)
- `cgs.context`, `cgs.set`, `ln.later`, and `testing.log` are high-level keywords. If we use the word `keyword` without specifying if it's high or low-level, that's what we mean. low-level keywords are boring, so we don't refer to them as just `keywords`.
  - `cgs.context` creates a new context which is one layer of the lexical scope of the program. All the variables belong to some context, and when you call a function, we search for it up the context stack.
  - `cgs.set` sets a variable, but in Forest, we use contexts as hashes, so we can well enough treat it as setting a key-value pair of some hash.
  - `ln.later` creates a function, that can be called with `ln.now`.
  - `testing.log` is just another keyword that can be used in testing.

## Usage

```bash
bin/forest.rb FOREST_FILE
```

You can also install Forest in your system, e.g. by cloning `forest-rb` and `core-lib-forest` to the same directory and then running the following commands:

```bash
ln -s ~/4st/forest-rb/bin/forest.rb /usr/local/bin/forest
ln -s ~/4st/core-lib-forest ~/forestcorelib
```

(assuming that the `forest-rb` and `core-lib-forest` repos are in `~/4st/` directory).

Then you can, for example, clone `core-lib-forest` and call `forest app test` to run all tests.

## Status of the language

Forest is a work in progress. Lots of things can change, but not syntax, which won't **ever** change. I can bet on that (but I'll gladly loose that bet if I'll see that there is a better syntax for static analysis).

## Community

If you like this language, and you'd like to use it or just play with it, feel free to create github issues whenever something doesn't work, or if you just have questions. I'd love to have a conversation with you, but I also like the async and public nature (more people benefit from a conversations) of communication through github issues. A good starting point to play with Forest and with Groundcover or Forest is to follow the instructions at https://github.com/netizer/forest-utils
