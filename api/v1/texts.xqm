xquery version "3.0" encoding "UTF-8";

module namespace textsv1 = "http://api.salamanca.school/v1/texts";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";

import module namespace rest = "http://exquery.org/ns/restxq";


declare
%rest:GET
%rest:path("/v1/texts")
%output:method("xml")
function textsv1:TEIgetCorpus() {

  <result>
    <content>Hello Corpus</content>
  </result>
         
};

(:declare
%rest:GET
%rest:path("/v1/texts/W0034:1.1")
%output:method("xml")
function textsv1:TEIgetW003411() {

  <result>
    <content>Hello W0034:1.1</content>
  </result>
         
};:)

declare
%rest:GET
%rest:path("/v1/texts/{$rid}")
%output:method("xml")
function textsv1:TEIgetW0034($rid) {

  <result>
    <content>Hello {$rid}</content>
  </result>
         
};

(:declare
%rest:GET
%rest:path("/v1/authors")
%output:method("xml")
function textsv1:TEIgetAuthors() {

  <result>
    <content>Hello Authors</content>
  </result>
         
};:)

(:
declare
%rest:GET
%rest:path("/v1/texts/{rid}")
%output:method("xml")
function textsv1:TEIgetDoc($rid) {

  <result>
    <content>Hello Doc "{$rid}"</content>
  </result>
         
};:)
