<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:hcmc="http://hcmc.uvic.ca/ns" xmlns:teix="http://www.tei-c.org/ns/Examples" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xs xd xhtml hcmc exist teix" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> February 21, 2013</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> mholmes</xd:p>
            <xd:p>This stylesheet renders the TEI output from 
              codesharing.xql into an XHTML5 page with a form. </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output encoding="UTF-8" method="xhtml" exclude-result-prefixes="#all" indent="no" doctype-system="about:legacy-compat" cdata-section-elements="script"/>
  
  
  <xsl:preserve-space elements="*"/>

<!-- All the parameters we need are included as data in the TEI input stream. -->
  
  
  <xsl:template match="/">
    <!--<xsl:text disable-output-escaping='yes'>
      <!DOCTYPE html>
    </xsl:text>-->
    <html>
      <head>
        <meta charset="UTF-8"/> 
        <title>
                    <xsl:value-of select="TEI/teiHeader/fileDesc/titleStmt/title[1]"/>
                </title>
        <script type="text/ecmascript">
            <xsl:comment>
            /* This function ensures that a return keypress in a textbox
               submits the form. */
               
            function submitOnReturn(e){
              if (e.keyCode == 13){
                return document.getElementById('codeSharingForm').submit();
              }
              else{
                return false;
              }
            }
            
            function changePage(sender){
              var startFrom = sender.options[sender.selectedIndex].value;
              var loc = document.location.toString();
              var matcher = /from=\d+(&amp;|$)/;
              if (loc.match(matcher)){
                document.location = loc.replace(matcher, 'from='+startFrom);
              }
              else{
                document.location = loc + '&amp;from=' + startFrom;
              }
            }
            </xsl:comment>
        </script>
        
        <style type="text/css">
          <xsl:comment>
            
            /* Main style settings. */
           html{
              height: 100%;
           }
           body{
              /* height: 100%; */
              background-color: #ffffff;
              background-image: linear-gradient(gray 0, white 100%);
              background-attachment: fixed;
              margin-left: 10%;
              margin-right: 10%;
              font-family: verdana, garamond, sans-serif;
           }
            
           div.bgImage{
              position: absolute;
              left: 0;
              top: 0;
              margin: 0.25em;;
              background-color: transparent;
              z-index: -3;
              border-style: none;
              width: 20em;
              height: 20em;
              opacity: 0.2;
           }
           h2, h3{
              text-align: center;
           }
           
           
            h4{
               background-color: #dddddd;
               border-color: #f0f0f0 #999999 #999999 #f0f0f0;
               border-style: solid;
               border-width: 2px;
               color: #000000;
               margin: 0;
               padding: 5px;
               text-align: left;
            }
           
           div {
              border-color: #000000;
              border-style: solid;
              border-width: 1px;
              margin-top: 2em;
              background-color: #ffffff;
           }
           
           div.results&gt;div{
              border-width: 0;
              clear: both;
           }
           
           div p{
             margin: 0.5em;
           }
           
           div.back{
              font-size: 75%;
              text-align: center;
              clear: both;
           }
           
           button, input, select{
              background-color: #d0d0d0;
           }
           
           label{
              display: inline-block;
              width: 10em;
           }
           
           span.hint{
             font-size: 80%;
             color: #a0a0a0;
           }
           
           button, input, select, label{
              margin-bottom: 0.25em;
              margin-top: 0.25em;
           }
           
           p.paginator{
              margin: 0.25em 0 0.25em auto;
              padding-right: 1%;
              text-align: right;
              width: 45%;
              float: right;
           }
           
           p.nextPrevButtons{
              margin: 0.25em auto 0.25em 0;
              padding-left: 1%;
              text-align: left;
              width: 45%;
              float: left;
           }
           
           input[type=text], select{
             min-width: 18em;
           }
            
           /* Handling of example XML code embedded in pages. */
           
           div.egXML{
            display: block;
            padding: 0.5em;
            border-width: 1px 0px 0px 0px;
            border-style: solid;
            margin-top: 0.25em;
            margin-bottom: 0.25em;
            overflow: auto;
           }
           
           div.sourceDocLink{
            text-align: right;
            font-size: 80%;
            color: #990000;
            border-style: none;
           }
           
           .xmlTag, .xmlAttName, .xmlAttVal, .egXML{
             font-family: monospace;
           }
           
           .xmlTag, .xmlAttName, .xmlAttVal{
             font-weight: bold;
           }
           
           .xmlTag{
             color: #000099;
           }
           
           .xmlAttName{
             color: #f5844c;
           }
           
           .xmlAttVal{
             color: #993300;
           }
           
           .xmlComment{
             color: #009900;
           }
           
         
          </xsl:comment>
        </style>
      </head>
      <body>
