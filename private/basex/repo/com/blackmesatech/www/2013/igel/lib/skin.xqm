(: skin.xq:  handle our HTML representation of things :)

(: 

   Copyright (c) 2013, Black Mesa Technologies, LLC

   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

   Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

   Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the
   distribution.

   Neither the name of Black Mesa Technologies, LLC, nor the names of
   contributors to the Igel project may be used to endorse or promote
   products derived from this software without specific prior written
   permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
   FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
   COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
   INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
   STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
   OF THE POSSIBILITY OF SUCH DAMAGE.

:)

module namespace skin = 'http://www.blackmesatech.com/2013/igel/lib/skin';

(: We depend on the BaseX XSLT module, and on stylesheet decls_to_html.xsl :)
import module namespace xslt="http://basex.org/modules/xslt";

(: Miscellaneous HTML generation routines for standard page furniture. :)

declare namespace rest = 'http://www.blackmesatech.com/2013/igel/lib/rest';
declare variable $skin:version-number as xs:string := '0.63';
declare variable $skin:collection as xs:QName := xs:QName("rest:grammars");
declare variable $skin:decls-to-html as xs:string := 
  "/opt/igel/private/basex/webapp/decls_to_html.xsl";

declare function skin:default-metadata($title as xs:string) 
                                as element()* {
      <title>{concat('Igel v', $skin:version-number, ':  ', $title)}</title>,
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />,
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />,
      <link href="lib/bootstrap/css/bootstrap.min.css" rel="stylesheet"></link>,
      <link href="lib/bootstrap/css/bootstrap-responsive.css" rel="stylesheet"></link>,
      <link href="lib/css/main.css" rel="stylesheet"></link>
};

declare function skin:navbar(
	$dtdkeys as xs:string*
	) as element()* {
      <div class="navbar navbar-fixed-top">
        <div class="navbar-inner">
          <!--*
          <a class="brand" id="title" href="#">Document Grammar Comparator</a>
          *-->
          <div style="padding-left: 0.25in;">
          <a class="nav" href="{skin:pageuri('home',$dtdkeys)}">Home</a>
          <a class="nav" href="{skin:pageuri('grammarlist',$dtdkeys)}">Grammars</a>
          <a class="nav" href="{skin:pageuri('elements',$dtdkeys)}">Elements</a>
          <a class="nav" href="{skin:pageuri('attributes',$dtdkeys)}">Attributes</a>
          <a class="nav" href="{skin:pageuri('notations',$dtdkeys)}">Notations</a>
          <a class="nav" href="{skin:pageuri('pes',$dtdkeys)}">Parameter entities</a>
          <!--* If we can, make this depend on whether the user is logged in or not. *-->
          <a class="nav" style="float:right;" href="admin.html">Admin</a>
          </div>
        </div>
      </div>
};

declare function skin:pagehead(
  $head as item()*,
  $dtdkeys as xs:string*
) {
        <div class="page-header">          
          <h1 id="page-h1"><a href="{skin:pageuri('home', $dtdkeys)}"><img id="mascot" src="lib/images/ClausRebler.320x213.jpg" alt="A young hedgehog"/></a>{$head}</h1>
          <!--*
          <div style="font-size: 70%; width: 320px; line-height: 1em; text-align: right;"><a 
            href="http://www.flickr.com/photos/zunami/2038774508/in/photostream/">Hedgehog</a>
            &#169;&#160;2007
            <a href="http://www.flickr.com/people/zunami/">Claus Rebler</a>,
            used <a href="http://creativecommons.org/licenses/by-sa/2.0/">by permission</a>.</div>
        *-->
        </div>
};

declare function skin:footer() as element()* {
  <div class="feedback-invite">
    Got ideas for improvements?  Things you&#x2019;d like to be able to do from this page?
    <a href="mailto:cmsmcq+igel@blackmesatech.com">Write us!</a>
  </div>,
  skin:acks()
};

declare function skin:acks() as element()* {
      <div class="modal-footer" style="font-size: 80%; margin-top: 2em;">
        <div>
          <a href="http://www.flickr.com/photos/zunami/2038774508/in/photostream/">Hedgehog</a>
            &#169;&#160;2007
            by <a href="http://www.flickr.com/people/zunami/">Claus Rebler</a>,
            used by permission
            (<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC BY-SA 2.0</a>).
        </div>
        <div>Igel was developed by <a href="http://blackmesatech.com/">Black Mesa Technologies, LLC</a></div>
        <div>
          (This version of) Igel uses the
          XQuery engine <a href="http://basex.org/">BaseX</a>.
          Development of Igel supported by 
          <a href="http://www.ids-mannheim.de/">Institut für Deutsche Sprache</a>, Mannheim.
        </div>
      </div>
};

