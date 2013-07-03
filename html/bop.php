<?php
// bop.php:  BaseX over PHP.
// A PHP script that is intended to do nothing but
// serve as a simple proxy between the user and BaseX.

/* This program is set up to perform, on demand, a finite and
   extremely limited set of tasks, defined by verb, object, and
   qualifier.  It is NOT a general administrative interface, just a
   convenience for performing some standard tasks.

   Current verbs:  hello, make, query, drop

   N.B.The current design does NOT pass ANY input from the user direct
   into BaseX; conditionals test for expected values and take
   appropriate action.  This makes the program cumbersome to change.
   But if you ever want to change it, be sure you sanitize all input
   effectively against XQuery or PHP injection.  (The current design
   protects against injection by simply not having any action
   specified for unexpected input.)

*/

// 0 Set up
$errmsg = "";

// Customization / installation variables
//$MISCPATH = "/Users/cmsmcq/localhost/2013/06/hello-miscpath";
$MISCPATH = "/opt/igel/private/misc";
$PORT = "8984";
$XSL = "no"; /* set $XSL to "no" to see raw XML output, "yes" to format */

function escape_qstring($string) {

  //  $mb_array = array(0x80, 0xffff, 0, 0xffff,
  //		    0x22, 0x22, 0, 0xfff, // turn " to &#34;
  //		    0x26, 0x26, 0, 0xfff, // escape ampersand
  //		    0x27, 0x27, 0, 0xfff, // escape '
  //		    0x3C, 0x3C, 0, 0xfff, // escape < 
  //		    0x3E, 0x3E, 0, 0xfff, // escape >
  //		    );

    $string = str_replace("\\\"", "\"", $string);
    $string = str_replace("\\'", "'", $string);
    $string = str_replace("\\\\", "\\", $string);
    // $string = mb_encode_numericentity($string, $mb_array, 'UTF-8');
    $string = str_replace("&","&amp;", $string);
    $string = str_replace("<","&lt;", $string);
    $string = str_replace(">","&gt;", $string);
    $string = str_replace('"',"&amp;quot;", $string);
    $string = str_replace("'","&amp;apos;", $string);

    $string = str_replace("&#34;","&amp;quot;", $string);
    $string = str_replace("&#39;","&amp;apos;", $string);
    return $string;
};

function stringjoin_dtdkeys() {
  /* completely ad hoc function for passing $dtdkeys variable to XQuery */
  /*
  $val = "";
  foreach ($_GET['dtdkey'] as $d) {
    $val .= " " . $d;
  }
  $val = strip($val);
  */
  if (empty($_GET['dtdkey'])) {
    return '';
  } else {
    return escape_qstring(implode($_GET['dtdkey'],' '));
  };
    
};

// default values (just in case)
$responsetype = 'text/xml';
$go = 'no';

/* 1 Prepare the command to be issued. */

//////////////////////////////////////////////////////////////////
// 1a For 'page' requests ... 
//////////////////////////////////////////////////////////////////
if ($_GET['req'] == 'page') {
  $pageid = $_GET['page'];
  if ($pageid == 'home' 
      or $pageid == 'grammarlist' 
      or $pageid == 'elements' 
      or $pageid == 'attributes' 
      or $pageid == 'notations'
      or $pageid == 'pes'
      or $pageid == 'decls') { 
    if ($pageid == 'decls') {
      $declparms = ""
        . "     <variable name='construct' value='" 
	.            escape_qstring($_GET['construct']) 
        .            "'/>\n"
        . "     <variable name='cname' value='" 
	.            escape_qstring($_GET['cname']) 
        .            "'/>\n";
    } else {
      $declparms = '';
    }
    $req = "  <run xmlns='http://basex.org/rest'>\n"
      . "     <text>default.xq</text>\n"
      . "     <parameter name='wrap' value='no'/>\n"
      . "     <variable name='page' value='" . $pageid . "'/>\n"
      . "     <variable name='dtdkeystring' value='" . stringjoin_dtdkeys() . "'/>\n"
      . "     <variable name='grouping' value='" . escape_qstring($_GET['grouping']) . "'/>\n"
      . $declparms
      . "  </run>\n";
    $go = "yes";
    $responsetype = 'text/html';
  } else {
    $errmsg = "Unknown page " . $pageid . ", not implemented, sorry.";
  }
}

//////////////////////////////////////////////////////////////////
// 1b For 'make' requests ...
//////////////////////////////////////////////////////////////////
else if ($_GET['req'] == 'make') {
  if ($_GET['db'] == 'grammars') {
    $commandstring = "create db grammars";
  } else {
    $commandstring = "create db hello $MISCPATH/greetings.xml";
  }
  $req = "  <command xmlns='http://basex.org/rest'>\n"
    . "     <text>$commandstring</text>\n"
    . "     <parameter name='wrap' value='yes'/>\n"
    . "  </command>\n";
  $go = 'yes';
  $responsetype = 'text/xml';
} 

//////////////////////////////////////////////////////////////////
// 1c For 'add' requests ...
//////////////////////////////////////////////////////////////////
else if ($_GET['req'] == 'addcmd') {
  $dpp = "http://blackmesatech.com/lib/dpp.sh"
         . "?dtdloc="
         . $_GET['newloc'];
  $path = $_GET['newkey'] . '.xml';
  $commandstring = "execute \"open grammars; add to $path $dpp\"";
  $req = "  <command xmlns='http://basex.org/rest'>\n"
    . "     <text>$commandstring</text>\n"
    . "     <parameter name='wrap' value='yes'/>\n"
    . "  </command>\n";
  $go = 'yes';
  $responsetype = 'text/xml';
} 

