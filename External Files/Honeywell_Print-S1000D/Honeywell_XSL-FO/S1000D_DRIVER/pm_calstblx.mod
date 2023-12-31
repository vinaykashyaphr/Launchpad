<?xml version="1.0" encoding="utf-8"?>
<!-- ...................................................................... -->
<!-- file: calstblx.xsd

     **********************************************************************
     *                                                                    *
     *  This is a W3C XML Schema for the CALS Table Model.                *
     *  Created by Arbortext, 2004.                                       *
     *                                                                    *
     **********************************************************************

-->

<!-- 
     This DTD is based on the CALS Table Model
     PUBLIC "-//USA-DOD//DTD Table Model 951010//EN"
-->

<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">

<!-- ======================================================================= -->
<!--                                                                         -->
<!--    The following type, attributeGroup, and groups used in this module   -->
<!--    MUST BE DECLARED by any schema including this module.                -->
<!--                                                                         -->
<!-- ======================================================================= -->

<!--

  The "yesorno" type is used to type various attributes used in this
  table module.  Here is a sample declaration:

  <xsd:simpleType name='yesorno' type="xsd:NMTOKEN"/>

  The "bodyatt" attribute group should declare additional attributes
  that are to be declared on the table element.  Here is a simplified
  example declaration:

  <xsd:attributeGroup name="bodyatt">
    <xsd:attribute name="id" type="xsd:ID"/>
  </xsd:attributeGroup>

  The "secur" attribute group should declare additional attributes
  that are to be declared every element except the colspec and spanspec
  elements.  Here is a simplified example declaration:

  <xsd:attributeGroup name="secur">
    <xsd:attribute name="release" type="xsd:NMTOKENS"/>
  </xsd:attributeGroup>

  The "titles" group should declare a choice group of all the
  elements allowed as titles of tables.  Here is a simplified
  example declaration:

    <xsd:group name="titles">
      <xsd:choice>
        <xsd:element ref="title"/>
      </xsd:choice>
    </xsd:group>

  The "paracon" group should declare a choice group of all the
  elements allowed within the <entry> element (whose declaration
  in this file also allows mixed content).  Here is a simplified
  example declaration:

    <xsd:group name="paracon">
      <xsd:choice>
        <xsd:element ref="para"/>
      </xsd:choice>
    </xsd:group>

-->

<!-- ======================================================================= -->
<!--                 End of prerequiste declarations                         -->
<!-- ======================================================================= -->

<!-- The tbl.*.att attribute groups are mostly null here, but simplify
     the addition of attributes to the various table elements.      -->

<xsd:attributeGroup name='tbl.table.att'>
  <xsd:attribute name="pgwide" type="yesorno"/>
  <xsd:attribute name="tabstyle" type='xsd:string'/>
  <xsd:attribute name="tocentry" type="yesorno"/>
  <xsd:attribute name="shortentry" type="yesorno"/>
  <xsd:attribute name="orient">
    <xsd:simpleType>
      <xsd:restriction base='xsd:string'>
        <xsd:enumeration value='port'/>
        <xsd:enumeration value='land'/>
      </xsd:restriction>
    </xsd:simpleType>
  </xsd:attribute>
</xsd:attributeGroup>
<xsd:attributeGroup name='tbl.tgroup.att'>
  <xsd:attribute name="tgroupstyle" type='xsd:string'/>
</xsd:attributeGroup>
<xsd:attributeGroup name='tbl.colspec.att'/>
<xsd:attributeGroup name='tbl.spanspec.att'/>
<xsd:attributeGroup name='tbl.thead.att'/>
<xsd:attributeGroup name='tbl.tfoot.att'/>
<xsd:attributeGroup name='tbl.tbody.att'/>
<xsd:attributeGroup name='tbl.row.att'/>
<xsd:attributeGroup name='tbl.entrytbl.att'/>
<xsd:attributeGroup name='tbl.entry.att'/>

<!-- We define attribute groups for horizontal and vertical alignment -->

<xsd:attributeGroup name='tbl.align.attrib'>
  <xsd:attribute name="align">
    <xsd:simpleType>
      <xsd:restriction base='xsd:string'>
        <xsd:enumeration value='left'/>
        <xsd:enumeration value='right'/>
        <xsd:enumeration value='center'/>
        <xsd:enumeration value='justify'/>
        <xsd:enumeration value='char'/>
      </xsd:restriction>
    </xsd:simpleType>
  </xsd:attribute>
  <xsd:attribute name='char' type='xsd:string'/>
  <xsd:attribute name='charoff' type='xsd:NMTOKEN'/>
</xsd:attributeGroup>

