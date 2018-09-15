# LMMS-zyn-fusion test

## What's this?

This is a test repository for testing LMMS together with the new zyn-fusion,
using a new plugin technique. It's not official.

## What does work, what doesn't?

What should work:

- drag-drop instruments over songs
- drag-drop xmz files over songs
- play zyn from LMMS
- open/use the UI
- drag-drop zyn widgets

What still needs to be done:

- make removing connections more easy
- use LMMS controllers for zyn widgets
- loading/saving has a waiting time of 1 second
- reviews for
  * the spa concept in general
  * the LMMS implementation
  * the zyn implementation

## Precautions

* As with every experimental audio projects, start with low volume to avoid
  damaging your ears/speakers
* The saved files can currently not be loaded with LMMS' master and maybe they
  never will

## How to get it running?

There are two ways.
In both cases, you should not need any admin privileges.
Your system root and your LMMS config will not be touched.

### Automized install by making fresh clones

This is suited if you have enough bandwidth and disk space and don't plan
to work on the sources.

Starting in this (the README's) directory, do

```sh
./build.sh
./run
```

If build.sh fails, you can fix it in the script and re-run the script. Please
make a PR if you have fixed something.

### Install by re-using your current git-worktrees

If you have worktrees of e.g. LMMS or zyn and want to re-use them, this repo
is purely informative. Don't use the submodules here. Instead, you should
check out the following (use `git clone -b <branchname>`):

- spa
  * Remote: https://gitlab.com/simple-plugin-api/spa.git
  * Branch: master
- mruby-zest-build
  * Remote: git@github.com:mruby-zest/mruby-zest-build.git
  * Branch: master
- zynaddsubfx
  * Remote: git@github.com:zynaddsubfx/zynaddsubfx.git
  * Branch: osc-plugin
- LMMS
  * Remote: git@github.com:JohannesLorenz/lmms.git
  * Branch: osc-plugin

Make sure to run `git submodule update --init --recursive` in all four repos
(not in this repo). The `--depth 100` option can speed things up if you don't
need the submodule histories.

Then, go into this repo (the main repo) and type `git submodule status`.
Go to each of the four repos and check out the corresponding commits.

#### Compile + Install

Please keep the order as below

- spa
  * Follow README instructions for a normal install
  * Write down the PKG config file's directory for later. It's found in your
    install folder, subdirectories lib64/pkgconfig or lib/pkgconfig. The file
    contains a `spa.c` file.
    Example: `~/cprogs/spa/install/lib64/pkgconfig`
- mruby-zest-build
  * Compile like in the README
  * Run `make pack`
- zynaddsubfx
  * Do a build like in the README, but prepend
    `PKG_CONFIG_PATH=$PKG_CONFIG_PATH:<spa pkg config directory, see above>`
    to the cmake command and add the following cmake variables:
    - `-DZynFusionDir=<path to where fusion is>/package`
    - `-DGuiModule=zest`
  * At that stage, starting zyn (./src/zynaddsfubx from the build dir)
    should already work and start up zyn-fusion.
  * Write down the path of the newly built spa plugin, which is usually
    `src/Output/libzynaddsubfx_spa.so`
- LMMS
  * Do a build like in the README, but prepend
    `PKG_CONFIG_PATH=$PKG_CONFIG_PATH:<spa pkg config directory, see above>`
    to the cmake command. An install *should* not be required.
  * Start LMMS, go to `Edit->Settings` and remember the working directory
  * Make a symlink from that working directory to zyn's spa library, e.g.
    `ln -s <spa library, see above> <working-directory>/zynaddsfubx-spa.so`
  * At that stage, LMMS should be startable, and on the plugins menu you
    should see a zyn plugin with the new zest logo

## Reporting issues

* Issues from LMMS, zyn and fusion can go to the issue tracker of this project,
  if they are plugin related.
* Issues considering the spa library itself (e.g. design issues) should go
  preferably to the
  [spa issue tracker](https://gitlab.com/simple-plugin-api/spa/issues)
  or to the
  [spa mirror's issue tracker](https://github.com/JohannesLorenz/spa/issues)
