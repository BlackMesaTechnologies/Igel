<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:bmt="http://blackmesatech.com/2013/nss/model-comparisons"
  xmlns:xsdcr="http://www.w3.org/2000/10/XMLSchema" 
  xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
  version="1.0">
  <!--* declarations.xsl:  display content models and/or named model groups
      * in an HTML browser. 
      *-->

  <!--*

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

  *-->

  <xsl:output method="xml"/>

  <!--* default formatting *-->
  <xsl:template match="*">
    <div style="color:red"> </div>
  </xsl:template>

  <xsl:variable name="unstyled">color: red; margin-left:
    1em;</xsl:variable>
  <xsl:variable name="kw">color: gray; font-size: 80%;</xsl:variable>
  <xsl:variable name="elemname">color: green; font-size:
    150%;</xsl:variable>
  <xsl:variable name="pename">color: blue; font-size:
    150%;</xsl:variable>
  <xsl:variable name="literal">color: purple;</xsl:variable>
  <xsl:variable name="modelkw">color: brown;</xsl:variable>
  <xsl:variable name="elemref">color: navy;</xsl:variable>
  <xsl:variable name="namegrp-name">color: blue;</xsl:variable>
  <xsl:variable name="exceptions">color: red;</xsl:variable>
  <xsl:variable name="attname">color: #6DB;</xsl:variable>
  <xsl:variable name="atttype">color: brown;</xsl:variable>
  <xsl:variable name="atttypekw">color: brown;</xsl:variable>
  <xsl:variable name="attdft">color: orange;</xsl:variable>
  <xsl:variable name="attdftkw">color: brown;</xsl:variable>
  <xsl:variable name="attdftreq">color: #D00;</xsl:variable>
  <xsl:variable name="PEREF">color: #777; font-size:
    80%;</xsl:variable>
  <xsl:variable name="EE">color: #AAA; font-size: 70%;</xsl:variable>

  <xsl:variable name="rngref">color: #88D; font-size:
    80%;</xsl:variable>

  <xsl:variable name="model-group">display: block; margin-left:
    2em;</xsl:variable>
  <!--* 
  <xsl:variable name="model-group">display: inline;</xsl:variable>
  *-->

  <xsl:param name="show-pes" select="'yes'"/>
  <xsl:param name="block-display-groups" select="'no'"/>

  <xsl:template match="/" mode="full-doc">
    <html>
      <head>
        <title>Declarations for <xsl:value-of
            select="test/request-parameters/param[@name='gi']/@value"
        /><xsl:value-of select="bmt:declarations/@gi"
        /><xsl:value-of select="bmt:declarations/@nmg"/>
        </title>
      </head>
      <body>
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="*">
    <div style="{$unstyled}">
      <xsl:value-of select="concat(
	'&lt;', name()
	)"/>
      <xsl:apply-templates mode="lit" select="@*"/>
      <xsl:text>&gt;</xsl:text>
      <xsl:apply-templates/>
      <xsl:value-of select="concat(
	'&lt;/', name(), '>'
	)"/>
    </div>
  </xsl:template>

  <xsl:template match="@*" mode="lit">
    <xsl:value-of
      select="concat(
			  ' ', name(), ' = &quot;', ., '&quot;'
			  )"
    />
  </xsl:template>

  <xsl:template match="test" name="test">
    <div>
      <h1>Element declarations</h1>
      <h2>
        <xsl:value-of
          select="request-parameters/param[@name='gi']/@value"/>
      </h2>
      <hr/>
      <ul>
        <xsl:apply-templates mode="toc"/>
      </ul>
      <hr/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template
    match="p3[*] | p4[*] | p5[*] | ces[*] | xces[*] | idsxces[*]">
    <div id="{name()}">
      <h3>
        <xsl:value-of
          select="translate(name(),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"
        />
      </h3>
      <xsl:apply-templates/>
      <hr/>
    </div>
  </xsl:template>

  <xsl:template match="element">
    <div>
      <span style="{$kw}">&lt;!ELEMENT </span>
      <span style="{$elemname}">
        <xsl:value-of select="elemtype/gi"/>
      </span>
      <xsl:text>&#160;</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>></xsl:text>
    </div>
  </xsl:template>

  <xsl:template match="elemtype"/>

  <xsl:template match="omiss">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="element/EMPTY">
    <span style="{$modelkw}">
      <xsl:text>EMPTY</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="model | seq | or">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="modelgrp">
    <div style="{$model-group}">
      <xsl:text>(</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
      <xsl:call-template name="occsep"/>
    </div>
  </xsl:template>

  <xsl:template match="etoken">
    <span style="{$elemref}">
      <xsl:apply-templates/>
      <xsl:call-template name="occsep"/>
    </span>
  </xsl:template>

  <xsl:template match="PCDATA">
    <span style="{$modelkw}">
      <xsl:text>#PCDATA</xsl:text>
    </span>
    <xsl:call-template name="occsep"/>
  </xsl:template>

  <xsl:template match="exceptns">
    <span style="{$exceptions}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="exceptns/excl">
    <xsl:text> -(</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="exceptns/incl">
    <xsl:text> +(</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="excl/namegrp | incl/namegrp">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="namegrp/name">
    <span style="{$namegrp-name}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="attlist">
    <div style="margin-top: 0.5em;">
      <span style="{$kw}">&lt;!ATTLIST </span>
      <span style="{$elemname}">
        <xsl:value-of select="elemtype/gi"/>
      </span>
      <xsl:apply-templates/>
      <xsl:text>></xsl:text>
    </div>
  </xsl:template>

  <xsl:template match="attdefs">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="attdef-wrapper">
    <div class="attdef-wrapper">
      <span class="attdef-label">      
	<xsl:text>[On element </xsl:text>
	<xsl:value-of select="elemtype/gi"/>
	<xsl:text>] </xsl:text>
      </span>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="attdef">
    <div style="margin-left: 4em;">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="attdef-wrapper/attdef">
    <span class="attdef">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="attdef/name">
    <span style="{$attname}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="dvalue[dvkeywd]">
    <span style="{$atttypekw}">
      <xsl:value-of select="dvkeywd/@type"/>
    </span>
  </xsl:template>

  <xsl:template match="dvalue[ntgrp]">
    <span style="{$atttype}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="dvalue/ntgrp">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="ntoken">
    <xsl:apply-templates/>
    <xsl:call-template name="occsep"/>
  </xsl:template>

  <xsl:template match="default[IMPLIED]">
    <span style="{$attdftkw}">#IMPLIED</span>
  </xsl:template>

  <xsl:template match="default[REQUIRED]">
    <span style="{$attdftreq}">#REQUIRED</span>
  </xsl:template>

  <xsl:template match="default[avspec]">
    <span style="{$attdft}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="default/avspec">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="PEREF">
    <xsl:if test="$block-display-groups='yes'">
      <br/>
    </xsl:if>
    <xsl:if test="$show-pes = 'yes'">
      <xsl:if
        test="ancestor::model and following-sibling::* and not(following-sibling::*[1][self::PEREF or self::EE])">
        <br/>
      </xsl:if>
      <span style="{$PEREF}">
        <xsl:value-of select="concat('%', @entname, '{{')"/>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="EE">
    <xsl:if test="$show-pes = 'yes'">
      <span style="{$EE}">
        <xsl:value-of select="concat('}}', @entname, ';')"/>
      </span>
    </xsl:if>
    <xsl:if test="$block-display-groups='yes'">
      <br/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="PEREF[starts-with(@entname,'n.')]"/>
  <xsl:template match="PEREF[starts-with(@entname,'om.')]"/>

  <xsl:template match="EE[starts-with(@entname,'n.')]"/>
  <xsl:template match="EE[starts-with(@entname,'om.')]"/>

  <xsl:template name="occsep">

    <xsl:choose>
      <xsl:when test="self::PCDATA"/>
      <xsl:when test="self::ntoken"/>
      <xsl:when test="@occ='NIL'"/>
      <xsl:when
        test="@occ='REP' or (@minOccurs='0' and @maxOccurs='unbounded')">
        <xsl:text>*</xsl:text>
      </xsl:when>
      <xsl:when
        test="@occ='PLUS' or ((@minOccurs='1' or not(@minOccurs)) and @maxOccurs='unbounded')">
        <xsl:text>+</xsl:text>
      </xsl:when>
      <xsl:when
        test="@occ='OPT' or (@minOccurs='0' and (@maxOccurs='1' or not(@maxOccurs)))">
        <xsl:text>?</xsl:text>
      </xsl:when>
      <xsl:when test="@occ"> [<xsl:value-of select="@occ"/>] </xsl:when>
      <xsl:when test="@minOccurs = '1'  and @maxOccurs = '1'"> </xsl:when>
      <xsl:when test="@minOccurs or @maxOccurs">
        <xsl:value-of
          select="concat('{', @minOccurs, ',', @maxOccurs, '}')"/>
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when
        test="parent::seq and following-sibling::*[self::modelgrp or self::etoken or self::PCDATA]">
        <xsl:text>, </xsl:text>
      </xsl:when>
      <xsl:when
        test="parent::namegrp[@conn='SEQ'] and following-sibling::name">
        <xsl:text>, </xsl:text>
      </xsl:when>
      <xsl:when
        test="parent::ntgrp[@conn='SEQ'] and following-sibling::ntoken">
        <xsl:text>, </xsl:text>
      </xsl:when>
      <xsl:when
        test="parent::or and following-sibling::*[self::modelgrp or self::etoken or self::PCDATA]">
        <xsl:text> | </xsl:text>
      </xsl:when>
      <xsl:when
        test="parent::namegrp[@conn='OR'] and following-sibling::name">
        <xsl:text> | </xsl:text>
      </xsl:when>
      <xsl:when
        test="parent::ntgrp[@conn='OR'] and following-sibling::ntoken">
        <xsl:text> | </xsl:text>
      </xsl:when>
      <xsl:when test="(parent::xsdcr:sequence or parent::xsd:sequence) and following-sibling::*">
        <xsl:text>, </xsl:text>
      </xsl:when>
      <xsl:when test="(parent::xsdcr:choice or parent::xsd:choice) and following-sibling::*">
        <xsl:text> | </xsl:text>
      </xsl:when>
      <xsl:otherwise> </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="entity[@type='PE']">
    <div>
      <span style="{$kw}">&lt;!ENTITY % </span>
      <span style="{$pename}">
        <xsl:value-of select="entname"/>
      </span>
      <xsl:apply-templates/>
      <xsl:text>></xsl:text>
    </div>

  </xsl:template>

  <xsl:template match="entity[@type='PE']/entname"/>

  <xsl:template match="entity[@type='PE']/literal">
    <div style="{$literal}">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="bmt:declaration">
    <xsl:choose>
      <xsl:when test="*">
        <div>
          <h3>Declaration in <xsl:value-of select="@label"/></h3>
          <xsl:apply-templates/>
          <hr/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div style="color: #888;">
          <p>No declaration in <xsl:value-of select="@label"/></p>
          <hr/>
        </div>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>
  
  <xsl:template match="bmt:ditto">
    <div class="ditto" style="color:  green;">
      <p><span style="font-size: 120%;"><xsl:value-of select="@label"/></span> 
      <br/>
      has same declaration as 
      <xsl:value-of select="@twin"/></p>
      <hr/>
    </div>
  </xsl:template>

  <xsl:template match="bmt:element-report">
    <div id="{name()}">
      <h3>Summary report on instances for <xsl:value-of select="@gi"
        /></h3>
      <xsl:apply-templates/>
      <hr/>
    </div>
  </xsl:template>

  <xsl:template match="bmt:instantiation-report">
    <div id="{name()}">
      <p>Occurrences: <xsl:value-of select="@count"/></p>
      <xsl:apply-templates/>
      <hr/>
    </div>
  </xsl:template>

  <xsl:template match="bmt:instantiation-report/attributes[not(*)]">
    <p>No attributes.</p>
  </xsl:template>

  <xsl:template match="bmt:instantiation-report/attributes[(*)]">
    <ul>
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <xsl:template match="bmt:instantiation-report/attributes/att">
    <li>
      <xsl:value-of select="concat(@name, ' (', @count, ')')"/>
    </li>
  </xsl:template>

  <xsl:template match="bmt:instantiation-report/child-sequences[(*)]">
    <p>Children:</p>
    <ul>
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <xsl:template match="bmt:instantiation-report/child-sequences/seq">
    <li>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <xsl:template match="/bmt:declarations">
    <html>
      <head>
        <title>Comparison of <xsl:value-of select="concat(@gi,@nmg)"
          /></title>
        <body>
          <h1>Comparison of <xsl:value-of select="concat(@gi,@nmg)"
            /></h1>
          <hr/>
          <div>
            <xsl:apply-templates/>
          </div>
        </body>
      </head>
    </html>
  </xsl:template>

  <xsl:template match="xsdcr:group[@name] | xsd:group[@name]">
    <div>
      <span style="{$kw}">&lt;xsdcr:group name="</span>
      <span style="{$pename}">
        <xsl:value-of select="@name"/>
      </span>
      <span style="{$kw}">"></span>
      <xsl:apply-templates/>
      <span style="{$kw}">&lt;/xsdcr:group></span>
    </div>
  </xsl:template>
  
  <xsl:template match="xsdcr:group[@ref] | xsd:group[@ref]">
    <xsl:variable name="grpname" select="string(@ref)"/>
    <xsl:if test="$show-pes = 'yes'">
      <span style="{$PEREF}">
        <xsl:value-of select="concat('%', @ref, ';')"/>
      </span>
    </xsl:if>
    <xsl:if test="$show-pes = 'yes'">
      <span>
        <xsl:call-template name="occsep"/>
      </span>
    </xsl:if>
    
  </xsl:template>

  <xsl:template match="xsdcr:group[@ref] | xsd:group[@ref]" mode="v1">
    <xsl:variable name="grpname" select="string(@ref)"/>
    <xsl:if test="$show-pes = 'yes'">
      <span style="{$PEREF}">
        <xsl:value-of select="concat('%', @ref, '{{')"/>
      </span>
    </xsl:if>
    <xsl:apply-templates
      select="//xsdcr:group[@name=$grpname]/*
      | //xsd:group[@name=$grpname]/*"/>
    <xsl:if test="$show-pes = 'yes'">
      <span style="{$PEREF}">
        <xsl:value-of select="concat('}}', @ref, ';')"/>
      </span>
      <span>
        <xsl:call-template name="occsep"/>
      </span>
    </xsl:if>

  </xsl:template>

  <xsl:template match="xsdcr:sequence | xsdcr:choice | xsd:sequence | xsd:choice">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>)</xsl:text>
    <xsl:call-template name="occsep"/>
  </xsl:template>

  <xsl:template match="xsdcr:element | xsd:element">
    <span style="{$elemref}">
      <xsl:value-of select="concat(@name, @ref)"/>
    </span>
    <xsl:apply-templates/>
    <xsl:call-template name="occsep"/>
  </xsl:template>

  <xsl:template match="decl">
    <div class="decl">
      <h3><xsl:value-of select="@dtd"/></h3>
      <xsl:apply-templates/>
      <hr/>
    </div>
  </xsl:template>

</xsl:stylesheet>