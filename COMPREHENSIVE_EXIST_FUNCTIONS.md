# Comprehensive Analysis: eXist-db Specific Functions in the Repository

## Executive Summary

After a thorough analysis of the entire `modules/` directory, the following eXist-db specific function namespaces were found:

1. **xmldb:** - Database/collection management functions
2. **util:** - Utility functions (expand, log, binary operations, etc.)
3. **console:** - Console logging functions
4. **file:** - File system operations
5. **sm:** - Security manager functions (permissions, ownership)
6. **exist:** - eXist-db specific options and parameters

## Current Status

### ✅ Already Fixed (factory/works/ modules)
The following modules in `modules/factory/works/` have been cleaned of eXist-db specific functions:
- txt.xqm
- html.xqm
- index.xqm
- crumb.xqm
- iiif.xqm
- stats.xqm
- nlp.xqm

**Functions removed:**
- `util:expand()` → Direct node usage
- `console:log()` → `fn:trace()`
- `util:log()` → `fn:trace()`
- `exist:timeout` and `exist:output-size-limit` options removed

### ❌ Still Using eXist-db Functions (other modules)

The following modules still use eXist-db specific functions:

#### 1. modules/admin.xqm
**Functions used:**
- `xmldb:last-modified()` - ~40 occurrences
- `xmldb:get-child-resources()` - ~20 occurrences
- `xmldb:collection-available()` - ~10 occurrences
- `console:log()` - Multiple occurrences
- `exist:timeout` and `exist:output-size-limit` options

**Purpose:** Administrative functions for checking if webdata resources need regeneration

#### 2. modules/iiif.xqm
**Functions used:**
- `util:binary-doc()`, `util:binary-doc-available()`
- `util:binary-to-string()`
- `console:log()`

**Purpose:** IIIF manifest generation

#### 3. modules/net.xqm
**Functions used:**
- `util:declare-option()`
- `console:log()`

**Purpose:** Network/HTTP response handling

#### 4. modules/sphinx.xqm
**Functions used:**
- `util:binary-doc()`
- `util:binary-to-string()`
- `util:system-time()`
- `console:log()`

**Purpose:** Sphinx search integration

#### 5. modules/app.xqm
**Functions used:**
- `console:log()`
- `exist:stop-on-warn`, `exist:stop-on-error` parameters (in XSLT transform params)

**Purpose:** Application logic and XSLT transformations

#### 6. modules/config.xqm
**Functions used:**
- `console:log()`

**Purpose:** Configuration management

#### 7. modules/export.xqm
**Functions used:**
- `console:log()`
- `file:serialize()`, `file:serialize-binary()`
- `file:exists()`, `file:delete()`, `file:mkdirs()`
- `file:directory-list()`, `file:is-directory()`, `file:is-writeable()`
- `xmldb:store()`, `xmldb:remove()`, `xmldb:create-collection()`
- `sm:*` functions (chmod, chown, chgrp, set-umask, id, username, real)
- `util:binary-doc-available()`, `util:collection-name()`

**Purpose:** Data export and file system operations

#### 8. modules/gui.xqm
**Functions used:**
- `console:log()`

**Purpose:** GUI/interface functions

#### 9. modules/sutil.xqm
**Functions used:**
- `console:log()`
- `util:expand()`
- `util:copy()`, `util:deep-copy()`
- `util:strip-diacritics()`
- `util:convert()`
- `util:normalize()`
- `util:base()`
- `util:format()`
- `xmldb:size()`
- `file:file()`

**Purpose:** Shared utility functions

## Detailed Function Categories

### 1. Database Operations (xmldb:)
These functions interact with the eXist-db database:

- `xmldb:last-modified()` - Get modification timestamp of resources
- `xmldb:get-child-resources()` - List resources in a collection
- `xmldb:collection-available()` - Check if collection exists
- `xmldb:store()` - Store a resource in the database
- `xmldb:remove()` - Remove a resource from the database
- `xmldb:create-collection()` - Create a new collection
- `xmldb:size()` - Get size of a resource