<!--
        <div class="bgImage">
          <svg xmlns:cc="http://creativecommons.org/ns#" xmlns="http://www.w3.org/2000/svg" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:svg="http://www.w3.org/2000/svg" xmlns:dc="http://purl.org/dc/elements/1.1/" version="1.0" width="100%" height="100%" viewBox="0 0 474.51702 474.35875" id="svg2696">
            <defs id="defs3041"/>
            <g transform="matrix(0.70710678,0.70710678,-0.70710678,0.70710678,289.06344,-237.08661)" id="layer1">
              <g transform="translate(-294.06,237.51)" id="g3597">
                <path d="m 589.19,323.15 c -0.18,-4.56 -1.96,-9.64 -3.34,-11.41 -1.53,-1.98 -2.51,-6.95 -2.51,-12.86 0,-5.3 -0.59,-9.64 -1.32,-9.64 -0.73,0 -17.41,5.23 -37.08,11.62 -19.66,6.38 -35.96,11.61 -36.22,11.61 -0.26,0 -0.47,-5.59 -0.47,-12.42 v -12.42 l 6.4,-4.17 c 3.52,-2.29 9.09,-6.03 12.37,-8.32 3.29,-2.29 8.66,-6.02 11.95,-8.29 3.29,-2.28 8.66,-6.01 11.95,-8.3 15.1,-10.51 18.32,-12.71 24.29,-16.59 6.01,-3.92 6.32,-4.53 5.49,-11.2 -5.34,-43.36 -11.49,-119.89 -12.25,-152.62 -0.51,-21.674 -1.43,-39.405 -2.04,-39.405 -0.62,0 -11.32,3.322 -23.77,7.381 -19.98,6.515 -174.09,89.344 -176.9,91.354 -2.82,2.01 -7.39,8.28 -10.17,13.92 l -5.04,10.26 -3.1,-5.88 c -1.71,-3.24 -3.48,-5.88 -3.93,-5.88 -1.49,0 -16.79,7.67 -30.92,15.51 -7.64,4.24 -14.75,7.71 -15.78,7.71 -1.25,0 -1.89,-5.37 -1.89,-15.84 0,-17.48 0.6,-18.6 15.36,-28.32 3.28,-2.16 8.66,-5.81 11.95,-8.09 3.28,-2.29 8.85,-6.04 12.37,-8.33 l 6.4,-4.16 0.02,-12.835 c 0.03,-14.755 1.18,-20.302 4.23,-20.302 1.18,0 2.65,-2.426 3.27,-5.392 0.87,-4.233 1.47,-4.857 2.74,-2.903 0.9,1.369 1.65,3.795 1.66,5.392 0.01,1.597 1.09,2.903 2.39,2.903 2.79,0 4.41,5.03 4.44,13.813 l 0.02,6.347 4.7,-3.533 c 5.66,-4.26 15.16,-10.993 23.46,-16.627 3.37,-2.281 32.64,-22.604 35.85,-24.885 3.2,-2.281 20.68,-14.309 23.89,-16.59 3.21,-2.281 17.89,-13.102 17.03,-17.419 -1.61,-8.1336 -3.01,-60.005 -1.79,-66.328 0.8,-4.152 2.03,-5.838 4.25,-5.838 2.16,0 3.47,-1.67 4.24,-5.392 0.88,-4.233 1.47,-4.857 2.75,-2.903 0.9,1.368 1.64,3.795 1.65,5.391 0.02,2.086 1.41,2.904 4.94,2.904 4.17,0 5.07,-0.811 6.02,-5.392 0.88,-4.233 1.47,-4.857 2.75,-2.903 0.9,1.368 1.64,3.795 1.66,5.391 0.01,1.729 1.32,2.904 3.24,2.904 4.53,0 5.27,4.205 5.29,30.479 l 0.03,23.013 3.84,-2.7084 c 2.11,-1.4897 6.52,-4.5642 9.81,-6.8326 3.28,-2.268 8.66,-5.995 11.95,-8.283 3.28,-2.288 32.74,-22.622 36.26,-24.912 l 6.4,-4.162 0.01,-30.256 c 0,-16.64 0.79,-38.471 1.77,-48.501 4.43,-45.65 16.4,-76.91 26.38,-68.86 12.92,10.43 21.34,56.7 21.34,117.36 v 30.257 l 6.4,4.162 c 3.52,2.29 32.98,22.624 36.27,24.912 3.28,2.288 8.66,6.015 11.94,8.283 3.29,2.2684 7.71,5.3429 9.82,6.8326 l 3.84,2.7085 0.02,-23.013 c 0.03,-26.274 0.76,-30.479 5.3,-30.479 1.91,0 3.22,-1.175 3.24,-2.904 0.01,-1.596 0.76,-4.023 1.65,-5.391 1.28,-1.954 1.87,-1.33 2.75,2.903 0.95,4.581 1.86,5.392 6.03,5.392 3.52,0 4.91,-0.818 4.93,-2.904 0.01,-1.596 0.76,-4.023 1.65,-5.391 1.28,-1.954 1.87,-1.33 2.75,2.903 0.77,3.722 2.09,5.392 4.24,5.392 2.22,0 3.45,1.686 4.25,5.838 1.22,6.323 -0.18,58.194 -1.79,66.328 -0.85,4.317 -0.17,5.527 5.11,9.124 3.35,2.281 68.3,47.489 71.66,49.77 8.3,5.634 17.81,12.367 23.47,16.627 l 4.69,3.533 0.02,-6.347 c 0.04,-8.783 1.65,-13.813 4.45,-13.813 1.29,0 2.37,-1.306 2.38,-2.903 0.02,-1.597 0.76,-4.023 1.66,-5.392 1.28,-1.954 1.87,-1.33 2.75,2.903 0.61,2.966 2.08,5.392 3.26,5.392 3.05,0 4.2,5.547 4.23,20.302 l 0.02,12.835 6.4,4.16 c 3.52,2.29 19.24,13.1 21.95,14.89 8.91,5.86 15.14,11.21 17.25,14.79 3.47,5.9 2.15,30.9 -1.62,30.9 -0.92,0 -7.92,-3.47 -15.57,-7.71 -14.13,-7.84 -29.43,-15.51 -30.92,-15.51 -0.45,0 -2.21,2.64 -3.92,5.88 l -3.11,5.88 -5.04,-10.26 c -2.77,-5.64 -7.35,-11.91 -10.16,-13.92 -2.82,-2.01 -156.93,-84.839 -176.91,-91.354 -12.45,-4.059 -23.14,-7.381 -23.76,-7.381 -0.62,0 -1.54,17.731 -2.04,39.401 -0.77,32.734 -6.91,109.26 -12.26,152.62 -0.82,6.67 -0.52,7.28 5.5,11.2 3.5,2.27 9.05,6.01 12.34,8.3 3.29,2.28 8.66,6.02 11.95,8.29 3.28,2.28 8.66,6.01 11.94,8.3 13.92,9.69 18.27,12.65 24.32,16.61 l 6.4,4.17 v 12.42 c 0,6.83 -0.21,12.42 -0.47,12.42 -0.26,0 -16.56,-5.23 -36.22,-11.61 -19.66,-6.39 -36.35,-11.62 -37.08,-11.62 -0.72,0 -1.32,4.34 -1.32,9.64 0,5.91 -0.97,10.88 -2.51,12.86 -1.38,1.77 -3.06,6.85 -3.24,11.41 l 0.09,8.4 -1.1,-8.3 c -1.07,-8.06 0.93,-1.46 -2.02,-2.49 l -0.92,5.81 -0.54,-5.81 c -2.13,0.85 -0.95,-3.86 -1.71,2.49 l -1.17,8.3 0.19,-8.4 z" id="path2709" style="fill:#010000;stroke:#000000"/>
                <path d="m 585.69,-166.43 v 0.03 0.02 0.02 c -0.04,0.01 -0.14,0.02 -0.18,0.04 -0.03,0.01 -0.08,0.05 -0.11,0.06 -0.08,0.03 -0.18,0.07 -0.24,0.1 -0.02,0.01 -0.09,0.06 -0.11,0.07 -0.07,0.05 -0.18,0.15 -0.24,0.2 -0.01,0.01 -0.04,0.05 -0.05,0.06 -0.01,0.01 -0.05,0.04 -0.06,0.05 -0.1,0.13 -0.23,0.33 -0.29,0.49 -0.01,0.04 -0.04,0.13 -0.06,0.17 v 0.04 c 0.01,0.04 0.01,0.13 0,0.16 0,0.04 -0.06,0.13 -0.07,0.17 v 0.02 0.02 0.02 0.04 c 0.01,0.04 0.07,0.13 0.07,0.17 0.05,0.28 0.17,0.58 0.35,0.8 0.01,0.01 0.05,0.06 0.06,0.07 0.06,0.06 0.16,0.14 0.24,0.2 0,0 -0.01,0.02 0,0.02 0.01,0.02 0.04,0.04 0.05,0.05 0.24,0.16 0.57,0.28 0.88,0.33 0.04,0 0.12,0.03 0.17,0.04 h 0.05 0.02 0.04 0.01 c 0.05,-0.01 0.13,-0.04 0.17,-0.04 0.04,0 0.14,-0.01 0.18,0 h 0.06 c 0.04,-0.01 0.12,-0.05 0.16,-0.07 0.17,-0.05 0.39,-0.16 0.53,-0.26 0.01,-0.01 0.05,-0.06 0.06,-0.07 0.01,-0.01 0.06,-0.03 0.07,-0.04 0.05,-0.04 0.13,-0.12 0.17,-0.16 0.01,-0.01 0.04,-0.06 0.05,-0.07 0.01,-0.01 0.05,-0.08 0.06,-0.1 0.04,-0.06 0.09,-0.13 0.13,-0.21 0.01,-0.02 0.04,-0.09 0.05,-0.12 0.01,-0.03 0.04,-0.1 0.06,-0.14 0.01,-0.05 0.04,-0.17 0.05,-0.23 v -0.21 -0.23 c -0.01,-0.09 -0.02,-0.21 -0.05,-0.31 -0.04,-0.1 -0.12,-0.24 -0.17,-0.33 0,0 -0.02,-0.01 -0.02,-0.02 -0.01,-0.03 -0.04,-0.06 -0.05,-0.08 -0.01,-0.02 -0.05,-0.11 -0.06,-0.12 l -0.05,-0.05 -0.06,-0.06 c -0.02,-0.02 -0.09,-0.08 -0.11,-0.1 -0.01,-0.01 -0.06,-0.05 -0.07,-0.06 -0.01,-0.01 -0.05,-0.04 -0.06,-0.04 -0.02,-0.01 -0.09,-0.06 -0.11,-0.07 -0.02,-0.01 -0.09,-0.04 -0.12,-0.06 -0.1,-0.04 -0.25,-0.11 -0.35,-0.14 -0.11,-0.03 -0.25,-0.05 -0.35,-0.07 h -0.24 c -0.05,0.01 -0.16,0 -0.22,0 -0.02,0 -0.1,0.01 -0.13,0 h -0.05 c -0.01,0 -0.03,0.01 -0.04,0 h -0.02 z m 16.83,0 v 0.03 0.02 0.02 c -0.04,0.01 -0.12,0.02 -0.17,0.04 -0.02,0.01 -0.09,0.05 -0.12,0.06 -0.08,0.03 -0.16,0.07 -0.22,0.1 -0.02,0.01 -0.11,0.06 -0.13,0.07 -0.07,0.05 -0.19,0.15 -0.24,0.2 l -0.06,0.06 -0.05,0.05 c -0.11,0.13 -0.23,0.33 -0.29,0.49 -0.02,0.04 -0.05,0.13 -0.06,0.17 v 0.04 0.16 c -0.01,0.04 -0.04,0.13 -0.05,0.17 v 0.02 0.02 0.02 0.04 c 0.01,0.04 0.04,0.13 0.05,0.17 0.05,0.28 0.17,0.58 0.35,0.8 0.01,0.01 0.04,0.06 0.05,0.07 0.06,0.06 0.17,0.14 0.24,0.2 l 0.04,0.04 c 0,0.01 0.02,0.02 0.02,0.03 0.24,0.16 0.57,0.28 0.88,0.33 0.03,0 0.14,0.03 0.18,0.04 h 0.04 0.02 0.05 c 0.04,-0.01 0.15,-0.04 0.18,-0.04 0.04,0 0.13,-0.01 0.17,0 h 0.05 c 0.05,-0.01 0.14,-0.05 0.19,-0.07 0.17,-0.05 0.39,-0.16 0.53,-0.26 0.01,-0.01 0.04,-0.06 0.05,-0.07 0.02,-0.01 0.05,-0.03 0.06,-0.04 0.04,-0.04 0.13,-0.12 0.16,-0.16 0.01,-0.01 0.07,-0.06 0.08,-0.07 0.01,-0.01 0.04,-0.08 0.05,-0.1 0.04,-0.06 0.08,-0.14 0.11,-0.21 0.02,-0.02 0.05,-0.09 0.06,-0.12 0.01,-0.04 0.06,-0.1 0.07,-0.14 0.01,-0.05 0.04,-0.17 0.06,-0.23 0,-0.06 -0.01,-0.16 0,-0.21 v -0.23 c -0.02,-0.09 -0.03,-0.21 -0.06,-0.31 -0.03,-0.1 -0.13,-0.24 -0.18,-0.33 -0.01,-0.01 -0.03,-0.06 -0.04,-0.08 0,0 -0.01,-0.02 -0.02,-0.02 -0.01,-0.02 -0.04,-0.11 -0.05,-0.12 -0.01,-0.01 -0.07,-0.04 -0.08,-0.05 -0.01,-0.01 -0.04,-0.05 -0.05,-0.06 -0.02,-0.02 -0.09,-0.08 -0.11,-0.1 -0.01,-0.01 -0.04,-0.05 -0.06,-0.06 -0.01,-0.01 -0.04,-0.04 -0.05,-0.04 -0.02,-0.01 -0.11,-0.06 -0.13,-0.07 -0.03,-0.01 -0.08,-0.04 -0.11,-0.06 -0.09,-0.04 -0.24,-0.11 -0.35,-0.14 -0.1,-0.03 -0.24,-0.05 -0.35,-0.07 H 603 c -0.06,0.01 -0.18,0 -0.24,0 -0.02,0 -0.09,0.01 -0.11,0 h -0.08 -0.01 -0.02 -0.02 z m -8.51,10.39 c -1.46,0.35 -2.23,2.12 -2.23,5.19 0,3.45 0.93,5.19 2.8,5.19 1.87,0 2.81,-1.74 2.81,-5.19 0,-3.46 -0.94,-5.19 -2.81,-5.19 -0.14,0 -0.3,-0.01 -0.42,0 -0.01,-0.01 -0.04,-0.01 -0.05,0 h -0.02 c 0,-0.01 -0.02,0 -0.02,0 0,0 -0.02,-0.01 -0.02,0 -0.01,0 -0.02,-0.01 -0.04,0 z m -4.82,6.53 v 0.06 0.04 0.02 0.02 0.03 c -0.28,0.77 -0.61,4.57 -0.75,10.15 l -0.35,14.27 h 6.49 6.55 l -0.35,-14.27 c -0.14,-5.58 -0.48,-9.38 -0.77,-10.15 v -0.03 -0.02 -0.02 -0.04 c 0,0 -0.04,-0.05 -0.06,-0.06 -0.01,0.01 -0.05,0.06 -0.05,0.06 v 0.04 c -0.05,0.12 -0.13,0.36 -0.18,0.71 -0.54,3.67 -1.72,4.75 -5.14,4.75 -3.41,0 -4.56,-1.08 -5.09,-4.75 -0.05,-0.33 -0.12,-0.59 -0.17,-0.71 v -0.04 c 0,0 -0.06,-0.05 -0.07,-0.06 h -0.06 z m -1.22,26.32 0.29,14.27 c 0.31,15.949 2.03,22.046 6.32,22.046 1.6,0 3.62,-1.747 4.49,-3.887 0.88,-2.14 1.72,-10.309 1.87,-18.159 l 0.3,-14.27 h -6.66 -6.61 z" id="path2715" style="fill:#747474;stroke:#58615f"/>
              </g>
            </g>
            <metadata id="metadata3039">
              <rdf:RDF>
                <cc:Work>
                  <dc:format>image/svg+xml</dc:format>
                  <dc:type rdf:resource="http://purl.org/dc/dcmitype/StillImage"/>
                  <cc:license rdf:resource="http://creativecommons.org/licenses/publicdomain/"/>
                  <dc:publisher>
                    <cc:Agent rdf:about="http://openclipart.org/">
                      <dc:title>Openclipart</dc:title>
                    </cc:Agent>
                  </dc:publisher>
                  <dc:title/>
                  <dc:date>2006-10-21T08:51:49</dc:date>
                  <dc:description>This clipart was converted with permission from the the collection at http://www.vectorsite.net/gfxaus1.html</dc:description>
                  <dc:source>https://openclipart.org/detail/810/boeing-b47e-by-theresaknott</dc:source>
                  <dc:creator>
                    <cc:Agent>
                      <dc:title>TheresaKnott</dc:title>
                    </cc:Agent>
                  </dc:creator>
                  <dc:subject>
                    <rdf:Bag>
                      <rdf:li>aircraft</rdf:li>
                      <rdf:li>airplane</rdf:li>
                      <rdf:li>boeing</rdf:li>
                      <rdf:li>plane</rdf:li>
                    </rdf:Bag>
                  </dc:subject>
                </cc:Work>
                <cc:License rdf:about="http://creativecommons.org/licenses/publicdomain/">
                  <cc:permits rdf:resource="http://creativecommons.org/ns#Reproduction"/>
                  <cc:permits rdf:resource="http://creativecommons.org/ns#Distribution"/>
                  <cc:permits rdf:resource="http://creativecommons.org/ns#DerivativeWorks"/>
                </cc:License>
              </rdf:RDF>
            </metadata>
          </svg>
        </div>
