xquery version "3.1";

import module namespace repair="http://exist-db.org/xquery/repo/repair" at "resource:org/exist/xquery/modules/expathrepo/repair.xql";

repair:clean-all(),
repair:repair()
