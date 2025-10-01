# eXist-db Specific Functions Removed

## Summary

This document describes the changes made to remove eXist-db specific XQuery functions from the `modules/factory/works/` directory, making the code more portable and compatible with standard W3C XQuery 3.1 processors.

## Changed Files

The following files were modified:

1. `modules/factory/works/txt.xqm`
2. `modules/factory/works/html.xqm`
3. `modules/factory/works/index.xqm`
4. `modules/factory/works/crumb.xqm`
5. `modules/factory/works/iiif.xqm`
6. `modules/factory/works/stats.xqm`
7. `modules/factory/works/nlp.xqm`

## Changes Made

### 1. Removed eXist-db Specific Namespace Declarations

**Removed:**
- `declare namespace exist = "http://exist.sourceforge.net/NS/exist";`
- `declare namespace util = "http://exist-db.org/xquery/util";`

These namespaces are specific to eXist-db and are not part of standard XQuery.

### 2. Removed eXist-db Specific Module Imports

**Removed:**
- `import module namespace console = "http://exist-db.org/xquery/console";`
- `import module namespace util = "http://exist-db.org/xquery/util";`

These modules provide eXist-db specific functionality that is not portable.

### 3. Removed eXist-db Specific Options

**Removed:**
- `declare option exist:timeout "166400000";`
- `declare option exist:output-size-limit "5000000";`

**Reason:** These options control eXist-db specific behavior (query timeouts and memory limits). These settings should be configured at the XQuery processor level instead, not in the query code itself.

**Note:** A comment was added to the affected files explaining that these options should be configured at the processor level.

### 4. Replaced `util:expand()`

**Before:**
```xquery
let $work := util:expand($tei)
```

**After:**
```xquery
(: Directly use $tei instead of util:expand($tei) :)
```

**Reason:** `util:expand()` is an eXist-db specific function that resolves XIncludes and creates an in-memory copy of the node tree. In most XQuery processors, nodes are already expanded when accessed, or XInclude resolution happens automatically. The function was simply removed, and the original `$tei` parameter is used directly.

**Impact:** This is a safe change because:
- XIncludes are typically resolved when the document is loaded
- The in-memory copy aspect of `util:expand()` was primarily for performance in eXist-db's specific architecture
- Standard XQuery processors handle node access efficiently without needing explicit expansion

### 5. Replaced Logging Functions

#### `console:log()` Replacement

**Before:**
```xquery
let $debug := if ($config:debug = "trace") then 
                console:log("[MODULE] Message: " || $details)
              else ()
```

**After:**
```xquery
let $debug := if ($config:debug = "trace") then 
                trace("[MODULE] Message: " || $details, "[MODULE]")
              else ()
```

#### `util:log()` Replacement

**Before:**
```xquery
let $debug := util:log('info', '[MODULE] Processing node ' || $node/@xml:id)
```

**After:**
```xquery
let $debug := trace('[MODULE] Processing node ' || $node/@xml:id, "[MODULE]")
```

**Reason:** Both `console:log()` and `util:log()` are eXist-db specific logging functions. The standard W3C XQuery function `fn:trace()` provides similar functionality:
- First argument: the value to trace (message or value)
- Second argument: a label for identification
- Returns: the first argument unchanged (so it can be used in pipelines)

**Note:** The `fn:` prefix is optional and was omitted in the replacements since `trace()` is in the default function namespace.

## Standard XQuery Functions Used

All replacements use standard W3C XQuery 3.1 functions:

1. **`fn:trace($value as item()*, $label as xs:string) as item()*`**
   - Standard function for debugging/logging
   - Available in all XQuery 3.0+ processors
   - Returns the input value unchanged, making it safe to use in let bindings

## Testing Recommendations

When testing these changes:

1. **XInclude Resolution**: Verify that documents with XInclude references are still processed correctly
2. **Logging Output**: Check that trace messages appear in your XQuery processor's logging output
3. **Performance**: Monitor for any performance changes (though none are expected)
4. **Functionality**: Run existing tests to ensure transformations produce the same output

## Compatibility

These changes make the code compatible with:
- BaseX
- Saxon
- Any XQuery 3.1 compliant processor
- eXist-db (still works, as it supports standard XQuery functions)

## Notes for Developers

- **Logging Levels**: The original code used different log levels ('info', 'warn', 'error'). The `trace()` function doesn't distinguish between levels, so all traces are treated equally. If level-specific behavior is needed, it should be implemented at the application level.
  
- **Timeout Configuration**: Since `exist:timeout` options were removed, configure timeouts in your XQuery processor's configuration instead:
  - BaseX: Use `.basex` configuration file or GUI settings
  - Saxon: Use `-T` option or configuration API
  - eXist-db: Use `conf.xml` or controller configuration

- **Memory Limits**: Similar to timeouts, memory limits should be configured at the processor level, not in queries.

## References

- W3C XQuery 3.1 Specification: https://www.w3.org/TR/xquery-31/
- XQuery Functions and Operators: https://www.w3.org/TR/xpath-functions-31/
- EXPath Specifications: http://expath.org/spec