**Portability:** These have no standard equivalents. Alternatives depend on the target processor:
- BaseX: Use `db:` functions
- Saxon: Not applicable (file-based)
- Standard approach: Abstract into a persistence layer

### 2. File System Operations (file:)
These functions interact with the file system:

- `file:exists()`, `file:delete()`, `file:mkdirs()`
- `file:serialize()`, `file:serialize-binary()`
- `file:directory-list()`, `file:is-directory()`, `file:is-writeable()`

**Portability:** 
- EXPath File Module standard: http://expath.org/spec/file
- Most XQuery processors support the EXPath file module
- ✅ These are actually **EXPath standard functions** and are portable!

### 3. Security/Permissions (sm:)
These functions manage permissions and ownership:

- `sm:chmod()`, `sm:chown()`, `sm:chgrp()`
- `sm:set-umask()`, `sm:id()`, `sm:username()`, `sm:real()`

**Portability:** No standard equivalents. These are eXist-db specific security features.

### 4. Utility Functions (util:)
Various utility functions:

- `util:expand()` - Resolve XIncludes (already removed from factory/works)
- `util:log()` - Logging (already replaced with trace())
- `util:binary-doc()`, `util:binary-doc-available()` - Binary resource access
- `util:binary-to-string()` - Convert binary to string
- `util:copy()`, `util:deep-copy()` - Node copying
- `util:strip-diacritics()` - Text normalization
- `util:convert()`, `util:normalize()` - Text conversion
- `util:base()` - Base URI resolution
- `util:format()` - String formatting
- `util:system-time()` - Get system time
- `util:declare-option()` - Declare options dynamically

**Portability:** Most have standard or alternative approaches

### 5. Logging (console:)
- `console:log()` - Console logging

**Portability:** Replace with `fn:trace()` (already done in factory/works)

### 6. eXist Options (exist:)
- `exist:timeout`, `exist:output-size-limit` - Processor options
- `exist:stop-on-warn`, `exist:stop-on-error` - XSLT parameters

**Portability:** Configure at processor level

## Recommendations

### Priority 1: Modules in factory/works (✅ DONE)
Already completed in the previous commits.

### Priority 2: Core utility modules
**modules/sutil.xqm** should be refactored to remove eXist-db dependencies since it's used by many other modules.

### Priority 3: Admin/operational modules
**modules/admin.xqm** uses many `xmldb:` functions for checking file timestamps and existence. These would need:
- Abstraction layer for database operations
- Or acceptance that admin functionality is eXist-db specific

### Priority 4: Integration modules
Modules like **export.xqm** that use file system and security functions could:
- Use EXPath file module (already standard)
- Abstract security operations if needed

## Standard Alternatives

| eXist-db Function | Standard Alternative | Notes |
|-------------------|---------------------|-------|
| `console:log()` | `fn:trace()` | ✅ Already replaced in factory/works |
| `util:log()` | `fn:trace()` | ✅ Already replaced in factory/works |
| `util:expand()` | Direct node usage | ✅ Already replaced in factory/works |
| `file:*` | EXPath File Module | ✅ Already portable (EXPath standard) |
| `xmldb:*` | Processor-specific DB functions | ❌ Needs abstraction layer |
| `sm:*` | OS-level permissions | ❌ eXist-db specific |
| `util:binary-doc*()` | `fn:unparsed-text-available()` + custom | Partial alternative |
| `util:system-time()` | `fn:current-dateTime()` | Standard equivalent |
| `util:copy()` | XQuery 3.0 node construction | Standard approach |

## Conclusion

The **factory/works/** transformation modules are now fully portable. The remaining eXist-db dependencies are primarily in:

1. **Administrative modules** (admin.xqm) - Database metadata operations
2. **Utility modules** (sutil.xqm) - Shared utility functions
3. **Integration modules** (export.xqm, sphinx.xqm, iiif.xqm) - File and HTTP operations

The file system operations (`file:*`) are actually **EXPath standard** and thus portable across processors that support the EXPath file module.