-->
        <xsl:apply-templates select="TEI/text/front"/> 
        <xsl:apply-templates select="TEI/text/body"/>
        <xsl:apply-templates select="TEI/text/back"/>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="front">
    <h2>
            <xsl:value-of select="descendant::*[@xml:id='cs_project']/text()"/>
        </h2>
    <h3>CodeSharing service</h3>
    
    <form id="codeSharingForm" accept-charset="UTF-8" action="{descendant::*[@xml:id='cs_url']/text()}" method="get" enctype="application/x-www-form-urlencoded">
      <div>
        <h4>Search for code samples</h4>
        <p>
                    <label for="verb">What do you want to do? (verb)</label> 
        <select id="verb" name="verb">
          <option value="getExamples">
            <xsl:if test="descendant::*[@xml:id='cs_verb']/text() = 'getExamples'">
              <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            get examples</option>
          <option value="listElements">
            <xsl:if test="descendant::*[@xml:id='cs_verb']/text() = 'listElements'">
              <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            list all elements</option>
          <option value="listAttributes">
            <xsl:if test="descendant::*[@xml:id='cs_verb']/text() = 'listAttributes'">
              <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            list all attributes</option>
          <option value="listDocumentTypes">
            <xsl:if test="descendant::*[@xml:id='cs_verb']/text() = 'listDocumentTypes'">
              <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            list all document types</option>
          <option value="listNamespaces">
            <xsl:if test="descendant::*[@xml:id='cs_verb']/text() = 'listNamespaces'">
              <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            list all namespaces</option>
        </select>
        </p>
        
        <p>
          <label for="elementName">Element name</label> <input type="text" id="elementName" name="elementName" onkeypress="submitOnReturn(event)">
            <xsl:attribute name="value" select="descendant::*[@xml:id='cs_elementName']/text()"/>
          </input>
                    <br/>
          <label for="wrapped">Wrap element in parent</label> <input value="true" type="checkbox" id="wrapped" name="wrapped" onkeypress="submitOnReturn(event)">
                        <xsl:if test="descendant::*[@xml:id='cs_wrapped']/text()='true'">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                        </xsl:if>
                    </input>
                    <br/>
          <label for="attributeName">Attribute name</label> <input type="text" id="attributeName" name="attributeName" onkeypress="submitOnReturn(event)">
            <xsl:attribute name="value" select="descendant::*[@xml:id='cs_attributeName']/text()"/>
          </input>
                    <br/>
          <label for="attributeValue">Attribute value</label> <input type="text" id="attributeValue" name="attributeValue" onkeypress="submitOnReturn(event)">
            <xsl:attribute name="value" select="descendant::*[@xml:id='cs_attributeValue']/text()"/>
          </input>
                    <br/>
          <label for="documentType">Document type</label> <input type="text" id="documentType" name="documentType" onkeypress="submitOnReturn(event)">
            <xsl:attribute name="value" select="descendant::*[@xml:id='cs_documentType']/text()"/>
          </input>
                    <br/>
          <label for="namespace">Namespace</label> <input type="text" id="namespace" name="namespace" onkeypress="submitOnReturn(event)">
            <xsl:attribute name="value" select="descendant::*[@xml:id='cs_namespace']/text()"/>
          </input>
                    <button onclick="document.getElementById('namespace').value = 'http://www.tei-c.org/ns/1.0'; return false;" title="Insert the TEI namespace.">← TEI</button>
                    <br/>
        </p>
        
        <p>
          <label for="maxItemsPerPage">Results per page</label>
          <select id="maxItemsPerPage" name="maxItemsPerPage">
            <xsl:variable name="currInstances" select="xs:integer(descendant::*[@xml:id='cs_maxItemsPerPage']/text())"/>
            <option value="1">
              <xsl:if test="$currInstances = 1">
                <xsl:attribute name="selected">selected</xsl:attribute>
              </xsl:if>
              1 (limit for huge elements)
            </option>
            <option value="3">
              <xsl:if test="$currInstances = 3">
                <xsl:attribute name="selected">selected</xsl:attribute>
              </xsl:if>
              3 (limit for large elements)
            </option>
            <xsl:variable name="lowInstances" select="xs:integer(descendant::*[@xml:id='cs_defaultMaxItemsPerPage']/text())"/>
            <xsl:variable name="highInstances" select="xs:integer(descendant::*[@xml:id='cs_absoluteMaxItemsPerPage']/text())"/>
            
            <xsl:for-each select="$lowInstances to $highInstances">
              <xsl:if test=". mod 10 = 0">
                <option value="{.}">
                  <xsl:if test=". = $currInstances">
                    <xsl:attribute name="selected">selected</xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="."/>
                                </option>
              </xsl:if>
            </xsl:for-each>
          </select>
        </p>
        
        <p>
                    <input type="submit" value="Submit"/>
                </p>
      </div>
    </form>
  </xsl:template>
  
  <xsl:template match="body">
    <xsl:variable name="maxItems" select="xs:integer(/TEI/text/front/descendant::*[@xml:id='cs_maxItemsPerPage']/text())"/>
    <xsl:variable name="from" select="xs:integer(/TEI/text/front/descendant::*[@xml:id='cs_from']/text())"/>
    <xsl:variable name="totalInstances" select="xs:integer(/TEI/text/front/descendant::*[@xml:id='cs_totalInstances']/text())"/>
    <xsl:variable name="prevLabel">
            <xsl:choose>
                <xsl:when test="$maxItems = 1">
                    <xsl:value-of select="$from - 1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$from - $maxItems"/> - <xsl:value-of select="$from - 1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
    <xsl:variable name="nextLabel">
            <xsl:choose>
                <xsl:when test="$maxItems = 1">
                    <xsl:value-of select="$from + 1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$from + $maxItems"/> - <xsl:value-of select="min(($from + (2 * $maxItems) - 1, $totalInstances))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
    
    <xsl:variable name="navButtons">
      <form onsubmit="return false();">
        <xsl:if test="string-length(/TEI/text/front/descendant::*[@xml:id='cs_nextUrl']/text()) gt 0 or string-length(/TEI/text/front/descendant::*[@xml:id='cs_prevUrl']/text()) gt 0">

          <p class="paginator">
            <select onchange="changePage(this)">
              <xsl:call-template name="hcmc:makeOptions">
                <xsl:with-param name="pageNum" select="1"/>
                <xsl:with-param name="startItemNum" select="1"/>
                <xsl:with-param name="pageBy" select="$maxItems"/>
                <xsl:with-param name="totalInstances" select="$totalInstances"/>
                <xsl:with-param name="currStartItemNum" select="$from"/>
              </xsl:call-template>
            </select>
          </p>
        
        </xsl:if>
        <p class="nextPrevButtons">
          <xsl:if test="string-length(/TEI/text/front/descendant::*[@xml:id='cs_prevUrl']/text()) gt 0">
            <button onclick="location='{/TEI/text/front/descendant::*[@xml:id='cs_prevUrl']/text()}'">Previous (<xsl:value-of select="$prevLabel"/>)</button>
          </xsl:if>
          <xsl:if test="string-length(/TEI/text/front/descendant::*[@xml:id='cs_nextUrl']/text()) gt 0">
            <button onclick="location='{/TEI/text/front/descendant::*[@xml:id='cs_nextUrl']/text()}'">Next (<xsl:value-of select="$nextLabel"/> of <xsl:value-of select="$totalInstances"/>)</button>
          </xsl:if>
        </p>
      </form>
    </xsl:variable>
    <xsl:if test="child::*">
      <div class="results">
        <h4>Results</h4>
      <xsl:copy-of select="$navButtons"/>
      <xsl:apply-templates/>
      <xsl:copy-of select="$navButtons"/>
      </div>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="hcmc:makeOptions" as="element()*">
    <xsl:param name="pageNum" select="1"/>
    <xsl:param name="startItemNum" select="1"/>
    <xsl:param name="pageBy" select="10"/>
    <xsl:param name="totalInstances" select="1"/>
    <xsl:param name="currStartItemNum" select="1"/>
    <xsl:if test="$startItemNum le $totalInstances">
      <option value="{$startItemNum}">
        <xsl:if test="$startItemNum = $currStartItemNum">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:text>Page </xsl:text>
                <xsl:value-of select="$pageNum"/>
        <xsl:text> (</xsl:text>
        <xsl:value-of select="$startItemNum"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="min((($startItemNum + $pageBy - 1), $totalInstances))"/>
        <xsl:text>)</xsl:text>
      </option>
      <xsl:call-template name="hcmc:makeOptions">
        <xsl:with-param name="pageNum" select="$pageNum + 1"/>
        <xsl:with-param name="startItemNum" select="$startItemNum + $pageBy"/>
        <xsl:with-param name="pageBy" select="$pageBy"/>
        <xsl:with-param name="totalInstances" select="$totalInstances"/>
        <xsl:with-param name="currStartItemNum" select="$currStartItemNum"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="list">
    <ul>
      <xsl:apply-templates/>
    </ul>
  </xsl:template>
  
  <xsl:template match="list/item">
    <li>
            <xsl:apply-templates/>
        </li>
  </xsl:template>
  
  <xsl:template match="ptr">
    <a href="{@target}">
            <xsl:value-of select="@target"/>
        </a>
  </xsl:template>

  <xsl:template match="div">
    <div>
            <xsl:apply-templates/>
        </div>
  </xsl:template>
  
  <xsl:template match="back/div">
    <div class="back">
            <xsl:apply-templates/>
        </div>
  </xsl:template>

  <xsl:template match="p">
    <p>
            <xsl:apply-templates/>
        </p>
  </xsl:template>
  
  <xsl:template match="ref">
    <a href="{@target}">
            <xsl:apply-templates/>
        </a>
  </xsl:template>
  
  <xsl:template match="name">
    <strong>
            <xsl:apply-templates/>
        </strong>
  </xsl:template>
  