<xsd:attributeGroup name='tbl.valign.attrib'>
  <xsd:attribute name="valign">
    <xsd:simpleType>
      <xsd:restriction base='xsd:string'>
        <xsd:enumeration value='top'/>
        <xsd:enumeration value='middle'/>
        <xsd:enumeration value='bottom'/>
      </xsd:restriction>
    </xsd:simpleType>
  </xsd:attribute>
</xsd:attributeGroup>


<!-- =====  Element and attribute declarations follow. =====  -->

   <xsd:group name="tbl.table-titles.mdl">
     <xsd:choice>
       <xsd:group ref="titles" minOccurs="0"/>
     </xsd:choice>
   </xsd:group>

<!-- ***** table element declaration ***** -->

<xsd:complexType name="table-element.type">
  <xsd:sequence>
    <xsd:group ref="tbl.table-titles.mdl"/>
    <xsd:element ref="tgroup" maxOccurs="unbounded"/>
  </xsd:sequence>
  <xsd:attribute name='frame'>
    <xsd:simpleType>
      <xsd:restriction base='xsd:string'>
        <xsd:enumeration value='top'/>
        <xsd:enumeration value='bottom'/>
        <xsd:enumeration value='topbot'/>
        <xsd:enumeration value='all'/>
        <xsd:enumeration value='sides'/>
        <xsd:enumeration value='none'/>
      </xsd:restriction>
    </xsd:simpleType>
  </xsd:attribute>
  <xsd:attribute name='colsep' type='yesorno'/>
  <xsd:attribute name='rowsep' type='yesorno'/>
  <xsd:attributeGroup ref='tbl.table.att'/>
  <xsd:attributeGroup ref='bodyatt'/>
  <xsd:attributeGroup ref='secur'/>
  <!-- RS 20140912: Added change attribute group from main S1000D schema (pm_cmb.xsd). Changes can also be applied to rows, -->
  <!-- but not sure if we're going to support that yet... leave for now. -->
  <xsd:attributeGroup ref="changeAttGroup"/>
  
</xsd:complexType>

<xsd:element name="table" type="table-element.type"/>

<!-- ***** tgroup element declaration ***** -->

<xsd:element name='tgroup'>
  <xsd:complexType>
    <xsd:sequence>
      <xsd:element ref='colspec' minOccurs='0' maxOccurs='unbounded'/>
      <xsd:element ref='spanspec' minOccurs='0' maxOccurs='unbounded'/>
      <xsd:element ref='thead' minOccurs='0' maxOccurs='1'/>
      <xsd:element ref='tfoot' minOccurs='0' maxOccurs='1'/>
      <xsd:element ref='tbody'/>
    </xsd:sequence>
    <xsd:attribute name='cols' type='xsd:integer' use='required'/>
    <xsd:attribute name='colsep' type='yesorno'/>
    <xsd:attribute name='rowsep' type='yesorno'/>
    <xsd:attributeGroup ref='tbl.align.attrib'/>
    <xsd:attributeGroup ref='tbl.tgroup.att'/>
    <xsd:attributeGroup ref='secur'/>
  </xsd:complexType>
</xsd:element>

<!-- ***** colspec element declaration ***** -->

<xsd:element name='colspec'>
  <xsd:complexType>
    <!-- EMPTY -->
    <xsd:attribute name='colnum' type='xsd:integer'/>
    <xsd:attribute name='colname' type='xsd:NMTOKEN'/>
    <xsd:attribute name='colwidth' type='xsd:string'/>
    <xsd:attribute name='colsep' type='yesorno'/>
    <xsd:attribute name='rowsep' type='yesorno'/>
    <xsd:attributeGroup ref='tbl.align.attrib'/>
    <xsd:attributeGroup ref='tbl.colspec.att'/>
  </xsd:complexType>
</xsd:element>

<!-- ***** spanspec element declaration ***** -->

<xsd:element name='spanspec'>
  <xsd:complexType>
    <!-- EMPTY -->
    <xsd:attribute name='namest' type='xsd:NMTOKEN' use="required"/>
    <xsd:attribute name='nameend' type='xsd:NMTOKEN' use="required"/>
    <xsd:attribute name='spanname' type='xsd:NMTOKEN' use="required"/>
    <xsd:attribute name='colsep' type='yesorno'/>
    <xsd:attribute name='rowsep' type='yesorno'/>
    <xsd:attributeGroup ref='tbl.align.attrib'/>
    <xsd:attributeGroup ref='tbl.spanspec.att'/>
  </xsd:complexType>
</xsd:element>

<!-- ***** thead element declaration ***** -->

