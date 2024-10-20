"""Generate a file using a template.
"""

def symengine_config(**kwargs):
    _symengine_config(
        **kwargs
    )

def _symengine_config_impl(ctx):
    ctx.actions.expand_template(
        template = ctx.file.template,
        output = ctx.outputs.output,
        substitutions = {
            "${SYMENGINE_MAJOR_VERSION}": "0",
            "${SYMENGINE_MINOR_VERSION}": "7",
            "${SYMENGINE_PATCH_VERSION}": "0",
            "${SYMENGINE_VERSION}": "0.7.0",
            "#include <symengine/symengine_export.h>": "",
            "#cmakedefine WITH_SYMENGINE_ASSERT": "",
            "#cmakedefine HAVE_SYMENGINE_GMP": "#define HAVE_SYMENGINE_GMP",
            "#cmakedefine WITH_SYMENGINE_RCP": "#define WITH_SYMENGINE_RCP",
            "#cmakedefine WITH_SYMENGINE_TEUCHOS": "",
            "#cmakedefine WITH_SYMENGINE_THREAD_SAFE": "",
            "#cmakedefine HAVE_SYMENGINE_ECM": "",
            "#cmakedefine HAVE_SYMENGINE_PRIMESIEVE": "",
            "#cmakedefine WITH_SYMENGINE_VIRTUAL_TYPEID": "",
            "#cmakedefine HAVE_SYMENGINE_FLINT": "",
            "#cmakedefine HAVE_SYMENGINE_ARB": "",
            "#cmakedefine HAVE_SYMENGINE_MPFR": "",
            "#cmakedefine HAVE_SYMENGINE_PIRANHA": "",
            "#cmakedefine HAVE_SYMENGINE_BOOST": "",
            "#cmakedefine HAVE_SYMENGINE_PTHREAD": "",
            "#cmakedefine HAVE_SYMENGINE_MPC": "",
            "#cmakedefine HAVE_SYMENGINE_LLVM": "",
            "#cmakedefine HAVE_C_FUNCTION_NOT_FUNC": "",
            "#cmakedefine HAVE_DEFAULT_CONSTRUCTORS": "#define HAVE_DEFAULT_CONSTRUCTORS",
            "#cmakedefine HAVE_SYMENGINE_RESERVE": "#define HAVE_SYMENGINE_RESERVE",
            "#cmakedefine HAVE_SYMENGINE_STD_TO_STRING": "#define HAVE_SYMENGINE_STD_TO_STRING",
            "#cmakedefine HAVE_SYMENGINE_NOEXCEPT": "#define HAVE_SYMENGINE_NOEXCEPT",
            "#cmakedefine HAVE_SYMENGINE_IS_CONSTRUCTIBLE": "#define HAVE_SYMENGINE_IS_CONSTRUCTIBLE",
            "SYMENGINE_${SYMENGINE_INTEGER_CLASS}": "SYMENGINE_GMP",
            "${SYMENGINE_SIZEOF_LONG_DOUBLE}": "16",
        },
    )

_symengine_config = rule(
    implementation = _symengine_config_impl,
    attrs = {
        "template": attr.label(
            default = "symengine/symengine_config.h.in",
            allow_single_file = True,
        ),
        "output": attr.output(mandatory = True),
    },
)

def symenginepy_config(**kwargs):
    _symenginepy_config(
        **kwargs
    )

def _symenginepy_impl(ctx):
    ctx.actions.expand_template(
        template = ctx.file.template,
        output = ctx.outputs.output,
        substitutions = {
            "${HAVE_SYMENGINE_MPFR}" : "False",
            "${HAVE_SYMENGINE_MPC}" : "False",
            "${HAVE_SYMENGINE_PIRANHA}" : "False",
            "${HAVE_SYMENGINE_FLINT}" : "False",
            "${HAVE_SYMENGINE_LLVM}" : "False",
            "${HAVE_SYMENGINE_LLVM_LONG_DOUBLE}" : "False",
        },
    )

_symenginepy_config = rule(
    implementation = _symenginepy_impl,
    attrs = {
        "template": attr.label(
            default = "symengine/lib/config.pxi.in",
            allow_single_file = True,
        ),
        "output": attr.output(mandatory = True),
    },
)

def symengine_test(name,
                group="basic"):
        native.cc_test(
                name = name,
                srcs = ["symengine/tests/" + group + "/" + name + ".cpp"],
                deps = [
                        ":symengine",
                        ":catch",
                ],
                linkstatic = True,
        )


def benchmark(name, hdrs = [], srcs = []):
    return native.cc_test(
        name = name,
        srcs = ["benchmarks/"+name+".cpp"],
        deps = [":symengine",":bench_lib"],
        linkstatic = True,
        tags = ["benchmark","manual"],

    )




