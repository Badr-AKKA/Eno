<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:eno="http://xml.insee.fr/apps/eno" xmlns:enoxml="http://xml.insee.fr/apps/eno/xml"
    xmlns:enoxsl="http://xml.insee.fr/apps/eno/xsl" version="2.0">

    <!-- Importing the different resources -->
    <xsl:import href="../inputs/xml/source.xsl"/>
    <xsl:import href="../outputs/xsl/models.xsl"/>
    <xsl:import href="../lib.xsl"/>

    <xd:doc>
        <xd:desc>Transform xml generic document (see fods2xml.xsl) into xslt stylesheet.</xd:desc>
        <xd:p>Main principles of the transformation:
        <xd:ul>
            <xd:il>Based on formatDrivers : A high level driver, based on the format parameter value, drives which templates should apply</xd:il>
            <xd:il>Different implementations : based on a formatDriver, each driver implementation depends on which output is expected</xd:il>
            <xd:il>Expected specific xml input structure : The GenericElements of the input should have specific content (consistent whith the FormatDriver).</xd:il>
        </xd:ul>
        </xd:p>
        <xd:p>formatDriver and associated driver :
            <xd:ul>
                <xd:il>DriverFlow - Template: takes transformations/in2out/drivers.fods (after fods2xml) and expects Xpath and Driver columns.</xd:il>                
                <xd:il>InGetterImplementation - Implementation : takes inputs/in/templates.fods (after fods2xml) and expects Xpath and Match columns.</xd:il>
                <xd:il>OutGetterImplementation - TransitionFunction and NotSupportedFunction: takes transformations/in2out/functions.fods and expects Out_Function and InFunction or InExpression columns (no InFunction nor InExpresion drives to NotSupportedFunction)to  .</xd:il>
                <xd:il>InGetterLibrairy - SourceFunction: takes inputs/in/functions.fods and expects a Function column. </xd:il>
                <xd:il>TreeNavigation - GetChildren: takes transformations/in2out/tree-navigation.fods and expects a Parent column.</xd:il>
                <xd:il>Debug - TransitionFunction and NotSupportedFunction : same as OutGetterImplementation but generates a models-debug.xsl.</xd:il>
            </xd:ul>
        </xd:p>
        <xd:p>Architecture of the transformation:
        <xd:ul>
            <xd:il>xml2xsl:xsl: entry point, drivers flow implementation, outGetters implementation</xd:il>
            <xd:il>xml/source.xsl: inGetters implementation</xd:il>
            <xd:il>xsl/models.xsl: drivers implementation</xd:il>
        </xd:ul></xd:p>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Param driving the output format mode.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="format" select="'NoFormat'"/>
    <xd:doc>
        <xd:desc>
            <xd:p>Param needed for the debug format to retrieve namespaces for the models-debug generated.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="models-uri-for-debug-mode" select="''" as="xs:string"/>
    
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet is used to transform a generic xml structure into xsl
                stylesheet.</xd:p>
        </xd:desc>
    </xd:doc>

    <!-- The output file generated will be xml type -->
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <xsl:strip-space elements="*"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Starting the transformation from xml by the 'Root' element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:apply-templates select="Root" mode="source"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>The Root element first add a FormatDriver, then the 'Sheet' driver.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="Root" mode="source">
        <xsl:variable name="driver">
            <driver/>
        </xsl:variable>
        <xsl:variable name="driverFormatted" select="eno:append-empty-element($format,$driver)"/>
        <xsl:apply-templates select="eno:append-empty-element('Sheet',$driverFormatted)" mode="model">
            <xsl:with-param name="source-context" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>This specific template is used to generate xslt stylesheet for Eno :</xd:p>
            <xd:p>the presence of those two elements means that the input xml comes from a
                drivers.fods file.</xd:p>
            <xd:p>So it is linked to the 'DriverFlow' driver :</xd:p>
            <xd:p>it will connect an input Xpath to a output driver through a template.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template
        match="GenericElement[DefinedElement[@name='Xpath'] and DefinedElement[@name='Driver']]"
        mode="source">
        <xsl:param name="driver" tunnel="yes">
            <driver/>
        </xsl:param>
        <xsl:apply-templates select="eno:append-empty-element('Template',$driver)" mode="model">
            <xsl:with-param name="source-context" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>This specific template is used to generate xslt stylesheet for Eno :</xd:p>
            <xd:p>the presence of those two elements means that the input xml comes from a
                templates.fods file.</xd:p>
            <xd:p>So it is linked to the 'Implementation' driver :</xd:p>
            <xd:p>it will create a template for an input Xpath for a given input function
                mode.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template
        match="GenericElement[DefinedElement[@name='Xpath'] and DefinedElement[@name='Match']]"
        mode="source">
        <xsl:param name="driver" tunnel="yes">
            <driver/>
        </xsl:param>
        <xsl:apply-templates select="eno:append-empty-element('Implementation',$driver)"
            mode="model">
            <xsl:with-param name="source-context" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>This specific template is used to generate xslt stylesheet for Eno :</xd:p>
            <xd:p>the presence of those two elements means that the input xml comes from a
                functions.fods file (in transformations folder).</xd:p>
            <xd:p>So it is linked to the 'TransitionFunction' driver :</xd:p>
            <xd:p>it will generate an output function which will be linked to an unique input
                function.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template
        match="GenericElement[DefinedElement[@name='Out_Function'] and (DefinedElement[@name='In_Function']/text() or DefinedElement[@name='In_Expression']/text())]"
        mode="source">
        <xsl:param name="driver" tunnel="yes">
            <driver/>
        </xsl:param>
        <xsl:apply-templates select="eno:append-empty-element('TransitionFunction',$driver)"
            mode="model">
            <xsl:with-param name="source-context" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>This specific template is used to generate xslt stylesheet for Eno :</xd:p>
            <xd:p>the presence of those two elements means that the input xml comes from a
                functions.fods file (on transformation side).</xd:p>
            <xd:p>So it is linked to the 'TransitionFunction' driver :</xd:p>
            <xd:p>it will generate an output function which will return an empty text because it
                isn't linked to an input function.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template
        match="GenericElement[DefinedElement[@name='Out_Function'] and not(DefinedElement[@name='In_Function']/text() or DefinedElement[@name='In_Expression']/text())]"
        mode="source">
        <xsl:param name="driver" tunnel="yes">
            <driver/>
        </xsl:param>
        <xsl:message>
            <xsl:value-of
                select="concat('Not supported yet : ',DefinedElement[@name='Out_Function']/text())"
            />
        </xsl:message>
        <xsl:apply-templates select="eno:append-empty-element('NotSupportedFunction',$driver)"
            mode="model">
            <xsl:with-param name="source-context" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>This specific template is used to generate xslt stylesheet for Eno :</xd:p>
            <xd:p>the presence of this element means that the input xml comes from a functions.fods
                file (on input side).</xd:p>
            <xd:p>So it is linked to the 'SourceFunction' driver :</xd:p>
            <xd:p>it will create a function who calls a template on its context.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="GenericElement[DefinedElement[@name='Function']]" mode="source">
        <xsl:param name="driver" tunnel="yes">
            <driver/>
        </xsl:param>
        <xsl:apply-templates select="eno:append-empty-element('SourceFunction',$driver)"
            mode="model">
            <xsl:with-param name="source-context" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>This specific template is used to generate xslt stylesheet for Eno :</xd:p>
            <xd:p>the presence of this element means that the input xml comes from a
                tree-navigation.fods file (on input side).</xd:p>
            <xd:p>So it is linked to the 'GetChildren' driver :</xd:p>
            <xd:p>it creates a template who indicates which elements to parse after the
                'Parent'.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="GenericElement[DefinedElement[@name='Parent']]" mode="source">
        <xsl:param name="driver" tunnel="yes">
            <driver/>
        </xsl:param>
        <xsl:apply-templates select="eno:append-empty-element('GetChildren',$driver)" mode="model">
            <xsl:with-param name="source-context" select="." tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Linking output function enoxsl:get-documentation to input function
                enoxml:get-documentation.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="enoxsl:get-documentation">
        <xsl:param name="context" as="item()"/>
        <xsl:apply-templates select="$context" mode="enoxml:get-documentation"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Linking output function enoxsl:get-xpath to input function
                enoxml:get-xpath.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="enoxsl:get-xpath">
        <xsl:param name="context" as="item()"/>
        <xsl:apply-templates select="$context" mode="enoxml:get-xpath"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Linking output function enoxsl:get-xpath-mode to input function
                enoxml:get-xpath-mode.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="enoxsl:get-xpath-mode">
        <xsl:param name="context" as="item()"/>
        <xsl:apply-templates select="$context" mode="enoxml:get-xpath-mode"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Linking output function enoxsl:get-match to input function
                enoxml:get-match.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="enoxsl:get-match">
        <xsl:param name="context" as="item()"/>
        <xsl:apply-templates select="$context" mode="enoxml:get-match"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Linking output function enoxsl:get-match-mode to input function
                enoxml:get-match-mode.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="enoxsl:get-match-mode">
        <xsl:param name="context" as="item()"/>
        <xsl:apply-templates select="$context" mode="enoxml:get-match-mode"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Linking output function enoxsl:get-function to input function
                enoxml:get-function.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="enoxsl:get-function">
        <xsl:param name="context" as="item()"/>
        <xsl:apply-templates select="$context" mode="enoxml:get-function"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Linking output function enoxsl:get-output-function to input function
                enoxml:get-output-function.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="enoxsl:get-output-function">
        <xsl:param name="context" as="item()"/>
        <xsl:apply-templates select="$context" mode="enoxml:get-output-function"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Linking output function enoxsl:get-input-function to input function
                enoxml:get-input-function.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="enoxsl:get-input-function">
        <xsl:param name="context" as="item()"/>
        <xsl:apply-templates select="$context" mode="enoxml:get-input-function"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Linking output function enoxsl:get-input-function to input function
                enoxml:get-input-function.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="enoxsl:get-input-expression">
        <xsl:param name="context" as="item()"/>
        <xsl:apply-templates select="$context" mode="enoxml:get-input-expression"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Linking output function enoxsl:get-driver to input function
                enoxml:get-driver.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="enoxsl:get-driver">
        <xsl:param name="context" as="item()"/>
        <xsl:apply-templates select="$context" mode="enoxml:get-driver"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Linking output function enoxsl:get-parameters to input function
                enoxml:get-parameters.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="enoxsl:get-parameters" as="xs:string *">
        <xsl:param name="context" as="item()"/>
        <xsl:apply-templates select="$context" mode="enoxml:get-parameters"/>
    </xsl:function>
    
    <xsl:function name="enoxsl:get-default-value">
        <xsl:param name="parameter-name"/>      
        <xsl:choose>
            <xsl:when test="$parameter-name = 'language'">
                <xsl:value-of select="'''fr'''"/>
            </xsl:when>
            <xsl:when test="$parameter-name = 'index'">
                <xsl:sequence select="0"/>
            </xsl:when>
            <xsl:when test="$parameter-name = 'format'">
                <xsl:value-of select="'''#all'''"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Linking output function enoxsl:get-parent to input function
                enoxml:get-parent.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="enoxsl:get-parent">
        <xsl:param name="context" as="item()"/>
        <xsl:apply-templates select="$context" mode="enoxml:get-parent"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Linking output function enoxsl:get-as to input function
                enoxml:get-as.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="enoxsl:get-as">
        <xsl:param name="context" as="item()"/>
        <xsl:apply-templates select="$context" mode="enoxml:get-as"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Linking output function enoxsl:get-children to input function
                enoxml:get-get-children.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="enoxsl:get-children">
        <xsl:param name="context" as="item()"/>
        <xsl:apply-templates select="$context" mode="enoxml:get-children"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>
            <xd:p>Implementation of the enoxml:get-documentation function for the GenericElement element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="GenericElement" mode="enoxml:get-documentation">
        <xsl:value-of select="enoxml:get-value(./DefinedElement[@name='Documentation'])"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Implementation of the enoxml:get-xpath function for the GenericElement element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="GenericElement" mode="enoxml:get-xpath">
        <xsl:value-of select="enoxml:get-value(./DefinedElement[@name='Xpath'])"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Implementation of the enoxml:get-xpath-mode function for the GenericElement element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="GenericElement" mode="enoxml:get-xpath-mode">
        <xsl:value-of select="enoxml:get-value(./DefinedElement[@name='Xpath_Mode'])"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Implementation of the enoxml:get-match function for the GenericElement element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="GenericElement" mode="enoxml:get-match">
        <xsl:value-of select="enoxml:get-value(./DefinedElement[@name='Match'])"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Implementation of the enoxml:get-match-mode function for the GenericElement element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="GenericElement" mode="enoxml:get-match-mode">
        <xsl:value-of select="enoxml:get-value(./DefinedElement[@name='Match_Mode'])"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Implementation of the enoxml:get-function function for the GenericElement element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="GenericElement" mode="enoxml:get-function">
        <xsl:value-of select="enoxml:get-value(./DefinedElement[@name='Function'])"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Implementation of the enoxml:get-output-function function for the GenericElement element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="GenericElement" mode="enoxml:get-output-function">
        <xsl:value-of select="enoxml:get-value(./DefinedElement[@name='Out_Function'])"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Implementation of the enoxml:get-input-function function for the GenericElement element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="GenericElement" mode="enoxml:get-input-function">
        <xsl:value-of select="enoxml:get-value(./DefinedElement[@name='In_Function'])"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Implementation of the enoxml:get-input-expression function for the GenericElement element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="GenericElement" mode="enoxml:get-input-expression">
        <xsl:value-of select="enoxml:get-value(./DefinedElement[@name='In_Expression'])"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Implementation of the enoxml:get-driver function for the GenericElement element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="GenericElement" mode="enoxml:get-driver">
        <xsl:value-of select="enoxml:get-value(./DefinedElement[@name='Driver'])"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Implementation of the enoxml:get-parameters function for the GenericElement element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="GenericElement" mode="enoxml:get-parameters">
        <xsl:call-template name="split">
            <xsl:with-param name="chain"
                select="enoxml:get-value(./DefinedElement[@name='Parameters'])"/>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Implementation of the enoxml:get-parent function for the GenericElement element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="GenericElement" mode="enoxml:get-parent">
        <xsl:value-of select="enoxml:get-value(./DefinedElement[@name='Parent'])"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Implementation of the enoxml:get-as function for the GenericElement element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="GenericElement" mode="enoxml:get-as">
        <xsl:value-of select="enoxml:get-value(./DefinedElement[@name='As'])"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Implementation of the enoxml:get-children function for the GenericElement element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="GenericElement" mode="enoxml:get-children">
        <xsl:value-of select="enoxml:get-value(./DefinedElement[@name='Children'])"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>This template recursively splits a string chain on the "," character to build a set of strings.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="split">
        <xsl:param name="chain"/>
        <xsl:choose>
            <xsl:when test="contains($chain,',')">
                <xsl:value-of select="substring-before($chain,',')"/>
                <xsl:call-template name="split">
                    <xsl:with-param name="chain" select="substring-after($chain,',')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$chain"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
