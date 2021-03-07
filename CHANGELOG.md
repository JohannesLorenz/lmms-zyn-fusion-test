# CHANGELOG

If your old use cases/savefiles does not work anymore, please look here first.

## 0.2.0 (2021-03-07)

* `LMMS_PLUGIN_DIR` is now `SPA_PATH`
* Savefiles must be patched now (sorry!). The name `attribute` of the plugin
  keys changed. Please fix your mmp files (let me know how you did it, then I
  can provide a regular expression). It now looks like:
```
<attribute name="plugin" value="github.com::zynaddsubfx::osc-plugin::ZASF"/>
```