else if ($_GET['req'] == 'addfun' or $_GET['req'] == 'add') {
  /* not working as of 5 pm 12 June */
  /* but working as of 3 July */
  $req = "  <run xmlns='http://basex.org/rest'>\n"
    . "     <text>updates.xq</text>\n"
    . "     <parameter name='wrap' value='yes'/>\n"
    . "     <variable name='req' value='add'/>\n"
    . "     <variable name='newkey' value='" . $_GET['newkey'] . "'/>\n"
    . "     <variable name='newloc' value='" . $_GET['newloc'] . "'/>\n"
    . "  </run>\n";
  $go = "yes";
  $responsetype = 'text/xml';
} 

else if ($_GET['req'] == 'addlocal') {
  $req = "  <run xmlns='http://basex.org/rest'>\n"
    . "     <text>updates.xq</text>\n"
    . "     <parameter name='wrap' value='yes'/>\n"
    . "     <variable name='req' value='addlocal'/>\n"
    . "     <variable name='newkey' value='" . $_GET['newkey'] . "'/>\n"
    . "     <variable name='newloc' value='" . $_GET['newloc'] . "'/>\n"
    . "  </run>\n";
  $go = "yes";
  $responsetype = 'text/xml';
} 

//////////////////////////////////////////////////////////////////
// 1c For 'drop' requests ...
//////////////////////////////////////////////////////////////////
else if ($_GET['req'] == 'drop') {
  if ($_GET['db'] == 'grammars') {
    $commandstring = "drop db grammars";
  } else {
    $commandstring = "drop db hello";
  }
  $req = "  <command xmlns='http://basex.org/rest'>\n"
    . "     <text>$commandstring</text>\n"
    . "     <parameter name='wrap' value='yes'/>\n"
    . "  </command>\n";
  $go = 'yes';
  $responsetype = 'text/xml';
} 

//////////////////////////////////////////////////////////////////
// 1d For 'query' requests ... 
//////////////////////////////////////////////////////////////////
else if ($_GET['req'] == 'query') {
  $req = "  <run xmlns='http://basex.org/rest'>\n"
    . "     <text>greetings.xq</text>\n"
    . "     <parameter name='wrap' value='yes'/>\n"
    . "     <variable name='languages' value='" . escape_qstring($_GET['langs']) . "'/>\n"
    . "  </run>\n";
    $go = "yes";
}

//////////////////////////////////////////////////////////////////
// 1e For 'hello' requests ... 
//////////////////////////////////////////////////////////////////
else if ($_GET['req'] == 'hello') {
  $req = "  <run xmlns='http://basex.org/rest'>\n"
    . "     <text>helloworld.xq</text>\n"
    . "     <parameter name='wrap' value='yes'/>\n"
    . "  </run>\n";
    $go = "yes";
}

else {
  $errmsg = "Unknown request verb, not implemented, sorry.";
}; 

/* 2 emit bits of HTTP header
*/

header('Content-type: ' . $responsetype);

/* 3 Report on parameters (this is for debugging while I'm
   developing the thing).
*/

if ($go == 'yes') {

  // Prepare a request ...
  $ch = curl_init("http://localhost:" . $PORT . "/rest");
  
  curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
  /* in v0.1, we don't have a userid set up ...
     curl_setopt($ch, CURLOPT_USERPWD, "admin:iaia2011");
  */
  curl_setopt($ch, CURLOPT_HEADER, TRUE);
  curl_setopt($ch, CURLOPT_POST, TRUE);
  curl_setopt($ch, CURLOPT_POSTFIELDS, $req);
  curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/xml'));
  
  if ($responsetype == 'text/html') {

    // Run the request and echo it to the user
    curl_exec($ch);
    
  } else { /* responsetype not text/html, so we know it's text/xml */

    if ($XSL == "yes" and $responsetype = 'text/xml') {
      echo "<?xml-stylesheet type='text/xsl' href='../hello/hello.xsl'?>\n";
    }
    echo "<test>\n";
    
    echo "<request-parameters>\n";
    foreach ($_GET as $key => $val) {
      echo "<param name='" . htmlentities($key) . "'"
	. " value='" . htmlentities($val) . "'/>\n";
    }
    echo "</request-parameters>\n";
    
    echo "<req>\n" . $req . "</req>\n";
    // Run the request and echo it to the user
    curl_exec($ch);

    echo "<curl_errno>" . curl_errno($ch) . "</curl_errno>\n";
    echo "<curl_error>" . curl_error($ch) . "</curl_error>\n";

    echo "<curl_info>\n";
    echo "<CURLINFO_HTTP_CODE>" . curl_getinfo($ch,CURLINFO_HTTP_CODE);
    echo "</CURLINFO_HTTP_CODE>\n";
    echo "<CURLINFO_CONTENT_TYPE>" . htmlentities(curl_getinfo($ch,CURLINFO_CONTENT_TYPE));
    echo "</CURLINFO_CONTENT_TYPE>\n";

    echo "</curl_info>\n";
    // Close down
    curl_close($ch);
    echo "</test>\n";
  } 
} else {
  /* $go not = 'yes' */

  echo "<msg>" . $errmsg . "</msg>\n";
}

?>