<!-- This section covers handling of documentation elements such as tag and 
      attribute names, and example XML code. -->
  
<!-- Handling of inline code elements. -->
  <xsl:template match="code">
    <code>
      <xsl:apply-templates select="@* | * | text()"/>
    </code>
  </xsl:template>
  
<!-- <gi> elements specify tag names, and should be embellished with angle brackets. -->
  <xsl:template match="gi">
        <code class="xmlTag">&lt;<a>
    <xsl:attribute name="href">
      <xsl:value-of select="concat(//*[@xml:id='cs_url']/text(), '?verb=getExamples&amp;elementName=', .)"/>
    </xsl:attribute>
    <xsl:value-of select="."/>
            </a>&gt;</code>
    </xsl:template>
  
  <!-- <att> elements specify attribute names, and should be prefixed with @. -->
  <xsl:template match="att">
        <code class="xmlAttName">@<a>
    <xsl:attribute name="href">
      <xsl:value-of select="concat(//*[@xml:id='cs_url']/text(), '?verb=getExamples&amp;attributeName=', .)"/>
    </xsl:attribute>
    <xsl:value-of select="."/>
            </a>
        </code>
    </xsl:template>
  
  <!-- <val> elements specify attribute values, and should be quoted. -->
  <xsl:template match="val">
        <code class="xmlAttVal">"<xsl:value-of select="."/>"</code>
    </xsl:template>
  
