load("@bazel_skylib//lib:paths.bzl", "paths")

def _impl(ctx):
    arguments = ["--cpp"]

    # header output dir
    header_output_path = ctx.label.name + "_gen" + "/lcmtypes"
    header_output_dir = ctx.actions.declare_directory(header_output_path)
    arguments.extend(["--cpp-hpath", header_output_dir.path])
    arguments.extend(["--cpp-include", "lcmtypes"])

    files = ctx.attr.src[DefaultInfo].files.to_list()
    for file in files:
        #print(file.path)
        arguments.append(file.path)# the lcm file

    #arguments.extend(["--verbose"])
    #arguments.extend(["--print-def"])

    ctx.actions.run(
        inputs = [ctx.file.src],
        outputs = [header_output_dir],
        mnemonic = "LcmCompile",
        progress_message = "generating lcm types...",
        arguments = arguments,
        executable = ctx.executable._compiler,
    )

    # ideally we split this into headers and cc
    compilation_context = cc_common.create_compilation_context(
        headers = depset([header_output_dir]),
        includes = depset([header_output_dir.path,
                           header_output_dir.path.replace("/lcmtypes", "")]),
    )
    return [
            DefaultInfo(files = depset([header_output_dir])),
            CcInfo(
                compilation_context = compilation_context,
            )
    ]

_lcmgen = rule(
    attrs = {
        "src": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "_compiler": attr.label(
            executable = True,
            cfg = "exec",
            default = Label("@rules_symforce//symforce_tools:lcmgen"),
        ),
    },
    implementation = _impl,
)

def cc_lcm_library(name,
                   src,
                   deps = []):
    _lcmgen(
        name = name,
        src = src,
    )

def _py_lcm_impl(ctx):
    arguments = ["--python"]

    # Python output dir - structure is {name}_gen/lcmtypes/{package}/*.py
    # The symforce code imports from lcmtypes.sym, so we generate into lcmtypes/ subdir
    python_output_path = ctx.label.name + "_gen/lcmtypes"
    python_output_dir = ctx.actions.declare_directory(python_output_path)
    arguments.extend(["--python-path", python_output_dir.path])
    arguments.append("--python-namespace-packages")

    # Collect all input files from srcs
    input_files = []
    for src in ctx.attr.srcs:
        input_files.extend(src[DefaultInfo].files.to_list())
    for file in input_files:
        arguments.append(file.path)

    ctx.actions.run(
        inputs = input_files,
        outputs = [python_output_dir],
        mnemonic = "LcmPythonCompile",
        progress_message = "generating python lcm types...",
        arguments = arguments,
        executable = ctx.executable._compiler,
    )

    # The imports path needs to work for two import patterns:
    # 1. External imports: "from lcmtypes.sym._foo import foo" - needs {gen_dir}/ in path
    # 2. Internal imports: "from sym._bar import bar" - needs {gen_dir}/lcmtypes/ in path
    #
    # For external repos: short_path is "../symforce_repo+/symforce_lcm_py_gen/lcmtypes"
    # For main repo: short_path is "symforce_lcm_py_gen/lcmtypes"
    short_path = python_output_dir.short_path
    if short_path.startswith("../"):
        # External repo - path looks like "../symforce_repo+/symforce_lcm_py_gen/lcmtypes"
        parts = short_path.split("/")
        # Skip ".." parts
        non_dotdot_idx = 0
        for i, p in enumerate(parts):
            if p != "..":
                non_dotdot_idx = i
                break
        # Join remaining parts except the last one (lcmtypes)
        gen_dir_path = "/".join(parts[non_dotdot_idx:-1])
        lcmtypes_dir_path = "/".join(parts[non_dotdot_idx:])
    else:
        # Main repo - path is relative
        gen_dir_path = paths.dirname(short_path)
        lcmtypes_dir_path = short_path
    return [
        DefaultInfo(files = depset([python_output_dir])),
        PyInfo(
            transitive_sources = depset([python_output_dir]),
            imports = depset([gen_dir_path, lcmtypes_dir_path]),
        ),
    ]

_py_lcmgen = rule(
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".lcm"],
            mandatory = True,
        ),
        "_compiler": attr.label(
            executable = True,
            cfg = "exec",
            default = Label("@rules_symforce//symforce_tools:lcmgen"),
        ),
    },
    implementation = _py_lcm_impl,
)

def py_lcm_library(name, srcs, deps = []):
    _py_lcmgen(
        name = name,
        srcs = srcs,
    )
