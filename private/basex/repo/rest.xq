(: rest:  simple request handling for Igel project. :)

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

module namespace rest = 'http://www.blackmesatech.com/2013/igel/lib/rest';

declare namespace db = "http://basex.org/modules/db";

import module namespace web = "http://expath.org/ns/http-client";

declare namespace igel = "http://www.blackmesatech.com/2013/igel";

declare variable $rest:grammars as xs:string := "grammars";
(: declare collection rest:grammars as node()*; :)

declare variable $rest:DPP as xs:string := "http://www.blackmesatech.com/lib/dpp.sh";
declare variable $rest:nsuri as xs:string := "http://www.blackmesatech.com/2013/igel/lib/rest";


(: get-did-in-xml:  accept DTD URI and key (short ID); return p element
   possibly followed by XML representation of DTD. :) 
declare function rest:get-dtd-in-xml(
  $dtdloc as xs:string, 
  $dtdkey as xs:string
) as element()* {
   
      (: check that arguments are OK :)
  let $already-here := collection($rest:grammars)/igel:dtd[@loc eq $dtdloc],
      $key-in-use := collection($rest:grammars)/igel:dtd[@key eq $dtdkey],
      
      (: prepare and (all being well) issue the GET request :)
      $request-uri := concat($rest:DPP,'?dtdloc=',$dtdloc),
      $request-parms := 
        <web:request method="GET"   
                     href="{$request-uri}" >
          <web:header name="Referer"
                      value="http://www.blackmesatech.com/2013/igel/"/>
        </web:request>,
      $response := if ($already-here) then 
          () 
        else
          web:send-request($request-parms, $request-uri, () ),
          
      (: analyse the response :)
      $status-code := $response[1]/@status,
      $status-msg := $response[1]/@message,
      $content-type := $response[1]//web:header[@name='Content-Type'],
      $dtdxml := $response[2]/*,
      $metadata := <igel:dtd loc="{$dtdloc}" 
                             uri="{base-uri($dtdxml)}"
                             key="{$dtdkey}"
                             dadd="{adjust-date-to-timezone(current-date(),())}" 
                             dtadd="{current-dateTime()}"/>,
      $bogon := <igel:dtd loc="{$dtdloc}" 
                             uri="{base-uri($dtdxml)}"
                             key="{$dtdkey}"
                             dadd="{adjust-date-to-timezone(current-date(),())}" 
                             dtadd="{current-dateTime()}">{
                   $response[2]
                }</igel:dtd>
  return (: if the DTD is already here, say so :)
          if ($already-here) then 
             <p class="error alreadyhere">{
               concat("The DTD ", $dtdloc, 
               ' is already part of the collection.')}</p>
         else if ($key-in-use) then 
             <p class="error keyinuse">{
               concat("The key ", $dtdkey, 
               ' is already in use in the database.  Choose another key!')}</p>
         else if ($status-code != 200) then 
              (: if the request was unsuccessful, return an error. :)
             <p class="error http">{
               concat('Error ', $status-code, ' "', $status-msg, 
               '" retrieving ', $dtdloc)}</p>
         else if ($response[2]/error) then 
             (: If the root element is error, return an error. :)
             <div class="error dpp">
               <p>{concat('DPP returned an error processing ', $dtdloc)}</p>
               {$response}
             </div> 
            (: If the result is not well formed (how do we tell?),
               return an error. :)
            (: Otherwise, all seems to be OK, so we will be able to
               add the DTD :)
            (: Note that this success message is really just a
               promissory note:  the actual add is done by the caller. :)
         else (<p class="ok">Inserted {$dtdloc} successfully ({
                  count($response[2]/descendant-or-self::node())
               } nodes).</p>, $bogon (:($dtdxml, $metadata) :) ) 
 
};

(: rest:add-dtd():  accept XML representation of DTD and status
   message.  If status is already bad, return error message;
   otherwise, add the document to the database and return an
   appropriate status message. :)
declare function rest:add-dtd-nogo($node as node()*, $msg as element()) {
  (: How many ways are there to get this wrong? :)
  (: 1 List expression: all expressionsmust be updating or return 
     an empty sequence. :)
  (:
  if (starts-with($msg/@class,'error')) then
     $msg
  else 
     (db:add($rest:grammars,$node), $msg)
  :)  
  (: "No database updates allowed within transform expression." :)
  (: 
  if (starts-with($msg/@class, 'error')) then
     $msg
  else
     copy $message := $msg
     modify (
       db:add($rest:grammars, $node)
     )
     return $message
  :)  
  (: Try expression: ... 
  if (starts-with($msg/@class,'error')) then
     $msg
  else 
     try { db:add($rest:grammars,$node) }
     catch * {
       <p>Error during update</p>
   }
  :)
  error(fn:QName($rest:nsuri,'rest:update-cannot-be-outwitted'))
};


(: rest:add-dtd():  accept XML representation of DTD and status
   message.  If status is already bad, raise error; otherwise, 
   add the document to the database. :)
(: The detour through the status messages is not a clean design
   choice:  it's a way to avoid rewriting even more of the 
   application. :)
declare updating function rest:add-dtd(
  $node as node()*, 
  $newkey as xs:string,
  $msg as element()
) {
  if ($msg/@class = "error alreadyhere") then 
    error(fn:QName($rest:nsuri,'rest:dtd-already-in-db'))
  else if ($msg/@class = "error keyinuse") then
    error(fn:QName($rest:nsuri,'rest:key-already-in-use'))
  else if ($msg/@class = "error http") then
    error(fn:QName($rest:nsuri,'rest:http-error-invoking-dpp'))
  else if ($msg/@class = "error dpp") then
    error(fn:QName($rest:nsuri,'rest:dpp-returned-error'))
  else if (empty($node)) then
    error(fn:QName($rest:nsuri,'rest:empty-grammar'))
  else db:add($rest:grammars,$node,concat($newkey,'.xml'))
};

(: rest:add():  given DTD location and key, add it to the db
   or else return an error message :)
declare updating function rest:add (
  $dtdloc as xs:string, 
  $dtdkey as xs:string
) {
  (: $dtdloc is the URI of a DTD.  We want to add it to the
     database. :)
     
  let $addenda := rest:get-dtd-in-xml($dtdloc, $dtdkey)
  (: $addenda now contains a status message and possibly
     the XML representation of a DTD :)
  return rest:add-dtd($addenda[position() > 1], $dtdkey, $addenda[1])
};

declare updating function rest:add-local(
  $filename as xs:string,
  $dtdkey as xs:string
) {
  (: $filename is the name of a DTD in XML form, in 
     /opt/igel/private/misc/dtdxml.  We want to add it
     to the database. :)
       
      (: check that arguments are OK :)
  if (collection($rest:grammars)/igel:dtd[@loc eq $filename]) then
      rest:add-dtd((),
                   $dtdkey,
                   <p class="error alreadyhere">{
                     concat("The DTD ", $filename, 
                     ' is already part of the collection.')}</p>)
  else if (collection($rest:grammars)/igel:dtd[@key eq $dtdkey]) then
      rest:add-dtd((), $dtdkey,
                   <p class="error keyinuse">{
                     concat("The key ", $dtdkey, 
                     ' is already in use in the database.  ',
                     'Choose another key!')}</p>
                 )
  else let $dtdxml := <igel:dtd loc="{$filename}" 
                             uri="{$filename}"
                             key="{$dtdkey}"
                             dadd="{adjust-date-to-timezone(current-date(),())}" 
                             dtadd="{current-dateTime()}">{
                               doc(concat(
                                    'file://',
                                    '/opt/igel/private/misc/dtdxml/',
                                    $filename))}</igel:dtd>
       return rest:add-dtd($dtdxml,
                           $dtdkey,
                           <p class="ok">Inserted 
                             {$filename} successfully 
                             ({ count($dtdxml/descendant-or-self::node())
                             } nodes).</p>) 
};

(:                            
declare function rest:clear() { 
  db:delete-nodes(db:collection($rest:grammars));
};
:)

declare function rest:gilist-alpha($dtdkeys as xs:string*) 
                                as element()* {

  let $dtds := collection($rest:grammars)/*[@key = $dtdkeys],
      $gis := distinct-values($dtds//element/elemtype/gi/string())
  for $gi in $gis
  let $decls := $dtds//element[elemtype/gi = $gi],
      $hosts := $decls/ancestor::igel:dtd/@key/string(),
      $n := count($decls),
      $n2 := count($hosts)      
  order by lower-case($gi)
  return <element gi="{$gi}" defined-in="{$hosts}"/>                           

};

declare function rest:gilist-venn($dtdkeys as xs:string*) 
                                as element()* { 
  let $gis := rest:gilist-alpha($dtdkeys),
      $locs := distinct-values($gis/@defined-in)
  for $loclist in $locs
  let $n := count(tokenize(normalize-space($loclist),'\s+'))
  order by $n descending, $loclist ascending
  return <gilist declared-in="{$loclist}" count="{$n}">{
    for $gi in $gis[@defined-in=$loclist]
    order by $gi/@gi
    return $gi
  }</gilist>
};

declare function rest:attlist-alpha($dtdkeys as xs:string*) 
                                as element()* {

  let $dtds := collection($rest:grammars)/*[@key = $dtdkeys],
      $ans := distinct-values($dtds//attlist/attdefs/attdef/name/string())
  for $an in $ans
  let $decls := $dtds//attlist/attdefs/attdef[name = $an],
      $hosts := for $h in distinct-values($decls/ancestor::igel:dtd/@key/string()) 
                order by $h
                return $h,
      $n := count($decls),
      $n2 := count($hosts)      
  order by lower-case($an)
  return <attribute name="{$an}" defined-in="{$hosts}">{
    for $gi in distinct-values($decls/../../elemtype/gi/string())
    let $angi-decls := $decls[../../elemtype/gi = $gi],
        $angi-hosts := $angi-decls/ancestor::igel:dtd/@key/string()
    order by lower-case($gi)
    return <host gi="{$gi}" defined-in="{$hosts}"/>
  }</attribute>                           

};

declare function rest:attlist-venn($dtdkeys as xs:string*) 
                                as element()* { 
  let $atts := rest:attlist-alpha($dtdkeys),
      $locs := distinct-values($atts/@defined-in)
  for $loclist in $locs
  let $n := count(tokenize(normalize-space($loclist),'\s+'))
  order by $n descending, $loclist ascending
  return <attlist declared-in="{$loclist}" count="{$n}">{
    for $att in $atts[@defined-in=$loclist]
    order by lower-case($att/@name)
    return $att
  }</attlist>
};



declare function rest:notnlist-alpha($dtdkeys as xs:string*) 
                                as element()* {

  let $dtds := collection($rest:grammars)/*[@key = $dtdkeys],
      $notns := distinct-values($dtds//notation/name/string())
  for $notn in $notns
  let $decls := $dtds//notation[name = $notn],
      $hosts := $decls/ancestor::igel:dtd/@key/string(),
      $n := count($decls),
      $n2 := count($hosts)      
  order by lower-case($notn)
  return <notation name="{$notn}" defined-in="{$hosts}"/>                           

};

declare function rest:notnlist-venn($dtdkeys as xs:string*) 
                                as element()* { 
  let $notns := rest:notnlist-alpha($dtdkeys),
      $locs := distinct-values($notns/@defined-in)
  for $loclist in $locs
  let $n := count(tokenize(normalize-space($loclist),'\s+'))
  order by $n descending, $loclist ascending
  return <notationlist declared-in="{$loclist}" count="{$n}">{
    for $notn in $notns[@defined-in=$loclist]
    order by lower-case($notn/@notn)
    return $notn
  }</notationlist>
};


declare function rest:pelist-alpha($dtdkeys as xs:string*) 
                                as element()* {

  let $dtds := collection($rest:grammars)/*[@key = $dtdkeys],
      $pes := distinct-values($dtds//entity[@type='PE']/entname/string())
  for $pe in $pes
  let $decls := $dtds//entity[@type='PE'][entname = $pe],
      $hosts := $decls/ancestor::igel:dtd/@key/string(),
      $n := count($decls),
      $n2 := count($hosts)      
  order by lower-case($pe)
  return <pe name="{$pe}" defined-in="{$hosts}"/>                           

};

declare function rest:pelist-venn($dtdkeys as xs:string*) 
                                as element()* { 
  let $pes := rest:pelist-alpha($dtdkeys),
      $locs := distinct-values($pes/@defined-in)
  for $loclist in $locs
  let $n := count(tokenize(normalize-space($loclist),'\s+'))
  order by $n descending, $loclist ascending
  return <pelist declared-in="{$loclist}" count="{$n}">{
    for $pe in $pes[@defined-in=$loclist]
    order by lower-case($pe/@name)
    return $pe
  }</pelist>
};

(:
rest:get-dtd-in-xml("http://blackmesatech.com/2012/10/leep/simpledoc.dtd","simpledoc")
rest:add("http://blackmesatech.com/2012/10/leep/simpledoc.dtd","simpledoc")

:)

declare function rest:decls (
  $construct as xs:string,
  $name as xs:string,
	$dtdkeys as xs:string*
) as element()* {       
  
  for $key in $dtdkeys
  let $dtd := collection($rest:grammars)/*[@key = $key]
  let $decls := 
      if ($construct = 'element') then 
         ($dtd//element[elemtype/gi = $name],
          $dtd//attlist[elemtype/gi = $name])
      else if ($construct = 'attribute') then
         $dtd//attdef[name = $name]
      else if ($construct = 'notation') then
         $dtd//notation[name = $name]
      else if ($construct = 'pe') then
         $dtd//entity[@type='PE'][entname = $name]
      else <nonesuch/>
  (: process decls further here if you need to :)
  return <decl construct="{$construct}"
               name="{$name}"
               dtd="{$key}">{ 
               if ($construct = 'attribute') then 
                  for $decl in $decls
                  order by $decl/../../elemtype/string()
                  return <attdef-wrapper>{
                    $decl/../../elemtype,
                    $decl
                  }</attdef-wrapper>
               else 
                  $decls 
             }</decl>
};