<!-- Handling of <egXML> elements in the TEI example namespace. -->
  <xsl:template match="teix:egXML[not(ancestor::teix:egXML)]">
    <div class="egXML">
<!-- We need to add the initial space before the first element.     -->
<!-- Still unable to make this look right, whatever I do. Needs more work. 
      The initial space is always too big. -->
      <!--<xsl:if test="(child::* | child::text())[1][self::text()]">
       <xsl:value-of select="replace(replace(child::text()[1], '[ \t]', ' '), '[\r\n]', '')"/>
      </xsl:if>-->
      <xsl:if test="(child::* | child::text())[1][self::text()]">
        <xsl:variable name="lastTextSpace" select="tokenize(child::text()[last()], '[\r\n]')[last()]"/>
        <xsl:if test="matches($lastTextSpace, '^\s+$')">
                    <span class="space">
                        <xsl:value-of select="replace($lastTextSpace, '[ \t]', '&#160;')"/>
                    </span>
                </xsl:if>
      </xsl:if>
      <xsl:apply-templates/>
    <xsl:if test="@source">
      <div class="sourceDocLink">
      <a href="{@source}">
                        <xsl:value-of select="@source"/>
                    </a>
      </div>
    </xsl:if>
    </div>
  </xsl:template>
  
<!-- Escaping all tags and attributes within the teix (examples) namespace except for 
the containing egXML. -->
<!-- This is very messy because of the need to avoid extraneous spaces in the output. -->
  <xsl:template match="teix:*[not(local-name(.) = 'egXML')]|teix:egXML[ancestor::teix:egXML]"><!-- Opening tag, including any attributes. -->
        <span class="xmlTag">&lt;<xsl:value-of select="name()"/>
        </span>
        <xsl:for-each select="@*">
            <span class="xmlAttName">
                <xsl:text> </xsl:text>
                <xsl:value-of select="name()"/>=</span>
            <span class="xmlAttVal">"<xsl:value-of select="."/>"</span>
        </xsl:for-each>
        <xsl:choose>
            <xsl:when test="hcmc:isSelfClosing(local-name())">
                <span class="xmlTag">/&gt;</span>
            </xsl:when>
            <xsl:otherwise>
                <span class="xmlTag">&gt;</span>
                <xsl:apply-templates select="* | text() | comment()"/>
                <span class="xmlTag">&lt;/<xsl:value-of select="local-name()"/>&gt;</span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
  
  <xsl:template match="teix:*/text()[not(parent::teix:egXML)]">
    <span class="space">
            <xsl:analyze-string select="." regex="[\r\n]">
      <xsl:matching-substring>
                    <br/>
                </xsl:matching-substring>
      <xsl:non-matching-substring>
                    <xsl:value-of select="replace(., '[ \t]', '&#160;')"/>
                </xsl:non-matching-substring>
    </xsl:analyze-string>
        </span>
    </xsl:template>
  
