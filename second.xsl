<x:transform xmlns:x="http://www.w3.org/1999/XSL/Transform" version="2.0"
             xmlns="http://www.w3.org/2000/svg"
             xmlns:fn="http://www.w3.org/2005/xpath-functions"
             xmlns:f="http://lapin-bleu.net/ns"
             xmlns:p="http://lapin-bleu.net/osm2svg/ns"
             xmlns:xs="http://www.w3.org/2001/XMLSchema"
             xmlns:xlink="http://www.w3.org/1999/xlink">

  <x:variable name="scaling-factor" select="100000"/>


  <x:variable name="minlat"
              select="number(if (/osm/bounds) then /osm/bounds/@minlat else fn:replace(/osm/bound/@box,'([\-0-9.]+),[\-0-9.]+,[\-0-9.]+,[\-0-9.]+', '$1'))"/>

  <x:variable name="minlon"
              select="number(if (/osm/bounds) then /osm/bounds/@minlon else fn:replace(/osm/bound/@box,'[\-0-9.]+,([\-0-9.]+),[\-0-9.]+,[\-0-9.]+', '$1'))"/>

  <x:variable name="maxlat"
              select="number(if (/osm/bounds) then /osm/bounds/@maxlat else fn:replace(/osm/bound/@box,'[\-0-9.]+,[\-0-9.]+,([\-0-9.]+),[\-0-9.]+', '$1'))"/>

  <x:variable name="maxlon"
              select="number(if (/osm/bounds) then /osm/bounds/@maxlon else fn:replace(/osm/bound/@box,'[\-0-9.]+,[\-0-9.]+,[\-0-9.]+,([\-0-9.]+)', '$1'))"/>

  <x:variable name="width" select="$scaling-factor * ($maxlon - $minlon)"/>
  <x:variable name="height" select="$scaling-factor * ($maxlat - $minlat)"/>

  <x:function name="f:x" as="xs:float">
    <x:param name="lon"/>
    <x:value-of select="$scaling-factor * ($lon - $minlon)"/>
  </x:function>

  <x:function name="f:y" as="xs:float">
    <x:param name="lat"/>
    <x:value-of select=" - $scaling-factor * ($lat - $maxlat)"/>
  </x:function>


  <x:variable name="viewBox" select="concat('0 0 ',$width,' ',$height)"/>
  <x:variable name="total-area" select="$width * $height"/>

  <x:output indent="yes"/>


  <x:template match="/">
    <x:apply-templates/>
    <x:comment> minlon: <x:value-of select="$minlon"/></x:comment>
    <x:comment> minlat: <x:value-of select="$minlat"/></x:comment>
    <x:comment> maxlon: <x:value-of select="$maxlon"/></x:comment>
    <x:comment> maxlat: <x:value-of select="$maxlat"/></x:comment>
  </x:template>

  <x:variable name="params" select="document('params.xml')/p:params"/>



  <x:template match="osm">
    <x:processing-instruction name="xml-stylesheet" select="' type=&quot;text/css&quot; href=&quot;style.css&quot;'"/>
    <svg version="1.1" viewBox="{$viewBox}" width="{$width}" height="{$height}" id="svgroot" preserveAspectRatio="none">
      <x:apply-templates select="relation"/>
      <x:apply-templates select="way[not(tag[@k='highway'])]"/>
      <x:apply-templates select="way[tag[@k='highway']]"><x:with-param name="mode" select="'fill'"/></x:apply-templates>
      <x:apply-templates select="node"/>
    </svg>
  </x:template>

  <!-- highways (roads, motorways, etc) -->
  <x:template match="way[tag[@k='highway']]">
    <x:param name="mode" select="'fill'"/>
    <x:variable name="type" select="tag[@k='highway']/@k"/>
    <x:variable name="subtype" select="tag[@k=$type]/@v"/>
    <x:variable name="points" select="for $node in node return concat(f:x($node/@lon),',', f:y($node/@lat),' ')"/>
    <polyline class="{$type} {$subtype}" points="{$points}"/>
  </x:template>

</x:transform>
