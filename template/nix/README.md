# Nix Code Documentation

This repository uses [`IOGX`](https://www.github.com/zeme-wana/iogx/tree/6a7c9bb312b13b4b638edc0484fcc29eab40c06a) to structure its nix code.

What follows is a documentation of how each file in the `nix` folder affects the final flake outputs.

The following files are used by IOGX to generate the flake outputs:

- [`iogx-config`](./iogx-config.nix) — Top level configration for IOGX 
- [`haskell-project`](./haskell-project.nix) — Declaration of the [`haskell.nix`](https://github.com/input-output-hk/haskell.nix) project
- [`shell`](./shell.nix) — Nix development shell 
- [`hydra-jobs`](./hydra-jobs.nix) — `hydraJobs` jobset for CI
- [`read-the-docs`](./read-the-docs.nix) — Support for a [`read-the-docs`](https://readthedocs.org) site
- [`per-system-outputs`](./per-system-outputs.nix) — Additional system dependent outputs
- [`system-independent-outputs`](./system-independent-outputs.nix) — Top level flake outputs


## `iogx-config.nix`
Contains those config values that are global or shared by several components.
```nix
{
    debug = true;
    flakeOutputsPrefix = "";
    repoRoot = ./.;
    systems = [];
    compilers = [];
    defaultCompiler = "ghc8107";
    crossSystem = null;
}
```

### 2 `./nix/per-system-outputs.nix`
Same as current interface, except that `flakeops` disappears.

If this is not needed, the empty attrset can be returned.
```nix
{ inputs, systemized-inputs, pkgs }:
{}
```

### 3 `./nix/system-independent-outputs.nix`
If this is not needed, the empty attrset can be returned.
```nix
{ inputs, systemized-inputs }:
{}
```

### 4 `./nix/haskell-project.nix` 
Compared to the current interface, we ca remove `flakeopt`, `ghc`, `enableProfiling`.
And we can also hide the call to `cabalProject'`.
And instead of returning a h.nix project, we require that the user return an attrset containing h.nix specific values that iogx will feed internally to `cabalProject'`.
This file it not optional.
```nix
{ inputs, systemized-inputs, pkgs, deferPluginErrors }:
{ 
    shaMap = {};
    cabalConfig = "";
    modules = {};
}
```

### 5 `./nix/shell.nix`
The new interface does not need `flakeopts`. Also, `shellPrompt` and `shellWelcomeMessage` can be moved here from the top-level. If no augmentations to the shell are needed, `enabled` can be set to false.
```nix
{ inputs, systemized-inputs, pkgs, haskell-nix-project }: 
{ 
    enabled = true;
    prompt = "";
    welcomeMessage = "";

    scripts = {};
    packages = [];
    env = {};
    shellHook = "";  
    processes = {}; # TODO (not trivial, will add when actually needed)
}
```

### 6 `./nix/read-the-docs.nix`
Relevant config values can be moved here from `flakeopts`.

If read-the-docs is not supported, `enabled` can be set to false.
```nix
{ inputs, systemized-inputs, pkgs, haskell-nix-project }:
{   
    enabled = true;
    siteDir = ./docs;
    haddockPrologue = "";
    extraHaddockPackages = _: {};
}
```

### 7 `./nix/hydra-jobs.nix`
Note that several config values that used to be in `flakeops` can be moved here from the top-level.
If hydra jobs are not needed, `enabled` can be set to false.
```nix
{ inputs, systemized-inputs, pkgs, haskell-nix-project }: 
{   
    enabled = true;
    buildSystems = [];
    excludeProfiledHaskell = true;
    blacklistedJobs = [];
    enablePreCommitCheck = true;
}
```

Note that various escape-hatches can be implemented by means of additional fields in the attrsets returned by each of these 7 files. They can be added as neede.

> In IOGX, everything is defined through a single grab-bag top-level attribute set, without clarity about how everything interrelates or which parts one needs to think about for which purpose or what one should do if the default capabilities don't quite fit the needs. 

I think that due to the scope of this, a grab-bag top-level attribute set could be the right abstraction, at least until we find that new repositories require feature that make the scope larger and more complex to the point where an explicit separation of components at the interface level becomes a better solution.

> Users have to write complex functions (e.g. preparing a call to cabalProject' themselves), 

See comments below: this can be simplified but not totally. Functions are unavoidable if we want to expose values to the users to play with (e.g. `inputs`, `pkgs`)

> boilerplate is stored in templates (which will go stale), the system is pretty heavily "all or nothing". 

Templates can go stale, however they are very handy: you can run `nix flake template --init` and get started immediately. I'm not sure we should give up on them yet.
The system only *appears* to be "all or nothing": out of the 6 components identified above, only 1 is required: the haskell project. devShells, hydra, readTheDocs, perSystemOutputs, globalOutputs can be turned on/off by setting or `null`ing the relevant flakeops fields. Granted, this approach is not ideal and a better alternative will be given, for example by means of a general `enable` field for each component.

> Internally, flakeopts is passed around everywhere, and so every component can (and, inevitably, will) borrow implicitly from the interface of other components. The interface is more a copied around template file than it is functions.

Internally it must be, but it turns out that it does *not* have to be exposed to the user. The files `per-system-output.nix`, `haskell-project.nix` and `shell-module.nix` do *not* need to know about `flakeopts`, and so it can be removed from the interface.

## README

> We should have standalone documentation of various components, not just comments in templates.
> Would be good for each component to document a fuller inventory of "what you get" from it. E.g. "the default flake includes code formatters and a dev shell that can build your Haskell project"
> What is "a standard environment"? Do you mean a shell? But doesn't iogx do more than that?
> Should have links for setting up Nix, ideally with our caches. OK to reuse upstream docs (or maybe h.nix's).

Agreed to all this, the readme needs to be revised and expanded. I would still put off writing shiny and thorough documentation until we get user feedback and have a real v1.

## flake.nix

> Should we be putting things in a top-level lib output?

Yes, it makes sense and seems to be convention.

> Can we get documentation for what is exported?

Yes, I will include that in the docs.

## template/flake.nix

> Would be good to link to some general flake docs explaining what a flake is and how the flake CLI works

Noted.

> For input overrides, we should consider (or perhaps present the difference between) overriding in flake.nix with follows or in flake.lock with a nested --update-input. The latter means that the next time we update the top-level input we will lose the nested override, which may be good (since the top-level input may in fact need something newer/different) or bad.

Noted. Documenting the various ways to "play" with flake inputs will be useful information to the users.

> When might I need to override some input?

When wanting to use a different version of an input managed by iogx. 
I will include this in the docs.

> How can I know if some input is included in iogx vs can just be added top-level?

The inputs included in iogx are listed in the comments in flake.nix.
One can also do `nix flake info github:zeme-wana/iogx`.
I will include this in the docs.

> The "systemized"/"desystemized" terminology is never fully explained

Much like flake-parts has `inputs` and `inputs'`, we have `inputs` and `systemized-inputs`.
I will improve the docs for this.

> Might help to document what description is a description of

Noted.

> With separate docs I don't think we should have fields with sane defaults in the template

I dislike implicit defaults in configurations because they hide information from me. 
For each field, I want to know what it does and what its default value is.
If we use a template, we have a few choices:

1. (best IMO)
```
# The nonempty list of supported systems.
systems = [ "x86_64-linux" "x86_64-darwin" ];
```
2. (one character longer than 1, and makes validating the config more complex)
```
# The nonempty list of supported systems.
# systems = [ "x86_64-linux" "x86_64-darwin" ];
```
3. (hides what the default value is)
```
# The nonempty list of supported systems.
# Available values are: x86_64-linux, x86_64-darwin
# systems = 
```

> Would be good to have a worked-out example of using a flake using flakeOutputsPrefix to transition

Notes.

> Can we default repoRoot to inputs.self?

Using `inputs.self` leads to a nasty infinite recursion bug. Eventually it'll be fixed and we can rid of `repoRoot`.

> Why do we have our own list of allowable compilers? Can't we just use h.nix's and have haskellCompilers be a subset of that?

`haskellCompilers` already is a subset of h.nix's. It's a small subset, because each compiler needs to be "tested" i.e. make sure that its tools are availalble, cached, and working, and set to the correct version (stylish-haskell, hlint, fourmolu, cabal, cabal-fmt, hls). Eventually the `haskellCompilers` set will expand. For now it contains the two compilers that are used by the SC repos.

> Ideally we'd have settings of different subcomponents (here's how you define the haskell project info, here's how you define dev shell info, here's how you define CI info, here's how you define readthedocs info) completely separate, but at least it would be good to have them grouped together clearly in the docs.

Noted.

> haskellCrossSystem: Why only one host system, why not just a per-system thing? Perhaps with an enableCross :: System -> Bool?

Because one host system is what is needed by those repos that use it. `enableCross` would be overkill (as of now)

> shellWelcomeMessage/shellPrompt: Would be good to link to generic docs for PS1, ANSI escape codes

Noted.

> shellModule: What is a "devShell module"?

Obsolete term. This will be named `shellFile` or simply `shell`. 

> shellModule: Would be good to clarify that nothing in shell module means nothing added to the Haskell shell not that you get no shell at all

Noted. 

> Hydra: Maybe we should define our own simple CI interface that we can compile down to hydra or GHA or whatever? Since we don't have a stable CI solution across the teams yet. I've started some work in this direction if you're interested.

I think we should put that off until someone actually decides to transition to GHA or use something else. All SC repos I've seen so far use Hydra.

> Would be good to explain why you don't want profiled builds in CI

Noted.

> Would be good to explain why you would want to add something to the CI blacklist

Noted.

> readTheDocsExtraHaddockPackages: Would be good if by default this could be "all of the locally declared packages in the cabal.project", and if we exported a function to start there and let the user add more.

Noted.

> Is it possible end users may want extra outputs that aren't per-system?

It's possible, just I haven't witnessed it yet in the repos I've worked on, so I did not provision for it.

## template/nix/haskell-project.nix

> The type of this file is pretty complex and includes details we shouldn't need. Why does the haskell.nix definition take the entire flakeopts?

This file can be simplified. I can get rid of `flakeopts` altogether.

> Ideally this would be declarative (or declarative with the option to expand to something more involved as needed).

We had discussed this, and we had agreed that we should leave this for last or not do it at all, because creating a declarative layer on top of h.nix may end up being unachievable or not very useful, given the many edge-cases specific to each repository. 

> Should document that this is expected to return "a haskell.nix project value"

Noted.

> The double negative of "systemized" is confusing here

Noted. 

> Why shouldn't we use inputs.nixpkgs?

Because we create an overlayed version of nixpkgs using h.nix (see src/bootstrap/pkgs.nix). Users should use that because it's configured and overlayed properly: using two nixpkgs is asking for trouble. This explanation will be added to the docs

> If the user has to call cabalProject', what are we adding? Shouldn't the invocation be in lib with upstream-controlled defaults/interpretation/etc.?

Yes we can simplify this further by moving the invocation out of the template and making the template simpler.