<!-- We also need to process XML comments. -->
  <xsl:template match="teix:*/comment()">
    <span class="xmlComment">&lt;!-- <xsl:value-of select="."/> --&gt;</span>
        <xsl:text>
</xsl:text>
  </xsl:template>

<!-- This function identifies tags which are typically used in self-closing mode, so that 
  they can be rendered in the same way in the output. -->
  <xsl:function name="hcmc:isSelfClosing" as="xs:boolean">
    <xsl:param name="tagName"/>
    <xsl:value-of select="$tagName = ('lb', 'pb', 'cb')"/>
  </xsl:function>
    
    <!-- 
    This function takes a string as input, and replaces all single and double 
    quotes with their numeric escapes, so that the string is safe to use in 
    attribute values.
    
  -->
  <xsl:function name="hcmc:escape-quotes" as="xs:string">
    <!-- Incoming parameters -->
    <xsl:param name="inString" as="xs:string"/>
    <xsl:variable name="singlesDone" select="replace($inString, '''', '&amp;#x0027;')"/>
    <xsl:variable name="output" select="replace($singlesDone, '&#34;', '&amp;#x0022;')"/>
    <xsl:sequence select="$output"/>
  </xsl:function>
  
  <!-- 
    This function takes a string as input, and replaces all double 
    quotes with their backslash escapes, so that the string is safe to use in 
    attribute values.
    
  -->
  <xsl:function name="hcmc:backslash-double-quotes" as="xs:string">
    <!-- Incoming parameters -->
    <xsl:param name="inString" as="xs:string"/>
    <xsl:variable name="output" select="replace($inString, '&#34;', '\\&#34;')"/>
    <xsl:sequence select="$output"/>
  </xsl:function>

  
  
  
</xsl:stylesheet>