declare function skin:list-active-grammars(
	$dtdkeys as xs:string*
	) as element()* {
  if (not(empty($dtdkeys))) then
     (<p>Document grammars currently active:
         {  for $dtdkey in $dtdkeys
            return <span class="dtdkey">{$dtdkey}&#xA0;</span>
         }
     </p>)
  else <p><em>No document grammars currently active.</em>
    To select grammars, go to the <a href="bop.php?req=page&amp;page=grammarlist">Document Grammars</a>
    page.</p>
};

declare function skin:select-active-grammars(
	$page as xs:string,
	$dtdkeys as xs:string*
	) as element()* {

       <form class="well" method="get" action="{$page}">
         <label>Select the DTDs you want to work with:</label>
         { for $dtd in collection($skin:collection)
           return (element input {
                      attribute value {$dtd/@key},
                      attribute type { "checkbox" },
                      attribute name { "dtdkey" },
                      if (string($dtd/@key) = $dtdkeys) then 
                         attribute checked { "checked" }
                      else ()
                   },
                   element label {
                      attribute class { "runin" },
                      $dtd/@key/string()
                   }
                   )
           }
         <input type="submit" class="btn btn-primary" value="Go" /> 
       </form>
};

(: pageuri($page, $dtds):  return a bop.php-based page uri :)
declare function skin:pageuri(
	$page as xs:string,
	$dtdkeys as xs:string*
	) as xs:string {
  concat('bop.php?req=page&amp;page=', 
         $page,
         '&amp;',
         string-join(
            for $dtdkey in $dtdkeys
            return concat('dtdkey[]=', $dtdkey),
            '&amp;' ) )
};

declare function skin:pageuri(
	$page as xs:string, 
	$parms as xs:string,
	$dtdkeys as xs:string*
	) as xs:string {
  concat('bop.php?req=page&amp;page=', 
         $page, 
         '&amp;',
         $parms,
         if ($parms) then '&amp;' else '',
         string-join(
            for $dtdkey in $dtdkeys
            return concat('dtdkey[]=', $dtdkey),
            '&amp;' ) )
};

declare function skin:uri(
	$base as xs:string,
	$dtdkeys as xs:string*
	) as xs:string {
  concat($base, 
         '?', 
         string-join(
            for $dtdkey in $dtdkeys
            return concat('dtdkey[]=', $dtdkey),
            '&amp;' ) )
};


declare function skin:uri(
	$base as xs:string, 
	$parms as xs:string,
	$dtdkeys as xs:string*
	) as xs:string {
  concat($base, 
         '?', 
         $parms,
         if ($parms) then '&amp;' else '',
         string-join(
            for $dtdkey in $dtdkeys
            return concat('dtdkey[]=', $dtdkey),
            '&amp;' ) )
};

declare function skin:grammarlist-known-dtd(
	$key as xs:string,
	$uri as xs:string,
	$label as xs:string,
	$dtdkeys as xs:string*
	) as element() {
  <a class="btn" 
     href="{ skin:uri('grammarlist', 
                      concat('newkey=',$key,'&amp;newloc=', $uri),
	 	      $dtdkeys) }"
     >{ $label }
  </a>
};

declare function skin:pack-gi-v0(
  $gi as xs:string,
  $dtdkeys as xs:string*
) as item() {
  <a href="{skin:pageuri('decls',
                         concat('construct=element',
                                '&amp;',
                                'cname=',
                                $gi),
                         $dtdkeys) }"
    ><code class="gi">{$gi}</code></a>
};

declare function skin:pack-gi(
  $gi as xs:string,
  $dtdkeys as xs:string*
) as item() {
  skin:pack-generic($gi,'element','gi',$dtdkeys)
};

declare function skin:pack-attname(
  $an as xs:string,
  $dtdkeys as xs:string*
) as item() {
  skin:pack-generic($an,'attribute','attname',$dtdkeys)
};

declare function skin:pack-notnname(
  $name as xs:string,
  $dtdkeys as xs:string*
) as item() {
  skin:pack-generic($name,'notation','notnname',$dtdkeys)
};

declare function skin:pack-pename(
  $gi as xs:string,
  $dtdkeys as xs:string*
) as item() {
  skin:pack-generic($gi,'pe','pename',$dtdkeys)
};


declare function skin:pack-generic(
  $name as xs:string,
  $construct as xs:string,
  $class as xs:string,
  $dtdkeys as xs:string*
) as item() {
  <a href="{skin:pageuri('decls',
                         concat('construct=',
                                $construct,
                                '&amp;',
                                'cname=',
                                $name),
                         $dtdkeys) }"
   ><code class="{$class}">{$name}</code></a>
};

declare function skin:format-decl(
	$decl as item()*
	) as element() {  
  (: this is just a placeholder for now 
  <pre>{$decl}</pre>
  :)
  xslt:transform($decl,$skin:decls-to-html)/*
  (: xslt:transform($doc,$xslt,
        <xslt:parameters>
          <xslt:key value="val"/>
          ...
        </xslt:parameters>)
  :)
};