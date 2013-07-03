(:
 : default.xq : collection of functions to return HTML pages.
 : Based on a template by 28msec Inc., 2010.
 : Rewritten 2013 by Black Mesa Technologies, LLC.
 : 
 : Each function returns the appropriate page of the application:
 : ./index maps to def:index(), ./grammarlist to def:grammarlist(), etc.
 :   
 : Pages are:  index, grammarlist, elements, attributes, notations, pes.
 :)

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


declare namespace def = "http://www.blackmesatech.com/2013/igel/default";

(: REST routines :)
import module namespace rest="http://www.blackmesatech.com/2013/igel/lib/rest";
(: common HTML routines :)
import module namespace skin="http://www.blackmesatech.com/2013/igel/lib/skin";

declare namespace igel = "http://www.blackmesatech.com/2013/igel";

(: Parameters from the user's HTTP request :)
declare variable $page as xs:string external;
declare variable $dtdkeystring as xs:string external;
declare variable $grouping as xs:string external;
declare variable $construct as xs:string external;
declare variable $cname as xs:string external;

declare variable $dtdkeys as xs:string* := tokenize($dtdkeystring,'\s+');

(: Declare a variable for the name of the collection: :)
(: declare variable $def:grammars as xs:QName := xs:QName("rest:grammars"); :)

declare function def:index (
	$dtdkeys as xs:string*
	) as element() {
  (:
  <html><head>Dummy</head><body><h1>Well, we're not dead yet.</h1></body></html>
  :)
  <html>
    <head>
      { skin:default-metadata('Document Grammar Comparator') }
    </head>
    <body>
      { skin:navbar($dtdkeys) }
      <div class="container" id="main">
        { skin:pagehead('Document Grammar Comparator', $dtdkeys) }

       <p>This site is an experimental* tool for examining XML document grammars; at
       the moment it supports only document grammars defined in DTD syntax.  From 
       here you have several options:</p>
       <dl>
       <dt><a href="{skin:pageuri('grammarlist',$dtdkeys)}">Manage grammar list</a></dt>
       <dd>Examine the list of document grammars known to the system; add new ones; 
       delete old ones.  Select certain grammars as <em>active</em>.</dd>
       <dt><a href="{skin:pageuri('elements',$dtdkeys)}">Elements</a></dt>
       <dd>Examine the list of elements defined in the active document grammars.</dd>
       <dt><a href="{skin:pageuri('attributes',$dtdkeys)}">Attributes</a></dt>
       <dd>List the attributes defined in the active document grammars.</dd>       
       <dt><a href="{skin:pageuri('notations',$dtdkeys)}">Notations</a></dt>
       <dd>List the notations defined in the active document grammars.</dd>       
       <dt><a href="{skin:pageuri('pes',$dtdkeys)}">Parameter entities</a></dt>
       <dd>List the parameter entities defined in the active document grammars.</dd>
       
       </dl>
       { skin:list-active-grammars($dtdkeys) }
       <p>* It's "experimental" in that it is currently rather slow, 
       it is not guaranteed to be stable,
       and it may change from hour to hour.</p>
      </div>
      { skin:footer() }
    </body>
  </html>
  
};

declare function def:grammarlist (
	$dtdkeys as xs:string*
	) as element() {

  (: <html><head>Dummy 2</head><body><h1>What's that smell?</h1></body></html> :)

  <html>
    <head>
      { skin:default-metadata('Grammar list') }
    </head>
    <body>
      { skin:navbar($dtdkeys) }
      <div class="container" id="main">
        { skin:pagehead('Document grammar list', $dtdkeys) }
    
        <div>
          <h3>Active document grammars</h3>
         { skin:list-active-grammars($dtdkeys) }
        </div>
       
        <h3>Document grammars known to the system</h3>
       <form class="well" method="get" action="bop.php">
         <input type="hidden" name="req" value="page"/>
         <input type="hidden" name="page" value="grammarlist"/>
         
         { for $dtd in collection($rest:grammars)/*
           return <div class="dtd selectentry">{
                   (element input {
                      attribute value {$dtd/@key},
                      attribute type { "checkbox" },
                      attribute name { "dtdkey[]" },
                      (: the [] is a PHP hack, sorry about that :)
                      if (string($dtd/@key) = $dtdkeys) then
                         attribute checked { "checked" }
                      else () 
                   },
                   element label {
                      attribute class { "runin" },
                      element span { 
                        attribute class { "dtdkey selectlist" },
                        $dtd/@key/string() 
                      },
                      ' ',
                      element span {
                        attribute class { "DTDloc" },
                        $dtd/@loc/string()
                      }
                   }
                   ) 
                 }</div>
           }
         <input style="margin-top: 0.5em;" 
                type="submit" 
                class="btn btn-primary" 
                value="Make selected DTDs active" /> 
       </form>
       
       <!--*
       <hr/>
       
       <h3>Add a DTD</h3>
       <p>N.B. this may take a minute or two.  Be patient ...</p>

       <form class="well" method="get" action="grammarlist">
          <label>URI of the DTD:</label> 
          <input value="http://blackmesatech.com/lib/xslt10.dtd" 
                 type="text"
                 size="70" 
                 style="width: 600px;"
                 name="newloc"/>
          <label>Short name for the DTD (up to 8 characters):</label> 
          <input value="xslt" 
                 type="text"
                 size="8"
                 style="width: 8em;"
                 max-length="8" 
                 name="newkey"/>
          <input type="submit" class="btn btn-primary" value="Add DTD to database" /> 
        </form>
       *-->
       
       <!--* 0.46 *-->
       <!--*
       <form class="well" method="get" action="grammarlist">
          <div class="wellknown">
          <h4>TEI Lite and variations:</h4>
          {
            skin:grammarlist-known-dtd('TEILite-P3','http://www.tei-c.org/Vault/P4/Lite/DTD/teilite.dtd','TEI P3 (SGML) version'),
            skin:grammarlist-known-dtd('TEILite-P4','http://www.tei-c.org/Vault/P4/Lite/DTD/teixlite.dtd','TEI P4 (XML) version'),
            skin:grammarlist-known-dtd('SWeb','http://blackmesatech.com/lib/swebxml.dtd','TEI Lite + SWeb')
          }
          </div>
          <div class="wellknown">
          <h4>Corpus Encoding Standard:</h4>
          {
            skin:grammarlist-known-dtd('XCES-doc', 'http://www.xces.org/dtd/xcesDoc.dtd', 'XCES Doc'),
            skin:grammarlist-known-dtd('XCES-ana', 'http://www.xces.org/dtd/xcesAna.dtd', 'XCES Ana'),
            skin:grammarlist-known-dtd('XCES-align', 'http://www.xces.org/dtd/xcesAlign.dtd', 'XCES Align'),
            skin:grammarlist-known-dtd('IDS-XCES-1','http://corpora.ids-mannheim.de/idsxces1/DTD/ids.xcesdoc.dtd','IDS-XCES')
          }
          </div> *-->
          <!--*
          <div>
          <h4>HTML:</h4>
          <br/>
          {
            skin:grammarlist-known-dtd('HTML4-strict','http://www.w3.org/TR/html4/strict.dtd','HTML 4.01 Strict'),
            skin:grammarlist-known-dtd('HTML4-loose','http://www.w3.org/TR/html4/loose.dtd','HTML 4.01 Loose'),
            skin:grammarlist-known-dtd('SWeb','http://blackmesatech.com/lib/swebxml.dtd','TEI Lite + SWeb')
          }
          </div>
          *-->
          <!--*
          <div class="wellknown">
          <h4>Miscellaneous public DTDs:</h4>
          {
            skin:grammarlist-known-dtd('XSLT','http://blackmesatech.com/lib/xslt10.dtd','XSLT 1.0'),
            skin:grammarlist-known-dtd('8879E-s','http://blackmesatech.com/2012/09/leep/iso8879-annex-e.sgml.dtd','ISO 8879 Annex E (SGML)'),
            skin:grammarlist-known-dtd('8879E-x','http://blackmesatech.com/2012/09/leep/iso8879-annex-e.xml.dtd','ISO 8879 Annex E (XML)'),
            skin:grammarlist-known-dtd('RFC1341','http://blackmesatech.com/2012/09/leep/rfc1341.dtd','RFC 1341 (richtext)'),
            skin:grammarlist-known-dtd('Toy','http://blackmesatech.com/2012/10/leep/simpledoc.dtd','Toy DTD for simple documents')
            
          }
          </div> *-->
          <!--* These are not working, comment them out for now. 
          <div style="margin-top: 0.5em;">
          <h4>NLM Journal Archiving Tag Set (JATS)</h4>
          <span>Version 2.3</span>
          <br/>
          {
          skin:grammarlist-known-dtd('Jats2.3-Arch', 'http://dtd.nlm.nih.gov/archiving/2.3/archivearticle.dtd', 'Archiving'),
          skin:grammarlist-known-dtd('Jats2.3-Publ', 'http://dtd.nlm.nih.gov/publishing/2.3/journalpublishing.dtd','Publishing'),
          skin:grammarlist-known-dtd('Jats2.3-Auth', 'http://dtd.nlm.nih.gov/articleauthoring/2.3/articleauthoring.dtd','Authoring'),
          skin:grammarlist-known-dtd('Jats2.3-Book', 'http://dtd.nlm.nih.gov/book/2.3/book.dtd', 'Book')
          }    
          <br/>
          <span>Version 3.0</span>
          <br/>
          {
          skin:grammarlist-known-dtd('Jats3-Arch', 'http://dtd.nlm.nih.gov/archiving/3.0/archivearticle3.dtd', 'Archiving'),
          skin:grammarlist-known-dtd('Jats3-Publ', 'http://dtd.nlm.nih.gov/publishing/3.0/journalpublishing3.dtd', 'Publishing'),
          skin:grammarlist-known-dtd('Jats3-Auth', 'http://dtd.nlm.nih.gov/articleauthoring/3.0/articleauthoring3.dtd', 'Authoring'),
          skin:grammarlist-known-dtd('Jats3-Book', 'http://dtd.nlm.nih.gov/book/3.0/book3.dtd', 'Book')
          }                     
          </div>  
        </form> 
          *--> 
        
        
        <hr/>
      </div>
      <div class="todo"><b>To do:</b>
        provide larger list of well known DTDs;
        pre-load most of them
      </div>
      { skin:footer() }
    </body>
  </html>
 
};


declare function def:elements (
	$dtdkeys as xs:string*
	) as element() {
  <html>
    <head>
      { skin:default-metadata('Element list') }
    </head>
    <body>
      { skin:navbar($dtdkeys) }
      <div class="container" id="main">
        { skin:pagehead('Elements', $dtdkeys) }
        { skin:list-active-grammars($dtdkeys)
          (: , skin:select-active-dtds('elements') :)
        }     
        <p><a href="{skin:pageuri('elements', $dtdkeys)}">Grouped</a> 
           &#183; 
           <a href="{skin:pageuri('elements','grouping=alpha', $dtdkeys)}">Sorted</a>
        </p>
        { let $kw := $grouping 
          return if ($kw = 'alpha') then            
                    <ol>{
                      for $gi in 
                          rest:gilist-alpha($dtdkeys)
                      return <li>
                               { skin:pack-gi($gi/@gi/string(), $dtdkeys) }
                               <span class="dtdlist">({$gi/@defined-in/string()})</span>
                             </li>
                    }</ol>
         else let $venn := rest:gilist-venn($dtdkeys)
              for $subset in $venn
              return (<h3>Elements declared in
                          {for $dtdkey in tokenize($subset/@declared-in/string(),'\s+')
                           return (<span class="dtdkey">{$dtdkey}</span>), ' '}</h3>,
                      <p>{
                        for $gi in $subset/* 
                        return <span>
                               { skin:pack-gi($gi/@gi/string(), $dtdkeys) }
                               </span>
                      }</p>)
              
       }
      </div>
      <div class="todo"><b>To do:</b>
        list of elements referred to but not declared,
        list of elements declared but not referred to,
        links to displays of declarations,
        display of parents, ancestors, children, and descendants for a given element.
        Display alpha list as table to align the DTD identifiers.
      </div>


      
      { skin:footer() }
    </body>
  </html>
};

declare function def:attributes (
	$dtdkeys as xs:string*
) as element() {
  <html>
    <head>
      { skin:default-metadata('Attribute lists') }
    </head>
    <body>
      { skin:navbar($dtdkeys) }
      <div class="container" id="main">
        { skin:pagehead('Attributes', $dtdkeys) }
        { skin:list-active-grammars($dtdkeys) }
       <!--* Links to various attribute display options *-->
       <p><a href="{skin:pageuri('attributes', $dtdkeys)}">Grouped by DTD</a> 
           &#183; 
           <a href="{skin:pageuri('attributes','grouping=alpha', $dtdkeys)}">Sorted</a>
        </p>
        
        <!--* Display of current list *-->
        { let $kw := $grouping
          return if ($kw = 'alpha') then            
                    <ol>{
                      for $att in 
                          rest:attlist-alpha($dtdkeys)
                      return <li>
                               { (: <code class="attname">{$att/@name/string()}</code> :)
                                 skin:pack-attname($att/@name/string(), $dtdkeys) }
                               <span class="dtdlist">({$att/@defined-in/string()})</span>
                             </li>
                    }</ol>
         else let $venn := rest:attlist-venn($dtdkeys)
              for $subset in $venn
              return (<h3>Attributes declared in
                          {for $dtdkey in tokenize($subset/@declared-in/string(),'\s+')
                           return (<span class="dtdkey">{$dtdkey}</span>), ' '}</h3>,
                      <p>{
                        for $att in $subset/* 
                        return <span>
                               { (: <code class="attname">{$att/@name/string()}</code> :)
                                 skin:pack-attname($att/@name/string(), $dtdkeys) }
                               </span>
                      }</p>)
              
       }
       
      </div>
      <div class="todo"><b>To do:</b>
        group by DTD, 
        group by host element,
        group by declared type,
        links to displays of declarations.
      </div>
      { skin:footer() }
    </body>
  </html>
};

declare function def:notations (
 	$dtdkeys as xs:string*
) as element() {
  <html>
    <head>
      { skin:default-metadata('Notations list') }
    </head>
    <body>
      { skin:navbar($dtdkeys) }
      <div class="container" id="main">
        { skin:pagehead('Notations', $dtdkeys) }
        { skin:list-active-grammars($dtdkeys) }

       <!--* Links to various display options *-->        
        <!--* Display of current list *-->
        { let $kw := $grouping 
          return if ($kw = 'alpha') then            
                    <ol>{
                      for $name in 
                          rest:notnlist-alpha($dtdkeys)
                      return <li>
                               { (: <code class="notnname">{$name/@name/string()}</code> :)
                                 skin:pack-notnname($name/@name/string(), $dtdkeys) }
                               <span class="dtdlist">({$name/@defined-in/string()})</span>
                             </li>
                    }</ol>
         else let $venn := rest:notnlist-venn($dtdkeys)
              for $subset in $venn
              return (<h3>Notations declared in
                          {for $dtdkey in tokenize($subset/@declared-in/string(),'\s+')
                           return (<span class="dtdkey">{$dtdkey}</span>), ' '}</h3>,
                      <p>{
                        for $e in $subset/* 
                        return <span>
                               { (: <code class="notnname">{$name/@name/string()}</code> :)
                                 skin:pack-notnname($e/@name/string(), $dtdkeys) }
                               </span>
                      }</p>)
              
       }
      </div>
      <div class="todo"><b>To do:</b>
        list of declared notations,
        link to declarations
      </div>
      { skin:footer() }
    </body>
  </html>
};

declare function def:pes (
	$dtdkeys as xs:string*
) as element() {
  <html>
    <head>
      { skin:default-metadata('Parameter entities') }
    </head>
    <body>
      { skin:navbar($dtdkeys) }
      <div class="container" id="main">
        { skin:pagehead('Parameter entities', $dtdkeys) }
        { skin:list-active-grammars($dtdkeys) }
        
       <!--* Links to various display options *-->
       <!--*
       <p><a href="{skin:pageuri('elements', $dtdkeys)}">Grouped</a> 
           &#183; 
           <a href="{skin:pageuri('elements','grouping=alpha', $dtdkeys)}">Sorted</a>
        </p> *-->
        
        <!--* Display of current list *-->
        { let $kw := $grouping 
          return if ($kw = 'alpha') then            
                    <ol>{
                      for $pe in 
                          rest:pelist-alpha($dtdkeys)
                      return <li>
                               { (: <code class="pename">{$pe/@name/string()}</code> :)
                               skin:pack-pename($pe/@name/string(), $dtdkeys) }
                               <span class="dtdlist">({$pe/@defined-in/string()})</span>
                             </li>
                    }</ol>
         else let $venn := rest:pelist-venn($dtdkeys)
              for $subset in $venn
              return (<h3>Parameter entities declared in
                          {for $dtdkey in tokenize($subset/@declared-in/string(),'\s+')
                           return (<span class="dtdkey">{$dtdkey}</span>), ' '}</h3>,
                      <p>{
                        for $pe in $subset/* 
                        return <span>
                               { (: <code class="pename">{$pe/@name/string()}</code> :)
                               skin:pack-pename($pe/@name/string(), $dtdkeys) }
                               </span>
                      }</p>)
              
       }
      </div>
      <div class="todo"><b>To do:</b>
        links to displays of declarations;
        for a given P.E., list of other parameter entities referred to directly or indirectly;
        for given P.E., list of other parameter entities referring to the given PE.
      </div>
      { skin:footer() }
    </body>
  </html>
};

declare function def:decls (
  $construct as xs:string,
  $name as xs:string,
	$dtdkeys as xs:string*
) as element() {
  <html>
    <head>{ skin:default-metadata('Declarations') }</head>
    <body>
      { skin:navbar($dtdkeys) }
      <div class="container" id="main">
        { skin:pagehead(concat('Declarations for ', 
                               $construct,
                               ' ',
                               $name), 
                        $dtdkeys) }
        { skin:list-active-grammars($dtdkeys) }
        
        <!--* Display of declarations *-->
        { for $decl in rest:decls($construct, $name, $dtdkeys) 
          return skin:format-decl($decl)               
        }
      </div>
      <div class="todo"><b>To do:</b>
        links to displays of declarations;
        for a given P.E., list of other parameter entities referred to directly or indirectly;
        for given P.E., list of other parameter entities referring to the given PE.
      </div>
      { skin:footer() }
    </body>
  </html>
};


       if ($page eq 'home') then def:index($dtdkeys)
       else if ($page eq 'grammarlist') then def:grammarlist($dtdkeys)
       else if ($page eq 'elements') then def:elements($dtdkeys)
       else if ($page eq 'attributes') then def:attributes($dtdkeys)
       else if ($page eq 'notations') then def:notations($dtdkeys)
       else if ($page eq 'pes') then def:pes($dtdkeys)
       else if ($page eq 'decls') then def:decls($construct,$cname,$dtdkeys)
       else def:grammarlist($dtdkeys)