<xsd:element name='thead'>
  <xsd:complexType>
    <xsd:sequence>
      <xsd:element ref='colspec' minOccurs='0' maxOccurs='unbounded'/>
      <xsd:element ref='row' minOccurs='1' maxOccurs='unbounded'/>
    </xsd:sequence>
    <xsd:attributeGroup ref='tbl.valign.attrib'/>
    <xsd:attributeGroup ref='tbl.thead.att'/>
    <xsd:attributeGroup ref='secur'/>
  </xsd:complexType>
</xsd:element>

<!-- ***** tfoot element declaration ***** -->

<xsd:element name='tfoot'>
  <xsd:complexType>
    <xsd:sequence>
      <xsd:element ref='colspec' minOccurs='0' maxOccurs='unbounded'/>
      <xsd:element ref='row' minOccurs='1' maxOccurs='unbounded'/>
    </xsd:sequence>
    <xsd:attributeGroup ref='tbl.valign.attrib'/>
    <xsd:attributeGroup ref='tbl.tfoot.att'/>
    <xsd:attributeGroup ref='secur'/>
  </xsd:complexType>
</xsd:element>

<!-- ***** tbody element declaration ***** -->

<xsd:element name='tbody'>
  <xsd:complexType>
    <xsd:choice>
      <xsd:element ref='row' minOccurs='1' maxOccurs='unbounded'/>
    </xsd:choice>
    <xsd:attributeGroup ref='tbl.valign.attrib'/>
    <xsd:attributeGroup ref='tbl.tbody.att'/>
    <xsd:attributeGroup ref='secur'/>
  </xsd:complexType>
</xsd:element>

<!-- ***** row element declaration ***** -->

<xsd:element name='row'>
  <xsd:complexType>
    <xsd:choice minOccurs='1' maxOccurs='unbounded'>
      <xsd:element ref='entry'/>
      <xsd:element ref='entrytbl'/>
    </xsd:choice>
    <xsd:attribute name='rowsep' type='yesorno'/>
    <xsd:attributeGroup ref='tbl.valign.attrib'/>
    <xsd:attributeGroup ref='tbl.row.att'/>
    <xsd:attributeGroup ref='secur'/>
  </xsd:complexType>
</xsd:element>

<!-- ***** entry element declaration ***** -->

<xsd:element name='entrytbl'>
  <xsd:complexType>
    <xsd:sequence>
      <xsd:element ref='colspec' minOccurs='0' maxOccurs='unbounded'/>
      <xsd:element ref='spanspec' minOccurs='0' maxOccurs='unbounded'/>
      <xsd:element ref='thead' minOccurs='0' maxOccurs='1'/>
      <xsd:element ref='tbody'/>
    </xsd:sequence>
    <xsd:attribute name='cols' type='xsd:integer' use='required'/>
    <xsd:attribute name='colname' type='xsd:NMTOKEN'/>
    <xsd:attribute name='namest' type='xsd:NMTOKEN'/>
    <xsd:attribute name='nameend' type='xsd:NMTOKEN'/>
    <xsd:attribute name='spanname' type='xsd:NMTOKEN'/>
    <xsd:attribute name='colsep' type='yesorno'/>
    <xsd:attribute name='rowsep' type='yesorno'/>
    <xsd:attributeGroup ref='tbl.align.attrib'/>
    <xsd:attributeGroup ref='tbl.entrytbl.att'/>
    <xsd:attributeGroup ref='secur'/>
  </xsd:complexType>
</xsd:element>

<!-- ***** entry element declaration ***** -->

<xsd:element name='entry'>
  <xsd:complexType mixed="true">
    <xsd:choice minOccurs="0" maxOccurs="unbounded">
      <xsd:group ref="paracon"/>
    </xsd:choice>
    <xsd:attribute name='colname' type='xsd:NMTOKEN'/>
    <xsd:attribute name='namest' type='xsd:NMTOKEN'/>
    <xsd:attribute name='nameend' type='xsd:NMTOKEN'/>
    <xsd:attribute name='spanname' type='xsd:NMTOKEN'/>
    <xsd:attribute name='morerows' type='xsd:integer'/>
    <xsd:attribute name='colsep' type='yesorno'/>
    <xsd:attribute name='rowsep' type='yesorno'/>
    <xsd:attributeGroup ref='tbl.align.attrib'/>
    <xsd:attributeGroup ref='tbl.valign.attrib'/>
    <xsd:attribute name='rotate' type='yesorno'/>
    <xsd:attributeGroup ref='tbl.entry.att'/>
    <xsd:attributeGroup ref='secur'/>
  </xsd:complexType>
</xsd:element>

<!-- end of calstblx.xsd -->
</xsd:schema>
