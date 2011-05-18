import Options
from os import unlink, symlink, system
from os.path import exists, abspath

srcdir = "."
blddir = "build"
VERSION = "0.0.1"

def set_options(opt):
  opt.tool_options("compiler_cxx")

def configure(conf):
  conf.check_tool("compiler_cxx")
  conf.check_tool("node_addon")
  conf.check(lib='sqlite3', libpath=['/lib', '/usr/lib', '/usr/local/lib', '/usr/local/sqlite/lib', '/usr/local/pkg/sqlite-3.7.2/lib'])

  conf.env.append_value("LIBPATH_MPOOL", abspath("./deps/mpool-2.1.0/"))
  conf.env.append_value("LIB_MPOOL",     "mpool")
  conf.env.append_value("CPPPATH_MPOOL", abspath("./deps/mpool-2.1.0/"))


def build(bld):
  system("cd deps/mpool-2.1.0/; make");
  obj = bld.new_task_gen("cxx", "shlib", "node_addon")
  obj.cxxflags = ["-g", "-D_FILE_OFFSET_BITS=64", "-D_LARGEFILE_SOURCE", "-Wall"]
  obj.target = "sqlite3_bindings"
  obj.source = "src/sqlite3_bindings.cc src/database.cc src/statement.cc"
  obj.uselib = "SQLITE3 PROFILER MPOOL"

t = 'sqlite3_bindings.node'
def shutdown():
  # HACK to get binding.node out of build directory.
  # better way to do this?
  if Options.commands['clean']:
    if exists(t): unlink(t)
    system("cd deps/mpool-2.1.0/; make clean");
  else:
    if exists('build/default/' + t) and not exists(t):
      symlink('build/default/' + t, t)

